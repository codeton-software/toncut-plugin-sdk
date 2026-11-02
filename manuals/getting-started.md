# Getting Started

This SDK targets TonCut Desktop 8.5, plugin engine interface version 24
(`cEngineVersion`). The full Plugin API reference is at
https://docs.toncut.com/tc-plugin-sdk/.

## How TonCut Finds A Plugin

- TonCut Desktop is a 32-bit (Win32) application. Build every plugin for
  Win32; a 64-bit DLL cannot be loaded.
- A plugin is a DLL with the extension `.plg`, in lowercase: the extension
  test is case-sensitive.
- TonCut scans the `Plugins\` folder next to `TonCut.exe`, including its
  subfolders, at startup.
- The DLL must export `TcpInitializeV2` under exactly that name. It is the only
  export TonCut resolves.
- `ITcPlugin.Name` must be unique across all installed plugins and should be
  plain ASCII. A duplicate name aborts loading the remaining plugins.
- `ITcPlugin.EngineVersion` must return exactly `cEngineVersion` (24). Any
  other value is not an error message: TonCut lists the plugin as "Not
  compatible" in Options -> Plugins and never activates it.

## Minimal Path

1. Read `plugin-contract-and-abi.md` for the host contract, the entry point
   and the ABI rules.
2. Choose the starter closest to your toolchain under `../examples/`.
3. Build it for Win32 so the output is already a `.plg` file.
4. Copy the built `.plg` into `Plugins\` next to `TonCut.exe` and restart
   TonCut. The C# starter needs only its native `.plg`; its managed DLL is used
   only after you add your own bridge to it.
5. Check Options -> Plugins: the plugin must be listed and active.

## SDK Files You Will Touch First

- Pascal contract: `../include/pascal/uITcPlugin.pas`
- Host services: `../include/pascal/uITonCut.pas`
- Common C++ contract: `../include/cpp/TonCutPluginSdk.hpp`
- Shared CSV sample: `../examples/shared/csv/example.csv`

## Starter Behavior

The shipped examples all implement one combined starter plugin:

- `Features = [feImport, feExport, feSaveResultToFile, feAbout]`; only what is
  implemented is advertised (there is no `feConfigure`)
- `.csv` registered for import and export (`etImport`, `etExport`)
- `.plt` (cutting paths, HPGL) and `.csv` (sheet layout with placed parts and
  waste) registered for result export (`etExportResults`)
- `GetPlotterInfo` returns a valid plotter description; TonCut requires one
  whenever a result or plot save feature is advertised
- `About` shows a message box only when TonCut passes a window handle
- `IsMyFile` validates the extension and the required header
- `LoadFile` fills TonCut's staging collections without any dialog, converting
  CSV millimeters to TonCut's 0.01 mm units with `cLengthMultiplier`
- `SaveFile` exports the same CSV schema back out in millimeters
- `SaveResult` writes one solution sheet as HPGL cutting paths or as a layout
  CSV, then sets `IsSaved`
- every method that returns a `TTcpResult` reports its outcome through it (in
  C++ it then returns `S_OK`), and no method lets an exception escape

See `csv-schema.md` for the file formats and the exact import semantics.
