# HW05 WF-04 - Agent Skill Prompt Sequence

Use these staged prompts with the `jmeter-performance-testing` skill. WF-04 is distinct from the three team workflows supplied by the student and has one coherent goal: publish a product and verify it in the catalogue.

## Prompt 1 - Analyse and design

```text
Use $jmeter-performance-testing to inspect the HW05 assignment and
the real EShop source. Design this same workflow for all scenarios:

WF-04: POST /api/login as admin
  -> POST /api/admin/import-products with the JWT
  -> GET /api/products?search=<unique imported name>
  -> GET /api/products/<correlated product ID>

Map it to auth-heavy, transactional/write-heavy, and read-heavy groups.
Specify CSV fields, correlation, business assertions, state reset,
think time, and stop conditions. Do not run tests or fabricate evidence.
```

## Prompt 2 - Generate and smoke

```text
Generate data-driven JMeter plans for student 23127035 using the real
execution date. Use 80 independent synthetic admin accounts. Extract and
assert JWT/user ID/admin role, create a runtime-unique product, assert one
successful import, correlate exactly one matching product ID, and verify
ID/name/price at the detail endpoint. Put CSV, JSON headers, and the
200-500 ms timer at Test Plan scope. Run 1 VU x 1 iteration Smoke and stop
if any HTTP or business assertion fails.
```

## Prompt 3 - Audit plans

```text
Audit Load, Stress, and Spike XML before execution. Confirm the same four
WF-04 requests and correlation in every thread group; distinct workload
shapes and listeners; sufficient CSV rows; disabled View Results Tree in
non-GUI mode; raw JTL fields; clean DB preconditions; and an isolated
backend port. Record every AI error, correction, evidence, and likely cause.
```

## Prompt 4 - Execute and analyse

```text
Run Load, Stress, Spike, then a 10-15 minute Soak from clean isolated
database states. Preserve full JTL, HTML, backend PID/resource CSV, and DB
pre/post counts. Reject any contaminated or prematurely ended run. Count
completed workflows using the successful final FR06 sampler, not sample/4.
Separate observed baselines, proposed regression gates, and approved SLAs.
Classify optimization suggestions against the real Express/SQLite source.
```

## Student-owned evidence

The student must personally capture the tool and resource monitor in the same frame, record Vietnamese narration, supply the hardware screenshot and hostname match, confirm the team allocation, publish the repository/video links, and approve the human review. AI must not imitate these artifacts.
