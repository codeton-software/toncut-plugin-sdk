# SDK Tests Agent Notes

Run everything from `SDK/tests` unless stated otherwise.

## Goal

Keep the SDK test loop unattended for these lanes:

- Delphi
- MSVC
- C#

Use `--skip-cppbuilder` when C++Builder is not installed.

## Repeatable Loop

1. Regenerate artifacts after any SDK contract or generator change:
   `python tools/run_sdk_tests.py contract`
2. Build all supported lanes:
   `python tools/run_sdk_tests.py build --skip-cppbuilder --execute`
3. Refresh runtime manifests:
   `python tools/run_sdk_tests.py runtime --skip-cppbuilder`
4. Run the unattended checks:
   `python generated\runtime\run_manual_checks.py --skip-cppbuilder`
5. Print the summary:
   `python tools/run_sdk_tests.py report --skip-cppbuilder`

If you only want the command list, replace `--execute` with `--dry-run`.

## Automatic Runtime Scope

The current unattended runtime flow is probe-only:

- `generated/probes/delphi/.../ContractProbe.plg`
- `generated/probes/msvc/.../ContractProbe.plg`
- `generated/probes/csharp/.../ContractProbe.plg`
- `generated/probes/csharp-managed/.../ManagedCoreProbe.exe`
- `generated/harness/delphi/.../ContractHostHarness.exe`

The generated Python runner:

- runs the managed probe directly
- runs the native probe plugins through the Delphi harness
- returns exit code `1` on any failing managed probe or harness run
- does not run starter plugins
- does not expect CSV or PLT output files from the probe-only loop
- enforces a 60-second timeout per process by default; use
  `--timeout-seconds <seconds>` only when a slower host requires it

## Starter Plugins

Starter example projects are still built in the loop so they remain compilable across Delphi, MSVC, and C#.

The starter plugins now use distinct TonCut-visible identities so they can be installed side by side:

- Delphi: `CsvImportExportDelphi.plg`, `CsvImportExportTemplateDelphi`
- C++Builder: `CsvImportExportCppBuilder.plg`, `CsvImportExportTemplateCppBuilder`
- MSVC: `CsvImportExportMsvc.plg`, `CsvImportExportTemplateMsvc`
- C#: `CsvImportExportCSharp.plg`, `CsvImportExportTemplateCSharp`

Their runtime behavior is not yet part of the unattended loop. The current harness initializes plugins with `TcpInitializeV2(..., nil)` and does not provide the TonCut host objects that the starter implementations need for real import/export work.

A future automatic starter-runtime pass needs host doubles for at least:

- `ITonCut`
- `IProjects` / `IProject`
- `IMaterials` / `IMaterial`
- `IFormats` / `IFormat`
- `ISheets` / `ISheet`
- `ISolutionSheet`
- `ISolutionCuts` / `ISolutionCut`

## Non-Interactive Requirement

The starter `About` handlers were changed to avoid UI in automated runs:

- the C++ starter only shows `MessageBoxW` when `aWindow != nullptr`
- the Delphi starter only shows `MessageBoxW` when `aWindow <> 0`

The harness passes `0` for these smoke calls, so the unattended run does not block on message boxes.

## Toolchain Notes

- `run_sdk_tests.py` auto-discovers Visual Studio `MSBuild.exe` with `vswhere.exe` when `msbuild` is not on `PATH`
- Delphi and C++Builder project commands auto-load RAD Studio `rsvars.bat`
- C# solution builds use `/restore`

## Expected Healthy Result

With `--skip-cppbuilder`, a good run looks like this:

- `build` succeeds for Delphi, MSVC, and C#
- `runtime` reports `probe: 3/3 present`, `managed-probe: 1/1 present`, `harness: 1/1 present`, and `starter: 3/3 present`
- `run_manual_checks.py` exits `0`
- `report` shows `Managed probe: pass` and `Harness runs: pass=3`

## Files To Check First

- `tools/run_sdk_tests.py`
- `tools/sdk_test_lib.py`
- `generated/runtime/run_manual_checks.py`
- `generated/runtime/manual-runtime-report.json`
- `generated/runtime/logs/`
- `README.md`
