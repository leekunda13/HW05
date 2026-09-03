# HW05 Task 1 - Reproducible Metrics

Percentiles use the nearest-rank method over JMeter `elapsed` milliseconds. Sample throughput is HTTP samples divided by each observed measurement window. Completed workflow throughput counts only successful final FR06 samplers, so scheduled partial iterations are not over-counted.

| Scenario | Samples | Errors | Error % | Mean ms | p90 ms | p95 ms | p99 ms | Samples/s | Workflows/s | Peak CPU % | Peak RSS MB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Load | 1902 | 0 | 0.00 | 2.69 | 5 | 5 | 6 | 15.93 | 3.97 | 7.5 | 72.55 |
| Stress | 6489 | 0 | 0.00 | 2.33 | 4 | 5 | 6 | 36.19 | 8.96 | 14.0 | 118.81 |
| Spike | 3208 | 0 | 0.00 | 2.35 | 4 | 5 | 6 | 26.91 | 6.61 | 17.7 | 101.23 |
| Soak | 49200 | 0 | 0.00 | 2.15 | 4 | 4 | 6 | 80.15 | 20.04 | 28.2 | 138.95 |

## Stage metrics

### Load

| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Load - 6 VUs steady | 1902 | 0 | 0.00 | 5 | 15.93 |

### Stress

| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Stress stage 1 - 6 VUs | 933 | 0 | 0.00 | 5 | 15.74 |
| Stress stage 2 - 12 VUs | 1851 | 0 | 0.00 | 5 | 31.09 |
| Stress stage 3 - 24 VUs | 3705 | 0 | 0.00 | 4 | 62.08 |

### Spike

| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Spike baseline - 3 VUs | 357 | 0 | 0.00 | 7 | 8.06 |
| Spike burst - 30 VUs | 2468 | 0 | 0.00 | 5 | 83.04 |
| Spike recovery - 3 VUs | 383 | 0 | 0.00 | 5 | 8.66 |

### Soak

| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Soak - 30 VUs sustained | 49200 | 0 | 0.00 | 4 | 80.15 |
