# Support By Language

| Environment | Status | Notes |
| --- | --- | --- |
| Delphi | Full native starter | Uses the shipped Pascal interfaces directly. |
| C++Builder | Native starter on the SDK C++ subset | Covers CSV import/export plus single-sheet PLT result export. |
| VS C++ | Native starter on the SDK C++ subset | Covers CSV import/export plus single-sheet PLT result export. |
| C# | Split starter scaffold | Ships the native `TcpInitializeV2` boundary, native PLT result export, and the managed CSV core. |

## Practical Boundary

- Delphi and C++Builder can treat the Pascal units as native source contracts.
- VS C++ and C++Builder expose the contiguous `ISolutionSheet` vtable prefix
  through `CalcEffectiveLayout`, which contains the methods needed by the PLT
  starter. The wider Desktop API still needs careful ABI translation work
  before you expand the prefix.
- The native C++ view exposes the complete `ISolutionCut` contract, including
  `NeedShift`, `CalcLength`, and `ShiftDistance`, in the Pascal vtable order.
- Interface parameters and results use their exact Pascal interface pointer
  types even when that interface remains otherwise opaque in C++. A documented
  opaque interface exposes only its `IUnknown` prefix, so callers can retain
  and release the returned pointer but cannot call its Pascal members. The
  omission is a source-language support boundary, not permission to erase ABI
  types.
- C# has no direct managed projection of the public Pascal interfaces. Its
  supported interface surface belongs to `examples/csharp/native-shim`; a
  project-specific bridge is still required to connect that native shim to
  `examples/csharp/managed-core` for CSV logic.

## Machine-Readable Boundary

`tests/generated/language-support.json` derives each non-Delphi lane's support
boundary from the Pascal contract and C++ header. Every projected native
interface records omitted Pascal slots in `unsupportedMethods` and properties
with unavailable accessors in `unsupportedProperties`. The C# lane separates
`nativeShimSupportedInterfaces` from its empty
`directManagedSupportedInterfaces`. Pointer types that expose only ownership
operations are listed separately in `ownershipOnlyInterfaces` and
`opaquePointerTypes` (or the C# lane's `nativeShimOwnershipOnlyInterfaces` and
`nativeShimOpaquePointerTypes`) and remain in `unsupportedInterfaces` because
none of their Pascal members is callable. Documentation consumers therefore do
not need to hard-code either boundary.
