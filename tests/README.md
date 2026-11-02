# SDK Test Automation

This workspace contains generated contract and probe assets for the TonCut SDK test plan.

Run these commands from the `SDK/tests` directory. If you start in `SDK`, use `python tests/tools/run_sdk_tests.py ...` instead.

## Commands

- `python tools/run_sdk_tests.py contract`
  Validates that every translated C++ interface is a documented opaque view or
  an exact Pascal vtable prefix, then regenerates the contract manifest,
  language support matrix, probe sources, IDE wrapper files, runtime manifest,
  and summary report. Unsafe skipped or reordered methods fail the command.
- `python -m unittest tools.test_sdk_test_lib`
  Runs focused contract-generator regressions, including the prior unsafe
  `ISolutionSheet` non-prefix projection.
- `python tools/run_sdk_tests.py build`
  (The C++Builder lane has never been run by the maintainers; see `SDK/README.md`.) Prints fresh-rebuild commands for probes, harness, and starter examples. Add `--skip-cppbuilder` if C++Builder is not installed. Add `--dry-run` to force print-only output even if `TONCUT_SDK_TESTS_DRY_RUN=0` is set. Use `--execute` or set `TONCUT_SDK_TESTS_DRY_RUN=0` to run the commands. The runner auto-discovers Visual Studio `MSBuild.exe` with `vswhere.exe` when it is installed but not already on `PATH`, and it auto-loads RAD Studio `rsvars.bat` for Delphi/C++Builder projects.
- `python tools/run_sdk_tests.py runtime`
  Discovers built artifacts, writes `generated/runtime/artifact-status.json`, and prints the next manual runtime commands. Add `--skip-cppbuilder` to stop treating C++Builder outputs as required.
- `python tools/run_sdk_tests.py report`
  Prints the generated summary, runtime expectations, artifact status, and any saved `manual-results.json`. Add `--skip-cppbuilder` to keep the report aligned with a non-C++Builder setup. Saved runtime results are accepted only when their contract fingerprint and skipped lanes match the current report request.

Lane skips affect only the selected local build/runtime/report work. The
checked-in contract, support matrix, runner, and runtime manifest always
describe all four SDK lanes and remain unchanged by a skipped-lane run.

## Manual Runtime Flow

1. Run `python tools/run_sdk_tests.py contract` after any SDK or generator change.
2. Run `python tools/run_sdk_tests.py build --skip-cppbuilder --dry-run` if Embarcadero C++Builder is not installed and you only want the command list. Use `--execute` or set `TONCUT_SDK_TESTS_DRY_RUN=0` only on a machine with the required build toolchains in `PATH`.
3. Run `python tools/run_sdk_tests.py runtime --skip-cppbuilder` if the build step skipped C++Builder so artifact discovery and runtime guidance stay consistent.
4. Execute `python generated\runtime\run_manual_checks.py --skip-cppbuilder` from the `SDK/tests` directory when that lane was skipped (omit the option after a complete four-lane build). The runner is non-interactive, applies a 60-second timeout to each process by default, and does not open plugin message boxes.
5. Review:
   - `generated/runtime/manual-runtime-report.json`
   - `generated/runtime/logs/`
6. Treat the starter examples as build-verified in the unattended loop. Their import/export behavior still needs a richer TonCut host double than the current harness provides.
7. Copy `generated/runtime/manual-results.template.json` to `generated/runtime/manual-results.json`, fill in any optional starter-example notes, then run `python tools/run_sdk_tests.py report --skip-cppbuilder` if that lane was bypassed earlier.

## Workspace Files

- `generated/contract-manifest.json`
- `generated/language-support.json`
- `generated/reports/contract-summary.md`
- `generated/probes/`
- `generated/harness/`
- `generated/runtime/expectations.json`
- `generated/runtime/runtime-manifest.json`
- `generated/runtime/manual-checklist.md`
- `generated/runtime/manual-results.template.json`
- `generated/runtime/run_manual_checks.py`
- `generated/runtime/manual-runtime-report.json` after running the manual Python runner
- `generated/runtime/logs/` after running the manual Python runner
- `generated/runtime/manual-results.json` after copying the template and recording verdicts

`generated/language-support.json` is the machine-readable support boundary.
For every non-Delphi lane, whole interfaces absent from the C++ header appear
in `unsupportedInterfaces`. Projected-interface entries include
`unsupportedMethods` (Pascal slot, name, and signature),
`supportedPropertyAccessors`, and accessor-aware `unsupportedProperties`.
Ownership-only `IUnknown` pointer types are kept out of callable support counts
and recorded separately in `ownershipOnlyInterfaces`/`opaquePointerTypes` while
also remaining in `unsupportedInterfaces`.
For C#, those native entries live under `nativeShimSupportedInterfaces`; the
separate `directManagedSupportedInterfaces` list is empty because the managed
core does not directly project the Pascal COM interfaces. Its native opaque
ownership types use `nativeShimOwnershipOnlyInterfaces` and
`nativeShimOpaquePointerTypes`.
