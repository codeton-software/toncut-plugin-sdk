# C++Builder CsvImportExport

> This example has not been compiled or tested by the maintainers and is provided as-is. If you find a problem, please open an issue or pull request in the SDK repository (see `SDK/README.md`).

Open `CsvImportExport.cbproj` or `CsvImportExport.groupproj` in C++Builder and build the `Win32` target. The project emits `CsvImportExportCppBuilder.plg` directly into `bin\Win32\Release` or `bin\Win32\Debug`.

This example uses only SDK-local sources: `SDK/examples/shared/cpp` for the reusable C++ starter logic and `SDK/include/cpp/TonCutPluginSdk.hpp` for the translated host contract. The starter covers CSV import/export plus single-sheet result export (HPGL cutting paths or a CSV sheet layout). The project has no `.def` file: check the built `.plg` with `tdump` and add one if `TcpInitializeV2` is exported under a decorated name. For the broader package guide, use `SDK/manuals/building-examples.md` and `SDK/manuals/support-by-language.md`.
