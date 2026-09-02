import argparse
import os
import shutil
import subprocess
import sys
from collections import OrderedDict
from functools import lru_cache
from pathlib import Path


EXAMPLES_ROOT = Path(__file__).resolve().parent
SDK_ROOT = EXAMPLES_ROOT.parent

CANONICAL_EXAMPLE_IDS = ("delphi", "cppbuilder", "msvc", "csharp")
EXAMPLE_LABELS = {
    "delphi": "Delphi",
    "cppbuilder": "C++Builder",
    "msvc": "MSVC",
    "csharp": "C#",
}
EXAMPLE_ALIASES = {
    "delphi": "delphi",
    "cppbuilder": "cppbuilder",
    "c++builder": "cppbuilder",
    "msvc": "msvc",
    "visualstudio": "msvc",
    "visual-studio": "msvc",
    "visual studio": "msvc",
    "csharp": "csharp",
    "c#": "csharp",
}


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Build the TonCut SDK CsvImportExport starter examples.",
        epilog=(
            "Run this from SDK/examples. From the SDK root, use "
            "'python examples/build_examples.py'."
        ),
    )
    parser.add_argument(
        "--example",
        action="append",
        default=[],
        metavar="ID",
        help=(
            "Build only the selected example id. Repeat or use commas. "
            "Supported ids: delphi, cppbuilder, msvc, csharp."
        ),
    )
    parser.add_argument(
        "--exclude",
        action="append",
        default=[],
        metavar="ID",
        help=(
            "Exclude example ids from the build. Repeat or use commas. "
            "Supported ids: delphi, cppbuilder, msvc, csharp."
        ),
    )
    parser.add_argument(
        "--skip-cppbuilder",
        action="store_true",
        help="Exclude the C++Builder example.",
    )
    parser.add_argument(
        "--config",
        default="Debug",
        help="Build configuration. Default: Debug.",
    )
    parser.add_argument(
        "--platform",
        default="Win32",
        choices=["Win32"],
        help="Build platform. The TonCut plugin ABI supports Win32 only.",
    )
    execution_mode = parser.add_mutually_exclusive_group()
    execution_mode.add_argument(
        "--dry-run",
        action="store_true",
        help="Print build commands without executing them. Overrides TONCUT_SDK_EXAMPLES_DRY_RUN=0.",
    )
    execution_mode.add_argument(
        "--execute",
        action="store_true",
        help="Execute build commands immediately. Overrides TONCUT_SDK_EXAMPLES_DRY_RUN.",
    )
    return parser


def parse_args(argv: list[str]) -> tuple[argparse.ArgumentParser, argparse.Namespace]:
    parser = build_parser()
    return parser, parser.parse_args(argv)


def canonical_example_id(raw_value: str) -> str | None:
    return EXAMPLE_ALIASES.get(raw_value.strip().lower())


def expand_example_args(values: list[str]) -> list[str]:
    expanded: list[str] = []
    for value in values:
        for part in value.split(","):
            stripped = part.strip()
            if stripped:
                expanded.append(stripped)
    return expanded


def normalize_example_ids(
    values: list[str], parser: argparse.ArgumentParser, option_name: str
) -> list[str]:
    normalized: list[str] = []
    for raw_value in expand_example_args(values):
        canonical = canonical_example_id(raw_value)
        if canonical is None:
            supported = ", ".join(CANONICAL_EXAMPLE_IDS)
            parser.error(
                f"Unsupported value for {option_name}: {raw_value!r}. Supported ids: {supported}."
            )
        normalized.append(canonical)
    return list(OrderedDict.fromkeys(normalized))


def resolve_selected_examples(
    args: argparse.Namespace, parser: argparse.ArgumentParser
) -> tuple[list[str], set[str]]:
    selected = normalize_example_ids(args.example, parser, "--example")
    excluded = set(normalize_example_ids(args.exclude, parser, "--exclude"))
    if args.skip_cppbuilder:
        excluded.add("cppbuilder")

    if not selected:
        selected = list(CANONICAL_EXAMPLE_IDS)

    filtered = [example_id for example_id in selected if example_id not in excluded]
    if not filtered:
        parser.error("No examples remain after applying the selection and exclusions.")
    return filtered, excluded


def describe_examples(example_ids: list[str] | set[str]) -> str:
    if not example_ids:
        return ""
    ordered_ids = [example_id for example_id in CANONICAL_EXAMPLE_IDS if example_id in example_ids]
    return ", ".join(EXAMPLE_LABELS[example_id] for example_id in ordered_ids)


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


def run_command(command: str) -> None:
    prepared_command = prepare_command(command)
    print(f"> {prepared_command}", flush=True)
    subprocess.run(prepared_command, cwd=SDK_ROOT, shell=True, check=True)


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

    env_value = os.environ.get("TONCUT_SDK_EXAMPLES_DRY_RUN")
    dry_run = env_value != "0"
    if dry_run:
        return True, "default"

    missing_tools = missing_command_tools(commands)
    if missing_tools:
        missing_summary = ", ".join(missing_tools)
        print(
            "Build execution was requested by TONCUT_SDK_EXAMPLES_DRY_RUN=0, "
            f"but these tools are not available or could not be discovered: {missing_summary}."
        )
        print("Falling back to dry-run mode. Use --execute after the build toolchain is installed.")
        return True, "auto-fallback"
    return False, "TONCUT_SDK_EXAMPLES_DRY_RUN=0"


def build_commands(
    selected_examples: list[str], config: str, platform: str
) -> list[dict[str, str]]:
    definitions = {
        "delphi": {
            "label": "Build Delphi CsvImportExport",
            "command": (
                "msbuild examples\\delphi\\CsvImportExport\\CsvImportExport.dproj "
                f"/p:Config={config} /p:Platform={platform}"
            ),
            "outputs": [
                f"examples\\delphi\\CsvImportExport\\Win32\\{config}\\CsvImportExportDelphi.plg"
            ],
        },
        "cppbuilder": {
            "label": "Build C++Builder CsvImportExport",
            "command": (
                "msbuild examples\\cppbuilder\\CsvImportExport\\CsvImportExport.groupproj "
                f"/p:Config={config} /p:Platform={platform}"
            ),
            "outputs": [
                f"examples\\cppbuilder\\CsvImportExport\\bin\\{platform}\\{config}\\CsvImportExportCppBuilder.plg"
            ],
        },
        "msvc": {
            "label": "Build MSVC CsvImportExport",
            "command": (
                "msbuild examples\\msvc\\CsvImportExport\\CsvImportExport.sln "
                f"/p:Configuration={config} /p:Platform={platform}"
            ),
            "outputs": [
                f"examples\\msvc\\CsvImportExport\\bin\\{config}\\CsvImportExportMsvc.plg"
            ],
        },
        "csharp": {
            "label": "Build C# CsvImportExport",
            "command": (
                "msbuild examples\\csharp\\CsvImportExport\\CsvImportExport.sln "
                f"/restore /p:Configuration={config} /p:Platform={platform}"
            ),
            "outputs": [
                f"examples\\csharp\\CsvImportExport\\bin\\{config}\\CsvImportExportCSharp.plg",
                f"examples\\csharp\\CsvImportExport\\bin\\{config}\\TonCutCsv.Managed.dll",
            ],
        },
    }
    return [
        {
            "id": example_id,
            "label": definitions[example_id]["label"],
            "command": definitions[example_id]["command"],
            "outputs": definitions[example_id]["outputs"],
        }
        for example_id in selected_examples
    ]


def print_selection(
    selected_examples: list[str], excluded_examples: set[str], args: argparse.Namespace
) -> None:
    print(f"Configuration: {args.config}")
    print(f"Platform: {args.platform}")
    print(f"Selected examples: {describe_examples(selected_examples)}")
    if excluded_examples:
        print(f"Excluded examples: {describe_examples(excluded_examples)}")


def main(argv: list[str]) -> int:
    parser, args = parse_args(argv)
    selected_examples, excluded_examples = resolve_selected_examples(args, parser)
    commands = build_commands(selected_examples, args.config, args.platform)
    dry_run, mode_source = resolve_build_mode(args, commands)

    if dry_run:
        if mode_source == "auto-fallback":
            print("Example build is running in dry-run mode after toolchain detection failed.")
        elif mode_source == "--dry-run":
            print("Example build is running in dry-run mode (--dry-run).")
        else:
            print("Example build is running in dry-run mode.")
        print_selection(selected_examples, excluded_examples, args)
        for item in commands:
            print(f"[{item['id']}] {item['label']}: {prepare_command(item['command'])}")
            for output_path in item["outputs"]:
                print(f"  output: {output_path}")
        print(
            "Use --execute, or set TONCUT_SDK_EXAMPLES_DRY_RUN=0, to execute these commands on a machine with all toolchains installed."
        )
        return 0

    print(f"Example build is executing commands ({mode_source}).", flush=True)
    print_selection(selected_examples, excluded_examples, args)
    sys.stdout.flush()
    for item in commands:
        run_command(item["command"])
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        raise SystemExit(1)
