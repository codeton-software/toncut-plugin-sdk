# TonCut Plugin SDK

This folder is the external-facing SDK package for TonCut Desktop plugins. It contains the public Pascal interface units, the translated C++ contract header, buildable CSV import/export and result-export starter examples, and Markdown manuals for external developers.

## Start Here

1. Read `manuals/getting-started.md` and browse the Plugin API reference at https://docs.toncut.com/tc-plugin-sdk/.
2. Review `manuals/plugin-contract-and-abi.md`.
3. Open one of the example projects under `examples/`.
4. Build the native plugin output as `.plg`.

## Compatibility

- Supported host: TonCut Desktop 8.5.
- Plugin engine interface version: 24 (`cEngineVersion` in `include/pascal/uITcPluginCommon.pas`, mirrored in `include/cpp/TonCutPluginSdk.hpp`). The host refuses a plugin that reports a different value, so rebuild every plugin against this SDK.
- Documentation: the Plugin API reference is published at https://docs.toncut.com/tc-plugin-sdk/.

TonCut Desktop is a 32-bit application: every plugin must be a Win32 (x86) DLL named `*.plg` (lowercase) in the `Plugins\` folder next to `TonCut.exe`. The shipped SDK assumes the TonCut Win32 ABI used by the Delphi plugins, including quad-word record alignment. A C# plugin is a native C++ shim; TonCut does not load .NET assemblies directly (see `manuals/support-by-language.md`).

> **C++Builder is untested.** The Delphi, VS C++, and C# examples are built by the maintainers. The C++Builder example (`examples/cppbuilder/`) and the C++Builder build path in the example and test drivers have never been compiled or tested by the maintainers, so they are provided as-is and may need adjustments. If you find a problem, please [open an issue](https://github.com/codeton-software/toncut-plugin-sdk/issues) or send a [pull request](https://github.com/codeton-software/toncut-plugin-sdk/pulls).

## Layout

- `include/cpp/TonCutPluginSdk.hpp` is the shared C++ contract header.
- `include/pascal/` contains the published Pascal interface units copied from the TonCut Desktop source tree.
- `examples/` contains the starter plugins and shared example helpers.
- `manuals/` contains the SDK guides in Markdown.
- `tests/` contains the contract generator, probe projects, host harness, and manual runtime test workflow.

## Example Entry Points

- Delphi: `examples/delphi/CsvImportExport/CsvImportExport.dproj`
- C++Builder (not tested by the maintainers, see Compatibility): `examples/cppbuilder/CsvImportExport/CsvImportExport.cbproj`
- VS C++: `examples/msvc/CsvImportExport/CsvImportExport.sln`
- C#: `examples/csharp/CsvImportExport/CsvImportExport.sln`
- Example build driver: `examples/build_examples.py`

## Manuals

- `manuals/getting-started.md`
- `manuals/sdk-layout.md`
- `manuals/plugin-contract-and-abi.md`
- `manuals/csv-schema.md`
- `manuals/support-by-language.md`
- `manuals/building-examples.md`
- `manuals/public-contract-units.md`

## Testing

- Run the focused generator regressions from `SDK/tests` with
  `python -m unittest tools.test_sdk_test_lib`.
- Run the driver from `SDK/tests`, for example `python tools/run_sdk_tests.py build --skip-cppbuilder --dry-run`.
- From the `SDK` root, use `python tests/tools/run_sdk_tests.py build --skip-cppbuilder --dry-run`.
- The test runner can auto-discover Visual Studio `MSBuild.exe` and auto-load RAD Studio `rsvars.bat` when those toolchains are installed but not already on `PATH`.
- The unattended runtime runner is probe-only: it executes the managed probe and the native ContractProbe plugins without showing message boxes. Starter examples are currently build-verified only.
- See `tests/README.md` for the full workflow.
