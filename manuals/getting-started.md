# Getting Started

TonCut Desktop loads `.plg` files from the `Plugins\` tree, resolves the exported `TcpInitializeV2` entrypoint, and expects an initialized `ITcPlugin` result.

In Delphi, that is written as a normal function result. In native C++ exports, Delphi passes the interface result as a hidden first `ITcPlugin**` parameter.

## Minimal Path

1. Read `plugin-contract-and-abi.md` to understand the host contract.
2. Choose the starter closest to your toolchain under `../examples/`.
3. Build the example so the output file already has the `.plg` extension.
4. Copy the built plugin into TonCut Desktop's `Plugins\` directory tree.

## SDK Files You Will Touch First

- Pascal contract: `../include/pascal/uITcPlugin.pas`
- Host services: `../include/pascal/uITonCut.pas`
- Common C++ contract: `../include/cpp/TonCutPluginSdk.hpp`
- Shared CSV sample: `../examples/shared/csv/example.csv`

## Starter Behavior

The shipped examples all implement one combined starter plugin:

- `Features = [feImport, feExport, feSaveResultToFile, feConfigure, feAbout]`
- `.csv` registered for both import and export
- `.plt` registered for result export
- `Configure` is implemented as a starter placeholder and is advertised through `feConfigure`
- `About` shows a simple message box for a quick host-integration check
- `About` is advertised through `feAbout`
- `IsMyFile` validates extension and required header
- `LoadFile` populates TonCut collections
- `LoadFile` reads CSV size columns as millimeters and scales them by `cLengthMultiplier`
- `SaveFile` exports the same CSV schema back out in millimeters
- `SaveResult` exports one solution sheet as PLT by transforming `ISolutionSheet` geometry
- batch result save and plot callbacks still return `cprNotImplemented`
