# Public Contract Units

The SDK ships the public Pascal interface units unchanged under:

- `../include/pascal/`

The current mirror contains 55 units and is byte-for-byte synchronized with
the canonical TonCut Desktop interface sources. `uITcPluginCommon.pas` keeps
`cEngineVersion = 23`, the already reserved unpublished engine value.

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
`ISheet` in `TonCutPluginSdk.hpp` remains an intentional 18-method prefix
that stops before `GetEdging`, so `Priority` was never projected there and
needs no C++ change; see "ABI Mapping Rules" in `plugin-contract-and-abi.md`
for why a prefix may not skip slots.
