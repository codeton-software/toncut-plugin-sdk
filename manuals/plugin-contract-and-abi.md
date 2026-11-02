# Plugin Contract And ABI

## Source Of Truth

The SDK ships the public Pascal contract directly:

- `../include/pascal/uITcPlugin.pas`
- `../include/pascal/uITcPluginCommon.pas`
- `../include/pascal/uITonCut.pas`
- `../include/pascal/uITcEnumExtensionsCallback.pas`
- `../include/pascal/*.pas`

For non-Delphi plugins, the translated C++ view lives in:

- `../include/cpp/TonCutPluginSdk.hpp`

## Platform

TonCut Desktop is a 32-bit Windows (Win32, x86) process. Every plugin, in
every language, must be a Win32 DLL. The C++ header refuses to compile for any
other target (`static_assert(sizeof(void*) == 4)`).

## Discovery

- TonCut scans `<folder of TonCut.exe>\Plugins\` and its subfolders at startup.
- Only files ending in lowercase `.plg` are considered; the test is
  case-sensitive.
- A missing `TcpInitializeV2` export, a `LoadLibrary` failure, a `nil` result
  or an exception during loading shows a plugin load error, and the plugin is
  not listed.
- `ITcPlugin.Name` identifies the plugin. It must be unique across all
  installed plugins: a duplicate raises during the startup scan and aborts
  loading the remaining plugins. TonCut narrows `Name` and `Title` to ANSI
  short strings (at most 255 characters), so keep `Name` plain ASCII. `Name`
  is also the key that ties a cutting device to its driver plugin
  (`IDevice.Driver`) and the backup file name `<Name>Config.json`.

## Entry Point

TonCut resolves one export, `TcpInitializeV2`, declared by the host as:

```pascal
function TcpInitializeV2(const aRegRoot: PChar; aLanguageId: Integer;
  aTonCut: ITonCut): ITcPlugin; stdcall;
```

- In C and C++ the Delphi interface result is a hidden out parameter passed
  **first**:

  ```cpp
  extern "C" void __stdcall TcpInitializeV2(
    toncut::ITcPlugin** aResult, const wchar_t* aRegRoot,
    int aLanguageId, toncut::ITonCut* aTonCut);
  ```

  `toncut::TTcPluginInitialize` in the C++ header is the matching function
  pointer type.
- MSVC decorates a Win32 `__stdcall` export as `_TcpInitializeV2@16`. Use a
  module definition (`.def`) file with `EXPORTS TcpInitializeV2` (or an
  `/EXPORT:` linker option) so the exported name is exactly `TcpInitializeV2`.
- `aRegRoot` is a temporary UTF-16 string: copy it. It is a key below
  `HKEY_CURRENT_USER`, of the form
  `\SOFTWARE\Codeton\TonCut\<version>\Plugins\<file>.plg`.
- `aTonCut` is the host service object. Keep a reference if you need it after
  the call, and release it in `Finalize`.
- **The host never calls `ITcPlugin.Initialize`.** The entry point must create
  the plugin object and call `Initialize` itself.
- The returned object carries exactly one reference, owned by the host, which
  the host releases at unload. The host never calls `QueryInterface` on it
  (`ITcPlugin` has no GUID). Leave the result `nil` on failure and never let an
  exception escape the entry point.

## Lifecycle

1. Load: `EngineVersion`, then `UiScale` (set once), then `Name`, `Title`,
   `Version`.
2. `LoadConfig` is called when the plugin's registry key already exists, so
   not on the very first run and not for incompatible plugins.
3. For an active plugin TonCut calls `EnumExtensions` three times
   (`etImport`, `etExport`, `etExportResults`) to build its file filters.
4. `LanguageId` is set on every state change and when the user switches the
   UI language.
5. Unload: `Finalize`, then the final `Release`, then `FreeLibrary`
   immediately. This happens at shutdown and before a plugin auto-update.
   Stopping a plugin in Options does not unload it. Every object the plugin
   created and every host object it kept must reach a reference count of zero
   by then.

## Version Gate

- The plugin is activated only when `EngineVersion` equals the host's
  `cEngineVersion` exactly. This SDK and TonCut Desktop 8.5 use `24`.
- A mismatch is silent: no error message. The plugin is listed as "Not
  compatible" in Options -> Plugins and never activated; `UiScale`, `Name`,
  `Title` and `Version` are still called.
- Rebuild every plugin against the SDK of the TonCut version it targets.

## Plugin Version (`TTcpVersion`)

`TTcpVersion` is a `UInt64` of four 16-bit fields, high to low:
`major.minor.build.revision`, shown as `a.b.c.d`. Build it with
`(major shl 48) or (minor shl 32) or (build shl 16) or revision`;
`toncut::MakeTcpVersion` in the C++ header and `MakeTcpVersion` in the Delphi
example (`uCsvCommon.pas`) do exactly that. TonCut compares versions as
strings when it looks for plugin updates.

## Professional Edition

When `Professional` returns `True`, import, export, result saving, plotting
and accept-solution export require the Professional edition of TonCut; other
editions show a message and abort the operation.

## Results And Error Handling

TonCut tests only these `TTcpResult` values:

| Call | Meaning of the result |
| --- | --- |
| `IsMyFile` | `cprOK` picks the plugin at once; `cprMaybe` makes it a candidate (the last candidate in scan order wins); anything else ignores it |
| `LoadFile` | `cprOK` opens the Import dialog; `cprCancel` stops silently; anything else shows "Error reading file" |
| `SaveFile` | `cprOK` is success; anything else, `cprCancel` included, shows "Error writing file" |
| `SaveResult`, `SavePlot`, `BatchSaveResult`, `BatchSavePlot` | anything other than `cprOK` is silent |
| `Configure`, `About`, `EnumExtensions`, `LoadConfig`, `SaveConfig` | ignored |

`cprFailed`, `cprException`, `cprNotImplemented` and the other codes all just
mean "not OK"; `cprNothing`, `cprNotInitialized`, `cprMoreData` and `cprNo`
have no special host meaning.

**Never let an exception or a failed `HRESULT` escape a plugin method.** TonCut
calls the plugin through `safecall`: an exception leaving a Delphi method, or a
failed `HRESULT` returned by a C++ method, is raised inside TonCut, which marks
the plugin as failed, disables it and shows a generic plugin error with the
plugin name. The exception text is discarded, and a few calls are not even
wrapped by the host. Catch everything, return a `TTcpResult`, and show your own
message (owned by `aWindow`) when the user needs details. In C++ a method with
a `TTcpResult` out parameter should return `S_OK` and report the outcome
through that parameter.

## Threading And Windows

All calls arrive on TonCut's main (UI) thread, one at a time. A plugin that
pumps window messages can be re-entered. `aWindow` is the window that owns the
current operation, not always the main form: the import frame for `LoadFile`,
the main form for `SaveFile`, the modal Save results or Plot dialog for result
and plot calls, and the calling dialog for `Configure` and `About`. It may be
`0`; do not show UI without a window.

## Features, Extensions And Commands

`ITcPlugin.Features` decides which host commands use the plugin:

| Flag | Host effect |
| --- | --- |
| `feImport` | only enables `IsMyFile` auto-detection (Open dialog "All files", drag and drop, temporary-file import, command line); choosing the plugin's own filter calls `LoadFile` directly |
| `feExport` | not read by the host |
| `feSaveResultToFile`, `feSavePlotToFile` | enable "Save one" (a single unsaved page selected) |
| `feBatchSaveResultToFile`, `feBatchSaveResultToFolder`, `feBatchSavePlotToFile`, `feBatchSavePlotToFolder` | enable "Save all" |
| any save flag | lists the plugin in the Save results dialog |
| `fePlot` / `feBatchPlot` | enables the Plot command; `feBatchPlot` makes it call `BatchPlot` instead of `Plot` |
| `feConfigure`, `feAbout` | enable the Settings and About buttons; `Configure` and `About` are called only then |

Advertise only what you implement.

File-dialog filters come only from `EnumExtensions`. Call the callback only
inside `EnumExtensions`, once per filter, with the type TonCut passed in. The
filter is built as `Name (*ext)|*ext`, so the extension must include the
leading dot (`.csv`). `etImport` feeds the Import dialog, `etExport` the Save
data, Export project and accept-solution export dialogs, and
`etExportResults` the Save results dialog.

**`GetPlotterInfo` is mandatory whenever any result or plot save flag is
set.** TonCut copies the returned `ITcPlotterInfo`; a `nil` result fails the
plugin and disables it. Return a valid object (the starters implement a
minimal one: `StarterPlotterInfo.hpp` in C++, `TStarterPlotterInfo` in the
Delphi example). Its `MaterialKinds` must contain every material kind the
plugin can save: the Save results dialog disables pages of any other kind.
Its `AxisX`, `AxisY`, `DefaultRotation` and `DefaultMirror` take part in the
effective output frame of the pages TonCut prepares for the plugin's save and
plot calls (`SolutionCuts`, `CalcPoint`); set them to match the target
machine or file format. For a plugin that saves plots
(`feSavePlotToFile` and the batch plot-save flags), pages whose material's
cutting device names a different driver plugin are also disabled.

For batch saves TonCut passes `stFolder` when `feBatchSaveResultToFolder` or
`feBatchSavePlotToFolder` is set (`aPath` is a folder and the plugin chooses
the file names), otherwise `stFile` (`aPath` is the chosen file; TonCut
appends the chosen extension when the user typed none and asks before
overwriting). It calls `BatchSaveResult` when a batch result flag is set,
otherwise `BatchSavePlot`.

After a successful `BatchSaveResult`, TonCut marks as saved only the pages
whose `ISolutionSheet.IsSaved` the plugin set to `True`. After a successful
`SaveResult` TonCut marks the page itself, but "Save one" and the next-unsaved
selection read the flag, so set it in both cases. The flag is not persisted.

## Import Staging (`LoadFile`)

- `LoadFile` receives new, empty in-memory staging collections (devices,
  materials, bands, projects, pieces, sheets), never the live data. Lookups
  such as `FindByTitle` see only what this call added.
- After `cprOK` TonCut shows its Import dialog: the user chooses what to
  import, and TonCut merges inside a database transaction. Materials and bands
  are matched by name, sheets are merged by content with their quantities
  summed, and the user may replace the pieces and stock of a new project.
  Devices the plugin adds to the staging collection are ignored.
- On any other result, or an exception, everything staged is discarded.

Create objects for an import with the collection factories
`IMaterials.CreateMaterial`, `IProjects.CreateProject`,
`IFormats.CreateFormat`, `ISheets.CreateSheet`, `IBands.CreateBand` and
`IDevices.CreateDevice`. They are plain constructors: no dialog, never `nil`,
temporary negative IDs, and the object is not inserted until you call `Add`.

`ITonCut.CreateMaterial`, `ITonCut.CreateProject` and `ITonCut.CreateBand`
are interactive: each opens a modal dialog, returns `nil` when the user
cancels, and on OK adds the object to the **live** database at once, even if
the user later cancels the import. Do not use them in an import, and never
`Add` their result to a collection again.

- Give every new staged material a `Device` taken from `ITonCut.Devices`.
- A 2D material has `Width = 0`; a 1D material's `Width` is the bar width, and
  a 1D piece always has the width of its material.
- `IMaterials.FindByTitle(aTitle, aKind, aWidth, aThickness)` is an exact,
  case-sensitive match on all four values (pass width `0` for non-1D
  materials).
- When `ITonCut.UsingProjects` is false, TonCut assigns every piece to its
  single project and overwrites `IFormat.Project`. When it is true and a piece
  has no project, TonCut creates a project named after the imported file.
- `BeginUpdate`/`EndUpdate`/`IsUpdating` exist on `IProjects`, `IFormats`,
  `ISheets` and `IDevices` (not on `IMaterials`, `IBands`, `IResults` or
  `ITemplates`). They are optional during `LoadFile` but must be balanced.
- `IFormat.Description` is the piece name shown in TonCut; `Identifier` is a
  code shown by some label modes and in barcodes. `IFormat.Priority` uses
  `cPiecePriorityDefault` (0, inherit the project priority),
  `cPiecePriorityNormal` (1), `cPiecePriorityHigh` (10) and
  `cPiecePriorityCritical` (100).

## Units

- Every length and position is an integer in 0.01 mm
  (`millimeters x cLengthMultiplier`, `cLengthMultiplier = 100`), whatever
  display unit the user chose (`ITonCut.Units` only affects display). This
  covers piece, material, sheet, solution and cut geometry.
- Areas (`TField`) are `Int64` in (0.01 mm)^2: `cFieldMultiplier = 10000` per
  square millimeter.
- `TRotation` (`Word`) is in 0.1 degree: `cRotation90 = 900`. It is used by
  `IFormat.Rotation`, `IFormat.RotationStep` and `ISolutionFormat.Rotation`.
- `ISolutionSheet.Rotation` is an `Integer` in whole degrees, only 0, 90, 180
  or 270.
- Not scaled: quantities, stack sizes, cut-shift limits, priorities, weights.

## Results Geometry

- `ISolution.Count` is the number of distinct layouts. `ISolutionSheet.Quantity`
  is the number of identical sheets cut with one layout. `SolutionFormats`
  lists each placement once for one sheet, so the pieces produced are the
  entries times `Quantity`. Per-sheet waste fields are for one sheet;
  `ISolution` totals already include `Quantity`.
- `ISolutionFormat.X`/`Y` is the lower corner of the bounding box of the
  placed footprint in the **native sheet frame**: origin at the sheet corner
  (0,0), X along `ISheet.Length`, Y along `ISheet.Width`, before any sheet or
  plotter rotation or mirror.
- `ISolutionWaste` lists all waste, reusable or not, in the same native
  frame: `Length` along X, `Width` along Y, `Field` in `TField`.
- `ISolutionSheet.CalcPoint`/`CalcPointF` map a native point to the effective
  output frame (sheet rotation and mirror plus the plotter's default rotation
  and mirror). Units in equal units out (0.01 mm); there is no scaling.
  `UnCalcPoint`/`UnCalcPointF` are the inverse.
- `ISolutionSheet.SolutionCuts` are **already** in the effective output frame.
  Do not pass cut coordinates through `CalcPoint`/`CalcPointF`. TonCut fills
  the cuts only before a plot or save call.
- `CalcEffectiveLayout` returns the sheet size (swapped for 90 and 270
  degrees) and the sheet edging (trim), not material margins, rotated and
  mirrored, in 0.01 mm.
- To write plotter units, scale by plotter units per millimeter divided by
  `cLengthMultiplier`. For HPGL (40 units per millimeter) that is 0.4 per
  TonCut unit.

## Object Lifetime

Host objects are ordinary reference-counted interfaces. `ITonCut` may be kept
until `Finalize`. Do not keep the `LoadFile` staging collections, the
`SaveFile` collections (they are live data), `ISolution`/`ISolutionSheet`, or
the `ITcEnumExtensionsCallback` after the call that passed them returns.

## ABI Mapping Rules

The non-Delphi examples follow these mapping rules:

- Delphi `safecall` becomes `HRESULT` with the parameters in order, `var`/`out`
  parameters as pointers, and the function result as one trailing out pointer
- `WideString` becomes `BSTR`. The caller owns and frees input strings; an
  output `BSTR` is allocated by the callee with `SysAllocString*` and freed by
  the caller with `SysFreeString`
- an output interface pointer carries one reference the caller must
  `Release`. Set out slots to `nullptr` before the call: a Delphi callee
  releases whatever the slot held
- `set of enum` becomes a bitmask with the same storage width as the Delphi
  set, one bit per ordinal (`FeatureMask`, `MaterialKindMask`, `MirrorMask`)
- an open-array argument becomes its data pointer immediately followed by the
  hidden high-bound argument (`length - 1`)
- method order matches the Pascal declarations exactly, overloads and
  property accessors included; properties themselves occupy no slot. Pascal
  overloads get distinct C++ names (`IndexOfByObject`, `IndexOfById`, ...)
  because MSVC may reorder same-named virtual overloads, but the slot never
  changes
- every exposed C++ interface is either explicitly opaque or a contiguous
  prefix of the Pascal vtable (the projected interfaces are complete);
  selecting later methods while omitting earlier slots is ABI-unsafe
- an explicitly opaque C++ interface exposes the three-method `IUnknown`
  prefix only; this makes ownership operations (`QueryInterface`, `AddRef`, and
  `Release`) source-usable without claiming support for later Pascal slots
- a `Reserved...` method keeps the vtable aligned past a slot C++ must not
  call (`ReservedGetAlgorithmData`)
- `IUnknown` reference counting is preserved exactly
- Delphi Win32 record alignment is quad word (`{$A8}` / pack 8)
- `TcpInitializeV2` uses Delphi's hidden interface-result parameter on native C++ exports

### Type Sizes

| Delphi | C++ | Size |
| --- | --- | --- |
| `Boolean` | `DelphiBool` (`unsigned char`, `0`/`1`) | 1 byte |
| enumerations | `enum : std::uint8_t` | 1 byte |
| `TTcpFeatures` | `std::uint16_t` bitmask | 2 bytes |
| `TConfigurationParts`, `TOrnaments`, `TMirrors`, `TMaterialKinds` | `std::uint8_t` bitmask | 1 byte |
| `Integer` / `Cardinal` | `int` / `unsigned` | 4 bytes |
| `Word`, `TRotation` | `unsigned short` | 2 bytes |
| `Int64`, `TField` | `std::int64_t` | 8 bytes |
| `TTcpVersion` (`UInt64`) | `std::uint64_t` | 8 bytes |
| `Double`, `TDateTime`, `TTcPrice`, `TTcWeight` | `double` | 8 bytes |
| `Single` | `float` | 4 bytes |
| `WideString` | `BSTR` | pointer |
| `THandle` (window) | `HWND` | pointer |

### `IMaterial.Algorithm`

`IMaterial.Algorithm` is a `WideString` (`BSTR` in C++) since the 2026-11
contract correction at engine version 24; its two slots, `GetAlgorithm` and
`SetAlgorithm`, did not move. Earlier SDKs declared a Delphi `String` there,
which cannot cross a module boundary: plugins built against an older SDK must
not use `IMaterial.Algorithm`.

## Portability Boundary

The public floating-point ABI uses Delphi `Double`, which aligns the Pascal SDK
with the published C++ and C++Builder declarations. Non-Delphi plugins still
need to follow the documented `safecall`/`HRESULT`, `BSTR`, interface, and
method-order mappings.

The contract generator enforces these projection rules. It stops with an error
when a C++ interface skips or reorders a Pascal method, grows beyond the Pascal
contract, uses an undocumented overload alias or reserved slot, or becomes
opaque without being listed as an intentional opaque interface.
