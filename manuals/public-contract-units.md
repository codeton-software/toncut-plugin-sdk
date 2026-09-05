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
