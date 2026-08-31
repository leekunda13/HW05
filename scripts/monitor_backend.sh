#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <backend-pid> <scenario> <output.csv>" >&2
  exit 2
fi

backend_pid="$1"
scenario="$2"
output_file="$3"

printf 'timestamp,scenario,pid,cpu_percent,rss_kb,vsz_kb,elapsed\n' > "$output_file"
while kill -0 "$backend_pid" 2>/dev/null; do
  timestamp="$(date '+%Y-%m-%dT%H:%M:%S%z')"
  row="$(ps -p "$backend_pid" -o pid=,%cpu=,rss=,vsz=,etime= | awk '{$1=$1; print}')"
  if [[ -n "$row" ]]; then
    read -r pid cpu rss vsz elapsed <<< "$row"
    printf '%s,%s,%s,%s,%s,%s,%s\n' "$timestamp" "$scenario" "$pid" "$cpu" "$rss" "$vsz" "$elapsed" >> "$output_file"
  fi
  sleep 1
done
