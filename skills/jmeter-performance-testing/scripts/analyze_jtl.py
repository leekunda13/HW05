#!/usr/bin/env python3
"""Produce reproducible Markdown metrics from a CSV-format JMeter JTL file."""

from __future__ import annotations

import argparse
import csv
import math
import statistics
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


@dataclass(frozen=True)
class Sample:
    timestamp_ms: int | None
    elapsed_ms: float
    label: str
    response_code: str
    success: bool
    received_bytes: int
    sent_bytes: int


def parse_bool(value: str) -> bool:
    normalized = value.strip().lower()
    if normalized in {"true", "1", "yes"}:
        return True
    if normalized in {"false", "0", "no"}:
        return False
    raise ValueError(f"invalid success value: {value!r}")


def integer(row: dict[str, str], key: str, default: int = 0) -> int:
    value = row.get(key, "").strip()
    return int(float(value)) if value else default


def load_samples(path: Path) -> list[Sample]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        preview = handle.read(8192)
        handle.seek(0)
        try:
            dialect = csv.Sniffer().sniff(preview, delimiters=",;\t")
        except csv.Error:
            dialect = csv.excel
        reader = csv.DictReader(handle, dialect=dialect)
        fields = set(reader.fieldnames or [])
        required = {"elapsed", "label", "responseCode"}
        missing = required - fields
        if missing:
            raise ValueError(
                "JTL must be CSV with a header; missing columns: "
                + ", ".join(sorted(missing))
            )

        samples: list[Sample] = []
        for line_number, row in enumerate(reader, start=2):
            try:
                response_code = row.get("responseCode", "").strip()
                success_value = row.get("success", "").strip()
                success = (
                    parse_bool(success_value)
                    if success_value
                    else response_code.isdigit() and 200 <= int(response_code) < 400
                )
                timestamp = row.get("timeStamp", "").strip()
                samples.append(
                    Sample(
                        timestamp_ms=int(float(timestamp)) if timestamp else None,
                        elapsed_ms=float(row["elapsed"]),
                        label=row.get("label", "(unlabelled)").strip()
                        or "(unlabelled)",
                        response_code=response_code or "(blank)",
                        success=success,
                        received_bytes=integer(row, "bytes"),
                        sent_bytes=integer(row, "sentBytes"),
                    )
                )
            except (TypeError, ValueError) as exc:
                raise ValueError(f"invalid value on JTL line {line_number}: {exc}") from exc
    if not samples:
        raise ValueError("JTL contains no samples")
    return samples


def percentile(values: Iterable[float], percentage: float) -> float:
    ordered = sorted(values)
    rank = max(1, math.ceil(percentage / 100 * len(ordered)))
    return ordered[rank - 1]


def format_number(value: float | None, decimals: int = 2) -> str:
    return "n/a" if value is None else f"{value:.{decimals}f}"


def measurement_seconds(samples: list[Sample]) -> float | None:
    timed = [sample for sample in samples if sample.timestamp_ms is not None]
    if not timed:
        return None
    start = min(sample.timestamp_ms for sample in timed if sample.timestamp_ms is not None)
    end = max(
        sample.timestamp_ms + sample.elapsed_ms
        for sample in timed
        if sample.timestamp_ms is not None
    )
    return max((end - start) / 1000, 0.001)


def metrics(samples: list[Sample]) -> dict[str, object]:
    elapsed = [sample.elapsed_ms for sample in samples]
    errors = sum(not sample.success for sample in samples)
    seconds = measurement_seconds(samples)
    return {
        "count": len(samples),
        "errors": errors,
        "error_rate": errors / len(samples) * 100,
        "mean": statistics.fmean(elapsed),
        "median": statistics.median(elapsed),
        "p90": percentile(elapsed, 90),
        "p95": percentile(elapsed, 95),
        "p99": percentile(elapsed, 99),
        "minimum": min(elapsed),
        "maximum": max(elapsed),
        "throughput": len(samples) / seconds if seconds else None,
        "received": sum(sample.received_bytes for sample in samples),
        "sent": sum(sample.sent_bytes for sample in samples),
        "seconds": seconds,
    }


def table_row(name: str, result: dict[str, object]) -> str:
    values = [
        name.replace("|", "\\|"),
        str(result["count"]),
        str(result["errors"]),
        format_number(float(result["error_rate"])),
        format_number(float(result["mean"])),
        format_number(float(result["median"])),
        format_number(float(result["p90"])),
        format_number(float(result["p95"])),
        format_number(float(result["p99"])),
        format_number(float(result["minimum"])),
        format_number(float(result["maximum"])),
        format_number(result["throughput"]),  # type: ignore[arg-type]
        str(result["received"]),
        str(result["sent"]),
    ]
    return "| " + " | ".join(values) + " |"


def render(path: Path, samples: list[Sample]) -> str:
    by_label: dict[str, list[Sample]] = defaultdict(list)
    for sample in samples:
        by_label[sample.label].append(sample)

    overall = metrics(samples)
    lines = [
        "# JMeter JTL Analysis",
        "",
        f"Source: `{path}`",
        "",
        f"Measurement window: {format_number(overall['seconds'])} seconds",
        "",
        "Percentiles use the nearest-rank method over JMeter `elapsed` milliseconds. "
        "Throughput is sample count divided by the interval from the earliest request "
        "timestamp to the latest response completion.",
        "",
        "| Scope | Samples | Errors | Error % | Mean ms | Median ms | p90 ms | p95 ms | p99 ms | Min ms | Max ms | Samples/s | Bytes received | Bytes sent |",
        "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
        table_row("ALL", overall),
    ]
    for label in sorted(by_label):
        lines.append(table_row(label, metrics(by_label[label])))

    codes = Counter(sample.response_code for sample in samples)
    failed_codes = Counter(
        sample.response_code for sample in samples if not sample.success
    )
    lines.extend(
        [
            "",
            "## Response Codes",
            "",
            ", ".join(f"`{code}`: {count}" for code, count in sorted(codes.items())),
            "",
            "## Failed Sample Codes",
            "",
            (
                ", ".join(
                    f"`{code}`: {count}" for code, count in sorted(failed_codes.items())
                )
                if failed_codes
                else "None"
            ),
        ]
    )
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Analyse a CSV-format JMeter JTL without third-party packages."
    )
    parser.add_argument("jtl", type=Path, help="path to a CSV JTL file")
    parser.add_argument(
        "-o", "--output", type=Path, help="write Markdown to this path instead of stdout"
    )
    args = parser.parse_args()

    if not args.jtl.is_file():
        parser.error(f"JTL file not found: {args.jtl}")
    try:
        report = render(args.jtl, load_samples(args.jtl))
    except ValueError as exc:
        parser.error(str(exc))
    if args.output:
        args.output.write_text(report, encoding="utf-8")
    else:
        print(report, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
