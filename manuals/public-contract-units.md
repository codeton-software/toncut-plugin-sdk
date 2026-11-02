# Public Contract Units

The SDK ships the public Pascal interface units unchanged under:

- `../include/pascal/`

The current mirror contains 55 units and is byte-for-byte synchronized with
the canonical TonCut Desktop interface sources. `uITcPluginCommon.pas` sets
`cEngineVersion = 24`, which carries the `ISheet.Priority` break, the
appended `ISheet.PricePerSqM` slots, the appended `IBand.PreviewColor` and
`IFormat.PreviewColor` slots, and the `soAllPermutations` stock order described
below.

## TonCut Contract Units

- `uITcEnumExtensionsCallback.pas`
- `uITcPlugin.pas`
- `uITcPluginCommon.pas`
- `uITonCut.pas`

## Kernel Interface Units

All `.pas` files under `../include/pascal/` are included in the SDK package. That folder contains the copied public Desktop interface surface for materials, devices, bands, projects, formats, sheets, results, templates, solutions, plugin lifecycle, and host services.

`uITcAlgorithmData.pas` declares typed access to opaque, implementation-owned
data. This SDK documents only its public interface signatures: it does not
publish or prescribe any algorithm-specific payload, schema, member paths,
keys, values, defaults, or examples, and it does not publish an internals
configuration tree. The current contracts also keep `IDevice.MinCutSize` and
`IDevice.MinCutDistance` as independent values, publish solution-sheet
waste-field metrics, and append solution-cut shift distance and solution-waste
holes without disturbing their established vtable prefixes. The C++
solution-cut view exposes `NeedShift`, then `CalcLength`, then the appended
`ShiftDistance` slot in the same order as the Pascal interface.

`IDevice` gained `DefaultRotation` (`0`, `90`, `180` or `270`, default `0`) and
`DefaultMirror` (a `TMirrors` set, default empty) in TonCut 8.5. They are the
device's persisted default orientation, appended after the existing members so
every established vtable slot keeps its position. The plugin interface version
stays `cEngineVersion = 24`. The C++ header projects the complete `IDevice`
interface, including `DefaultRotation` and `DefaultMirror`.

`IMaterial.Algorithm` (`GetAlgorithm`/`SetAlgorithm`) is a `WideString` (`BSTR`
in C++) since the 2026-11 contract correction at engine version 24. Earlier
SDKs declared a Delphi `String` there, which cannot cross a module boundary;
the two slots did not move and `cEngineVersion` stays `24`. Plugins built
against an older SDK must not use `IMaterial.Algorithm`.

**BREAKING CHANGE:** `ISheet.Priority` (`GetPriority`/`SetPriority`) changed
from the 1-byte `TStockPriority` enum to a numeric `Integer`,
`cStockPriorityMin`..`cStockPriorityMax` (`0`..`100`, higher means consume
earlier), mirroring the earlier `IFormat.Priority` piece-priority change.
`'low'` is `cStockPriorityLow` (`0`) and `'normal'` is `cStockPriorityNormal`
(`10`, the default); it is soft and enters the sheet score, breaking ordering
ties only. The old enum survives as `TOldStockPriority` for its legacy
`'normal'`/`'low'` labels only. `GetPriority`/`SetPriority` keep their
existing vtable slots and the same interface GUID, but the signature changed
in place — this is **not** merely a recompile notice. A `safecall` function
returns through a hidden result pointer, so a plugin built against the old
enum calling `GetPriority` passes a pointer to a 1-byte local while the
engine writes 4 bytes into it (memory corruption), and a stale
`SetPriority(spNormal)` arrives as priority `0` = LOW. Loading a plugin built
against the enum is undefined behaviour: **every plugin binary must be
rebuilt against this SDK before it is loaded again.** The C++ view of
`ISheet` in `TonCutPluginSdk.hpp` projects the complete interface, so
`GetPriority`/`SetPriority` appear there with the `int` signature; see "ABI
Mapping Rules" in `plugin-contract-and-abi.md` for why a projection may not
skip slots.

`ISheet` also gained two methods, `GetPricePerSqM`/`SetPricePerSqM`, appended
at the end of the interface directly after `EndUpdate`, and the
`PricePerSqM: TTcPrice` property built on them; the interface GUID is
unchanged. The property is declared next to `ExtractionCost`, but interface
properties occupy no vtable slots, so only the method order matters. A stock
item's `PricePerSqM` is either its own per-square-metre price or
`cStockPriceAbsent` (`-1`) when it has none, in which case the owning
material's `PricePerSqM` applies instead — any plugin that reads `ISheet`
pricing must apply that fallback itself, the engine does not resolve it for
the caller. Setting `cStockPriceAbsent` clears a stock item's own price; any
other value supplied to `SetPricePerSqM` must be finite and `>= 0`. Because
the two methods are appended after every earlier method, no existing vtable
slot moved, but every class implementing `ISheet` must add both methods to
remain a valid implementation (host-side; plugins only consume `ISheet`). The
C++ `ISheet` view declares both methods at its end.

`IBand` and `IFormat` each gained `GetPreviewColor`/`SetPreviewColor`, appended
at the end of the interface directly after `EndUpdate`, and a
`PreviewColor: TTcColor` property built on them; both interface GUIDs are
unchanged. The properties are declared next to `Surplus` (`IBand`) and
`StorageCost` (`IFormat`), but properties occupy no vtable slots. `uICommon.pas`
adds the `TTcColor = Integer` type and two special values:

- an ordinary `TTcColor` is a 24-bit RGB value packed as `$RRGGBB` (red in
  bits 16..23, blue in bits 0..7) - not the VCL `TColor` byte order;
- `clTcNone` (`-1`) means no preview color is assigned, which is the default;
- `clTcRandom` (`-2`) asks the host to derive a stable color from the item's
  `Id`;
- every other negative value is invalid.

No existing slot of either interface moved, but every class implementing
`IBand` or `IFormat` must add both methods to remain a valid implementation.
Plugins only consume these interfaces. In the C++ header `IBand` stays opaque
(its `IUnknown` prefix only), and the complete `IFormat` view ends with
`GetPreviewColor`/`SetPreviewColor`.

`TSheetOrder` in `uICommon.pas` gains `soAllPermutations`, appended after
`soCustom` as ordinal `4`; the ordinals of `soFromLarge`, `soFromSmall`,
`soRandom` and `soCustom` are unchanged. It selects a search over alternative
stock-item orders that keeps the best result (the engine's `allPermutations`
stock-order direction).
No interface method takes or returns `TSheetOrder`, so no vtable slot changes,
but code that switches over `TSheetOrder` must handle the new value. The C++
header does not declare `TSheetOrder`.

**Engine version 24.** `cEngineVersion` advances to `24` for this SDK: version
24 carries the `ISheet.Priority` break, the appended `ISheet.PricePerSqM`
slots, the appended `IBand`/`IFormat` `PreviewColor` slots, and the
`soAllPermutations` stock order. The host's plugin gate refuses a plugin whose reported engine version
does not match, so a plugin built against an earlier SDK is not loaded, and a
plugin built against this SDK is not loaded by an older host that lacks the
new slots. Rebuild every plugin against this SDK.
