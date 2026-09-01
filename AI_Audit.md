# AI Audit Report - HW05 Tasks 1-2

## Declaration

I use **OpenAI Codex** for assignment/SUT analysis, JMeter generation and review, run orchestration, raw JTL analysis, workflow correction, misinterpretation review preparation, optimization classification, and report drafting. Apache JMeter 5.6.3 generated real traffic; SQLite and macOS process tools captured database and resource evidence.

AI did not create screenshots, narration, YouTube links, group records, or a student's approval statement.

## Student prompts

```text
hãy làm toàn bộ task 1 của hw5 cho t (có đề nằm trong folder hw5), chọn luồng fr 3 9 16, web nằm trong folder hw04, đọc kĩ đề và làm, không để lại tồn đọng của AI, tạo git local trong folder hw05 và commit (message commit gắn gọn đơn giản)
```

```text
thực hiện tiếp task 2 của hw05
```

```text
t nghĩ cần điều chỉnh lại luồng, vì luồng hiênj tại của t ko phù hợp làm 1 workflow end-to-end, đây là luồng các bạn trong team t chọn: WF-01: Login → Product → Server Cart → Checkout; WF-02: Login → Product → Coupon → Checkout → Coupon Usage; WF-03: Login → Product → Checkout → Cancel Order
```

## Chronological interaction log

| Recorded time (ICT) | Prompt/instruction stage | AI output and review status |
| --- | --- | --- |
| 2026-08-31 before 17:28 | Read assignment and source; map requested FR03/FR09/FR16. | Generated the original chain and plans. Later student review correctly identified that the chain lacked one coherent business goal. |
| 2026-08-31 17:28-18:07 | Smoke, correct JMeter scope/readiness/isolation errors, then run Load/Stress/Spike/Soak. | Produced real but subsequently superseded evidence. Git history retains it; it is excluded from the WF-04 baseline. |
| 2026-09-01 09:52 | Perform Task 2 analysis. | Retained an AI first pass, recalculated metrics, and separated regression gates from SLA claims. This analysis was later regenerated after the workflow changed. |
| 2026-09-01 before 17:28 | Review the three team workflows and choose a non-duplicated coherent flow. | Replaced the unrelated chain with **WF-04 Admin Login -> Import Product CSV -> Search Imported Product -> View Product Detail**. The choice is distinct from the three workflows supplied and covers auth-heavy, write-heavy, and read-heavy groups. |
| 2026-09-01 17:28:50 | Run one WF-04 Smoke iteration. | Four samples passed; JWT/role and product ID were correlated; products increased 5 -> 6. |
| 2026-09-01 17:29:25-17:37:11 | Run WF-04 Load, Stress, and Spike on isolated port 3001. | Load 1,912, Stress 6,514, and Spike 3,216 samples; all had 0 failed assertions. Spike burst reached 84.03 samples/s and recovered to the 3-VU baseline. |
| 2026-09-01 17:37:48-17:49:04 | Run duration-scheduled WF-04 Soak and audit timestamps. | Excluded the attempt: JTL traffic covered 305.20 seconds while the host wall clock advanced roughly six minutes and ended the scheduler early. All raw evidence remains in `evidence/inconclusive`. |
| 2026-09-01 18:11:36-18:21:59 | Rerun Soak with 410 iterations per thread. | Accepted 49,200 samples and exactly 12,300 workflows over 618.94 JTL seconds, 0 errors, p95 4 ms, 79.49 samples/s, 19.87 workflows/s, peak CPU 22.3%, and peak RSS 136.67 MB. |
| 2026-09-01 after 18:21 | Re-run Task 2 analysis and rebuild the submission. | Updated the first-pass AI output, eight raw-log corrections, optimization judgments, reports, verification scripts, filenames, PDFs, and Git history for WF-04 only. |

## AI mistakes and corrections

| AI mistake/incompleteness | Evidence | Correction | Likely cause |
| --- | --- | --- | --- |
| Accepted FR03 -> FR09 -> FR16 as end-to-end. | The actions serve unrelated password recovery, coupon validation, and admin import goals. | Replace with one admin publishing journey ending in correlated product detail. | The AI optimized endpoint coverage instead of business coherence. |
| Used the original date in regenerated filenames. | New runs occurred on 2026-09-01. | Rename all primary plans/results/reports to `20260901`; raw JTL contents remain unchanged. | Reuse of prior generator constants. |
| Assumed a 600-second scheduler guaranteed ten minutes of traffic. | Excluded attempt: 305.20 JTL seconds, 303 resource observations, but 676 wall-clock seconds after a clock jump. | Use 410 iterations/thread; accept only the 618.94-second, 12,300-workflow rerun. | Scheduler behavior depended on wall-clock continuity. |
| Called HTTP sample throughput workflow throughput. | Soak has 79.49 samples/s and 19.87 exact workflows/s. | Count successful final FR06 samplers. | JMeter summaries foreground sampler rate. |
| Compared complete Stress and Spike averages. | Stress 24-VU stage is 62.21 samples/s; Spike burst is 84.03. | Compare equivalent stage windows. | Aggregate summaries hide workload shape. |
| Promoted the 1,151 ms max and 136.67 MB RSS peak to system properties. | Soak p95/p99 are 4/6 ms; RSS ends at 51.86 MB. | Keep max/peak as observations, not tail failure, leak, or ceiling. | Generic labels were applied without distribution/time-series review. |
| Proposed generic indexes and pooling. | Leading-wildcard search, existing coupon uniqueness index, and one SQLite handle. | Classify recommendations against exact query/schema/architecture. | Familiar database advice was reused without source inspection. |

## Integrity boundary

Accepted JTLs, HTML reports, resource logs, database snapshots, and commits were produced by real commands. The excluded Soak attempt remains visible rather than being silently discarded. Final human approval remains attributable only to the student after reading the raw-log corrections.
