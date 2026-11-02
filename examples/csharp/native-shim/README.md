# C# Native Shim

This folder is the Win32 half of the C# SDK example. It owns the `ITcPlugin` ABI, exports `TcpInitializeV2`, emits `CsvImportExportCSharp.plg` into `..\CsvImportExport\bin\$(Configuration)\`, and also contains the starter result export (HPGL cutting paths or a CSV sheet layout). This shim is the plugin TonCut loads; TonCut does not load .NET assemblies directly.

The shim stays intentionally close to the native C++ example. As shipped it compiles the native C++ starter (`CsvImportExportPluginBase`, `CsvCodec`), so CSV parsing, serialization and result export are all native and no managed code is loaded. Use it as the insertion point for your own bridge into `..\managed-core\TonCutCsv.Managed.csproj`; only then does the plugin need `TonCutCsv.Managed.dll` next to it. The support boundary is documented in `SDK/manuals/support-by-language.md`.
