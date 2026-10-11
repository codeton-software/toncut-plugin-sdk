unit uISheet;

interface

uses
  uICommon,
  uIRectangle,
  uIMaterial,
  uISheetDefects,
  uINotifyEvent,
  uIIdChangeEvent,
  uISheetDefectChangeEvent,
  uITcAlgorithmData;

const
  // ISheet.PricePerSqM when the stock item has no price of its own; a
  // supplied price is finite and >= 0, so this value cannot collide with
  // one, and an explicit 0 stays a real 0.
  cStockPriceAbsent = -1;

type
  ISheet = interface
    ['{3D92A70F-6B18-45C4-A8E1-7C204F6B9D35}']

    function GetId(): Int64; safecall;
    procedure SetId(aId: Int64); safecall;

    function GetWidth(): Cardinal; safecall;
    procedure SetWidth(aWidth: Cardinal); safecall;

    function GetLength(): Cardinal; safecall;
    procedure SetLength(aLength: Cardinal); safecall;

    function GetQuantity(): Integer; safecall;
    procedure SetQuantity(aQuantity: Integer); safecall;

    function GetStackSize(): Cardinal; safecall;
    procedure SetStackSize(aSize: Cardinal); safecall;

    function GetOrnament(): TOrnament; safecall;
    procedure SetOrnament(aOrnament: TOrnament); safecall;

    function GetIdentifier(): WideString; safecall;
    procedure SetIdentifier(const aIdentifier: WideString); safecall;

    function GetDescription(): WideString; safecall;
    procedure SetDescription(const aDescription: WideString); safecall;

    function GetMaterial(): IMaterial; safecall;
    procedure SetMaterial(const aMaterial: IMaterial); safecall;

    function GetEdging(): IRectangle; safecall;
    function GetMinEdgeDistance(): IRectangle; safecall;

    // Stock priority as a NUMBER, cStockPriorityMin..cStockPriorityMax
    // (0..100), higher = consume earlier; 'low' = cStockPriorityLow (0),
    // 'normal' = cStockPriorityNormal (10, the default). Soft: it enters the
    // sheet score and only breaks ordering ties. Values outside the range are
    // rejected. ABI NOTE: these are the same vtable slots (same GUID) that
    // used to carry the 1-byte TOldStockPriority enum; the signature changed
    // in place, as IFormat.Priority did for pieces. This is NOT merely "must
    // be recompiled": a safecall function returns through a hidden result
    // pointer, so a stale plugin calling GetPriority passes a pointer to a
    // 1-byte local and the engine writes 4 bytes into it (memory
    // corruption), and a stale SetPriority(spNormal) arrives here as
    // priority 0 = LOW. Loading a plugin built against the enum is undefined
    // behaviour; plugins MUST be rebuilt against the new SDK.
    function GetPriority(): Integer; safecall;
    procedure SetPriority(aPriority: Integer); safecall;

    function GetCutShiftHorzLimit(): Integer; safecall;
    procedure SetCutShiftHorzLimit(aLimit: Integer); safecall;
    function GetCutShiftVertLimit(): Integer; safecall;
    procedure SetCutShiftVertLimit(aLimit: Integer); safecall;

    function GetEffectiveCutShiftHorzLimit(): Integer; safecall;
    function GetEffectiveCutShiftVertLimit(): Integer; safecall;

    function GetExtractionCost(): TTcPrice; safecall;
    procedure SetExtractionCost(aCost: TTcPrice); safecall;

    function GetCustomData(): WideString; safecall;
    procedure SetCustomData(const aData: WideString); safecall;
    function GetAlgorithmData(): ITcAlgorithmData; safecall;

    function GetDefects(): ISheetDefects; safecall;
    function GetHoles(): ISheetDefects; safecall;

    function GetAvailableQuantity(): Cardinal; safecall;
    function GetField(): TField; safecall;
    function GetFieldOfAll(): TField; safecall;

    function IsStandard(): Boolean; safecall;

    procedure Assign(const aSheet: ISheet); safecall;

    function GetOnChange(): INotifyEvent; safecall;
    function GetOnIdChange(): IIdChangeEvent; safecall;

    function GetOnDefectAdd(): ISheetDefectChangeEvent; safecall;
    function GetOnDefectRemove(): ISheetDefectChangeEvent; safecall;
    function GetOnDefectChange(): ISheetDefectChangeEvent; safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;

    // The stock item's own price per square metre, or cStockPriceAbsent when
    // it has none (the material's PricePerSqM then applies). Setting
    // cStockPriceAbsent clears it; any other value must be finite and >= 0.
    // ABI NOTE: appended after every earlier method (same GUID), so every
    // existing vtable slot keeps its position. Engine version 24
    // (cEngineVersion) carries these slots; the host plugin gate refuses a
    // plugin built for a different engine version, and every ISheet
    // implementer must provide both methods.
    function GetPricePerSqM(): TTcPrice; safecall;
    procedure SetPricePerSqM(aPrice: TTcPrice); safecall;

    property Id: Int64 read GetId write SetId;
    property Width: Cardinal read GetWidth write SetWidth;
    property Length: Cardinal read GetLength write SetLength;
    property Quantity: Integer read GetQuantity write SetQuantity;
    property StackSize: Cardinal read GetStackSize write SetStackSize;
    property Ornament: TOrnament read GetOrnament write SetOrnament;
    property Identifier: WideString read GetIdentifier write SetIdentifier;
    property Description: WideString read GetDescription write SetDescription;
    property Material: IMaterial read GetMaterial write SetMaterial;
    property Edging: IRectangle read GetEdging;
    property MinEdgeDistance: IRectangle read GetMinEdgeDistance;
    property Priority: Integer read GetPriority write SetPriority;

    property CutShiftHorzLimit: Integer read GetCutShiftHorzLimit write SetCutShiftHorzLimit;
    property CutShiftVertLimit: Integer read GetCutShiftVertLimit write SetCutShiftVertLimit;
    property EffectiveCutShiftHorzLimit: Integer read GetEffectiveCutShiftHorzLimit;
    property EffectiveCutShiftVertLimit: Integer read GetEffectiveCutShiftVertLimit;

    property ExtractionCost: TTcPrice read GetExtractionCost write SetExtractionCost;
    property PricePerSqM: TTcPrice read GetPricePerSqM write SetPricePerSqM;

    property CustomData: WideString read GetCustomData write SetCustomData;
    // Mutable, typed access to the unit-aware algorithm data owned by this sheet.
    property AlgorithmData: ITcAlgorithmData read GetAlgorithmData;

    property Defects: ISheetDefects read GetDefects;
    property Holes: ISheetDefects read GetHoles;

    property AvailableQuantity: Cardinal read GetAvailableQuantity;
    property Field: TField read GetField;
    property FieldOfAll: TField read GetFieldOfAll;

    property OnChange: INotifyEvent read GetOnChange;
    property OnIdChange: IIdChangeEvent read GetOnIdChange;

    property OnDefectAdd: ISheetDefectChangeEvent read GetOnDefectAdd;
    property OnDefectRemove: ISheetDefectChangeEvent read GetOnDefectRemove;
    property OnDefectChange: ISheetDefectChangeEvent read GetOnDefectChange;
  end;


implementation

end.
