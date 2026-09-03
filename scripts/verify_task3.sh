#!/usr/bin/env bash
set -euo pipefail

task_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$task_root"

test -s task3_continuous_performance_proposal.md
test -s assets/task3_continuous_performance_flow.svg
xmllint --noout assets/task3_continuous_performance_flow.svg

search_cmd() {
  if command -v rg >/dev/null 2>&1; then
    rg "$@"
  else
    grep -E "$@"
  fi
}

for phrase in \
  "Commit-aware trigger policy" \
  "Flow chart" \
  "Metrics and regression decision" \
  "Cost and false-alarm trade-offs" \
  "human reviewer"; do
  search_cmd -q "$phrase" task3_continuous_performance_proposal.md
done

search_cmd -q "task3_continuous_performance_flow.svg" main_report.md
search_cmd -q "Task 3 outcome" README.md

if [[ "${HW05_VERIFY_PDFS:-0}" == "1" ]]; then
  test -s output/pdf/main_report.pdf
  pdf_text="$(mktemp)"
  trap 'rm -f "$pdf_text"' EXIT
  pdftotext output/pdf/main_report.pdf "$pdf_text"
  search_cmd -q "Task 3 - Continuous performance-testing model" "$pdf_text"
  search_cmd -q "Cost and false-alarm trade-offs" "$pdf_text"
else
  echo "PDF verification skipped until the final one-time build."
fi

echo "Task 3 proposal and flow-chart integration verified; PDF is checked only when HW05_VERIFY_PDFS=1."
