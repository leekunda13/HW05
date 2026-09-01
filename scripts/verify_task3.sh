#!/usr/bin/env bash
set -euo pipefail

task_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$task_root"

test -s task3_continuous_performance_proposal.md
test -s assets/task3_continuous_performance_flow.svg
test -s output/pdf/main_report.pdf
xmllint --noout assets/task3_continuous_performance_flow.svg

for phrase in \
  "Commit-aware trigger policy" \
  "Flow chart" \
  "Metrics and regression decision" \
  "Cost and false-alarm trade-offs" \
  "human reviewer"; do
  rg -q "$phrase" task3_continuous_performance_proposal.md
done

rg -q "task3_continuous_performance_flow.svg" main_report.md
rg -q "Task 3 outcome" README.md

pdf_text="$(mktemp)"
trap 'rm -f "$pdf_text"' EXIT
pdftotext output/pdf/main_report.pdf "$pdf_text"
rg -q "Task 3 - Continuous performance-testing model" "$pdf_text"
rg -q "Cost and false-alarm trade-offs" "$pdf_text"

echo "Task 3 proposal, flow chart, report integration, and rendered PDF verified."
