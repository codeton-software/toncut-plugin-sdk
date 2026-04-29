# Support By Language

| Environment | Status | Notes |
| --- | --- | --- |
| Delphi | Full native starter | Uses the shipped Pascal interfaces directly. |
| C++Builder | Native starter on the SDK C++ subset | Covers CSV import/export plus single-sheet PLT result export. |
| VS C++ | Native starter on the SDK C++ subset | Covers CSV import/export plus single-sheet PLT result export. |
| C# | Split starter scaffold | Ships the native `TcpInitializeV2` boundary, native PLT result export, and the managed CSV core. |

## Practical Boundary

- Delphi and C++Builder can treat the Pascal units as native source contracts.
- VS C++ and C++Builder now have the translated solution-sheet subset needed for the PLT starter, but the wider Desktop API still needs careful ABI translation work before you expand further.
- C# keeps PLT result export in `examples/csharp/native-shim` and still requires a project-specific bridge into `examples/csharp/managed-core` for CSV logic.
