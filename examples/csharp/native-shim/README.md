# C# Native Shim

This folder is the Win32 half of the C# SDK example. It owns the `ITcPlugin` ABI, exports `TcpInitializeV2`, emits `CsvImportExportCSharp.plg` into `..\CsvImportExport\bin\$(Configuration)\`, and also contains the starter PLT result export implementation.

The shim stays intentionally close to the native C++ example. Use it as the insertion point for your bridge into `..\managed-core\TonCutCsv.Managed.csproj`. CSV parsing and serialization stay on the managed side; PLT result export stays native in the shim starter. The support boundary is documented in `SDK/manuals/support-by-language.md`.
