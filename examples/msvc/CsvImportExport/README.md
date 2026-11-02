# VS C++ CsvImportExport

Open `CsvImportExport.sln` in Visual Studio 2019 and build `Debug|Win32` or `Release|Win32`. The project emits `CsvImportExportMsvc.plg` directly into `bin\Debug` or `bin\Release`.

The example depends only on `SDK/examples/shared/cpp` and `SDK/include/cpp/TonCutPluginSdk.hpp`. It covers CSV import/export plus single-sheet result export (HPGL cutting paths or a CSV sheet layout). `CsvImportExport.def` exports `TcpInitializeV2` under its plain name, which Win32 `__stdcall` would otherwise decorate; the wider TonCut surface is documented in `SDK/manuals/plugin-contract-and-abi.md` and `SDK/manuals/support-by-language.md`.
