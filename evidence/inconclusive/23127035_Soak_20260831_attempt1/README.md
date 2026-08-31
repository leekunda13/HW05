# Inconclusive Soak attempt 1

- Start/end: `2026-08-31T17:44:50+0700` to `2026-08-31T17:54:54+0700`
- JMeter result: 49,240 samples, zero failed samples
- Result: **Inconclusive - excluded from official endurance metrics**

The clean pre-state had 5 products and 0 coupon-usage rows. The JTL recorded 8,197 successful FR16 imports and did not contain `/api/coupon-usage`, so the deterministic post-state should have been 8,202 products and 0 coupon-usage rows. The actual database had 8,248 products and two coupon-usage rows for the default user, both timestamped `2026-08-31 10:48:12` UTC. This proves that traffic outside the JMeter plan reached the shared port 3000 during the measurement.

The raw JTL, HTML report, resource samples, logs, and state snapshots are retained unchanged here. The correction is to rerun the same reviewed 30-VU/10-minute JMX against an isolated temporary copy of the unchanged HW04 backend on port 3001. The final report uses only the clean rerun whose product delta exactly matches successful FR16 samples and whose coupon-usage count remains zero.
