#!/usr/bin/env python3
"""Create reproducible scenario/stage metrics from raw JTL and resource CSV files."""

from __future__ import annotations

import csv
import json
import math
import os
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RUN_DATE = os.environ.get("HW05_RUN_DATE", "20260901")
SCENARIOS = ("Load", "Stress", "Spike", "Soak")


def percentile(values: list[float], percent: float) -> float:
    if not values:
        return 0.0
    ordered = sorted(values)
    return ordered[max(0, math.ceil(percent * len(ordered)) - 1)]


def stage_name(thread_name: str) -> str:
    head, separator, tail = thread_name.rpartition(" ")
    if separator and "-" in tail and all(part.isdigit() for part in tail.split("-", 1)):
        return head
    return thread_name


def sample_metrics(rows: list[dict[str, str]]) -> dict[str, float | int]:
    elapsed = [float(row["elapsed"]) for row in rows]
    errors = sum(row["success"].strip().lower() != "true" for row in rows)
    starts = [float(row["timeStamp"]) for row in rows]
    ends = [float(row["timeStamp"]) + float(row["elapsed"]) for row in rows]
    window_seconds = max((max(ends) - min(starts)) / 1000.0, 0.001)
    return {
        "samples": len(rows),
        "errors": errors,
        "error_percent": round(errors * 100.0 / len(rows), 4) if rows else 0.0,
        "mean_ms": round(sum(elapsed) / len(elapsed), 3) if elapsed else 0.0,
        "p90_ms": percentile(elapsed, 0.90),
        "p95_ms": percentile(elapsed, 0.95),
        "p99_ms": percentile(elapsed, 0.99),
        "min_ms": min(elapsed, default=0.0),
        "max_ms": max(elapsed, default=0.0),
        "throughput_samples_s": round(len(rows) / window_seconds, 3),
        "window_seconds": round(window_seconds, 3),
    }


def resource_metrics(path: Path) -> dict[str, float | int]:
    with path.open(newline="", encoding="utf-8") as stream:
        rows = list(csv.DictReader(stream))
    cpu = [float(row["cpu_percent"]) for row in rows]
    rss_kb = [float(row["rss_kb"]) for row in rows]
    return {
        "observations": len(rows),
        "max_cpu_percent": max(cpu, default=0.0),
        "mean_cpu_percent": round(sum(cpu) / len(cpu), 3) if cpu else 0.0,
        "max_rss_mb": round(max(rss_kb, default=0.0) / 1024.0, 3),
        "final_rss_mb": round(rss_kb[-1] / 1024.0, 3) if rss_kb else 0.0,
    }


def main() -> None:
    output_dir = ROOT / "analysis"
    output_dir.mkdir(parents=True, exist_ok=True)
    summary: dict[str, dict] = {}

    for scenario in SCENARIOS:
        stem = f"23127035_{scenario}_{RUN_DATE}"
        jtl_path = ROOT / "results" / f"{stem}.jtl"
        resource_path = ROOT / "evidence" / "resource" / f"{stem}_backend_resource.csv"
        with jtl_path.open(newline="", encoding="utf-8") as stream:
            rows = list(csv.DictReader(stream))

        stages: dict[str, list[dict[str, str]]] = defaultdict(list)
        for row in rows:
            stages[stage_name(row["threadName"])].append(row)

        summary[scenario] = {
            "jtl": str(jtl_path.relative_to(ROOT)),
            "overall": sample_metrics(rows),
            "stages": {name: sample_metrics(stage_rows) for name, stage_rows in stages.items()},
            "resources": resource_metrics(resource_path),
            "response_codes": dict(sorted((code, sum(row["responseCode"] == code for row in rows)) for code in {row["responseCode"] for row in rows})),
        }

    json_path = output_dir / "task1_metrics.json"
    json_path.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# HW05 Task 1 - Reproducible Metrics",
        "",
        "Percentiles use the nearest-rank method over JMeter `elapsed` milliseconds. Throughput is HTTP samples divided by each observed measurement window; four samples form one completed workflow.",
        "",
        "| Scenario | Samples | Errors | Error % | Mean ms | p90 ms | p95 ms | p99 ms | Samples/s | Workflows/s | Peak CPU % | Peak RSS MB |",
        "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ]
    for scenario in SCENARIOS:
        overall = summary[scenario]["overall"]
        resources = summary[scenario]["resources"]
        lines.append(
            f"| {scenario} | {overall['samples']} | {overall['errors']} | {overall['error_percent']:.2f} | "
            f"{overall['mean_ms']:.2f} | {overall['p90_ms']:.0f} | {overall['p95_ms']:.0f} | {overall['p99_ms']:.0f} | "
            f"{overall['throughput_samples_s']:.2f} | {overall['throughput_samples_s'] / 4:.2f} | "
            f"{resources['max_cpu_percent']:.1f} | {resources['max_rss_mb']:.2f} |"
        )

    lines.extend(["", "## Stage metrics", ""])
    for scenario in SCENARIOS:
        lines.extend([
            f"### {scenario}",
            "",
            "| Thread group | Samples | Errors | Error % | p95 ms | Samples/s |",
            "| --- | ---: | ---: | ---: | ---: | ---: |",
        ])
        for name, metrics in summary[scenario]["stages"].items():
            lines.append(
                f"| {name} | {metrics['samples']} | {metrics['errors']} | {metrics['error_percent']:.2f} | "
                f"{metrics['p95_ms']:.0f} | {metrics['throughput_samples_s']:.2f} |"
            )
        lines.append("")

    markdown_path = output_dir / "task1_metrics.md"
    markdown_path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    print(json_path)
    print(markdown_path)


if __name__ == "__main__":
    main()
