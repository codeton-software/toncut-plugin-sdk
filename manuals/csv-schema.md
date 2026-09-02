# CSV Schema

The SDK examples all use one round-trip CSV contract:

```text
RecordType,ProjectTitle,MaterialTitle,MaterialKind,MaterialWidth,MaterialThickness,Length,Width,Quantity,Identifier,Description
```

## File Defaults

- UTF-8 with BOM
- comma delimiter
- CRLF line endings
- required header row
- header names are matched case-insensitively after trimming surrounding whitespace
- RFC4180-style quoting

## Row Rules

- `RecordType=FORMAT` maps to `IFormat`
- `RecordType=SHEET` maps to `ISheet`
- any other non-empty `RecordType` rejects the import
- `ProjectTitle` applies only to `FORMAT` rows
- `MaterialKind` uses `mk1D`, `mk2D`, or `mkUnknown`
- `MaterialWidth`, `MaterialThickness`, `Length`, and `Width` are stored in millimeters in the CSV
- a missing, invalid, or zero `Quantity` defaults to `1`
- `MaterialWidth` is only significant for `mk1D`; for `mk2D` and `mkUnknown`, the starter plugins ignore it on import and export `0`
- the starter plugins multiply those millimeter values by `cLengthMultiplier` on import and divide by `cLengthMultiplier` on export

## Sample File

Use `../examples/shared/csv/example.csv` as the baseline round-trip sample.

```text
FORMAT,Wardrobe Job,Birch plywood 18 mm,mk2D,0,18,1500,1000,2,P-001,Tall side panel
FORMAT,Wardrobe Job,Birch plywood 18 mm,mk2D,0,18,980,450,4,P-002,Adjustable shelf
SHEET,,Birch plywood 18 mm,mk2D,0,18,3200,2400,2,S-001,Raw stock sheet
```

## Import And Export Behavior

- importers always create a fresh project for each original CSV project title they encounter during `LoadFile`
- during one `LoadFile` pass, project rows reuse only the project already created earlier for that same original CSV title, even if TonCut renames it while adding
- material groups are still reused when they already exist, and the starter importers keep an original-name cache for materials before falling back to `IMaterials.FindByTitle(...)`
- the starter importers normalize material width to `0` for non-`mk1D` materials before lookup, uniqueness checks, creation, and cache-key generation
- before creating a new material group, the starter importers call `IMaterials.CheckUniqueName(...)` and refuse to create a duplicate
- when a new material group is created through `ITonCut.CreateMaterial(...)`, TonCut's material dialog already commits it to the materials collection on OK, so the starter importers must not call `IMaterials.Add(...)` again
- `LoadFile` populates `IFormats` and `ISheets`
- `LoadFile` converts CSV millimeter values into TonCut internal length units with `cLengthMultiplier`
- `SaveFile` writes the same schema back in millimeters
