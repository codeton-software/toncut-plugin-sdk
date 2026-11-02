# Delphi CsvImportExport

Open `CsvImportExport.dproj` in RAD Studio and build the `Win32` target. The project emits `CsvImportExportDelphi.plg` directly into `Win32\Release` or `Win32\Debug`.

The project search path is already wired to `SDK/include/pascal`. For the SDK-level walkthrough, use `SDK/manuals/building-examples.md`, `SDK/manuals/plugin-contract-and-abi.md`, and `SDK/manuals/csv-schema.md`.

The starter covers CSV import/export plus single-sheet result export (HPGL cutting paths or a CSV sheet layout). The library source sets `{$E plg}`, quad-word record alignment (`{$A8}`, as in TonCut) and refuses any target other than Win32. `TcpInitializeV2` creates the plugin and calls `Initialize` itself, because TonCut never calls it.
