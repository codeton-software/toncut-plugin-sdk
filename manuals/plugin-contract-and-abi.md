# Plugin Contract And ABI

## Source Of Truth

The SDK ships the public Pascal contract directly:

- `../include/pascal/uITcPlugin.pas`
- `../include/pascal/uITcPluginCommon.pas`
- `../include/pascal/uITonCut.pas`
- `../include/pascal/uITcEnumExtensionsCallback.pas`
- `../include/pascal/*.pas`

For non-Delphi examples, the translated C++ view lives in:

- `../include/cpp/TonCutPluginSdk.hpp`

## Host Rules

- plugin binaries must export `TcpInitializeV2`
- the export uses `stdcall`
- the returned object must implement `ITcPlugin`
- the current engine compatibility value is the one shown in the header badge of the web docs
- TonCut Desktop discovers plugins recursively under `Plugins\`
- TonCut Desktop uses `ITcPlugin.Features` to decide which optional entry points are available; set `feConfigure` if `Configure` is supported and `feAbout` if `About` is supported

## ABI Mapping Rules

The non-Delphi examples follow these mapping rules:

- Delphi `safecall` becomes `HRESULT` plus explicit out parameters
- `WideString` becomes `BSTR`
- `set of enum` becomes a bitmask with the same storage width as the Delphi set
- an open-array argument becomes its data pointer immediately followed by the
  hidden high-bound argument (`length - 1`)
- every exposed C++ interface is either explicitly opaque or a contiguous
  prefix of the Pascal vtable; selecting later methods while omitting earlier
  slots is ABI-unsafe
- an explicitly opaque C++ interface exposes the three-method `IUnknown`
  prefix only; this makes ownership operations (`QueryInterface`, `AddRef`, and
  `Release`) source-usable without claiming support for later Pascal slots
- method order matches the Pascal declarations exactly; C++ overload aliases
  may change a source-level name but never its vtable slot
- `IUnknown` reference counting is preserved exactly
- Delphi Win32 record alignment is quad word (`{$A8}` / pack 8)
- `TcpInitializeV2` uses Delphi's hidden interface-result parameter on native C++ exports

## Portability Boundary

The public floating-point ABI now uses Delphi `Double`, which aligns the Pascal SDK with the published C++, C++Builder, and planned C# declarations. Non-Delphi plugins still need to follow the documented `safecall`/`HRESULT`, `BSTR`, interface, and method-order mappings, but floating-point values now use the same cross-language ABI type.

The contract generator enforces these projection rules. It stops with an error
when a C++ interface skips or reorders a Pascal method, grows beyond the Pascal
contract, uses an undocumented overload alias, or becomes opaque without being
listed as an intentional opaque interface.
