# SDK Layout

```text
SDK/
  README.md
  include/
    cpp/
      TonCutPluginSdk.hpp
    pascal/
      *.pas
  examples/
    shared/
      cpp/
        CsvCodec.cpp
        CsvCodec.hpp
        CsvImportExportPluginBase.cpp
        CsvImportExportPluginBase.hpp
      csv/
        example.csv
    delphi/
      CsvImportExport/
    cppbuilder/
      CsvImportExport/
    msvc/
      CsvImportExport/
    csharp/
      native-shim/
      managed-core/
      CsvImportExport/
  manuals/
    *.md
```

## Directory Roles

- `include/cpp` is the shared C++ view of the TonCut plugin contract.
- `include/pascal` is the copied source-of-truth Pascal contract shipped with the SDK.
- `examples/shared` contains reusable starter helpers and the sample CSV file.
- `examples/<language>` contains ready-to-open projects or solutions.
- `manuals` is the external developer documentation set for the SDK package.
