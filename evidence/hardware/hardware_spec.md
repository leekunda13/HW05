# Hardware specification

Captured from the actual execution host on `2026-08-31` (Asia/Ho_Chi_Minh). Sensitive hardware identifiers are intentionally excluded.

| Field | Observed value |
| --- | --- |
| Hostname | `MacBook-Air-cua-KunDa.local` |
| Computer name | `MacBook Air của KunDa` |
| Model | MacBook Air (`Mac16,12`) |
| Chip | Apple M4 |
| CPU cores | 10 (4 performance, 6 efficiency) |
| Memory | 16 GB (`17,179,869,184` bytes) |
| Operating system | macOS 26.5.1, build 25F80 |
| Kernel | Darwin 25.5.0 |
| Architecture | `arm64` |

Sources: `hostname`, `sw_vers`, `uname -m`, `sysctl`, and `system_profiler SPHardwareDataType SPSoftwareDataType` on the run host.

The HW04 workspace mentions that hostname evidence must be shown in the demo, but it does not contain a prior captured hostname value. Therefore this file records the current host without claiming an independently verified match to prior deployment evidence.
