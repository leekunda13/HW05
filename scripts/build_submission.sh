#!/usr/bin/env bash
set -euo pipefail

task_root="$(cd "$(dirname "$0")/.." && pwd)"
package_name="23127035_HW05_AI_Performance_100"
package_dir="$task_root/$package_name"

if [[ -e "$package_dir" || -e "$task_root/$package_name.zip" ]]; then
  echo "Submission artifact already exists; refusing to overwrite: $package_name" >&2
  exit 1
fi

mkdir -p \
  "$package_dir/analysis" \
  "$package_dir/assets" \
  "$package_dir/audit" \
  "$package_dir/data" \
  "$package_dir/evidence/database" \
  "$package_dir/evidence/hardware" \
  "$package_dir/evidence/resource" \
  "$package_dir/evidence/screenshots/20260903" \
  "$package_dir/reports" \
  "$package_dir/results" \
  "$package_dir/scripts" \
  "$package_dir/skills/jmeter-performance-testing/agents" \
  "$package_dir/skills/jmeter-performance-testing/references" \
  "$package_dir/skills/jmeter-performance-testing/scripts" \
  "$package_dir/test-plans"

markdown_files=(
  "README.md"
  "main_report.md"
  "AI_Audit.md"
  "AI_Critique.md"
  "bug_report.md"
  "task2_analysis_review.md"
  "task3_continuous_performance_proposal.md"
  "analysis/task1_metrics.md"
  "analysis/task2_metrics.md"
  "audit/agent_skill_prompts.md"
  "audit/phase1_ai_design.md"
  "audit/task2_first_pass_ai_analysis.md"
  "evidence/hardware/hardware_spec.md"
  "skills/jmeter-performance-testing/SKILL.md"
  "skills/jmeter-performance-testing/references/eshop-workflow.md"
  "skills/jmeter-performance-testing/references/hw05-deliverables.md"
)

temp_dir="$(mktemp -d "$task_root/tmp/pdfs/submission.XXXXXX")"
trap 'rm -rf "$temp_dir"' EXIT

render_markdown() {
  local source_rel="$1"
  local source="$task_root/$source_rel"
  local destination_md="$package_dir/$source_rel"
  local destination_pdf="${destination_md%.md}.pdf"
  local html="$temp_dir/$(printf '%s' "$source_rel" | tr '/ ' '__').html"
  local title

  title="$(sed -n 's/^# //p' "$source" | head -1)"
  [[ -n "$title" ]] || title="HW05 Supporting Document"

  cp "$source" "$destination_md"
  perl -CSDA -pi -e 's/\x{2011}|\x{2013}|\x{2014}/-/g' "$destination_md"
  pandoc "$destination_md" \
    --from gfm \
    --to html5 \
    --standalone \
    --embed-resources \
    --resource-path="$task_root:$(dirname "$source")" \
    --metadata "pagetitle=$title" \
    --css "$task_root/scripts/report.css" \
    --output "$html"
  node "$task_root/scripts/render_pdf.js" "$html" "$destination_pdf"
}

for markdown_file in "${markdown_files[@]}"; do
  render_markdown "$markdown_file"
done

cp "$task_root/analysis/task1_metrics.json" "$package_dir/analysis/"
cp "$task_root/analysis/task2_metrics.json" "$package_dir/analysis/"
cp "$task_root/assets/task3_continuous_performance_flow.svg" "$package_dir/assets/"
cp "$task_root/data/performance_users.csv" "$package_dir/data/"
cp "$task_root/evidence/hardware/sysinfo.png" "$package_dir/evidence/hardware/"
cp "$task_root/evidence/screenshots/20260903/23127035_Load_20260903_tool_resource.png" "$package_dir/evidence/screenshots/20260903/"
cp "$task_root/evidence/screenshots/20260903/23127035_Stress_20260903_tool_resource.png" "$package_dir/evidence/screenshots/20260903/"
cp "$task_root/evidence/screenshots/20260903/23127035_Spike_20260903_tool_resource.png" "$package_dir/evidence/screenshots/20260903/"
cp "$task_root/evidence/screenshots/20260903/23127035_Soak_20260903_tool_resource.png" "$package_dir/evidence/screenshots/20260903/"

for scenario in Smoke Load Stress Spike Soak; do
  cp "$task_root/test-plans/23127035_${scenario}_20260903.jmx" "$package_dir/test-plans/"
  cp "$task_root/results/23127035_${scenario}_20260903.jtl" "$package_dir/results/"
  cp -R "$task_root/reports/23127035_${scenario}_20260903" "$package_dir/reports/"
done

# JMeter bundles third-party Markdown documentation inside its HTML assets. These
# files are not submission documents and are not needed by the dashboards.
find "$package_dir/reports" -type f -name '*.md' -delete

find "$task_root/evidence/database" -maxdepth 1 -type f -name '*_20260903_*' -exec cp {} "$package_dir/evidence/database/" \;
find "$task_root/evidence/resource" -maxdepth 1 -type f -name '*_20260903_*' -exec cp {} "$package_dir/evidence/resource/" \;

cp "$task_root/scripts/analyze_task2.py" "$package_dir/scripts/"
cp "$task_root/scripts/build_submission.sh" "$package_dir/scripts/"
cp "$task_root/scripts/monitor_backend.sh" "$package_dir/scripts/"
cp "$task_root/scripts/render_pdf.js" "$package_dir/scripts/"
cp "$task_root/scripts/report.css" "$package_dir/scripts/"
cp "$task_root/scripts/run_official.sh" "$package_dir/scripts/"
cp "$task_root/scripts/seed_performance_data.sql" "$package_dir/scripts/"
cp "$task_root/scripts/summarize_task1.py" "$package_dir/scripts/"
cp "$task_root/scripts/verify_task1.sh" "$package_dir/scripts/"
cp "$task_root/scripts/verify_task2.sh" "$package_dir/scripts/"
cp "$task_root/scripts/verify_task3.sh" "$package_dir/scripts/"
cp "$task_root/scripts/verify_submission.sh" "$package_dir/scripts/"

cp "$task_root/skills/jmeter-performance-testing/agents/openai.yaml" "$package_dir/skills/jmeter-performance-testing/agents/"
cp "$task_root/skills/jmeter-performance-testing/scripts/analyze_jtl.py" "$package_dir/skills/jmeter-performance-testing/scripts/"

git -C "$task_root" log --reverse --format='%h %aI %s' > "$package_dir/git_commit_log.txt"

find "$package_dir" -name '.DS_Store' -delete

(
  cd "$package_dir"
  find . -type f ! -name 'MANIFEST_SHA256.txt' -print0 \
    | sort -z \
    | xargs -0 shasum -a 256 > MANIFEST_SHA256.txt
)

echo "Created $package_dir"
