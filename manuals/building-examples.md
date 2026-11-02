# Building The Examples

## Scripted Builds

From `SDK/examples`:

- Build all examples: `python build_examples.py --execute`
- Build one example: `python build_examples.py --example delphi --execute`
- Build all except C++Builder: `python build_examples.py --exclude cppbuilder --execute`

From `SDK`, use `python examples/build_examples.py ...` instead.

The driver auto-discovers Visual Studio `MSBuild.exe` with `vswhere.exe`, auto-loads RAD Studio `rsvars.bat` for Delphi and C++Builder projects, and supports `--dry-run` plus `TONCUT_SDK_EXAMPLES_DRY_RUN=0` in the same way as the SDK test runner.
The driver accepts only `--platform Win32`, matching the production plugin ABI.

## Delphi

- Open `../examples/delphi/CsvImportExport/CsvImportExport.dproj`
- Build the `Win32` target
- Output: `../examples/delphi/CsvImportExport/Win32/<Config>/CsvImportExportDelphi.plg`

## C++Builder

Not compiled or tested by the maintainers; provided as-is. If you hit a problem, please open an issue or pull request (see the notice in `../README.md`).

- Open `../examples/cppbuilder/CsvImportExport/CsvImportExport.cbproj`
- Build the `Win32` target
- Output: `../examples/cppbuilder/CsvImportExport/bin/Win32/<Config>/CsvImportExportCppBuilder.plg`

## Visual Studio C++

- Open `../examples/msvc/CsvImportExport/CsvImportExport.sln`
- Build `Debug|Win32` or `Release|Win32`
- Output: `../examples/msvc/CsvImportExport/bin/<Config>/CsvImportExportMsvc.plg`

## C#

- Open `../examples/csharp/CsvImportExport/CsvImportExport.sln`
- Build `Debug|Win32` or `Release|Win32`
- Native output: `../examples/csharp/CsvImportExport/bin/<Config>/CsvImportExportCSharp.plg`
- Managed output: `../examples/csharp/CsvImportExport/bin/<Config>/TonCutCsv.Managed.dll`

## Notes

- every native example is configured to emit `.plg` directly
- the Delphi project search path already points into `../include/pascal`
- the C++ examples use only `../include/cpp` and `../examples/shared/cpp`
- the Delphi SDK example and the translated native SDK header both use quad-word record alignment
- the shipped starter examples now cover CSV import/export plus single-sheet PLT result export
