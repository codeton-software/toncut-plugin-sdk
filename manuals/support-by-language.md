# Support By Language

Every plugin, in every language, must be a 32-bit (Win32, x86) DLL with the
`.plg` extension. TonCut Desktop is a 32-bit process and cannot load a 64-bit
plugin.

| Environment | Status | Notes |
| --- | --- | --- |
| Delphi | Full native starter | Uses the shipped Pascal interfaces directly. |
| C++Builder | Native starter on the SDK C++ header (not compiled or tested by the maintainers) | Same starter as VS C++. Provided as-is; see the notice in `../README.md`. |
| VS C++ | Native starter on the SDK C++ header | CSV import/export plus single-sheet result export (HPGL cutting paths or CSV sheet layout). |
| C# | Native shim only | The plugin itself is the C++ native shim, which uses the native C++ CSV code. The C# CSV library is not called until you add your own bridge. |

## Practical Boundary

- Delphi and C++Builder can treat the Pascal units as native source contracts.
- The C++ header projects the complete vtable of the interfaces a typical
  import, export or result-export plugin needs: `ITcPlugin`, `ITonCut`,
  `ITcEnumExtensionsCallback`, `ITcPlotterInfo`, `IDevice`, `IDevices`,
  `IMaterial`, `IMaterials`, `IProject`, `IProjects`, `IFormat`, `IFormats`,
  `ISheet`, `ISheets`, `ISolution`, `ISolutionSheet`, `ISolutionFormat`,
  `ISolutionFormats`, `ISolutionWaste`, `ISolutionWastes`, `ISolutionCut` and
  `ISolutionCuts`.
- `IMaterial.Algorithm` is a `WideString` (`BSTR` in C++) since the 2026-11
  contract correction at engine version 24; plugins built against an older
  SDK must not use it (see `plugin-contract-and-abi.md`).
- Pascal overloads have distinct C++ names, for example
  `ITonCut::FormatLengthFromInt`/`FormatLengthFromExtended`,
  `ITonCut::HumanReadableFieldFromInt64`/`HumanReadableFieldFromExtended`,
  `IFormats::IndexOfByObject`/`IndexOfById`/`IndexOfByList`/`IndexOfByOther`
  and `IFormats::LoadByProjectInto`/`LoadByProject`. Each keeps its Pascal
  vtable slot.
- Interface parameters and results use their exact Pascal interface pointer
  types even when that interface remains otherwise opaque in C++. A documented
  opaque interface exposes only its `IUnknown` prefix, so callers can retain
  and release the returned pointer but cannot call its Pascal members. The
  omission is a source-language support boundary, not permission to erase ABI
  types.
- C# has no managed projection of the Pascal interfaces, and TonCut does not
  load .NET assemblies. A C# plugin is a native C++ DLL (the
  `examples/csharp/native-shim` project) that exports `TcpInitializeV2` and
  implements the TonCut interfaces in C++. As shipped, the shim uses the
  native C++ CSV code and never loads managed code. The managed project
  (`examples/csharp/managed-core`) is a C# implementation of the same CSV
  schema for you to call once you add a bridge from the shim (C++/CLI, COM,
  or a hosted runtime); that bridge is project-specific and not part of the
  SDK. Managed code runs inside the 32-bit
  TonCut process, so build it for x86 (the managed project sets
  `PlatformTarget` to `x86`).

## Machine-Readable Boundary

`tests/generated/language-support.json` derives each non-Delphi lane's support
boundary from the Pascal contract and C++ header. Every projected native
interface records omitted Pascal slots in `unsupportedMethods` and properties
with unavailable accessors in `unsupportedProperties`; `reservedMethods` lists
the slots that exist only for vtable alignment. The C# lane separates
`nativeShimSupportedInterfaces` from its empty
`directManagedSupportedInterfaces`. Pointer types that expose only ownership
operations are listed separately in `ownershipOnlyInterfaces` and
`opaquePointerTypes` (or the C# lane's `nativeShimOwnershipOnlyInterfaces` and
`nativeShimOpaquePointerTypes`) and remain in `unsupportedInterfaces` because
none of their Pascal members is callable. Documentation consumers therefore do
not need to hard-code either boundary.
