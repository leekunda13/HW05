# HW05 Task 2 - AI Analysis and Misinterpretation Hunt

**Student ID:** 23127035<br>
**Run/analysis date:** 2026-09-03<br>
**Workflow:** WF-04 - Admin Login -> Import Product CSV -> Search Imported Product -> View Product Detail<br>
**AI tool:** OpenAI Codex

## 1. Method and evidence boundary

The unreviewed AI response from the earlier baseline is retained unchanged in `audit/task2_first_pass_ai_analysis.md`. The correction below is reproduced from the four accepted `20260903` JTL files by `scripts/analyze_task2.py`; machine-readable output is `analysis/task2_metrics.json`.

Percentiles use nearest rank over JMeter `elapsed`. A row fails when JMeter `success` is not `true`, so business-assertion failures count even for HTTP 2xx. A workflow completes only when the successful final sampler `FR06 View imported product detail` exists. This is stricter than dividing samples by four because scheduled Load/Stress/Spike shutdown can leave partial iterations.

The technical review is complete but is not labelled as the student's human review until the student checks and approves or amends it.

## 2. Authoritative raw-log summary

| Scenario | HTTP samples | Failed | p95 ms | p99 ms | Max ms | Samples/s | Completed workflows | Workflows/s |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Load | 1,902 | 0 | 5 | 6 | 22 | 15.93 | 474 | 3.97 |
| Stress | 6,489 | 0 | 5 | 6 | 23 | 36.19 | 1,606 | 8.96 |
| Spike | 3,208 | 0 | 5 | 6 | 20 | 26.91 | 788 | 6.61 |
| Soak | 49,200 | 0 | 4 | 6 | 33 | 80.15 | 12,300 | 20.04 |

Raw sources are `results/23127035_{Load,Stress,Spike,Soak}_20260903.jtl`. Overall, stage, sampler, and resource details are in `analysis/task2_metrics.md`.

## 3. Misinterpretation hunt

| First-pass AI statement | Correct raw value | Why it is wrong |
| --- | --- | --- |
| “Soak sustained 79.49 workflows/s.” | The accepted rerun sustained **80.15 HTTP samples/s**, exactly **12,300** final samplers and **20.04 completed workflows/s** over 613.82 s. | JMeter's default rate counts HTTP samplers, not business journeys. |
| “Stress achieved 36.33 requests/s,” used as its peak. | Whole Stress is 36.19 samples/s, but the **24-VU stage is 62.08 samples/s**, p95 4 ms, 0 failures. | The whole value averages 6-, 12-, and 24-VU windows. |
| “Spike is slower than Stress, so the burst degraded throughput.” | The **30-VU burst reached 83.04 samples/s**, p95 5 ms; 26.91 is the whole test including two 3-VU periods. | Different workload windows are not comparable peak stages. |
| “Spike did not recover.” | Recovery was **8.66 samples/s, p95 5 ms**, versus baseline **8.06 samples/s, p95 7 ms**. | Recovery must be compared with the same 3-VU baseline, not the burst or whole-run average. |
| “The 1,151 ms maximum proves a tail-latency failure.” | The accepted rerun's maximum is **33 ms**, with p95 **4 ms** and p99 **6 ms** across 49,200 samples. | A maximum is not a percentile and the current accepted raw log does not contain the claimed 1,151 ms value. |
| “0% errors proves production capacity at 79 users/s.” | Evidence proves **30 VUs**, 0 failures, 80.15 samples/s, and 20.04 workflows/s. No stage reached collapse. | VUs, user arrival rate, HTTP sample rate, and completed workflow rate are different quantities. |
| “Peak RSS 136.67 MB is the memory ceiling.” | Soak RSS start/peak/final is **66.59/138.95/69.39 MB**; first/last-quarter means are **99.05/77.05 MB**. | A transient peak followed by reclamation is neither an absolute ceiling nor proof of a leak. |
| “The suggested numbers are an SLA.” | Neither the assignment nor SUT defines a response-time/throughput SLA. | Local measurements support proposed regression gates only; product owners must approve service targets. |

## 4. Proposed same-environment regression gates

| Metric/scope | Proposed rule | Basis |
| --- | --- | --- |
| Business correctness | Fail on any HTTP/business assertion failure. | All accepted samples passed; functional failures must not be averaged away. |
| Selected gated-scope p95 | Warn above 7.5 ms; fail above 10 ms. | +50%/+100% over the worst p95 (5 ms) across Load, Stress 24 VUs, Spike burst, and Soak. |
| Selected gated-scope p99 | Warn above 9 ms; fail above 12 ms. | +50%/+100% over the worst p99 (6 ms) across those four gated scopes. |
| Load 6 VUs | Fail below 14.34 samples/s. | 10% below observed 15.93. |
| Stress 24 VUs | Fail below 55.87 samples/s. | 10% below observed 62.08. |
| Spike 30-VU burst | Fail below 74.74 samples/s. | 10% below observed 83.04. |
| Soak 30 VUs | Fail below 72.14 samples/s or 18.04 workflows/s. | 10% below observed 80.15 and 20.04. |
| Backend resources | Investigate above 35% Node CPU or 170 MB RSS; do not auto-fail. | Rounded bands above measured 28.2% and 138.95 MB peaks; host and GC dependent. |

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

WF-04 remained stable inside the tested envelope: zero assertion failures, proportional Stress scaling, and Spike recovery to the 3-VU baseline. The accepted endurance result is 30 VUs for 613.82 seconds at 80.15 HTTP samples/s and 20.04 completed workflows/s. It is not 80 workflows/s, production readiness, absolute capacity, or a measured memory ceiling.

For the assignment's human-review requirement, the student must compare these eight corrections with the referenced JTL/JSON and explicitly approve or amend them in `STUDENT_EVIDENCE_REQUIRED.md`. AI cannot truthfully sign that decision.
