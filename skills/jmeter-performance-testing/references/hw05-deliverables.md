# HW05 Deliverables and Evidence Checklist

Read this reference when planning work, reviewing completeness, writing reports, or packaging the submission.

## Test Design and Execution

- [ ] One non-duplicated group workflow confirmed by the student.
- [ ] Three JMX files named `{StudentID}_{Load|Stress|Spike}_{YYYYMMDD}.jmx`.
- [ ] All three plans exercise the same auth-heavy, read-heavy, and transactional journey.
- [ ] Requests are data-driven by one or more CSV files.
- [ ] Realistic think-time, ramp-up, users/threads, duration, rationale, and stop conditions are documented.
- [ ] Three distinct JMeter listener/report types; no type repeated.
- [ ] Human review records AI mistakes, corrections, evidence, and likely causes.
- [ ] Three real non-GUI executions with full raw `.jtl` files.
- [ ] Three HTML report folders.
- [ ] Each run has a real screenshot/frame showing the test tool and backend resource monitor together.
- [ ] Account-lockout reset is documented if it occurred.
- [ ] A real 10-15 minute soak run supports concrete stable RPS and memory-ceiling conclusions.
- [ ] Hardware screenshot and spec table include the same hostname used in prior deployment evidence.
- [ ] Genuine issues, if found, are filed on GitHub with real screenshots.

## Analysis and Proposal

- [ ] AI analysis is retained as AI output, followed by a distinct human review.
- [ ] Every identified AI misinterpretation cites a correct value from the raw JTL.
- [ ] Optimizations are classified feasible or hallucinated using EShop source evidence.
- [ ] Continuous-testing proposal watches commits, decides whether to run, and flags p95 regressions.
- [ ] Proposal includes a flow chart and cost/false-alarm trade-offs.
- [ ] AI critique is one 200-300 word paragraph addressing error/incompleteness, cause, and learned collaboration principle.
- [ ] AI Audit records tool, date/time, prompt, and output for each interaction.

## Student-Owned Evidence

The skill must never fabricate or simulate these anti-cheat artifacts:

- exact final test-plan filenames;
- full raw JTL logs;
- demo recording with the student's Vietnamese narration and tool/resource monitor in the same frame;
- hardware report and matching hostname;
- Git commits or timestamps claimed as past work.

The main demo must be at least 6 minutes total. The separate Agent Skill demo must show an end-to-end use of this skill on a complete endpoint group and include its YouTube link.

## Submission Package

- [ ] Main report in Markdown and PDF, including performance report and AI critique.
- [ ] Public GitHub repository link with plans and data.
- [ ] Three named test plans, three full JTL logs, and three HTML report folders.
- [ ] Resource-monitor and hardware-spec screenshots.
- [ ] Unlisted main demo link and Agent Skill demo link.
- [ ] AI Critique and AI Audit Report in Markdown and PDF.
- [ ] Text Git commit log.
- [ ] Bug/performance issue report and screenshots, if applicable.
- [ ] README with self-assessment, scenarios, endpoint groups, numerical endurance threshold, issue count, and demo link.
- [ ] ZIP named `<StudentID>_HW05_AI_Performance_<000-100>.zip`.

Missing a required document results in zero according to the assignment. Leave conspicuous placeholders for unfinished human evidence rather than inventing values.
