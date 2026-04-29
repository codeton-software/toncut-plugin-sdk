# Delphi CsvImportExport

Open `CsvImportExport.dproj` in RAD Studio and build the `Win32` target. The project emits `CsvImportExportDelphi.plg` directly into `Win32\Release` or `Win32\Debug`.

The project search path is already wired to `SDK/include/pascal`. For the SDK-level walkthrough, use `SDK/manuals/building-examples.md`, `SDK/manuals/plugin-contract-and-abi.md`, and `SDK/manuals/csv-schema.md`.

The starter covers CSV import/export plus single-sheet PLT result export. The example also sets Delphi record field alignment to quad word (`{$A8}`) to match the TonCut desktop plugin ABI.
