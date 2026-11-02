# C# CsvImportExport

Open `CsvImportExport.sln` in Visual Studio 2019 and build `Debug|Win32` or `Release|Win32`. The native project emits `CsvImportExportCSharp.plg`, and the managed project places `TonCutCsv.Managed.dll` in the same output folder.

TonCut loads only the native `CsvImportExportCSharp.plg`: the plugin is the C++ native shim, which as shipped uses the native C++ CSV code and the native result export (HPGL cutting paths or a CSV sheet layout) and never loads `TonCutCsv.Managed.dll`. The managed DLL is a C# version of the CSV logic; deploy it only after you write your own bridge from the shim to it; see `SDK/manuals/building-examples.md` and `SDK/manuals/support-by-language.md`.
