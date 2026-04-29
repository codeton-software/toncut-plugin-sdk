# C# CsvImportExport

Open `CsvImportExport.sln` in Visual Studio 2019 and build `Debug|Win32` or `Release|Win32`. The native project emits `CsvImportExportCSharp.plg`, and the managed project places `TonCutCsv.Managed.dll` in the same output folder.

This SDK example ships the managed CSV core and the native `TcpInitializeV2` boundary together. The native shim also includes the starter PLT result export path. The remaining bridge between those two halves is still the project-specific step; see `SDK/manuals/building-examples.md` and `SDK/manuals/support-by-language.md`.
