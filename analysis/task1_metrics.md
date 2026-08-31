# HW05 Task 1 - Reproducible Metrics

Percentiles use the nearest-rank method over JMeter `elapsed` milliseconds. Throughput is HTTP samples divided by each observed measurement window; six samples form one completed workflow.

| Scenario | Samples | Errors | Error % | Mean ms | p90 ms | p95 ms | p99 ms | Samples/s | Workflows/s | Peak CPU % | Peak RSS MB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Load | 1896 | 0 | 0.00 | 2.52 | 4 | 5 | 6 | 15.88 | 2.65 | 10.2 | 79.59 |
| Stress | 6476 | 0 | 0.00 | 2.54 | 4 | 5 | 6 | 36.11 | 6.02 | 19.4 | 132.59 |
| Spike | 3180 | 0 | 0.00 | 2.63 | 5 | 5 | 7 | 26.69 | 4.45 | 20.5 | 104.02 |
| Soak | 49322 | 0 | 0.00 | 2.46 | 4 | 5 | 6 | 82.29 | 13.72 | 38.7 | 140.47 |

## Stage metrics

### Load

| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Load - 6 VUs steady | 1896 | 0 | 0.00 | 5 | 15.88 |

### Stress

| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Stress stage 1 - 6 VUs | 936 | 0 | 0.00 | 5 | 15.78 |
| Stress stage 2 - 12 VUs | 1854 | 0 | 0.00 | 5 | 31.10 |
| Stress stage 3 - 24 VUs | 3686 | 0 | 0.00 | 5 | 61.87 |

### Spike

| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Spike baseline - 3 VUs | 357 | 0 | 0.00 | 6 | 8.11 |
| Spike burst - 30 VUs | 2456 | 0 | 0.00 | 5 | 82.96 |
| Spike recovery - 3 VUs | 367 | 0 | 0.00 | 5 | 8.21 |

### Soak

| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Soak - 30 VUs sustained | 49322 | 0 | 0.00 | 5 | 82.29 |
