from __future__ import annotations

import argparse
import json
import math
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

TESTS_ROOT = Path(__file__).resolve().parents[2]
PLUGIN_ENTRIES = json.loads(r'''[
  {
    "id": "probe-delphi-debug",
    "label": "Delphi ContractProbe Debug plugin",
    "lane": "delphi",
    "category": "probe",
    "path": "generated/probes/delphi/Win32/Debug/ContractProbe.plg"
  },
  {
    "id": "probe-cppbuilder-debug",
    "label": "C++Builder ContractProbe Debug plugin",
    "lane": "cppbuilder",
    "category": "probe",
    "path": "generated/probes/cppbuilder/bin/Win32/Debug/ContractProbe.plg"
  },
  {
    "id": "probe-msvc-debug",
    "label": "MSVC ContractProbe Debug plugin",
    "lane": "msvc",
    "category": "probe",
    "path": "generated/probes/msvc/bin/Debug/ContractProbe.plg"
  },
  {
    "id": "probe-csharp-native-debug",
    "label": "C# native ContractProbe Debug plugin",
    "lane": "csharp",
    "category": "probe",
    "path": "generated/probes/csharp/bin/Debug/ContractProbe.plg"
  }
]''')
DEFAULTS = json.loads(r'''{
  "generatedAt": "2026-09-02T08:42:18.215Z",
  "generationFingerprint": "37bf6ec2db783b367d2608d24ffc9b82b7b89f6f990bda68e4e3c0f9155613dc",
  "harnessPath": "generated/harness/delphi/Win32/Debug/ContractHostHarness.exe",
  "managedProbePath": "generated/probes/csharp-managed/bin/Debug/ManagedCoreProbe.exe",
  "sampleCsvPath": "../examples/shared/csv/example.csv",
  "outputDir": "generated/runtime/manual-output",
  "reportPath": "generated/runtime/manual-runtime-report.json",
  "logDir": "generated/runtime/logs",
  "timeoutSeconds": 60.0
}''')


def iso_timestamp() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")


def resolve_workspace_path(path_value: str) -> Path:
    candidate = Path(path_value)
    return candidate.resolve() if candidate.is_absolute() else (TESTS_ROOT / candidate).resolve()


def ensure_dir(dir_path: Path) -> None:
    dir_path.mkdir(parents=True, exist_ok=True)


def append_exception(log_path: Path, exc: Exception) -> None:
    ensure_dir(log_path.parent)
    message = f"{type(exc).__name__}: {exc}\n"
    with log_path.open("a", encoding="utf-8") as stream:
        stream.write(message)
    sys.stderr.write(message)


def positive_timeout(value: str) -> float:
    try:
        parsed = float(value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError("timeout must be a number") from exc
    if not math.isfinite(parsed) or parsed <= 0:
        raise argparse.ArgumentTypeError("timeout must be a finite number greater than zero")
    return parsed


def run_with_logging(command: list[str], log_path: Path, timeout_seconds: float) -> int:
    ensure_dir(log_path.parent)
    with log_path.open("w", encoding="utf-8", newline="") as stream:
        process = subprocess.Popen(
            command,
            cwd=TESTS_ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
        try:
            output, _ = process.communicate(timeout=timeout_seconds)
        except subprocess.TimeoutExpired as exc:
            process.kill()
            output, _ = process.communicate()
            if output:
                sys.stdout.write(output)
                stream.write(output)
            raise TimeoutError(
                f"Process timed out after {timeout_seconds:g} seconds: {command[0]}"
            ) from exc
        if output:
            sys.stdout.write(output)
            stream.write(output)
        return process.returncode


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--harness-path", default=DEFAULTS["harnessPath"])
    parser.add_argument("--managed-probe-path", default=DEFAULTS["managedProbePath"])
    parser.add_argument("--sample-csv-path", default=DEFAULTS["sampleCsvPath"])
    parser.add_argument("--output-dir", default=DEFAULTS["outputDir"])
    parser.add_argument("--report-path", default=DEFAULTS["reportPath"])
    parser.add_argument("--log-dir", default=DEFAULTS["logDir"])
    parser.add_argument("--skip-cppbuilder", action="store_true")
    parser.add_argument(
        "--timeout-seconds",
        type=positive_timeout,
        default=DEFAULTS["timeoutSeconds"],
    )
    args = parser.parse_args()

    skipped_lanes = {"cppbuilder"} if args.skip_cppbuilder else set()
    plugin_entries = [
        plugin for plugin in PLUGIN_ENTRIES if plugin["lane"] not in skipped_lanes
    ]

    harness_path = resolve_workspace_path(args.harness_path)
    managed_probe_path = resolve_workspace_path(args.managed_probe_path)
    sample_csv_path = resolve_workspace_path(args.sample_csv_path)
    output_dir = resolve_workspace_path(args.output_dir)
    report_path = resolve_workspace_path(args.report_path)
    log_dir = resolve_workspace_path(args.log_dir)
    ensure_dir(output_dir)
    ensure_dir(log_dir)
    ensure_dir(report_path.parent)

    report: dict[str, object] = {
        "checkedAt": iso_timestamp(),
        "contractGeneratedAt": DEFAULTS["generatedAt"],
        "generationFingerprint": DEFAULTS["generationFingerprint"],
        "testsRoot": str(TESTS_ROOT),
        "harnessPath": str(harness_path),
        "managedProbePath": str(managed_probe_path),
        "sampleCsvPath": str(sample_csv_path),
        "outputDir": str(output_dir),
        "logDir": str(log_dir),
        "skippedLanes": sorted(skipped_lanes),
        "timeoutSeconds": args.timeout_seconds,
        "harnessRuns": [],
        "managedProbe": None,
    }

    managed_log_path = log_dir / "managed-core-probe.log"
    if managed_probe_path.exists():
        try:
            exit_code = run_with_logging(
                [str(managed_probe_path)], managed_log_path, args.timeout_seconds
            )
            report["managedProbe"] = {
                "path": str(managed_probe_path),
                "logPath": str(managed_log_path),
                "exitCode": exit_code,
                "status": "pass" if exit_code == 0 else "fail",
            }
        except Exception as exc:
            append_exception(managed_log_path, exc)
            report["managedProbe"] = {
                "path": str(managed_probe_path),
                "logPath": str(managed_log_path),
                "status": "execution-error",
                "error": str(exc),
            }
    else:
        report["managedProbe"] = {
            "path": str(managed_probe_path),
            "logPath": str(managed_log_path),
            "status": "missing",
        }

    harness_runs = report["harnessRuns"]
    assert isinstance(harness_runs, list)
    for plugin in plugin_entries:
        plugin_path = resolve_workspace_path(plugin["path"])
        safe_id = re.sub(r"[^A-Za-z0-9._-]", "_", plugin["id"])
        log_path = log_dir / f"{safe_id}.log"
        entry = {
            "id": plugin["id"],
            "label": plugin["label"],
            "lane": plugin["lane"],
            "category": plugin["category"],
            "pluginPath": str(plugin_path),
            "logPath": str(log_path),
        }

        if not plugin_path.exists():
            entry["status"] = "missing-plugin"
            harness_runs.append(entry)
            continue

        if not harness_path.exists():
            entry["status"] = "missing-harness"
            harness_runs.append(entry)
            continue

        try:
            exit_code = run_with_logging(
                [str(harness_path), str(plugin_path), str(sample_csv_path), str(output_dir)],
                log_path,
                args.timeout_seconds,
            )
            entry["exitCode"] = exit_code
            entry["status"] = "pass" if exit_code == 0 else "fail"
        except Exception as exc:
            append_exception(log_path, exc)
            entry["status"] = "execution-error"
            entry["error"] = str(exc)
        harness_runs.append(entry)

    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Manual runtime report: {report_path}")
    print(f"Runtime logs directory: {log_dir}")
    managed_probe = report.get("managedProbe")
    if not isinstance(managed_probe, dict) or managed_probe.get("status") != "pass":
        return 1
    for run in harness_runs:
        if run.get("status") != "pass":
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
