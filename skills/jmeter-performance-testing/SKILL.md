---
name: jmeter-performance-testing
description: Design, audit, execute, and analyse data-driven JMeter performance tests for the EShop HW05 workflow. Use for Load, Stress, Spike, or soak-test planning; JMX/JTL review; raw-log metric analysis; evidence checklists; AI misinterpretation review; and continuous performance-testing proposals. Do not use it to fabricate execution logs, screenshots, hardware evidence, Git history, or video.
---

# JMeter Performance Testing

Build repeatable performance evidence from the real EShop backend and keep AI output visibly separate from the student's review. Treat the source code, raw `.jtl` files, and observed hardware data as authoritative.

## Start Here

1. Read the assignment PDF and the SUT source before designing a plan. For the supplied workspace, use `../../2026.HW05.Performance Testing_En.pdf` and `../../../hw04/eshop-sut-main` relative to this file.
2. Read [references/eshop-workflow.md](references/eshop-workflow.md) when mapping or validating EShop requests.
3. Read [references/hw05-deliverables.md](references/hw05-deliverables.md) when planning evidence, reviewing completeness, writing the report, or packaging the submission.
4. Confirm the student ID, run date, and that the selected workflow is not duplicated within the student's group. Do not claim group uniqueness without the student's confirmation.
5. Preserve a chronological AI audit containing tool name, date/time, the student's prompt, and the AI output. Record later human corrections separately.
6. Verify `jmeter --version` before generating run commands. If JMeter is absent, report that prerequisite and install it only with the student's authorization; do not silently switch tools because the submission format explicitly requires JMX/JTL artifacts.

## Design the Test Plans

Create Load, Stress, and Spike plans around the same end-to-end virtual-user journey:

```text
POST /api/login
  -> GET /api/products?search=...
  -> GET /api/products/{id}
  -> POST /api/cart
  -> POST /api/checkout
```

This covers auth-heavy, read-heavy, and transactional endpoint groups. Keep request order, correlation, assertions, and CSV schema equivalent across all three plans; vary only the workload model and the required distinct report listener.

- Put credentials, search terms, product IDs, quantities, totals, and shipping addresses in CSV input. Prefer unique pre-seeded accounts per concurrent virtual user so account state is not shared accidentally.
- Configure CSV exhaustion deliberately: do not silently recycle a small credential set under a larger thread count. Document sharing mode, recycle behavior, and the number of usable rows.
- Extract the JWT from the login JSON and send `Authorization: Bearer ${token}` to cart and checkout. Fail the iteration when extraction fails.
- Add response-code, JSON/body, and business assertions. Do not count an HTTP response as success solely because a socket completed.
- Add realistic timers between human actions, but do not add think-time to one scenario and omit it from the others without justification.
- Name the plans exactly `{StudentID}_{ScenarioType}_{YYYYMMDD}.jmx`, where scenario type is `Load`, `Stress`, or `Spike`. Use the same stem for the corresponding `.jtl` and report folder.
- Use three distinct listener types across the plans. A safe default mapping is Load = Summary Report, Stress = Aggregate Report, Spike = View Results Tree. Disable View Results Tree during a high-load non-GUI run and load the completed JTL into that listener afterward; otherwise the listener itself can distort the result.

Choose thread counts, ramp-up, duration, and spike shape from a smoke/baseline run and the student's hardware, not from an arbitrary universal preset. State the hypothesis and stop conditions for each scenario. A load test checks a realistic steady workload; a stress test increases load until degradation or a safety ceiling; a spike test changes concurrency abruptly and observes recovery.

## Review Before Running

Audit every generated JMX as code or XML before execution:

- host and port resolve to the backend API, normally `127.0.0.1:3000`;
- all five journey requests occur inside the same user iteration;
- CSV columns match variable references and contain enough independent accounts;
- token extraction and authenticated headers are scoped correctly;
- assertions distinguish application errors from transport success;
- timers are placed inside the journey and excluded from setup/cleanup;
- scenario schedules actually express load, stress, and spike rather than three renamed constant tests;
- listeners are distinct and expensive GUI listeners will not run during the measurement;
- raw JTL saving includes at least timestamp, elapsed time, label, response code, success, bytes, sent bytes, latency, connect time, and active threads.

Document each AI mistake, the evidence for the correction, the correction itself, and why the AI likely missed it. Never weaken an assertion merely to improve pass rate.

## Execute and Preserve Evidence

Run a smoke iteration first. For official measurement, start from a documented database state and run JMeter in non-GUI mode:

```bash
jmeter -n \
  -t test-plans/23127035_Load_20260829.jmx \
  -l results/23127035_Load_20260829.jtl \
  -e -o reports/23127035_Load_20260829
```

Adjust the ID/date and paths rather than reusing the example literally. JMeter requires the HTML output directory to be absent or empty. Keep the complete raw JTL; never replace it with a summary.

For each official run, the student must capture the JMeter/tool view and the backend process's resource usage in the same frame. Hardware screenshots, hostname, real execution logs, Git commits, and Vietnamese voice narration must come from the actual student environment. The skill may organize or review these artifacts but must not generate or imitate them.

Use valid credentials for performance traffic. If the application enters the three-failure lockout state, stop mixing that state into later measurements, reset it by a documented real procedure, and record the source defect described in the EShop reference. Do not silently edit the database.

Run a separate 10-15 minute sustained soak measurement. Report an empirical threshold only when the raw run and resource evidence support concrete stable RPS, p95, error rate, and memory ceiling values. Call an outcome inconclusive when the run ended early or the monitoring evidence is missing.

## Analyse Raw JTL Data

Use the bundled analyser for a reproducible first pass:

```bash
python3 skills/jmeter-performance-testing/scripts/analyze_jtl.py \
  results/23127035_Load_20260829.jtl
```

The script reports global and per-label counts, errors, error rate, mean, median, p90/p95/p99, min/max, throughput, received/sent bytes, and response-code counts. Its percentile method and measurement window are printed with the results.

Then review the result against the raw JTL:

- distinguish elapsed time from latency and connect time;
- distinguish iteration/transaction throughput from individual request throughput;
- distinguish average from p95 and maximum;
- calculate error rate from failed samples, not merely non-2xx codes when JMeter assertions can also mark a sample failed;
- compare scenarios only when workflow, timers, dataset, environment, and measurement boundaries are comparable;
- cite the exact raw-log value for every claimed AI misinterpretation;
- classify optimizations as feasible only when the source architecture supports them. EShop uses Node.js, Express, and SQLite; proposals for a framework or database not present in the source are hallucinated unless explicitly framed as a migration.

Do not invent thresholds. Separate observed baselines, student-approved acceptance targets, and proposed regression gates.

## Continuous Testing Proposal

Propose a commit-aware pipeline that detects relevant backend/database changes, runs a smoke gate first, schedules controlled performance tests on stable hardware, compares p95 and error rate to an approved baseline, stores raw artifacts, and requires human review before changing the baseline. Include a flow chart and discuss execution cost, noisy neighbours, data drift, false alarms, threshold ownership, and the danger of comparing different hardware.

## Completion Standard

Before declaring the assignment ready, verify the checklist in [references/hw05-deliverables.md](references/hw05-deliverables.md). Clearly label missing student-owned evidence and placeholders; never report them as complete.
