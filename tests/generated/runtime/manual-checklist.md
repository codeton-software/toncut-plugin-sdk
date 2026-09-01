# Manual SDK Test Checklist

## Build

- Build Delphi ContractProbe: `msbuild generated\probes\delphi\ContractProbe.dproj /p:Config=Debug /p:Platform=Win32`
- Build Delphi ContractHostHarness: `msbuild generated\harness\delphi\ContractHostHarness.dproj /p:Config=Debug /p:Platform=Win32`
- Build C++Builder ContractProbe: `msbuild generated\probes\cppbuilder\ContractProbe.groupproj /p:Config=Debug /p:Platform=Win32`
- Build MSVC ContractProbe: `msbuild generated\probes\msvc\ContractProbe.sln /p:Configuration=Debug /p:Platform=Win32`
- Build C# ContractProbe solution: `msbuild generated\probes\csharp\ContractProbe.sln /restore /p:Configuration=Debug /p:Platform=Win32`
- Build Delphi starter example: `msbuild ..\examples\delphi\CsvImportExport\CsvImportExport.dproj /p:Config=Debug /p:Platform=Win32`
- Build C++Builder starter example: `msbuild ..\examples\cppbuilder\CsvImportExport\CsvImportExport.groupproj /p:Config=Debug /p:Platform=Win32`
- Build MSVC starter example: `msbuild ..\examples\msvc\CsvImportExport\CsvImportExport.sln /p:Configuration=Debug /p:Platform=Win32`
- Build C# starter example: `msbuild ..\examples\csharp\CsvImportExport\CsvImportExport.sln /restore /p:Configuration=Debug /p:Platform=Win32`

## Runtime Smoke

- Build the Delphi harness: `msbuild generated\harness\delphi\ContractHostHarness.dproj /p:Config=Debug /p:Platform=Win32`
- Run the generated runner from the `SDK/tests` directory: `python generated\runtime\run_manual_checks.py`
- The generated runner is non-interactive: it executes the managed probe and the native ContractProbe plugins only.
- Or invoke the harness manually per probe plugin: `generated\harness\delphi\Win32\Debug\ContractHostHarness.exe <plugin.plg> ..\examples\shared\csv\example.csv generated\runtime\manual-output`
- Runtime report JSON: `generated\runtime\manual-runtime-report.json`
- Runtime logs directory: `generated\runtime\logs`

## Starter Behavior

- Starter examples are built in the automated loop, but their import/export behavior still needs a richer TonCut host double than the current harness provides.
- Sample CSV fixture: `..\examples\shared\csv\example.csv`
- Expected CSV export path: `generated\runtime\manual-output\manual-export.csv`
- Expected PLT export path: `generated\runtime\manual-output\manual-result.plt`

## Record Results

- Copy `generated\runtime\manual-results.template.json` to `generated\runtime\manual-results.json` and set each status to `pass`, `fail`, `pending`, or `not-applicable`.
- Use `python tools/run_sdk_tests.py report` to review artifact status, runtime logs, and your saved results.
