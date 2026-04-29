# Shared CSV Example

`example.csv` is the round-trip sample used by the SDK starter plugins. Its size values are written in millimeters, and the starter plugins convert them to and from TonCut internal units with `cLengthMultiplier`. `MaterialWidth` is only used for `mk1D`; for `mk2D` and `mkUnknown`, the examples treat it as `0`. The full column layout is documented in `../../../manuals/csv-schema.md`.
