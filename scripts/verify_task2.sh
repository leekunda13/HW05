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
    "Load": (1896, 0, 5, 6, 315),
    "Stress": (6476, 0, 5, 6, 1062),
    "Spike": (3180, 0, 5, 7, 513),
    "Soak": (49322, 0, 5, 6, 8207),
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
        row["label"] == "READ Verify imported product" and row["success"].lower() == "true"
        for row in rows
    )
    assert final_successes == overall["completed_workflows"], scenario

stress_24 = metrics["Stress"]["stages"]["Stress stage 3 - 24 VUs"]
spike_burst = metrics["Spike"]["stages"]["Spike burst - 30 VUs"]
assert round(stress_24["sample_rate_s"], 2) == 61.87
assert round(spike_burst["sample_rate_s"], 2) == 82.96

soak_resources = metrics["Soak"]["resources"]
assert round(soak_resources["rss_peak_mb"], 2) == 140.47
assert round(soak_resources["rss_final_mb"], 2) == 78.50

critique = (root / "AI_Critique.md").read_text(encoding="utf-8").split("\n\n")[1]
assert len(critique.split()) == 260

review = (root / "task2_analysis_review.md").read_text(encoding="utf-8")
assert review.count("| \u201c") == 8, "Expected eight first-pass correction rows"
assert review.count("**Feasible") == 3, "Expected three feasible classifications"
assert review.count("**Hallucinated") == 4, "Expected four hallucinated classifications"
assert "**Unsupported for this workload**" in review
print("Task 2 raw metrics, review rows, recommendation judgments, and critique length verified.")
PY

for pdf in \
  output/pdf/main_report.pdf \
  output/pdf/task2_analysis_review.pdf \
  output/pdf/AI_Audit.pdf \
  output/pdf/AI_Critique.pdf; do
  test -s "$pdf"
  pages="$(pdfinfo "$pdf" | awk '/^Pages:/ {print $2}')"
  test "$pages" -ge 1
done

if rg -n '__[A-Z_]+__|\bTODO\b|\bTBD\b|PLACEHOLDER|NaN|undefined' \
  README.md main_report.md task2_analysis_review.md AI_Audit.md AI_Critique.md; then
  echo "Unresolved marker found" >&2
  exit 1
fi

echo "Task 2 machine-verifiable artifacts passed. Final student approval remains intentionally student-owned."
