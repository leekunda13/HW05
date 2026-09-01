# HW05 Task 1 - Reproducible Metrics

Percentiles use the nearest-rank method over JMeter `elapsed` milliseconds. Throughput is HTTP samples divided by each observed measurement window; four samples form one completed workflow.

| Scenario | Samples | Errors | Error % | Mean ms | p90 ms | p95 ms | p99 ms | Samples/s | Workflows/s | Peak CPU % | Peak RSS MB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Load | 1912 | 0 | 0.00 | 2.35 | 4 | 5 | 6 | 16.04 | 4.01 | 6.9 | 72.59 |
| Stress | 6514 | 0 | 0.00 | 1.63 | 3 | 4 | 5 | 36.33 | 9.08 | 13.7 | 114.48 |
| Spike | 3216 | 0 | 0.00 | 1.76 | 3 | 4 | 5 | 26.98 | 6.75 | 15.4 | 101.77 |
| Soak | 49200 | 0 | 0.00 | 2.29 | 3 | 4 | 6 | 79.49 | 19.87 | 22.3 | 136.67 |

## Stage metrics

### Load

| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Load - 6 VUs steady | 1912 | 0 | 0.00 | 5 | 16.04 |

### Stress

| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Stress stage 1 - 6 VUs | 932 | 0 | 0.00 | 5 | 15.74 |
| Stress stage 2 - 12 VUs | 1873 | 0 | 0.00 | 4 | 31.44 |
| Stress stage 3 - 24 VUs | 3709 | 0 | 0.00 | 4 | 62.21 |

### Spike

| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Spike baseline - 3 VUs | 360 | 0 | 0.00 | 5 | 8.13 |
| Spike burst - 30 VUs | 2482 | 0 | 0.00 | 4 | 84.03 |
| Spike recovery - 3 VUs | 374 | 0 | 0.00 | 4 | 8.38 |

### Soak

| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Soak - 30 VUs sustained | 49200 | 0 | 0.00 | 4 | 79.49 |
