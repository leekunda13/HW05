#!/usr/bin/env bash
set -euo pipefail

task_root="$(cd "$(dirname "$0")/.." && pwd)"
temp_dir="$task_root/tmp/pdfs/final"
output_dir="$task_root/output/pdf"
mkdir -p "$temp_dir" "$output_dir"

build_one() {
  local source_md="$1"
  local output_name="$2"
  local title="$3"
  local html_file="$temp_dir/${output_name%.pdf}.html"

  pandoc "$task_root/$source_md" \
    --from gfm \
    --to html5 \
    --standalone \
    --metadata "pagetitle=$title" \
    --css "$task_root/scripts/report.css" \
    --output "$html_file"

  node "$task_root/scripts/render_pdf.js" "$html_file" "$output_dir/$output_name"
}

build_one "main_report.md" "main_report.pdf" "HW05 Tasks 1-2 Performance Report"
build_one "task2_analysis_review.md" "task2_analysis_review.pdf" "HW05 Task 2 Analysis Review"
build_one "AI_Audit.md" "AI_Audit.pdf" "HW05 Tasks 1-2 AI Audit"
build_one "AI_Critique.md" "AI_Critique.pdf" "HW05 AI Critique"

pdfinfo "$output_dir/main_report.pdf" | sed -n '1,20p'
pdfinfo "$output_dir/task2_analysis_review.pdf" | sed -n '1,20p'
pdfinfo "$output_dir/AI_Audit.pdf" | sed -n '1,20p'
pdfinfo "$output_dir/AI_Critique.pdf" | sed -n '1,20p'
