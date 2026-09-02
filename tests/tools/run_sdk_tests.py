from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from functools import lru_cache
from pathlib import Path
from typing import Any

from sdk_test_lib import (
    REPORTS_ROOT,
    ROOT,
    RUNTIME_ROOT,
    build_commands,
    build_runtime_manifest,
    describe_lane_ids,
    generate_artifacts,
    iso_timestamp,
    read_text,
    write_json,
)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate and inspect the TonCut SDK test workspace.",
        epilog=(
            "Run this from SDK/tests. From the SDK root, use "
            "'python tests/tools/run_sdk_tests.py <command>'."
        ),
    )
    parser.add_argument("command", choices=["contract", "build", "runtime", "report"])
    parser.add_argument(
        "--skip-cppbuilder",
        action="store_true",
        help="Exclude C++Builder probe and starter checks from build/runtime/report output.",
    )
    execution_mode = parser.add_mutually_exclusive_group()
    execution_mode.add_argument(
        "--dry-run",
        action="store_true",
        help="Print build commands without executing them. Overrides TONCUT_SDK_TESTS_DRY_RUN=0.",
    )
    execution_mode.add_argument(
        "--execute",
        action="store_true",
        help="Execute build commands immediately. Overrides TONCUT_SDK_TESTS_DRY_RUN.",
    )
    return parser.parse_args(argv)


def get_skipped_lanes(args: argparse.Namespace) -> set[str]:
    return {"cppbuilder"} if args.skip_cppbuilder else set()


def print_skipped_lanes(skipped_lanes: set[str]) -> None:
    skipped_summary = describe_lane_ids(skipped_lanes)
    if skipped_summary:
        print(f"Skipped lanes: {skipped_summary}")


def split_command(command: str) -> tuple[str, str, str]:
    stripped = command.lstrip()
    leading = command[: len(command) - len(stripped)]
    if not stripped:
        return leading, "", ""
    if stripped.startswith('"'):
        closing_quote = stripped.find('"', 1)
        if closing_quote == -1:
            return leading, stripped[1:], ""
        return leading, stripped[1:closing_quote], stripped[closing_quote + 1 :]
    token, separator, remainder = stripped.partition(" ")
    return leading, token, f"{separator}{remainder}"


@lru_cache(maxsize=1)
def discover_msbuild_path() -> str | None:
    direct_path = shutil.which("msbuild") or shutil.which("msbuild.exe")
    if direct_path:
        return direct_path

    program_files_x86 = os.environ.get("ProgramFiles(x86)")
    if program_files_x86:
        vswhere_path = (
            Path(program_files_x86)
            / "Microsoft Visual Studio"
            / "Installer"
            / "vswhere.exe"
        )
        if vswhere_path.exists():
            result = subprocess.run(
                [
                    str(vswhere_path),
                    "-latest",
                    "-products",
                    "*",
                    "-requires",
                    "Microsoft.Component.MSBuild",
                    "-find",
                    r"MSBuild\**\Bin\MSBuild.exe",
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            for line in result.stdout.splitlines():
                candidate = line.strip()
                if candidate and Path(candidate).exists():
                    return candidate

    visual_studio_root = (
        Path(program_files_x86) / "Microsoft Visual Studio"
        if program_files_x86
        else None
    )
    if visual_studio_root and visual_studio_root.exists():
        candidates = sorted(
            visual_studio_root.glob(r"*\*\MSBuild\Current\Bin\MSBuild.exe"),
            reverse=True,
        )
        if candidates:
            return str(candidates[0])
        legacy_candidates = sorted(
            visual_studio_root.glob(r"*\*\MSBuild\15.0\Bin\MSBuild.exe"),
            reverse=True,
        )
        if legacy_candidates:
            return str(legacy_candidates[0])

    return None


@lru_cache(maxsize=1)
def discover_rsvars_path() -> str | None:
    bds_root = os.environ.get("BDS")
    if bds_root:
        candidate = Path(bds_root) / "bin" / "rsvars.bat"
        if candidate.exists():
            return str(candidate)

    install_roots = [
        Path(r"C:\Program Files (x86)\Embarcadero"),
        Path(r"C:\Program Files\Embarcadero"),
    ]
    for root in install_roots:
        if not root.exists():
            continue
        candidates = sorted(root.glob(r"Studio\*\bin\rsvars.bat"), reverse=True)
        if candidates:
            return str(candidates[0])
    return None


@lru_cache(maxsize=1)
def discover_cppbuilder_rsvars_path() -> str | None:
    bds_root = os.environ.get("BDS")
    if bds_root:
        bin_dir = Path(bds_root) / "bin"
        rsvars_candidate = bin_dir / "rsvars.bat"
        compiler_candidate = bin_dir / "bcc32.exe"
        if rsvars_candidate.exists() and compiler_candidate.exists():
            return str(rsvars_candidate)

    install_roots = [
        Path(r"C:\Program Files (x86)\Embarcadero"),
        Path(r"C:\Program Files\Embarcadero"),
    ]
    for root in install_roots:
        if not root.exists():
            continue
        candidates = sorted(root.glob(r"Studio\*\bin\rsvars.bat"), reverse=True)
        for candidate in candidates:
            if candidate.with_name("bcc32.exe").exists():
                return str(candidate)
    return None


def resolve_tool_path(executable: str) -> str | None:
    direct_path = shutil.which(executable)
    if direct_path:
        return direct_path
    if executable.lower() in {"msbuild", "msbuild.exe"}:
        return discover_msbuild_path()
    return None


def msbuild_project_path(command: str) -> str | None:
    _, executable, remainder = split_command(command)
    if not executable or "msbuild" not in Path(executable).name.lower():
        return None
    _, project_path, _ = split_command(remainder)
    return project_path or None


def is_rad_studio_msbuild_command(command: str) -> bool:
    project_path = msbuild_project_path(command)
    if not project_path:
        return False
    return Path(project_path).suffix.lower() in {".dproj", ".groupproj", ".cbproj"}


def is_cppbuilder_msbuild_command(command: str) -> bool:
    project_path = msbuild_project_path(command)
    if not project_path:
        return False
    return Path(project_path).suffix.lower() in {".groupproj", ".cbproj"}


def ensure_build_target(command: str) -> str:
    lowered = command.lower()
    if " /t:" in lowered or " /target" in lowered:
        return command
    return f"{command} /t:Rebuild"


def resolve_command(command: str) -> str:
    leading, executable, remainder = split_command(command)
    if not executable:
        return command
    if shutil.which(executable) is not None:
        return command
    resolved_path = resolve_tool_path(executable)
    if not resolved_path:
        return command
    return f'{leading}"{resolved_path}"{remainder}'


def prepare_command(command: str) -> str:
    build_command = ensure_build_target(command) if msbuild_project_path(command) else command
    if is_rad_studio_msbuild_command(command):
        rsvars_path = (
            discover_cppbuilder_rsvars_path()
            if is_cppbuilder_msbuild_command(command)
            else discover_rsvars_path()
        )
        if rsvars_path:
            return f'call "{rsvars_path}" >nul && {build_command}'
        return build_command
    return resolve_command(build_command)


def run_command(command: str, cwd: Path = ROOT) -> None:
    prepared_command = prepare_command(command)
    print(f"> {prepared_command}")
    subprocess.run(prepared_command, cwd=cwd, shell=True, check=True)


def command_executable(command: str) -> str:
    return split_command(command)[1]


def missing_command_tools(commands: list[dict[str, str]]) -> list[str]:
    missing: list[str] = []
    seen: set[str] = set()
    for item in commands:
        if is_rad_studio_msbuild_command(item["command"]):
            if discover_rsvars_path() is None and "rad-studio-rsvars" not in seen:
                seen.add("rad-studio-rsvars")
                missing.append("rsvars.bat")
            if (
                is_cppbuilder_msbuild_command(item["command"])
                and discover_cppbuilder_rsvars_path() is None
                and "cppbuilder-compiler" not in seen
            ):
                seen.add("cppbuilder-compiler")
                missing.append("bcc32.exe")
            continue
        executable = command_executable(item["command"])
        normalized = executable.lower()
        if normalized in seen:
            continue
        seen.add(normalized)
        if resolve_tool_path(executable) is None:
            missing.append(executable)
    return missing


def resolve_build_mode(
    args: argparse.Namespace, commands: list[dict[str, str]]
) -> tuple[bool, str]:
    if args.dry_run:
        return True, "--dry-run"

    if args.execute:
        missing_tools = missing_command_tools(commands)
        if missing_tools:
            missing_summary = ", ".join(missing_tools)
            raise RuntimeError(
                "Build execution was requested with --execute, but these tools are not available or could not be discovered: "
                f"{missing_summary}. Install them or rerun with --dry-run."
            )
        return False, "--execute"

    env_value = os.environ.get("TONCUT_SDK_TESTS_DRY_RUN")
    dry_run = env_value != "0"
    if dry_run:
        return True, "default"

    missing_tools = missing_command_tools(commands)
    if missing_tools:
        missing_summary = ", ".join(missing_tools)
        print(
            "TONCUT_SDK_TESTS_DRY_RUN=0 requested build execution, but these tools are not available or could not be discovered: "
            f"{missing_summary}."
        )
        print("Falling back to dry-run mode. Use --execute after the build toolchain is installed.")
        return True, "auto-fallback"

    return False, "TONCUT_SDK_TESTS_DRY_RUN=0"


def load_json(file_path: Path) -> Any:
    import json

    return json.loads(read_text(file_path, bom=True))


def build_artifact_status(runtime_manifest: dict[str, Any]) -> dict[str, Any]:
    return {
        "checkedAt": iso_timestamp(),
        "artifacts": [
            {
                **artifact,
                "absolutePath": str((ROOT / artifact["path"]).resolve()),
                "exists": (ROOT / artifact["path"]).exists(),
            }
            for artifact in runtime_manifest["artifacts"]
        ],
    }


def write_artifact_status(runtime_manifest: dict[str, Any]) -> dict[str, Any]:
    status = build_artifact_status(runtime_manifest)
    write_json(RUNTIME_ROOT / "artifact-status.json", status)
    return status


def summarize_artifacts(
    status: dict[str, Any], skipped_lanes: set[str] | None = None
) -> str:
    counts: dict[str, dict[str, int]] = {}
    for artifact in status["artifacts"]:
        current = counts.setdefault(artifact["category"], {"total": 0, "present": 0})
        current["total"] += 1
        if artifact["exists"]:
            current["present"] += 1
    lines: list[str] = []
    skipped_summary = describe_lane_ids(skipped_lanes)
    if skipped_summary:
        lines.append(f"Skipped lanes: {skipped_summary}")
    lines.extend(
        f"{category}: {value['present']}/{value['total']} present"
        for category, value in counts.items()
    )
    return "\n".join(lines)


def summarize_manual_runtime_report(report: dict[str, Any]) -> str:
    lines: list[str] = []
    managed_probe = report.get("managedProbe")
    if isinstance(managed_probe, dict):
        managed_status = managed_probe.get("status")
        if not managed_status:
            exit_code = managed_probe.get("exitCode")
            managed_status = "pass" if isinstance(exit_code, int) and exit_code == 0 else "fail"
        lines.append(f"Managed probe: {managed_status}")
        if isinstance(managed_probe.get("exitCode"), int):
            lines.append(f"Managed probe exit code: {managed_probe['exitCode']}")
        if managed_probe.get("logPath"):
            lines.append(f"Managed probe log: {managed_probe['logPath']}")

    harness_runs = report.get("harnessRuns")
    if isinstance(harness_runs, list) and harness_runs:
        counts: dict[str, int] = {}
        for run in harness_runs:
            status = run.get("status", "unknown")
            counts[status] = counts.get(status, 0) + 1
        lines.append(
            "Harness runs: "
            + ", ".join(f"{status}={count}" for status, count in counts.items())
        )
        for run in [item for item in harness_runs if item.get("status") != "pass"]:
            label = (
                run.get("label")
                or run.get("id")
                or run.get("pluginPath")
                or "unknown"
            )
            suffix = (
                f" (exit {run['exitCode']})"
                if isinstance(run.get("exitCode"), int)
                else ""
            )
            lines.append(f"- {label}: {run.get('status', 'unknown')}{suffix}")
            if run.get("logPath"):
                lines.append(f"  log: {run['logPath']}")

    output_files = report.get("outputFiles")
    if isinstance(output_files, dict) and output_files:
        for name, entry in output_files.items():
            exists = "present" if entry.get("exists") else "missing"
            lines.append(f"Output {name}: {exists} ({entry.get('path', '')})")

    if report.get("logDir"):
        lines.append(f"Logs directory: {report['logDir']}")
    return "\n".join(lines)


def manual_runtime_report_compatibility_error(
    report: dict[str, Any],
    generation_fingerprint: str,
    skipped_lanes: set[str],
) -> str | None:
    report_fingerprint = report.get("generationFingerprint")
    if report_fingerprint != generation_fingerprint:
        if not isinstance(report_fingerprint, str) or not report_fingerprint:
            return "the saved report has no generated-contract fingerprint"
        return (
            "the saved report was produced for generated-contract fingerprint "
            f"{report_fingerprint}, not {generation_fingerprint}"
        )

    report_skipped_lanes = report.get("skippedLanes")
    if not isinstance(report_skipped_lanes, list) or not all(
        isinstance(lane, str) for lane in report_skipped_lanes
    ):
        return "the saved report has no valid skipped-lane provenance"
    if set(report_skipped_lanes) != skipped_lanes:
        expected = describe_lane_ids(skipped_lanes) or "none"
        actual = describe_lane_ids(set(report_skipped_lanes)) or "none"
        return f"the saved report skipped {actual}; this report expects {expected}"
    return None


def collect_manual_status_entries(value: Any, prefix: str = "") -> list[dict[str, str]]:
    if not isinstance(value, dict):
        return []

    entries: list[dict[str, str]] = []
    if "status" in value:
        notes = value.get("notes")
        entries.append(
            {
                "path": prefix or "<root>",
                "status": str(value.get("status")),
                "notes": notes.strip() if isinstance(notes, str) and notes.strip() else "",
            }
        )

    for key, child in value.items():
        if key in {"status", "notes"}:
            continue
        child_path = f"{prefix}.{key}" if prefix else key
        entries.extend(collect_manual_status_entries(child, child_path))
    return entries


def summarize_manual_results(manual_results: dict[str, Any]) -> str:
    entries = collect_manual_status_entries(manual_results)
    if not entries:
        return "No status fields were found in manual-results.json."

    allowed_statuses = {"pending", "pass", "fail", "not-applicable"}
    counts: dict[str, int] = {}
    for entry in entries:
        counts[entry["status"]] = counts.get(entry["status"], 0) + 1

    lines = [
        "Manual results: "
        + ", ".join(f"{status}={count}" for status, count in counts.items())
    ]
    for entry in [item for item in entries if item["status"] not in allowed_statuses]:
        lines.append(f'- {entry["path"]}: invalid status "{entry["status"]}"')
    for entry in [
        item
        for item in entries
        if item["status"] not in {"pass", "not-applicable"}
    ]:
        note_suffix = f" - {entry['notes']}" if entry["notes"] else ""
        lines.append(f"- {entry['path']}: {entry['status']}{note_suffix}")
    return "\n".join(lines)


def cmd_contract(skipped_lanes: set[str]) -> None:
    if skipped_lanes:
        raise ValueError(
            "--skip-cppbuilder applies to build, runtime, and report; "
            "contract artifacts always describe every SDK lane."
        )
    result = generate_artifacts()
    manifest = result["manifest"]
    support = result["support"]
    print(
        f"Generated contract artifacts for {manifest['totals']['interfaceCount']} Pascal interfaces and {len(support['lanes'])} lanes."
    )


def cmd_build(args: argparse.Namespace, skipped_lanes: set[str]) -> None:
    generate_artifacts()
    commands = build_commands(skipped_lanes)
    dry_run, mode_source = resolve_build_mode(args, commands)

    if dry_run:
        if mode_source == "auto-fallback":
            print("Build mode is running in dry-run mode after toolchain detection failed.")
        elif mode_source == "--dry-run":
            print("Build mode is running in dry-run mode (--dry-run).")
        else:
            print("Build mode is running in dry-run mode.")
        print_skipped_lanes(skipped_lanes)
        for item in commands:
            print(f"[{item['id']}] {item['label']}: {prepare_command(item['command'])}")
        print(
            "Use --execute, or set TONCUT_SDK_TESTS_DRY_RUN=0, to execute these commands on a machine with all toolchains installed."
        )
        return

    print(f"Build mode is executing commands ({mode_source}).")
    print_skipped_lanes(skipped_lanes)
    for item in commands:
        run_command(item["command"])


def cmd_runtime(skipped_lanes: set[str]) -> None:
    generated = generate_artifacts()
    runtime_manifest = build_runtime_manifest(
        skipped_lanes,
        generated_at=generated["manifest"]["generatedAt"],
        generation_fingerprint=generated["manifest"]["generationFingerprint"],
    )
    status = write_artifact_status(runtime_manifest)
    harness = next(
        (item for item in status["artifacts"] if item["id"] == "harness-delphi-debug"),
        None,
    )
    available_plugins = [
        item
        for item in status["artifacts"]
        if item["exists"] and item["category"] == "probe"
    ]

    print("Artifact status:")
    print(summarize_artifacts(status, skipped_lanes))
    print("")
    print(f"Checklist: {RUNTIME_ROOT / 'manual-checklist.md'}")
    print(f"Python runner: {RUNTIME_ROOT / 'run_manual_checks.py'}")
    print(f"Artifact report: {RUNTIME_ROOT / 'artifact-status.json'}")
    print(f"Runtime report: {RUNTIME_ROOT / 'manual-runtime-report.json'}")
    print(f"Runtime logs: {RUNTIME_ROOT / 'logs'}")
    print(f"Manual results template: {RUNTIME_ROOT / 'manual-results.template.json'}")
    print(f"Manual results file: {RUNTIME_ROOT / 'manual-results.json'}")
    print("")
    runner_options = " --skip-cppbuilder" if "cppbuilder" in skipped_lanes else ""
    print(
        f'Run the generated runner: python "{RUNTIME_ROOT / "run_manual_checks.py"}"'
        f"{runner_options}"
    )
    print("")

    if harness and harness["exists"] and available_plugins:
        print("Available automated probe harness runs:")
        for plugin in available_plugins:
            print(
                f'"{harness["absolutePath"]}" "{plugin["absolutePath"]}" "{(ROOT / runtime_manifest["fixtures"]["sampleCsv"]).resolve()}" "{(ROOT / runtime_manifest["fixtures"]["manualOutputDir"]).resolve()}"'
            )
        print("")
        print("Starter examples are build-verified only in the unattended loop.")
    else:
        print("Runtime artifacts are not complete yet.")
        if not harness or not harness["exists"]:
            build_harness = next(
                (
                    item
                    for item in runtime_manifest["buildCommands"]
                    if item["id"] == "build-harness-delphi"
                ),
                None,
            )
            if build_harness:
                print(f"Build the harness first: {prepare_command(build_harness['command'])}")
        if not available_plugins:
            print("No automated probe plugins were found yet.")


def cmd_report(skipped_lanes: set[str]) -> None:
    generated = generate_artifacts()
    runtime_manifest = build_runtime_manifest(
        skipped_lanes,
        generated_at=generated["manifest"]["generatedAt"],
        generation_fingerprint=generated["manifest"]["generationFingerprint"],
    )
    contract_summary_path = REPORTS_ROOT / "contract-summary.md"
    expectations_path = RUNTIME_ROOT / "expectations.json"
    status = write_artifact_status(runtime_manifest)
    print(read_text(contract_summary_path), end="")
    print(f"Runtime expectations: {expectations_path}")
    print("")
    print("Artifact status:")
    print(summarize_artifacts(status, skipped_lanes))

    manual_runtime_report_path = RUNTIME_ROOT / "manual-runtime-report.json"
    if manual_runtime_report_path.exists():
        manual_runtime_report = load_json(manual_runtime_report_path)
        print("")
        print("Manual runtime report:")
        compatibility_error = manual_runtime_report_compatibility_error(
            manual_runtime_report,
            generated["manifest"]["generationFingerprint"],
            skipped_lanes,
        )
        if compatibility_error:
            runner_options = " --skip-cppbuilder" if "cppbuilder" in skipped_lanes else ""
            print(f"Stale or incompatible: {compatibility_error}.")
            print(
                f'Rerun: python "{RUNTIME_ROOT / "run_manual_checks.py"}"'
                f"{runner_options}"
            )
        else:
            print(summarize_manual_runtime_report(manual_runtime_report))
    else:
        print("")
        print(f"Manual runtime report not found. Run {RUNTIME_ROOT / 'run_manual_checks.py'}")

    manual_results_path = RUNTIME_ROOT / "manual-results.json"
    if manual_results_path.exists():
        manual_results = load_json(manual_results_path)
        print("")
        print("Manual results:")
        print(summarize_manual_results(manual_results))
    else:
        print("")
        print(
            f"Manual results file not found. Start from {RUNTIME_ROOT / 'manual-results.template.json'}"
        )


def main() -> int:
    args = parse_args(sys.argv[1:])
    skipped_lanes = get_skipped_lanes(args)
    try:
        command = args.command
        if command == "contract":
            cmd_contract(skipped_lanes)
        elif command == "build":
            cmd_build(args, skipped_lanes)
        elif command == "runtime":
            cmd_runtime(skipped_lanes)
        elif command == "report":
            cmd_report(skipped_lanes)
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
