# Shared C++ Example Helpers

This directory contains the reusable native starter code used by the VS C++, C++Builder, and C# shim examples.

- `CsvCodec.*` implements the shared CSV parser and serializer
- `CsvImportExportPluginBase.*` implements the combined CSV import/export plus result-export plugin logic (HPGL cutting paths or a CSV sheet layout)
- `StarterPlotterInfo.hpp` is a minimal `ITcPlotterInfo`; TonCut requires a non-null plotter description whenever a result or plot save feature is advertised
- `../../../include/cpp/TonCutPluginSdk.hpp` provides the translated TonCut plugin contract
