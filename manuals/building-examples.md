# Building The Examples

Every example builds a 32-bit (Win32) DLL with the `.plg` extension. TonCut
Desktop is a 32-bit process and cannot load any other kind of plugin.

## Scripted Builds

From `SDK/examples`:

- Build all examples: `python build_examples.py --execute`
- Build one example: `python build_examples.py --example delphi --execute`
- Build all except C++Builder: `python build_examples.py --exclude cppbuilder --execute`

From `SDK`, use `python examples/build_examples.py ...` instead.

The driver auto-discovers Visual Studio `MSBuild.exe` with `vswhere.exe`, auto-loads RAD Studio `rsvars.bat` for Delphi and C++Builder projects, and supports `--dry-run` plus `TONCUT_SDK_EXAMPLES_DRY_RUN=0` in the same way as the SDK test runner.
The driver accepts only `--platform Win32`, matching the production plugin ABI.

## Delphi

- Open `../examples/delphi/CsvImportExport/CsvImportExport.dproj`
- Build the `Win32` target
- Output: `../examples/delphi/CsvImportExport/Win32/<Config>/CsvImportExportDelphi.plg`
- The library source `CsvImportExportDelphi.dpr` sets `{$E plg}` (output
  extension), `{$A8}` (quad-word record alignment, as in TonCut) and stops
  with a fatal message when the target is not Win32. It exports
  `TcpInitializeV2`, which creates the plugin, calls `Initialize` itself
  (TonCut never does), and returns `nil` instead of raising.

## C++Builder

Not compiled or tested by the maintainers; provided as-is. If you hit a problem, please open an issue or pull request (see the notice in `../README.md`).

- Open `../examples/cppbuilder/CsvImportExport/CsvImportExport.cbproj`
- Build the `Win32` target
- Output: `../examples/cppbuilder/CsvImportExport/bin/Win32/<Config>/CsvImportExportCppBuilder.plg`
- The project has no module definition file. Check the built `.plg` with
  `tdump` and add a `.def` file if `TcpInitializeV2` is exported under a
  decorated name.

## Visual Studio C++

- Open `../examples/msvc/CsvImportExport/CsvImportExport.sln`
- Build `Debug|Win32` or `Release|Win32`
- Output: `../examples/msvc/CsvImportExport/bin/<Config>/CsvImportExportMsvc.plg`
- `CsvImportExport.def` exports `TcpInitializeV2` under its plain name. Win32
  `__stdcall` would otherwise decorate it as `_TcpInitializeV2@16`, and TonCut
  would not find it. Check with `dumpbin /exports`.

## C#

- Open `../examples/csharp/CsvImportExport/CsvImportExport.sln`
- Build `Debug|Win32` or `Release|Win32`
- Native output (the plugin TonCut loads): `../examples/csharp/CsvImportExport/bin/<Config>/CsvImportExportCSharp.plg`
- Managed output: `../examples/csharp/CsvImportExport/bin/<Config>/TonCutCsv.Managed.dll`
- `CsvImportExport.Native.def` exports `TcpInitializeV2` under its plain name.
- The plugin is the native C++ shim. The shipped C# shim compiles the native C++ starter (`CsvImportExportPluginBase`, `CsvCodec`) and never loads managed code, so `TonCutCsv.Managed.dll` is not needed at run time. Ship it next to the `.plg` only after you add your own bridge from the shim to it. See `support-by-language.md`.

## Installing A Built Plugin

1. Close TonCut Desktop.
2. Copy the `.plg` file into the `Plugins\` folder next to `TonCut.exe`, or
   into a subfolder of it, together with any DLL your own code loads. The
   extension must be lowercase `.plg`. The shipped starters need no other
   file.
3. Start TonCut and open Options -> Plugins. The plugin is listed by its
   title. "Not compatible" means its `EngineVersion` is not `24`; a load error
   message means the export or the DLL itself could not be loaded.

## Notes

- every native example is configured to emit `.plg` directly
- the Delphi project search path already points into `../include/pascal`
- the C++ examples use only `../include/cpp` and `../examples/shared/cpp`
- the Delphi SDK example and the translated native SDK header both use quad-word record alignment
- the shipped starter examples cover CSV import/export plus single-sheet result
  export (HPGL cutting paths or CSV sheet layout)
