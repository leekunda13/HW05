#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <Smoke|Load|Stress|Spike|Soak>" >&2
  exit 2
fi

scenario="$1"
case "$scenario" in
  Smoke|Load|Stress|Spike|Soak) ;;
  *) echo "Unsupported scenario: $scenario" >&2; exit 2 ;;
esac

task_root="$(cd "$(dirname "$0")/.." && pwd)"
sut_backend="${HW05_SUT_BACKEND:-/Users/kunda/Documents/hw/hw04/eshop-sut-main/backend}"
sut_port="${HW05_PORT:-3000}"
database_file="$sut_backend/database.sqlite"
stem="23127035_${scenario}_20260901"
plan="$task_root/test-plans/${stem}.jmx"
jtl="$task_root/results/${stem}.jtl"
report="$task_root/reports/${stem}"
run_log="$task_root/results/${stem}_run.log"
jmeter_log="$task_root/results/${stem}_jmeter.log"
backend_log="$task_root/evidence/resource/${stem}_backend.log"
resource_csv="$task_root/evidence/resource/${stem}_backend_resource.csv"
metadata_csv="$task_root/evidence/resource/${stem}_run_metadata.csv"
pre_state="$task_root/evidence/database/${stem}_pre_state.csv"
post_state="$task_root/evidence/database/${stem}_post_state.csv"

for target in "$jtl" "$report" "$run_log" "$jmeter_log" "$backend_log" "$resource_csv" "$metadata_csv" "$pre_state" "$post_state"; do
  if [[ -e "$target" ]]; then
    echo "Refusing to overwrite existing evidence: $target" >&2
    exit 3
  fi
done

backend_pid=""
monitor_pid=""
cleanup() {
  if [[ -n "$monitor_pid" ]] && kill -0 "$monitor_pid" 2>/dev/null; then
    kill "$monitor_pid" 2>/dev/null || true
    wait "$monitor_pid" 2>/dev/null || true
  fi
  if [[ -n "$backend_pid" ]] && kill -0 "$backend_pid" 2>/dev/null; then
    kill "$backend_pid" 2>/dev/null || true
    wait "$backend_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

(
  cd "$sut_backend"
  exec node server.js
) > "$backend_log" 2>&1 &
backend_pid=$!

for attempt in {1..30}; do
  if curl -fsS "http://127.0.0.1:$sut_port/api/products" >/dev/null 2>&1; then
    break
  fi
  if ! kill -0 "$backend_pid" 2>/dev/null; then
    echo "Backend exited before becoming ready" >&2
    exit 4
  fi
  sleep 1
done
curl -fsS "http://127.0.0.1:$sut_port/api/products" >/dev/null

# database.js queues destructive DROP/CREATE/seed statements asynchronously and
# app.listen() can become reachable before that queue finishes.  Require the
# canonical seed counts to remain stable before inserting performance accounts.
stable_checks=0
for attempt in {1..45}; do
  seed_state="$(sqlite3 "$database_file" "select (select count(*) from users) || '|' || (select count(*) from products) || '|' || (select count(*) from coupons);")"
  if [[ "$seed_state" == "2|5|4" ]]; then
    stable_checks=$((stable_checks + 1))
  else
    stable_checks=0
  fi
  if [[ "$stable_checks" -ge 3 ]]; then
    break
  fi
  sleep 1
done
if [[ "$stable_checks" -lt 3 ]]; then
  echo "SUT database did not reach a stable canonical seed state" >&2
  exit 5
fi

sqlite3 "$database_file" < "$task_root/scripts/seed_performance_data.sql"
seeded_users="$(sqlite3 "$database_file" "select count(*) from users where email like 'perf%@eshop.local' and role='admin';")"
if [[ "$seeded_users" != "80" ]]; then
  echo "Expected 80 performance accounts, found $seeded_users" >&2
  exit 6
fi
sqlite3 -header -csv "$database_file" "select datetime('now','localtime') as captured_at, count(*) as users, sum(role='admin') as admins, (select count(*) from products) as products, (select count(*) from orders) as orders, (select count(*) from coupon_usage) as coupon_usage from users;" > "$pre_state"

start_iso="$(date '+%Y-%m-%dT%H:%M:%S%z')"
printf 'scenario,start_time,end_time,backend_pid,jmeter_version,host,port\n' > "$metadata_csv"

"$task_root/scripts/monitor_backend.sh" "$backend_pid" "$scenario" "$resource_csv" &
monitor_pid=$!

set +e
jmeter -n \
  -t "$plan" \
  -l "$jtl" \
  -j "$jmeter_log" \
  -e -o "$report" \
  -Jjmeter.save.saveservice.output_format=csv \
  -Jjmeter.save.saveservice.print_field_names=true \
  -Jjmeter.save.saveservice.connect_time=true \
  -Jjmeter.save.saveservice.latency=true \
  -Jjmeter.save.saveservice.bytes=true \
  -Jjmeter.save.saveservice.sent_bytes=true \
  -Jjmeter.save.saveservice.thread_counts=true \
  -Jjmeter.save.saveservice.assertion_results_failure_message=true \
  -Jport="$sut_port" \
  2>&1 | tee "$run_log"
jmeter_status=${PIPESTATUS[0]}
set -e

end_iso="$(date '+%Y-%m-%dT%H:%M:%S%z')"
printf '%s,%s,%s,%s,%s,%s,%s\n' "$scenario" "$start_iso" "$end_iso" "$backend_pid" "5.6.3" "127.0.0.1" "$sut_port" >> "$metadata_csv"
sqlite3 -header -csv "$database_file" "select datetime('now','localtime') as captured_at, count(*) as users, sum(role='admin') as admins, (select count(*) from products) as products, (select count(*) from orders) as orders, (select count(*) from coupon_usage) as coupon_usage from users;" > "$post_state"

kill "$monitor_pid" 2>/dev/null || true
wait "$monitor_pid" 2>/dev/null || true
monitor_pid=""

if [[ "$jmeter_status" -ne 0 ]]; then
  echo "JMeter exited with status $jmeter_status" >&2
  exit "$jmeter_status"
fi

test -s "$jtl"
test -s "$report/index.html"
echo "Completed $scenario with backend PID $backend_pid"
