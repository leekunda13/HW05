# Task 3 - Continuous Performance Testing Proposal

## 1. Objective and operating boundary

The proposed pipeline detects performance regressions early without running every expensive profile on every commit. It treats the current WF-04 results as a candidate same-environment baseline, not an SLA. Comparisons are valid only when the SUT revision, JMX/data versions, database seed, Node/JMeter versions, timers, and runner fingerprint are recorded. A result from different hardware is evidence for that host, not a direct regression comparison.

## 2. Commit-aware trigger policy

| Trigger or changed path | Automatic action | Reason |
| --- | --- | --- |
| Documentation or frontend-only change | Record a skip decision | Avoid cost when no backend performance path changed. |
| Backend route, authentication, validation, or middleware | Smoke, then Load | Detect functional failure first; measure the normal journey on each relevant pull request. |
| Database schema, SQL, import, dependency, or JMeter/data change | Smoke, Load, then Stress | These changes can alter write contention, query cost, or the measurement itself. |
| Nightly main branch | Smoke, Load, Stress, and Spike | Catches interactions between merged changes while keeping PR feedback short. |
| Weekly or release candidate | Smoke, all three profiles, then 10-15 minute Soak | Revalidates sustained behavior, resource growth, and the release baseline. |
| Manual performance label | Reviewer-selected profiles | Supports investigation without weakening the standard schedule. |

The path filter is advisory, not authoritative. A maintainer can promote a run when a small-looking change affects a shared dependency, startup behavior, or database state.

## 3. Flow chart

![Commit-aware continuous performance pipeline](assets/task3_continuous_performance_flow.svg)

The smoke gate must pass all HTTP and business assertions before load is applied. A failing smoke archives its log and stops, because performance numbers from a functionally incorrect workflow are meaningless. The runner then restores the canonical database, seeds the 80 accounts, pins the same JMX/CSV versions, starts the isolated backend, and records the commit SHA, dataset/JMX hashes, hostname, CPU/RAM/OS, Node/JMeter versions, PID, and timestamps.

## 4. Metrics and regression decision

Every performance job stores the complete JTL, HTML report, backend log, resource CSV, database pre/post state, and run metadata. The analyser calculates overall and per-sampler p95/p99, assertion failures, sample throughput, exact completed workflows, and resource peaks. Workflow throughput is the successful final FR06 count divided by the JTL window; it is not JMeter HTTP samples/s.

The current Task 2 numbers remain bootstrap candidate gates:

| Scope | Candidate decision |
| --- | --- |
| Functional correctness | Fail immediately on any HTTP/business assertion failure. |
| Selected gated-scope p95 | Warn above 7.5 ms; fail above 10 ms after a clean confirmation run. |
| Selected gated-scope p99 | Warn above 9 ms; fail above 12 ms after confirmation. |
| Load 6 VUs | Investigate/fail below 14.34 samples/s when the repeated run confirms it. |
| Stress 24 VUs | Investigate/fail below 55.87 samples/s. |
| Spike 30-VU burst | Investigate/fail below 74.74 samples/s and verify recovery against the 3-VU baseline. |
| Soak 30 VUs | Investigate/fail below 72.14 samples/s or 18.04 completed workflows/s. |
| Backend resources | Investigate above 35% Node CPU or 170 MB RSS; do not auto-fail on a single peak. |

Before enforcement, run at least three clean baselines on the pinned runner and use their median plus observed spread. A candidate p95 regression requires both a relative increase of at least 20% and an absolute increase of at least 2 ms, or it crosses the approved 10 ms hard band. The dual condition prevents a quantized move from 4 to 5 ms being treated as a serious regression merely because it is 25%. A candidate is repeated once from a clean state. Persistent failure flags the commit and can block release; a non-repeating result is quarantined for human review rather than silently changing the baseline.

Only a human reviewer may approve a new versioned baseline after explaining the intended source change. The pipeline never learns a slower result automatically, because that would normalize regressions.

## 5. Cost and false-alarm trade-offs

| Trade-off | Risk | Control |
| --- | --- | --- |
| Execution cost and feedback time | All profiles on every commit consume runner time and delay pull requests. | Run Smoke + Load only for relevant PRs; move Stress/Spike nightly and Soak weekly/release. |
| Noisy neighbours | Other processes can change CPU scheduling, I/O, and latency. | Use a dedicated/pinned host, reject runs with unexpected load, and repeat a suspected regression once. |
| Data drift | A growing SQLite file or recycled accounts can change query/write cost. | Restore the versioned seed and verify pre/post counts for every run. |
| False alarms from small latency values | A 1 ms change can be a large percentage when p95 is 4-5 ms. | Require both relative and absolute deltas, plus a confirmation run. |
| False negatives from broad aggregates | Overall throughput can hide a slow sampler or partial iteration. | Compare per-sampler percentiles and exact final-sampler workflow completions. |
| Hardware/version drift | Different host, Node, JMeter, or OS versions invalidate a direct baseline comparison. | Version the environment fingerprint and compare only like-for-like runs. |
| Baseline ownership | Automatic re-baselining can convert regressions into normal behavior. | Require a named human reviewer and retain both old and new baseline artifacts. |
| Artifact storage | Full JTL/HTML/resource evidence grows over time. | Keep all release failures; use retention rules for passing PR runs while preserving summaries and hashes. |

## 6. Outcome

This model gives fast PR feedback, broader nightly coverage, and sustained release evidence while keeping every decision traceable to raw data. It flags p95 regressions without confusing samples/s with workflows/s, controls false alarms through repeat confirmation and environment matching, and keeps threshold/baseline ownership with the student or project reviewer.
