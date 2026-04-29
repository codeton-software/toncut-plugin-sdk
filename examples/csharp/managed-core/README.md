# C# Managed Core

This project contains the managed CSV logic for the C# SDK example: schema constants, CSV parsing, CSV serialization, and row-level validation.

The native shim still owns the TonCut ABI surface and the starter PLT result export path. In a finished plugin, the shim forwards CSV text or row data into this library and keeps all `HRESULT`, `BSTR`, and vtable concerns on the native side. See `SDK/manuals/building-examples.md` for the full build flow.
