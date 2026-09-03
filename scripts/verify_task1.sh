#!/usr/bin/env bash
set -euo pipefail

task_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$task_root"
run_date="${HW05_RUN_DATE:-20260903}"

for scenario in Load Stress Spike; do
  stem="23127035_${scenario}_${run_date}"
  test -s "test-plans/${stem}.jmx"
  test -s "results/${stem}.jtl"
  test -s "reports/${stem}/index.html"
  xmllint --noout "test-plans/${stem}.jmx"
done

test -s "test-plans/23127035_Soak_${run_date}.jmx"
test -s "results/23127035_Soak_${run_date}.jtl"
test -s "reports/23127035_Soak_${run_date}/index.html"
xmllint --noout "test-plans/23127035_Soak_${run_date}.jmx"

python3 - <<'PY'
import csv
import json
import os
from pathlib import Path

root = Path.cwd()
run_date = os.environ.get("HW05_RUN_DATE", "20260903")
metrics = json.loads((root / "analysis/task1_metrics.json").read_text())
for scenario in ("Load", "Stress", "Spike", "Soak"):
    assert metrics[scenario]["overall"]["errors"] == 0, scenario
    stem = f"23127035_{scenario}_{run_date}"
    with (root / "results" / f"{stem}.jtl").open(newline="") as stream:
        jtl = list(csv.DictReader(stream))
    imports = sum(row["label"] == "FR16 Import one product" and row["success"].lower() == "true" for row in jtl)
    with (root / "evidence/database" / f"{stem}_pre_state.csv").open(newline="") as stream:
        before = next(csv.DictReader(stream))
    with (root / "evidence/database" / f"{stem}_post_state.csv").open(newline="") as stream:
        after = next(csv.DictReader(stream))
    assert int(after["products"]) - int(before["products"]) == imports, (scenario, imports, before, after)
    assert int(before["coupon_usage"]) == int(after["coupon_usage"]) == 0, scenario

with (root / f"evidence/resource/23127035_Soak_{run_date}_run_metadata.csv").open(newline="") as stream:
    soak_metadata = next(csv.DictReader(stream))
assert soak_metadata["port"] == "3001"

critique = (root / "AI_Critique.md").read_text().split("\n\n")[1]
word_count = len(critique.split())
assert 200 <= word_count <= 300, word_count
print("Raw metrics, state deltas, soak isolation, and critique length verified.")
PY

for scenario in Load Stress Spike Soak; do
  test -s "evidence/screenshots/${run_date}/23127035_${scenario}_${run_date}_tool_resource.png"
done

if [[ "${HW05_VERIFY_PDFS:-0}" == "1" ]]; then
  for pdf in output/pdf/main_report.pdf output/pdf/task2_analysis_review.pdf output/pdf/AI_Audit.pdf output/pdf/AI_Critique.pdf; do
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
  README.md main_report.md AI_Audit.md AI_Critique.md bug_report.md; then
  echo "Unresolved marker found" >&2
  exit 1
fi

echo "Task 1 machine-verifiable artifacts passed. Student-owned evidence remains intentionally outside this check."
