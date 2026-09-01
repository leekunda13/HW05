# HW05 Task 2 - AI Analysis and Misinterpretation Hunt

**Student ID:** 23127035  
**Run data:** 2026-08-31  
**Analysis date:** 2026-09-01  
**Workflow:** FR03 - FR09 - FR16  
**AI tool:** OpenAI Codex

## 1. Method and evidence boundary

The retained first-pass AI response is in `audit/task2_first_pass_ai_analysis.md`. It was generated before source and metric review and is intentionally not silently rewritten. The correction below was reproduced directly from the four accepted JTL files by `scripts/analyze_task2.py`; its machine-readable output is `analysis/task2_metrics.json`.

JMeter `elapsed` is used for response-time percentiles, with nearest-rank p90/p95/p99. A JTL row is failed when its `success` field is not `true`, so assertion failures are included even if the HTTP status is 2xx. A completed business workflow is counted only when the successful final sampler `READ Verify imported product` exists. This is stricter than dividing all HTTP samples by six because ramp-up and test shutdown can leave partial iterations.

The review is technically complete and ready for the student's decision. It is not labelled as the student's human review until the student reads the cited JTL evidence and approves or amends it.

## 2. Authoritative result summary

| Scenario | HTTP samples | Failed | Error % | p95 ms | p99 ms | Max ms | Samples/s | Completed workflows | Completed workflows/s |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Load | 1,896 | 0 | 0.00 | 5 | 6 | 24 | 15.88 | 315 | 2.64 |
| Stress | 6,476 | 0 | 0.00 | 5 | 6 | 32 | 36.11 | 1,062 | 5.92 |
| Spike | 3,180 | 0 | 0.00 | 5 | 7 | 30 | 26.69 | 513 | 4.30 |
| Soak | 49,322 | 0 | 0.00 | 5 | 6 | 222 | 82.29 | 8,207 | 13.69 |

The raw source paths are `results/23127035_{Load,Stress,Spike,Soak}_20260831.jtl`. The full overall, stage, sampler, and backend-resource extraction is in `analysis/task2_metrics.md`.

## 3. Misinterpretation hunt and corrections

| First-pass AI statement | Correct raw value | Why the statement is wrong |
| --- | --- | --- |
| “The soak sustained 82.29 workflows/s.” | Soak has **82.29 HTTP samples/s**, **8,207** successful final samplers, and **13.69 completed workflows/s** over the overall window. | JMeter reports sampler throughput. Each normal journey has six requests, and partial iterations make `samples / 6` only approximate. The final sampler count is the exact completion count. |
| “Stress achieved 36.11 requests/s,” used as its peak level. | Stress overall is **36.11 samples/s**, but the 24-VU stage is **61.87 samples/s**, p95 **5 ms**, 0 failures. | An overall value averages three different concurrency windows. Peak-stage behavior must be assessed within the stage boundary. |
| “Spike fell below Stress, so the burst reduced throughput.” | The 30-VU burst reached **82.96 samples/s**, p95 **5 ms**; the complete Spike average is **26.69** because it includes two 3-VU windows. | Comparing whole-test averages with different workload shapes confounds low-load baseline/recovery with the burst. |
| “The 222 ms maximum proves a tail-latency problem.” | Soak maximum is **222 ms**, but overall p95 is **5 ms** and p99 is **6 ms** across **49,322** samples. | One maximum is an outlier, not a percentile or evidence of a systematic tail problem. It is worth retaining, but not substituting for distribution metrics. |
| “0% errors proves capacity at 82 users/s and production readiness.” | The run proved **30 VUs for 600 s**, 0 failures, 82.29 samples/s, and 13.69 completed workflows/s. No tested stage reached collapse. | Error-free execution establishes a baseline inside the tested envelope, not an absolute user-arrival capacity, saturation point, or production SLA. |
| “Peak RSS 140.47 MB is the memory ceiling.” | Soak RSS started **66.64 MB**, peaked **140.47 MB**, ended **78.50 MB**; first/last-quarter means were **118.45/73.73 MB**. | A transient peak is not a ceiling and the final/quarter values show reclamation. A longer controlled run and heap/GC telemetry are needed for a leak or ceiling claim. |
| “CPU 38.7% means 61.3% whole-machine headroom.” | **38.7%** is the peak macOS percentage for the Node PID and is not normalized across the ten cores. | Process CPU semantics and unmeasured competing load prevent converting it directly into whole-system headroom. |
| “The suggested values can be treated as an SLA.” | The assignment/SUT provides no response-time or throughput SLA. | A measured local baseline can support provisional regression gates only after controlling hardware, source, data, timers, and measurement windows. Product owners must approve an SLA. |

## 4. Evidence-derived threshold proposal

These values are proposed **same-environment regression gates**, not contractual SLAs. Compare only the same workflow, timers, seed state, source configuration, JMeter version, and host class. Re-baselining requires a documented reason and human approval.

| Metric/scope | Proposed warning/fail rule | Evidence and intent |
| --- | --- | --- |
| Business smoke correctness | Fail on any failed HTTP/business assertion. | Accepted baseline had 0 failures in every scenario; correctness errors must not be averaged away. |
| Stable-stage p95 | Warn above 7.5 ms; fail above 10 ms. | Observed scenario p95 was 5 ms; gates flag +50% and +100% regressions, rather than claiming a user SLA. |
| Stable-stage p99 | Warn above 10.5 ms; fail above 14 ms. | Worst observed scenario p99 was 7 ms; same proportional bands. |
| Load 6-VU throughput | Fail below 14.29 samples/s. | 10% below observed 15.88 samples/s. |
| Stress 24-VU throughput | Fail below 55.68 samples/s. | 10% below observed stage rate 61.87 samples/s. |
| Spike 30-VU burst throughput | Fail below 74.66 samples/s. | 10% below observed burst rate 82.96 samples/s. |
| Soak 30-VU throughput | Fail below 74.06 samples/s or 12.32 completed workflows/s. | 10% below 82.29 samples/s and 13.69 exact-completion rate. |
| Backend resources | Investigate above 50% Node CPU or 170 MB RSS. Do not auto-fail. | Rounded observability bands above measured 38.7% and 140.47 MB peaks; resource semantics vary by host and GC timing. |

The 10% throughput floor and 50%/100% latency bands are policy choices proposed for sensitivity. They require repeated clean runs to estimate normal variance before becoming CI gates.

## 5. AI optimization recommendations judged against source

| Recommendation | Classification | Source-grounded judgment |
| --- | --- | --- |
| Wrap all FR16 import inserts in one explicit transaction. | **Feasible; prioritize experiment** | `server.js:209-240` prepares one statement and runs all rows but has no `BEGIN/COMMIT`. A transaction can reduce per-write commit overhead and make a batch atomic. Validate error/rollback behavior and benchmark multi-row imports. |
| Enable SQLite WAL and set `busy_timeout`. | **Feasible experiment, not guaranteed** | `database.js:5` opens one `sqlite3.Database`; no WAL or busy-timeout PRAGMA exists. WAL can improve read/write overlap, but writer contention, checkpointing, and deployment filesystem behavior must be measured. |
| Add a non-unique index on `users(email)`. | **Feasible; profile first** | `database.js:50-61` defines no email index, while `server.js:35` and `:70` perform equality lookups. The test database has only 82 users, and no latency bottleneck was observed. A unique index would additionally change current duplicate-email behavior. |
| Add a B-tree index on `products(name)` for current search. | **Hallucinated as a direct fix** | `server.js:144` uses `LIKE '%${searchQuery}%'`. The leading wildcard generally prevents ordinary B-tree prefix lookup. Use `EXPLAIN QUERY PLAN`; FTS5 or a product requirement permitting prefix search would be architectural alternatives. |
| Add an index on `coupons(code)`. | **Hallucinated/redundant** | `database.js:31` already declares `code TEXT UNIQUE`, for which SQLite creates a uniqueness index; the lookup at `server.js:370` already benefits from it. |
| Add a conventional database connection pool. | **Hallucinated for current architecture** | The app uses one in-process SQLite handle at `database.js:5`, not a client/server database. A PostgreSQL/MySQL-style pool is not a drop-in SQLite optimization and does not remove SQLite's single-writer constraint. |
| Cache exact product-search responses. | **Unsupported for this workload** | Each iteration imports a unique product and immediately verifies it. Expected hit rate is low and invalidation is required for read-after-write correctness. No raw metric identifies search as the bottleneck. |
| Run multiple clustered Node workers. | **Hallucinated as an immediate fix** | Multiple processes would open multiple SQLite handles and may increase write contention. It is a migration experiment requiring shared state, auth, database, and benchmark design, not an evidenced remedy for these results. |

The first experiment should therefore be a multi-row FR16 benchmark comparing explicit transaction versus current behavior, followed by WAL/busy-timeout combinations. Index changes should be justified by query plans and representative data volume, not by generic database advice.

## 6. Bounded conclusion and student decision

The accepted evidence shows stable behavior within the tested local envelope: zero JMeter/business-assertion failures, scenario p95 of 5 ms, proportional Stress scaling, and Spike recovery to the 3-VU baseline. The authoritative endurance result is 30 VUs for ten minutes at 82.29 HTTP samples/s and 13.69 completed workflows/s, not 82 workflows/s or an absolute capacity. No measured run establishes production readiness, a memory ceiling, or a formal SLA.

For the mandatory human-review requirement, the student must compare at least the eight corrections above with the referenced raw JTL/JSON and record approval or amendments in `STUDENT_EVIDENCE_REQUIRED.md`. AI cannot truthfully sign that decision on the student's behalf.
