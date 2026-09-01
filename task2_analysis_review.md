# HW05 Task 2 - AI Analysis and Misinterpretation Hunt

**Student ID:** 23127035<br>
**Run/analysis date:** 2026-09-01<br>
**Workflow:** WF-04 - Admin Login -> Import Product CSV -> Search Imported Product -> View Product Detail<br>
**AI tool:** OpenAI Codex

## 1. Method and evidence boundary

The unreviewed AI response is retained in `audit/task2_first_pass_ai_analysis.md`. The correction below is reproduced from the four accepted `20260901` JTL files by `scripts/analyze_task2.py`; machine-readable output is `analysis/task2_metrics.json`.

Percentiles use nearest rank over JMeter `elapsed`. A row fails when JMeter `success` is not `true`, so business-assertion failures count even for HTTP 2xx. A workflow completes only when the successful final sampler `FR06 View imported product detail` exists. This is stricter than dividing samples by four because scheduled Load/Stress/Spike shutdown can leave partial iterations.

The technical review is complete but is not labelled as the student's human review until the student checks and approves or amends it.

## 2. Authoritative raw-log summary

| Scenario | HTTP samples | Failed | p95 ms | p99 ms | Max ms | Samples/s | Completed workflows | Workflows/s |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Load | 1,912 | 0 | 5 | 6 | 72 | 16.04 | 477 | 4.00 |
| Stress | 6,514 | 0 | 4 | 5 | 19 | 36.33 | 1,613 | 9.00 |
| Spike | 3,216 | 0 | 4 | 5 | 50 | 26.98 | 793 | 6.65 |
| Soak | 49,200 | 0 | 4 | 6 | 1,151 | 79.49 | 12,300 | 19.87 |

Raw sources are `results/23127035_{Load,Stress,Spike,Soak}_20260901.jtl`. Overall, stage, sampler, and resource details are in `analysis/task2_metrics.md`.

## 3. Misinterpretation hunt

| First-pass AI statement | Correct raw value | Why it is wrong |
| --- | --- | --- |
| “Soak sustained 79.49 workflows/s.” | **79.49 HTTP samples/s**, exactly **12,300** final samplers and **19.87 completed workflows/s** over 618.94 s. | JMeter's default rate counts HTTP samplers, not business journeys. |
| “Stress achieved 36.33 requests/s,” used as its peak. | Whole Stress is 36.33 samples/s, but the **24-VU stage is 62.21 samples/s**, p95 4 ms, 0 failures. | The whole value averages 6-, 12-, and 24-VU windows. |
| “Spike is slower than Stress, so the burst degraded throughput.” | The **30-VU burst reached 84.03 samples/s**, p95 4 ms; 26.98 is the whole test including two 3-VU periods. | Different workload windows are not comparable peak stages. |
| “Spike did not recover.” | Recovery was **8.38 samples/s, p95 4 ms**, versus baseline **8.13 samples/s, p95 5 ms**. | Recovery must be compared with the same 3-VU baseline, not the burst or whole-run average. |
| “The 1,151 ms maximum proves a tail-latency failure.” | Soak p95 is **4 ms** and p99 **6 ms** across 49,200 samples; the maximum occurs in a brief multi-sampler cluster. | A maximum is an outlier, not a percentile or evidence of sustained tail degradation. |
| “0% errors proves production capacity at 79 users/s.” | Evidence proves **30 VUs**, 0 failures, 79.49 samples/s, and 19.87 workflows/s. No stage reached collapse. | VUs, user arrival rate, HTTP sample rate, and completed workflow rate are different quantities. |
| “Peak RSS 136.67 MB is the memory ceiling.” | Soak RSS start/peak/final is **67.64/136.67/51.86 MB**; first/last-quarter means are **111.26/51.41 MB**. | A transient peak followed by reclamation is neither an absolute ceiling nor proof of a leak. |
| “The suggested numbers are an SLA.” | Neither the assignment nor SUT defines a response-time/throughput SLA. | Local measurements support proposed regression gates only; product owners must approve service targets. |

## 4. Proposed same-environment regression gates

| Metric/scope | Proposed rule | Basis |
| --- | --- | --- |
| Business correctness | Fail on any HTTP/business assertion failure. | All accepted samples passed; functional failures must not be averaged away. |
| Stable-stage p95 | Warn above 7.5 ms; fail above 10 ms. | +50%/+100% over worst accepted p95 of 5 ms. |
| Stable-stage p99 | Warn above 9 ms; fail above 12 ms. | +50%/+100% over worst accepted p99 of 6 ms. |
| Load 6 VUs | Fail below 14.44 samples/s. | 10% below observed 16.04. |
| Stress 24 VUs | Fail below 55.99 samples/s. | 10% below observed 62.21. |
| Spike 30-VU burst | Fail below 75.63 samples/s. | 10% below observed 84.03. |
| Soak 30 VUs | Fail below 71.54 samples/s or 17.89 workflows/s. | 10% below observed 79.49 and 19.87. |
| Backend resources | Investigate above 30% Node CPU or 165 MB RSS; do not auto-fail. | Rounded bands above measured 22.3% and 136.67 MB peaks; host and GC dependent. |

These are candidate regression controls, not contractual SLAs. Repeated clean runs are required to estimate natural variance before CI enforcement or re-baselining.

## 5. AI recommendations judged against source

| Recommendation | Classification | Source-grounded judgment |
| --- | --- | --- |
| Wrap FR16 batch inserts in an explicit transaction. | **Feasible; prioritize experiment** | `server.js:209-240` prepares one statement but has no `BEGIN/COMMIT`. A transaction can reduce per-write commit overhead and make the batch atomic; benchmark multi-row imports and rollback behavior. |
| Enable SQLite WAL and `busy_timeout`. | **Feasible experiment, not guaranteed** | `database.js:5` opens one SQLite handle and defines no such PRAGMA. Measure writer contention and checkpoint behavior. |
| Add a non-unique index on `users(email)`. | **Feasible; profile first** | `database.js:50-61` has no email index; `server.js:35` performs equality login lookup. The local dataset has only 82 users and no observed login bottleneck. |
| Add a B-tree index on `products(name)` for current search. | **Hallucinated as a direct fix** | `server.js:144` uses `LIKE '%term%'`; the leading wildcard generally prevents ordinary prefix-index lookup. Examine `EXPLAIN QUERY PLAN`; consider FTS5 or a requirement change. |
| Add another index on `coupons(code)`. | **Hallucinated/redundant** | `database.js:31` already declares `code TEXT UNIQUE`, which creates a uniqueness index. Coupon lookup is not even part of WF-04. |
| Add a conventional database connection pool. | **Hallucinated for current architecture** | Current code uses one in-process SQLite handle, not a client/server database. A PostgreSQL/MySQL-style pool is not a drop-in fix and does not remove SQLite's single-writer constraint. |
| Cache exact product-search responses. | **Unsupported for this workload** | Every iteration imports a unique product then immediately reads it. Hit rate is near zero and invalidation is mandatory for read-after-write correctness. |
| Run clustered Node workers. | **Hallucinated as an immediate fix** | Multiple processes create multiple SQLite handles and may increase writer contention. This is an architectural experiment, not an evidenced fix for these results. |

The first optimization experiment should compare multi-row FR16 imports with and without one explicit transaction, then test WAL/busy-timeout combinations. Query plans and representative data volume must precede index claims.

## 6. Bounded conclusion and review ownership

WF-04 remained stable inside the tested envelope: zero assertion failures, proportional Stress scaling, and Spike recovery to the 3-VU baseline. The accepted endurance result is 30 VUs for 618.94 seconds at 79.49 HTTP samples/s and 19.87 completed workflows/s. It is not 79 workflows/s, production readiness, absolute capacity, or a measured memory ceiling.

For the assignment's human-review requirement, the student must compare these eight corrections with the referenced JTL/JSON and explicitly approve or amend them in `STUDENT_EVIDENCE_REQUIRED.md`. AI cannot truthfully sign that decision.
