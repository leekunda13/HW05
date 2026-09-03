# 23127035 - HW05 Tasks 1-3 Performance Testing

This repository contains the Task 1 through Task 3 technical work for the coherent WF-04 admin product-publishing journey:

`Admin Login -> Import Product CSV -> Search Imported Product -> View Product Detail`

WF-04 is distinct from the three team workflows supplied by the student: WF-01 Login/Product/Cart/Checkout, WF-02 Login/Product/Coupon/Checkout/Coupon Usage, and WF-03 Login/Product/Checkout/Cancel Order.

## Test summary

| Scenario | Workload | Samples | Error % | p95 ms | Samples/s | Exact workflows/s |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Load | 6 VUs / 120 s | 1,902 | 0.00 | 5 | 15.93 | 3.97 |
| Stress | 6 -> 12 -> 24 VUs | 6,489 | 0.00 | 5 | 36.19 | 8.96 |
| Spike | 3 -> 30 -> 3 VUs | 3,208 | 0.00 | 5 | 26.91 | 6.61 |
| Soak | 30 VUs / 410 iterations each | 49,200 | 0.00 | 4 | 80.15 | 20.04 |

Endpoint coverage:

- auth-heavy: FR02 admin login and JWT/role correlation;
- transactional/write-heavy: FR16 authenticated product import;
- read-heavy: FR05 exact search and FR06 correlated product detail;
- business completion: the imported name, ID, and price are verified at the final detail endpoint.

The maximum stable load observed was 30 VUs for 613.82 seconds, exactly 12,300 completed workflows, 80.15 samples/s, 20.04 workflows/s, p95 4 ms, 0.00% errors, peak Node CPU 28.2%, and peak RSS 138.95 MB. No absolute failure threshold was reached.

The Markdown and raw evidence reflect the accepted 20260903 runs.

## Task 2 outcome

The unreviewed AI first pass is retained under `audit/`. `task2_analysis_review.md` corrects eight metric misinterpretations with raw JTL values and classifies eight optimization recommendations against the Express/SQLite source. Suggested thresholds are same-environment regression gates, not an SLA.

## Task 3 outcome

`task3_continuous_performance_proposal.md` defines a commit-aware pipeline with path/risk-based profile selection, a smoke gate, a pinned environment, versioned artifacts, repeated p95 regression confirmation, and human-owned baseline changes. Its flow chart is stored in `assets/task3_continuous_performance_flow.svg`. Cost, noisy-neighbour, data-drift, small-latency, hardware-drift, false-alarm, baseline-ownership, and artifact-retention trade-offs are addressed.

## Self-assessment through Task 3

| Criterion | Maximum | Proposed technical score | Basis |
| --- | ---: | ---: | --- |
| Load testing | 30 | 30 | Dated JMX/JTL/HTML, assertions, DB/resource evidence. |
| Stress testing | 20 | 20 | Three concurrency stages with raw stage metrics. |
| Spike testing | 20 | 20 | Abrupt 3-to-30 VU burst and measured recovery. |
| Task 2 analysis and misinterpretation hunt | 10 | 10 | Retained first pass, eight raw-value corrections, regression gates, and eight source-grounded judgments. |
| Task 3 continuous performance proposal | 10 | 10 | Commit-aware decisions, p95 gate, flow chart, and cost/false-alarm trade-offs. |
| Agent Skill | 10 | 10 | Skill source plus [student-owned end-to-end demonstration](https://youtu.be/MxNkVFIW3Gk). |
| **Technical subtotal** | **100** | **100** | Proposed score based on the current technical artifacts and student-owned demonstrations. |

## Key files

- `main_report.md` and `output/pdf/main_report.pdf`
- `task2_analysis_review.md` and matching PDF
- `task3_continuous_performance_proposal.md` and `assets/task3_continuous_performance_flow.svg`
- `AI_Audit.md`, `AI_Critique.md`, and matching PDFs
- `test-plans/23127035_{Load,Stress,Spike}_20260903.jmx`
- `results/23127035_{Load,Stress,Spike,Soak}_20260903.jtl`
- `reports/23127035_{Load,Stress,Spike,Soak}_20260903/index.html`
- `evidence/screenshots/20260903/23127035_{Load,Stress,Spike,Soak}_20260903_tool_resource.png`
- `analysis/task1_metrics.{md,json}` and `analysis/task2_metrics.{md,json}`
- `evidence/resource`, `evidence/database`, and `evidence/inconclusive`
- `skills/jmeter-performance-testing`
- `git_commit_log.txt`

## Reproduction

The safe runner refuses to overwrite evidence. Prepare an isolated backend copy whose only source change is port 3001, then run:

```bash
HW05_RUN_DATE=20260903 HW05_SUT_BACKEND="$PWD/tmp/isolated-backend-wf04" HW05_PORT=3001 ./scripts/run_official.sh Load
HW05_RUN_DATE=20260903 HW05_SUT_BACKEND="$PWD/tmp/isolated-backend-wf04" HW05_PORT=3001 ./scripts/run_official.sh Stress
HW05_RUN_DATE=20260903 HW05_SUT_BACKEND="$PWD/tmp/isolated-backend-wf04" HW05_PORT=3001 ./scripts/run_official.sh Spike
HW05_RUN_DATE=20260903 HW05_SUT_BACKEND="$PWD/tmp/isolated-backend-wf04" HW05_PORT=3001 ./scripts/run_official.sh Soak
```

## Submission links and evidence

- Task 1 demo (YouTube Unlisted): [https://youtu.be/ukf1sTUyVuY](https://youtu.be/ukf1sTUyVuY)
- Agent Skill demo (YouTube Unlisted): [https://youtu.be/MxNkVFIW3Gk](https://youtu.be/MxNkVFIW3Gk)
- Public GitHub repository: [https://github.com/leekunda13/HW05](https://github.com/leekunda13/HW05)
- Activity Monitor screenshots for all accepted scenarios are in `evidence/screenshots/20260903`; the [hardware screenshot](evidence/hardware/sysinfo.png) and spec table are documented in `evidence/hardware/`.

No performance issue was filed because all accepted samples passed. The incomplete clock-jump Soak attempt is retained as excluded evidence and is not used in the endurance conclusion.
