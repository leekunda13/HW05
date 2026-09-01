# 23127035 - HW05 Tasks 1-2 Performance Testing

This repository contains the completed technical work for Tasks 1 and 2 using the selected FR03-FR09-FR16 EShop workflow. Load, Stress, Spike, and a ten-minute isolated Soak were executed with Apache JMeter 5.6.3 on `2026-08-31`; the retained AI first pass and raw-log correction were completed on `2026-09-01`.

## Test summary

| Scenario | Workload | Samples | Error % | p95 ms | Samples/s | Approx. workflows/s |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Load | 6 VUs / 120 s | 1,896 | 0.00 | 5 | 15.88 | 2.65 |
| Stress | 6 -> 12 -> 24 VUs | 6,476 | 0.00 | 5 | 36.11 | 6.02 |
| Spike | 3 -> 30 -> 3 VUs | 3,180 | 0.00 | 5 | 26.69 | 4.45 |
| Soak | 30 VUs / 600 s | 49,322 | 0.00 | 5 | 82.29 | 13.72 |

One complete workflow contains six HTTP samples. The endpoint-group mapping is:

- auth-heavy: FR03 forgot/reset plus login and JWT correlation;
- transactional/write-heavy: FR16 authenticated product import;
- read-heavy: exact product search after import;
- FR09 supplies coupon business validation with exact monetary assertions.

The maximum stable load **observed within the tested envelope** was 30 VUs for ten minutes at 82.29 samples/s, **8,207 exact completed workflows (13.69/s)**, p95 5 ms, 0.00% errors, peak Node CPU 38.7%, and peak RSS 140.47 MB. No absolute hardware failure threshold was reached. Task 2 corrects the earlier approximate `samples/s / 6` rate by counting the successful final workflow sampler.

## Task 2 outcome

The first-pass AI analysis is retained under `audit/` and is followed by a separate source-backed correction in `task2_analysis_review.md`. Eight metric misinterpretations are corrected from raw JTL values, including sample versus workflow throughput, whole-run versus stage throughput, maximum versus p95/p99, and RSS peak versus memory ceiling. Eight optimization proposals are classified against the Express/SQLite source. Proposed thresholds are explicitly regression gates for controlled same-environment comparison, not an SLA.

## Self-assessment through Task 2

| Criterion | Maximum | Proposed technical score | Basis |
| --- | ---: | ---: | --- |
| Load testing | 30 | 30 | Dated JMX, raw JTL, HTML dashboard, assertions, DB/resource evidence. |
| Stress testing | 20 | 20 | Three real concurrency stages with stage-level raw metrics. |
| Spike testing | 20 | 20 | Abrupt 3-to-30 VU burst and measured recovery. |
| Task 2 AI analysis and misinterpretation hunt | 10 | 10 | Retained first pass, eight raw-value corrections, proposed gates, and eight source-grounded recommendation judgments. |
| **Tasks 1-2 technical subtotal** | **80** | **80** | Conditional on the student performing and approving the mandatory human review and supplying the anti-cheat evidence below. |

The final self-assessed grade belongs to the student. Activity Monitor/hardware screenshots, student narration/YouTube URL, public GitHub URL, group-uniqueness proof, and explicit human approval are not fabricated; see `STUDENT_EVIDENCE_REQUIRED.md`.

## Key files

- `main_report.md` and `output/pdf/main_report.pdf`
- `AI_Audit.md`, `AI_Critique.md`, and matching PDFs
- `test-plans/23127035_{Load,Stress,Spike}_20260831.jmx`
- `data/performance_users.csv`
- `results/*.jtl`
- `reports/*/index.html`
- `analysis/task1_metrics.md` and `.json`
- `task2_analysis_review.md` and `output/pdf/task2_analysis_review.pdf`
- `audit/task2_first_pass_ai_analysis.md`
- `analysis/task2_metrics.md` and `.json`
- `evidence/resource`, `evidence/database`, and `evidence/inconclusive`
- `skills/jmeter-performance-testing`
- `git_commit_log.txt`

## Reproduce a clean run

The runner refuses to overwrite existing evidence. Move an old run to an audit directory before rerunning.

```bash
./scripts/run_official.sh Load
./scripts/run_official.sh Stress
./scripts/run_official.sh Spike
```

For an isolated soak, make a temporary backend copy, change only its listening port to 3001, and run:

```bash
HW05_SUT_BACKEND="$PWD/tmp/isolated-backend" HW05_PORT=3001 \
  ./scripts/run_official.sh Soak
```

## Demo and repository links

- Unlisted YouTube demo: not added by the agent; requires the student's real Vietnamese voice.
- Public GitHub repository: not published by the agent; the requested local Git repository is present on branch `main`.

No new performance issue was filed because all accepted samples returned HTTP 200 and passed their business assertions. The two rejected attempts and their corrections remain fully documented under `evidence/inconclusive`.
