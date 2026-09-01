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

    function GetPriority(): TStockPriority; safecall;
    procedure SetPriority(aPriority: TStockPriority); safecall;

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
    property Priority: TStockPriority read GetPriority write SetPriority;

    property CutShiftHorzLimit: Integer read GetCutShiftHorzLimit write SetCutShiftHorzLimit;
    property CutShiftVertLimit: Integer read GetCutShiftVertLimit write SetCutShiftVertLimit;
    property EffectiveCutShiftHorzLimit: Integer read GetEffectiveCutShiftHorzLimit;
    property EffectiveCutShiftVertLimit: Integer read GetEffectiveCutShiftVertLimit;

    property ExtractionCost: TTcPrice read GetExtractionCost write SetExtractionCost;

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
