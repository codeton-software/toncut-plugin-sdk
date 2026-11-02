# CSV Schema

The starter plugins read and write two CSV layouts and one HPGL file:

- the **data CSV** (import and export of pieces and stock sheets);
- the **layout CSV** (result export of one cut sheet with its placed parts and
  waste);
- the **cutting-path PLT** (result export of one cut sheet as HPGL).

All CSV files use these defaults:

- UTF-8 with BOM
- comma delimiter
- CRLF line endings
- required header row
- header names are matched case-insensitively after trimming surrounding whitespace
- RFC4180-style quoting

## Data CSV

```text
RecordType,ProjectTitle,MaterialTitle,MaterialKind,MaterialWidth,MaterialThickness,Length,Width,Quantity,Identifier,Description
```

### Row Rules

- `RecordType=FORMAT` maps to `IFormat` (a piece to cut)
- `RecordType=SHEET` maps to `ISheet` (a stock sheet or bar)
- any other non-empty `RecordType` rejects the import
- `ProjectTitle` applies only to `FORMAT` rows
- `MaterialKind` uses `mk1D`, `mk2D`, or `mkUnknown`
- `MaterialWidth`, `MaterialThickness`, `Length`, and `Width` are whole
  millimeters in the CSV
- a missing, invalid (including negative), or zero `Quantity` defaults to `1`
  on import
- `MaterialWidth` is only significant for `mk1D` (the bar width); for `mk2D`
  and `mkUnknown` the starters use `0` on import and write `0` on export
- for an `mk1D` piece the starters set `IFormat.Width` to the material width;
  the CSV `Width` of a 1D `FORMAT` row is ignored

### Units

TonCut stores every length and position as an integer in 0.01 mm, whatever
display unit the user chose (`ITonCut.Units` affects display only). The
starters multiply CSV millimeters by `cLengthMultiplier` (`100`) on import and
divide by it, rounding to the nearest millimeter, on export. A value that does
not fit in a 32-bit `Cardinal` after scaling rejects the import.

### Sample File

Use `../examples/shared/csv/example.csv` as the baseline round-trip sample.

```text
FORMAT,Wardrobe Job,Birch plywood 18 mm,mk2D,0,18,1500,1000,2,P-001,Tall side panel
FORMAT,Wardrobe Job,Birch plywood 18 mm,mk2D,0,18,980,450,4,P-002,Adjustable shelf
SHEET,,Birch plywood 18 mm,mk2D,0,18,3200,2400,2,S-001,Raw stock sheet
```

### Import (`LoadFile`)

`LoadFile` receives new, empty staging collections, never the live data. The
starters fill them without any dialog:

- materials, projects, pieces and sheets are created with the staging
  collection factories (`IMaterials.CreateMaterial`, `IProjects.CreateProject`,
  `IFormats.CreateFormat`, `ISheets.CreateSheet`), filled in, and inserted with
  `Add`. The factories never show a dialog and never insert the object
  themselves.
- the starters never call `ITonCut.CreateMaterial`, `ITonCut.CreateProject` or
  `ITonCut.CreateBand` during an import: those open a modal dialog per call and
  commit the new object to the live database immediately, even if the user
  later cancels the import.
- rows that name the same material reuse it:
  `IMaterials.FindByTitle(title, kind, width, thickness)` is an exact,
  case-sensitive match on all four values, with width `0` for non-1D
  materials. On a staging collection it only sees what this import added.
- every new material gets a cutting device from the live `ITonCut.Devices`: the
  first device whose `MaterialKind` matches, otherwise the first device. An
  import fails when TonCut has no device.
- projects are used only when `ITonCut.UsingProjects` is true. Rows with the
  same `ProjectTitle` share one staged project (found with
  `IProjects.FindByTitle`). A `FORMAT` row with an empty `ProjectTitle` gets no
  project; TonCut then creates one named after the imported file. Without
  projects mode TonCut assigns every piece to its single project and the CSV
  `ProjectTitle` is ignored.
- the starters wrap the work in balanced `BeginUpdate`/`EndUpdate` calls on
  `IProjects`, `IFormats` and `ISheets`. This is optional.

After `LoadFile` returns `cprOK`, TonCut shows its Import dialog and merges the
staged data: materials are matched by name, sheets are merged by content with
their quantities summed, and the user may import into a new project. Any other
result discards everything that was staged.

### Export (`SaveFile`)

`SaveFile` receives the live piece and sheet collections. The starters only
read them and write the same schema back in millimeters. `Quantity` is written
unchanged: `IFormat.Quantity` is a `Cardinal`, and `ISheet.Quantity` is a
signed `Integer`, so a sheet quantity of `0` or less is exported as is. Such a
value does not round-trip: importing it gives `1`.

## Layout CSV (result export)

Selected in TonCut's Save results dialog through the `.csv` result filter. One
file describes one cut layout (`ISolutionSheet`).

```text
RecordType,SheetIndex,SheetQuantity,MaterialTitle,X,Y,Length,Width,Rotation,Mirrored,Identifier,Description
```

- one `SHEET` row: the stock sheet, `X`/`Y` `0`, `Length`/`Width` of the sheet,
  and its identifier and description
- one `PART` row per placed piece (`ISolutionSheet.SolutionFormats`)
- one `WASTE` row per waste rectangle (`ISolutionSheet.SolutionWastes`);
  this lists all waste, reusable or not
- `SheetIndex` is `ISolutionSheet.Index`; `SheetQuantity` is
  `ISolutionSheet.Quantity`, the number of identical sheets cut with this
  layout. The `PART` and `WASTE` rows describe one sheet, so the number of
  pieces produced is the number of `PART` rows times `SheetQuantity`
- `X`, `Y`, `Length` and `Width` are millimeters with two decimals (TonCut's
  0.01 mm resolution)
- `X`/`Y` are in the native sheet frame: origin at the sheet corner (0,0), `X`
  along the sheet length, `Y` along the sheet width, before any output
  rotation or mirror. For a part, `X`/`Y` is the lower corner of the bounding
  box of its placed footprint; `Length`/`Width` are the piece dimensions as
  entered, before rotation. For waste, `Length` runs along `X` and `Width`
  along `Y`. Map a point to the output frame with `ISolutionSheet.CalcPoint`
  only when the consumer needs that frame
- `Rotation` is the part rotation in degrees with one decimal
  (`ISolutionFormat.Rotation` is in 0.1 degree); `Mirrored` is `1` or `0`

## Cutting-Path PLT (result export)

Selected through the `.plt` result filter. The file is ASCII HPGL:
`IN;PA;`, then for each cut `PUx,y;` followed by `PDx,y;` (line) or
`BZx1,y1,x2,y2,x3,y3;` (curve), then `PU;SP0;`.

- `ISolutionSheet.SolutionCuts` are already in the effective output frame:
  TonCut has applied the sheet and plotter rotation and mirror. The starters
  write them without `CalcPoint`/`CalcPointF`.
- HPGL uses 40 plotter units per millimeter, so one TonCut unit (0.01 mm) is
  `40 / cLengthMultiplier = 0.4` plotter units.
- after a successful save the starters set `ISolutionSheet.IsSaved := True`.
