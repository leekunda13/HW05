# AI Audit Report - HW05 Task 1

## Declaration

I use AI tools for the following tasks: assignment/SUT analysis, JMeter plan generation, XML audit, smoke and performance-run orchestration, raw JTL analysis, and report drafting. The AI tool was **OpenAI Codex**. Apache JMeter 5.6.3 executed the traffic; SQLite and macOS process tools captured database/resource evidence.

The Codex client did not expose the exact timestamp of the incoming chat message. It was received on `2026-08-31` before the first recorded execution artifact at `17:28:38+07:00`; this limitation is stated instead of inventing a timestamp.

## Original student prompt

```text
hãy làm toàn bộ task 1 của hw5 cho t (có đề nằm trong folder hw5), chọn luồng fr 3 9 16, web nằm trong folder hw04, đọc kĩ đề và làm, không để lại tồn đọng của AI, tạo git local trong folder hw05 và commit (message commit gắn gọn đơn giản)
```

## Interaction and output log

| Recorded time (ICT) | Prompt/instruction stage | AI output and review status |
| --- | --- | --- |
| 2026-08-31 before 17:28 | Read the nine-page assignment, reusable JMeter skill, and actual HW04 source; map FR03/FR09/FR16. | Produced the source-grounded workflow and contract in `audit/phase1_ai_design.md`. Confirmed FR03 auth writes, FR09 fixed-coupon validation, FR16 authenticated import, and an exact search read-after-write check. The earlier document is retained as historical AI output, not current execution status. |
| 2026-08-31 17:28:38-17:29:49 | Install/verify JMeter, create CSV/JMX, and run 1 VU x 1 iteration smoke. | Installed JMeter 5.6.3, generated five JMX files plus 80 synthetic accounts, and produced two successful six-sample smoke logs. The reviewed smoke had 0 errors. |
| 2026-08-31 17:30:23 | Save the first reviewed plan set. | Git commit `d523f16 add test plans`. Output includes exact dated Load/Stress/Spike names, data, generation script, and reusable skill. |
| 2026-08-31 17:31:56 | Audit XML scope and distinct workload/listener configuration. | Found that the initial generator placed shared config under only the first thread group. Moved CSV/header/timer to Test Plan scope and re-smoked successfully. Added the safe official runner in commit `c4c2fe6 fix plan scope`. |
| 2026-08-31 17:32:17-17:35:11 | Execute Load and classify failures. | Attempt 1 became 99.74% errors because the SUT's asynchronous destructive initializer removed performance accounts after the HTTP port opened. AI correctly excluded it, retained raw evidence under `evidence/inconclusive`, and added a three-check stable database readiness gate in commit `e139682 fix database readiness`. |
| 2026-08-31 17:35:22-17:43:42 | Run official Load, Stress, and Spike from clean database states. | Generated three full JTL logs, three HTML dashboards, run logs, exact PID/timestamp metadata, per-second backend CPU/RSS logs, and DB pre/post snapshots. All official samples passed. |
| 2026-08-31 17:44:43 | Select the endurance load from observed evidence. | Replaced the arbitrary 6-VU soak draft with 30 VUs because the real 30-VU spike completed with zero errors. Commit: `6b16cff tune soak load`. |
| 2026-08-31 17:44:50-17:57:45 | Run and audit soak state isolation. | First ten-minute soak had 0 JMeter errors but deterministic DB counts proved unrelated traffic reached shared port 3000. AI retained and excluded the run, configured an isolated temporary runtime on port 3001 without editing HW04 source, and committed `79a379d isolate soak run`. |
| 2026-08-31 17:57:45-18:07:48 | Rerun the same 30-VU/10-minute soak in isolation and generate final reports. | The clean run produced 49,322 samples, 0 errors, p95 5 ms, 82.29 samples/s, peak CPU 38.7%, and peak RSS 140.47 MB. Product delta matched 8,213 successful FR16 samples exactly and coupon usage remained zero. |

## AI mistakes and corrections

| AI mistake/incompleteness | Evidence | Correction | Likely cause |
| --- | --- | --- | --- |
| Shared CSV/header/timer scoped only to the first group in multi-stage plans. | XML tree audit after smoke. | Place all shared config directly under the Test Plan, before every Thread Group; validate with `xmllint` and smoke again. | A single-thread smoke could not exercise later thread groups; the generator optimized reuse without checking JMeter scope semantics. |
| HTTP readiness was treated as database readiness. | Inconclusive Load attempt: pre-state briefly had 82 users, then the DB fell back to 2; raw responses became 404/401/403. | Wait for canonical counts of 2 users, 5 products, and 4 coupons to remain stable for three checks, then seed and verify 80 accounts. | `database.js` queues DROP/CREATE/seed work asynchronously while `app.listen()` becomes reachable. |
| Initial soak reused 6 VUs without empirical justification. | Valid Spike sustained 30 VUs with 0 errors. | Use 30 VUs for ten minutes and label the result as the highest stable load observed, not an absolute hardware limit. | The first choice copied the ordinary-load level instead of waiting for baseline evidence. |
| First soak used the shared port and allowed unrelated local traffic. | Product delta exceeded successful FR16 samples by 46 and two unexpected coupon-usage rows appeared, although the JTL contained no usage request. | Preserve the run as inconclusive and rerun on an isolated runtime/DB at port 3001. | Process isolation was incomplete even though database reset logic was correct. |
| Raw sample throughput could be mistaken for completed workflow throughput. | The plan emits six HTTP samples per full journey. | Report both sample/s and the derived approximate workflow/s; do not label either as an approved SLA. | JMeter's default summary emphasizes sampler throughput rather than business-journey completion. |

## Integrity boundary

The JTL files, HTML dashboards, process samples, timestamps, database snapshots, and Git history were created by real commands in this workspace. The agent did **not** create or imitate Activity Monitor screenshots, a hardware screenshot, a Vietnamese voice recording, a YouTube URL, a GitHub Issue, group-uniqueness evidence, or a student's human-approval statement. Those student-owned items are listed once in `STUDENT_EVIDENCE_REQUIRED.md`.

The human-review decision remains attributable only after the student reads the final JMX/report and confirms it. This audit records AI self-corrections but does not mislabel them as student review.
