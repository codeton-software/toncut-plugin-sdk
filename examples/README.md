# SDK Examples

Run these commands from `SDK/examples`. If you start in `SDK`, use `python examples/build_examples.py ...` instead.

## Build Driver

- Build all examples: `python build_examples.py --execute`
- Build one example: `python build_examples.py --example delphi --execute`
- Build all except C++Builder: `python build_examples.py --exclude cppbuilder --execute`
- Shortcut for the same exclusion: `python build_examples.py --skip-cppbuilder --execute`
- Print commands without executing them: `python build_examples.py --dry-run`

The script auto-discovers Visual Studio `MSBuild.exe` with `vswhere.exe` and auto-loads RAD Studio `rsvars.bat` for Delphi and C++Builder projects.
It accepts only the production `Win32` platform; the TonCut plugin ABI is not
compatible with a Win64 build.

Note: the C++Builder example has not been compiled or tested by the maintainers and is provided as-is; see `SDK/README.md` for how to report problems.

## Example Ids

- `delphi`
- `cppbuilder`
- `msvc`
- `csharp`

## Distinct TonCut Identities

- Delphi: `CsvImportExportDelphi.plg`, plugin name `CsvImportExportTemplateDelphi`, title `CSV Import/Export + PLT Result Template (Delphi)`
- C++Builder: `CsvImportExportCppBuilder.plg`, plugin name `CsvImportExportTemplateCppBuilder`, title `CSV Import/Export + PLT Result Template (C++Builder)`
- MSVC: `CsvImportExportMsvc.plg`, plugin name `CsvImportExportTemplateMsvc`, title `CSV Import/Export + PLT Result Template (MSVC)`
- C#: `CsvImportExportCSharp.plg`, plugin name `CsvImportExportTemplateCSharp`, title `CSV Import/Export + PLT Result Template (C#)`
