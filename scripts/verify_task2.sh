#!/usr/bin/env bash
set -euo pipefail

task_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$task_root"

python3 scripts/analyze_task2.py >/dev/null

python3 - <<'PY'
import csv
import json
from pathlib import Path

root = Path.cwd()
metrics = json.loads((root / "analysis/task2_metrics.json").read_text())
expected = {
    "Load": (1902, 0, 5, 6, 474),
    "Stress": (6489, 0, 5, 6, 1606),
    "Spike": (3208, 0, 5, 6, 788),
    "Soak": (49200, 0, 4, 6, 12300),
}
for scenario, values in expected.items():
    overall = metrics[scenario]["overall"]
    actual = (
        overall["samples"],
        overall["failures"],
        int(overall["p95_ms"]),
        int(overall["p99_ms"]),
        overall["completed_workflows"],
    )
    assert actual == values, (scenario, actual, values)
    jtl_path = root / metrics[scenario]["source_jtl"]
    with jtl_path.open(newline="", encoding="utf-8") as stream:
        rows = list(csv.DictReader(stream))
    final_successes = sum(
        row["label"] == "FR06 View imported product detail" and row["success"].lower() == "true"
        for row in rows
    )
    assert final_successes == overall["completed_workflows"], scenario

stress_24 = metrics["Stress"]["stages"]["Stress stage 3 - 24 VUs"]
spike_burst = metrics["Spike"]["stages"]["Spike burst - 30 VUs"]
assert round(stress_24["sample_rate_s"], 2) == 62.08
assert round(spike_burst["sample_rate_s"], 2) == 83.04

soak_resources = metrics["Soak"]["resources"]
assert round(soak_resources["rss_peak_mb"], 2) == 138.95
assert round(soak_resources["rss_final_mb"], 2) == 69.39

critique = (root / "AI_Critique.md").read_text(encoding="utf-8").split("\n\n")[1]
assert 200 <= len(critique.split()) <= 300

review = (root / "task2_analysis_review.md").read_text(encoding="utf-8")
assert review.count("| \u201c") == 8, "Expected eight first-pass correction rows"
assert review.count("**Feasible") == 3, "Expected three feasible classifications"
assert review.count("**Hallucinated") == 4, "Expected four hallucinated classifications"
assert "**Unsupported for this workload**" in review

main_report = (root / "main_report.md").read_text(encoding="utf-8")
task2_review = main_report.split("## 9. Task 2", 1)[1].split("## 10.", 1)[0]
task2_optimizations = main_report.split("## 11. Task 2", 1)[1].split("## 12.", 1)[0]
assert task2_review.count("| \u201c") == 8, "Main report must contain all eight Task 2 corrections"
assert task2_optimizations.count("**Feasible") == 3, "Main report must contain three feasible classifications"
assert task2_optimizations.count("**Hallucinated") == 4, "Main report must contain four hallucinated classifications"
assert "**Unsupported for this workload**" in task2_optimizations
print("Task 2 raw metrics, integrated review, recommendation judgments, and critique length verified.")
PY

if [[ "${HW05_VERIFY_PDFS:-0}" == "1" ]]; then
  for pdf in \
    output/pdf/main_report.pdf \
    output/pdf/task2_analysis_review.pdf \
    output/pdf/AI_Audit.pdf \
    output/pdf/AI_Critique.pdf; do
    test -s "$pdf"
    pages="$(pdfinfo "$pdf" | awk '/^Pages:/ {print $2}')"
    test "$pages" -ge 1
  done
else
  echo "PDF verification skipped until the final one-time build."
fi

search_cmd() {
  if command -v rg >/dev/null 2>&1; then
    rg "$@"
  else
    grep -E "$@"
  fi
}

if search_cmd -n '__[A-Z_]+__|\bTODO\b|\bTBD\b|PLACEHOLDER|NaN|undefined' \
  README.md main_report.md task2_analysis_review.md AI_Audit.md AI_Critique.md; then
  echo "Unresolved marker found" >&2
  exit 1
fi

echo "Task 2 machine-verifiable artifacts passed. Final student approval remains intentionally student-owned."
