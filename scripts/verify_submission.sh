#!/usr/bin/env bash
set -euo pipefail

task_root="$(cd "$(dirname "$0")/.." && pwd)"
package_name="23127035_HW05_AI_Performance_100"
package_dir="${1:-$task_root/$package_name}"

test -d "$package_dir"
test "$(find "$package_dir" -type f -name '*.md' | wc -l | tr -d ' ')" = "16"
test "$(find "$package_dir" -type f -name '*.pdf' | wc -l | tr -d ' ')" = "16"

while IFS= read -r markdown; do
  pdf="${markdown%.md}.pdf"
  test -s "$pdf"
  test "$(pdfinfo "$pdf" | awk '/^Pages:/ {print $2}')" -ge 1
  extracted="$(mktemp)"
  pdftotext "$pdf" "$extracted"
  test -s "$extracted"
  rm -f "$extracted"
done < <(find "$package_dir" -type f -name '*.md' | sort)

for scenario in Load Stress Spike; do
  test -s "$package_dir/test-plans/23127035_${scenario}_20260903.jmx"
  test -s "$package_dir/results/23127035_${scenario}_20260903.jtl"
  test -s "$package_dir/reports/23127035_${scenario}_20260903/index.html"
  test -s "$package_dir/reports/23127035_${scenario}_20260903/statistics.json"
  test -s "$package_dir/evidence/screenshots/20260903/23127035_${scenario}_20260903_tool_resource.png"
done

test -s "$package_dir/test-plans/23127035_Soak_20260903.jmx"
test -s "$package_dir/results/23127035_Soak_20260903.jtl"
test -s "$package_dir/reports/23127035_Soak_20260903/index.html"
test -s "$package_dir/evidence/screenshots/20260903/23127035_Soak_20260903_tool_resource.png"
test -s "$package_dir/evidence/hardware/sysinfo.png"
test -s "$package_dir/assets/task3_continuous_performance_flow.svg"
test -s "$package_dir/git_commit_log.txt"
test -s "$package_dir/MANIFEST_SHA256.txt"

test -z "$(find "$package_dir/reports" -type f -name '*.md' -print -quit)"
rg -q 'https://youtu.be/ukf1sTUyVuY' "$package_dir/README.md" "$package_dir/main_report.md"
rg -q 'https://youtu.be/MxNkVFIW3Gk' "$package_dir/README.md" "$package_dir/main_report.md"
rg -q 'https://github.com/leekunda13/HW05' "$package_dir/README.md" "$package_dir/main_report.md"

for image in \
  "$package_dir/evidence/hardware/sysinfo.png" \
  "$package_dir/evidence/screenshots/20260903/23127035_Load_20260903_tool_resource.png" \
  "$package_dir/evidence/screenshots/20260903/23127035_Stress_20260903_tool_resource.png" \
  "$package_dir/evidence/screenshots/20260903/23127035_Spike_20260903_tool_resource.png" \
  "$package_dir/evidence/screenshots/20260903/23127035_Soak_20260903_tool_resource.png"; do
  test "$(sips -g pixelWidth "$image" | awk '/pixelWidth:/ {print $2}')" -ge 1200
done

raster_count="$(pdfimages -list "$package_dir/main_report.pdf" | awk 'NR > 2 && $1 ~ /^[0-9]+$/ {count++} END {print count+0}')"
test "$raster_count" -ge 5

if rg -n '__[A-Z_]+__|\bTODO\b|\bTBD\b|PLACEHOLDER|NaN|undefined' \
  "$package_dir/README.md" \
  "$package_dir/main_report.md" \
  "$package_dir/AI_Audit.md" \
  "$package_dir/AI_Critique.md"; then
  echo "Unresolved marker found in submission documents" >&2
  exit 1
fi

echo "Submission structure, Markdown/PDF pairs, images, reports, links, and PDF text passed."
