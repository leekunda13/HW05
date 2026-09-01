# Inconclusive WF-04 Soak Attempt - Clock Discontinuity

This 30-VU attempt was excluded even though all 24,528 HTTP samples passed. JMeter traffic spans only 305.20 seconds, while the external run metadata spans 676 seconds and the resource monitor contains 303 one-second observations. The host wall clock advanced by roughly six minutes during execution, so the scheduler reached its nominal end time after only about five minutes of real traffic.

The raw JTL, HTML dashboard, backend/resource logs, metadata, and database snapshots are retained here. The accepted rerun replaces the duration-based scheduler with 410 iterations per thread (12,300 intended completed workflows), which makes completion depend on performed work rather than the adjusted wall clock. This run must not be used for the endurance conclusion.
