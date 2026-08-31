# Inconclusive Load attempt 1

- Start: `2026-08-31T17:32:17+0700`
- Result: **Inconclusive - excluded from official metrics**
- Symptom: the database contained 82 users immediately before JMeter started, but fell back to the two canonical users while traffic was running. The raw log therefore contains 404 forgot-password responses, followed by invalid correlation and 401/403 responses.
- Root cause: `backend/database.js` queues destructive DROP/CREATE/seed statements asynchronously. `app.listen()` and the HTTP health endpoint became available before that queue had completely settled, so the external performance-account seed raced with the SUT initializer and was later removed.
- Correction: the runner now requires the canonical state `2 users | 5 products | 4 coupons` to remain stable for three checks, then seeds and verifies exactly 80 admin performance accounts before JMeter starts.
- Integrity: the raw JTL, HTML report, resource log, database snapshots, and JMeter logs from this attempt are retained unchanged under this directory. They are not used in the Task 1 summary.
