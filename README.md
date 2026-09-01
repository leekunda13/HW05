# 23127035 - HW05 Tasks 1-2 Performance Testing

This repository contains the Task 1 and Task 2 technical work for the coherent WF-04 admin product-publishing journey:

`Admin Login -> Import Product CSV -> Search Imported Product -> View Product Detail`

WF-04 is distinct from the three team workflows supplied by the student: WF-01 Login/Product/Cart/Checkout, WF-02 Login/Product/Coupon/Checkout/Coupon Usage, and WF-03 Login/Product/Checkout/Cancel Order.

## Test summary

| Scenario | Workload | Samples | Error % | p95 ms | Samples/s | Exact workflows/s |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Load | 6 VUs / 120 s | 1,912 | 0.00 | 5 | 16.04 | 4.00 |
| Stress | 6 -> 12 -> 24 VUs | 6,514 | 0.00 | 4 | 36.33 | 9.00 |
| Spike | 3 -> 30 -> 3 VUs | 3,216 | 0.00 | 4 | 26.98 | 6.65 |
| Soak | 30 VUs / 410 iterations each | 49,200 | 0.00 | 4 | 79.49 | 19.87 |

Endpoint coverage:

- auth-heavy: FR02 admin login and JWT/role correlation;
- transactional/write-heavy: FR16 authenticated product import;
- read-heavy: FR05 exact search and FR06 correlated product detail;
- business completion: the imported name, ID, and price are verified at the final detail endpoint.

The maximum stable load observed was 30 VUs for 618.94 seconds, exactly 12,300 completed workflows, 79.49 samples/s, 19.87 workflows/s, p95 4 ms, 0.00% errors, peak Node CPU 22.3%, and peak RSS 136.67 MB. No absolute failure threshold was reached.

## Task 2 outcome

The unreviewed AI first pass is retained under `audit/`. `task2_analysis_review.md` corrects eight metric misinterpretations with raw JTL values and classifies eight optimization recommendations against the Express/SQLite source. Suggested thresholds are same-environment regression gates, not an SLA.

## Self-assessment through Task 2

| Criterion | Maximum | Proposed technical score | Basis |
| --- | ---: | ---: | --- |
| Load testing | 30 | 30 | Dated JMX/JTL/HTML, assertions, DB/resource evidence. |
| Stress testing | 20 | 20 | Three concurrency stages with raw stage metrics. |
| Spike testing | 20 | 20 | Abrupt 3-to-30 VU burst and measured recovery. |
| Task 2 analysis and misinterpretation hunt | 10 | 10 | Retained first pass, eight raw-value corrections, regression gates, and eight source-grounded judgments. |
| **Tasks 1-2 subtotal** | **80** | **80** | Conditional on mandatory student-owned evidence and human approval. |

## Key files

- `main_report.md` and `output/pdf/main_report.pdf`
- `task2_analysis_review.md` and matching PDF
- `AI_Audit.md`, `AI_Critique.md`, and matching PDFs
- `test-plans/23127035_{Load,Stress,Spike}_20260901.jmx`
- `results/23127035_{Load,Stress,Spike,Soak}_20260901.jtl`
- `reports/23127035_{Load,Stress,Spike,Soak}_20260901/index.html`
- `analysis/task1_metrics.{md,json}` and `analysis/task2_metrics.{md,json}`
- `evidence/resource`, `evidence/database`, and `evidence/inconclusive`
- `skills/jmeter-performance-testing`
- `git_commit_log.txt`

## Reproduction

The safe runner refuses to overwrite evidence. Prepare an isolated backend copy whose only source change is port 3001, then run:

```bash
HW05_SUT_BACKEND="$PWD/tmp/isolated-backend-wf04" HW05_PORT=3001 ./scripts/run_official.sh Load
HW05_SUT_BACKEND="$PWD/tmp/isolated-backend-wf04" HW05_PORT=3001 ./scripts/run_official.sh Stress
HW05_SUT_BACKEND="$PWD/tmp/isolated-backend-wf04" HW05_PORT=3001 ./scripts/run_official.sh Spike
HW05_SUT_BACKEND="$PWD/tmp/isolated-backend-wf04" HW05_PORT=3001 ./scripts/run_official.sh Soak
```

## Student-owned links and evidence

- Unlisted YouTube demo: requires the student's real Vietnamese narration.
- Public GitHub repository: requires the student's publication action.
- Activity Monitor/hardware screenshots, group evidence, and explicit human review: see `STUDENT_EVIDENCE_REQUIRED.md`.

No performance issue was filed because all accepted samples passed. The incomplete clock-jump Soak attempt is retained as excluded evidence and is not used in the endurance conclusion.
