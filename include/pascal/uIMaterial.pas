unit uIMaterial;

interface

uses
  System.Classes,
  uICommon,
  uIRectangle,
  uIDevice,
  uIStandardSheets,
  uINotifyEvent,
  uIIdChangeEvent,
  uIStandardSheetChangeEvent;

type
  IMaterial = interface
    ['{E46E486D-1A55-4C92-A743-064A692AC230}']

    function GetId(): Int64; safecall;
    procedure SetId(aId: Int64); safecall;

    function GetTitle(): WideString; safecall;
    procedure SetTitle(const aTitle: WideString); safecall;

    function GetKind(): TMaterialKind; safecall;
    procedure SetKind(aKind: TMaterialKind); safecall;

    function GetWidth(): Cardinal; safecall;
    procedure SetWidth(aWidth: Cardinal); safecall;

    function GetThickness(): Cardinal; safecall;
    procedure SetThickness(aThickness: Cardinal); safecall;

    function GetHasOrnament(): Boolean; safecall;
    procedure SetHasOrnament(aHasOrnament: Boolean); safecall;

    function GetCanRotate(): Boolean; safecall;
    procedure SetCanRotate(aCanRotate: Boolean); safecall;

    function GetCanMirror(): Boolean; safecall;
    procedure SetCanMirror(aCanMirror: Boolean); safecall;

    function GetSurplus(): Cardinal; safecall;
    procedure SetSurplus(aSurplus: Cardinal); safecall;

    function GetSurplusEditable(): Boolean; safecall;
    procedure SetSurplusEditable(aEditable: Boolean); safecall;

    function GetMargin(): Cardinal; safecall;
    procedure SetMargin(aMargin: Cardinal); safecall;

    function GetMarginEditable(): Boolean; safecall;
    procedure SetMarginEditable(aEditable: Boolean); safecall;

    function GetDefaultEdging(): Cardinal; safecall;
    procedure SetDefaultEdging(aEdging: Cardinal); safecall;

    function GetCuttingDimensions(): TCuttingDimensions; safecall;
    procedure SetCuttingDimensions(aCuttingDimensions: TCuttingDimensions); safecall;

    function GetBandable(): Boolean; safecall;
    procedure SetBandable(aBandable: Boolean); safecall;

    function GetGrindable(): Boolean; safecall;
    procedure SetGrindable(aGrindable: Boolean); safecall;

    function GetColorable(): Boolean; safecall;
    procedure SetColorable(aColorable: Boolean); safecall;

    function GetDevice(): IDevice; safecall;
    procedure SetDevice(const aDevice: IDevice); safecall;

    function GetAlgorithm(): String; safecall;
    procedure SetAlgorithm(const aAlgorithm: String); safecall;

    function GetQualityLevel(): TQualityLevel; safecall;
    procedure SetQualityLevel(aQualityLevel: TQualityLevel); safecall;

    function GetReuseWaste(): Boolean; safecall;
    procedure SetReuseWaste(aReuse: Boolean); safecall;

    function GetMinShorterRecycleSize(): Cardinal; safecall;
    procedure SetMinShorterRecycleSize(aSize: Cardinal); safecall;

    function GetMinLongerRecycleSize(): Cardinal; safecall;
    procedure SetMinLongerRecycleSize(aSize: Cardinal); safecall;

    function GetPrefShorterRecycleSize(): Cardinal; safecall;
    procedure SetPrefShorterRecycleSize(aSize: Cardinal); safecall;

    function GetPrefLongerRecycleSize(): Cardinal; safecall;
    procedure SetPrefLongerRecycleSize(aSize: Cardinal); safecall;

    function GetEffectiveMinShorterRecycleSize(): Cardinal; safecall;
    function GetEffectiveMinLongerRecycleSize(): Cardinal; safecall;
    function GetEffectivePrefShorterRecycleSize(): Cardinal; safecall;
    function GetEffectivePrefLongerRecycleSize(): Cardinal; safecall;

    function GetKerf(): Cardinal; safecall;
    procedure SetKerf(aKerf: Cardinal); safecall;

    function GetAllowEdgeCuts(): Boolean; safecall;
    procedure SetAllowEdgeCuts(aAllow: Boolean); safecall;

    function GetRecycleEdgingOn(): Boolean; safecall;
    procedure SetRecycleEdgingOn(aOn: Boolean); safecall;

    function GetRecycleEdging(): Cardinal; safecall;
    procedure SetRecycleEdging(aMargins: Cardinal); safecall;

    function GetStackCutting(): Boolean; safecall;
    procedure SetStackCutting(aStackCutting: Boolean); safecall;

    function GetStackSize(): Cardinal; safecall;
    procedure SetStackSize(aSize: Cardinal); safecall;

    function GetAllowPartialStack(): Boolean; safecall;
    procedure SetAllowPartialStack(aAllow: Boolean); safecall;

    function GetMinStackSize(): Cardinal; safecall;
    procedure SetMinStackSize(aSize: Cardinal); safecall;

    function GetPricePerSqM(): TTcPrice; safecall;
    procedure SetPricePerSqM(aCost: TTcPrice); safecall;
    function GetWeightOfSqM(): TTcWeight; safecall;
    procedure SetWeightOfSqM(aWeight: TTcWeight); safecall;
    function GetPricePerMeter(): TTcPrice; safecall;
    procedure SetPricePerMeter(aCost: TTcPrice); safecall;
    function GetWeightOfMeter(): TTcWeight; safecall;
    procedure SetWeightOfMeter(aWeight: TTcWeight); safecall;
    function GetCutCostPerMeter(): TTcPrice; safecall;
    procedure SetCutCostPerMeter(aCost: TTcPrice); safecall;
    function GetReuseCost(): TTcPrice; safecall;
    procedure SetReuseCost(aCost: TTcPrice); safecall;
    function GetUtilizationCostPerKg(): TTcPrice; safecall;
    procedure SetUtilizationCostPerKg(aCost: TTcPrice); safecall;
    function GetSegmentShiftCost(): TTcPrice; safecall;
    procedure SetSegmentShiftCost(aCost: TTcPrice); safecall;
    function GetSegmentRotationCost(): TTcPrice; safecall;
    procedure SetSegmentRotationCost(aCost: TTcPrice); safecall;

    function GetPriceToCostMultiplier(): Double; safecall;
    procedure SetPriceToCostMultiplier(aMultiplier: Double); safecall;
    function GetReusableWasteExpectedUsage(): Double; safecall;
    procedure SetReusableWasteExpectedUsage(aExpectedUsage: Double); safecall;

    function GetCutExcess(): Integer; safecall;
    procedure SetCutExcess(aCutExcess: Integer); safecall;
    function GetCutShiftTotalLimit(): Integer; safecall;
    procedure SetCutShiftTotalLimit(aLimit: Integer); safecall;
    function GetCutShiftHorzLimit(): Integer; safecall;
    procedure SetCutShiftHorzLimit(aLimit: Integer); safecall;
    function GetCutShiftVertLimit(): Integer; safecall;
    procedure SetCutShiftVertLimit(aLimit: Integer); safecall;

    function GetCustomData(): WideString; safecall;
    procedure SetCustomData(const aData: WideString); safecall;

    function GetStandardSheets(): IStandardSheets; safecall;

    function GetOnChange(): INotifyEvent; safecall;
    function GetOnIdChange(): IIdChangeEvent; safecall;

    function GetOnStandardSheetAdd(): IStandardSheetChangeEvent; safecall;
    function GetOnStandardSheetRemove(): IStandardSheetChangeEvent; safecall;
    function GetOnStandardSheetChange(): IStandardSheetChangeEvent; safecall;

    procedure Assign(const aOther: IMaterial); safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;

    property Id: Int64 read GetId write SetId;
    property Title: WideString read GetTitle write SetTitle;
    property Kind: TMaterialKind read GetKind write SetKind;
    property Width: Cardinal read GetWidth write SetWidth;
    property Thickness: Cardinal read GetThickness write SetThickness;
    property HasOrnament: Boolean read GetHasOrnament write SetHasOrnament;
    property CanRotate: Boolean read GetCanRotate write SetCanRotate;
    property CanMirror: Boolean read GetCanMirror write SetCanMirror;
    property Surplus: Cardinal read GetSurplus write SetSurplus;
    property SurplusEditable: Boolean read GetSurplusEditable write SetSurplusEditable;
    property Margin: Cardinal read GetMargin write SetMargin;
    property MarginEditable: Boolean read GetMarginEditable write SetMarginEditable;
    property DefaultEdging: Cardinal read GetDefaultEdging write SetDefaultEdging;
    property CuttingDimensions: TCuttingDimensions read GetCuttingDimensions write SetCuttingDimensions;

    property Bandable: Boolean read GetBandable write SetBandable;
    property Grindable: Boolean read GetGrindable write SetGrindable;
    property Colorable: Boolean read GetColorable write SetColorable;

    property Device: IDevice read GetDevice write SetDevice;
    property Algorithm: String read GetAlgorithm write SetAlgorithm;
    property QualityLevel: TQualityLevel read GetQualityLevel write SetQualityLevel;

    property ReuseWaste: Boolean read GetReuseWaste write SetReuseWaste;
    property MinShorterRecycleSize: Cardinal read GetMinShorterRecycleSize write SetMinShorterRecycleSize;
    property MinLongerRecycleSize: Cardinal read GetMinLongerRecycleSize write SetMinLongerRecycleSize;
    property PrefShorterRecycleSize: Cardinal read GetPrefShorterRecycleSize write SetPrefShorterRecycleSize;
    property PrefLongerRecycleSize: Cardinal read GetPrefLongerRecycleSize write SetPrefLongerRecycleSize;

    property EffectiveMinShorterRecycleSize: Cardinal read GetEffectiveMinShorterRecycleSize;
    property EffectiveMinLongerRecycleSize: Cardinal read GetEffectiveMinLongerRecycleSize;
    property EffectivePrefShorterRecycleSize: Cardinal read GetEffectivePrefShorterRecycleSize;
    property EffectivePrefLongerRecycleSize: Cardinal read GetEffectivePrefLongerRecycleSize;

    property Kerf: Cardinal read GetKerf write SetKerf;
    property AllowEdgeCuts: Boolean read GetAllowEdgeCuts write SetAllowEdgeCuts;
    property RecycleEdgingOn: Boolean read GetRecycleEdgingOn write SetRecycleEdgingOn;
    property RecycleEdging: Cardinal read GetRecycleEdging write SetRecycleEdging;

    property StackCutting: Boolean read GetStackCutting write SetStackCutting;
    property StackSize: Cardinal read GetStackSize write SetStackSize;
    property AllowPartialStack: Boolean read GetAllowPartialStack write SetAllowPartialStack;
    property MinStackSize: Cardinal read GetMinStackSize write SetMinStackSize;

    property PricePerSqM: TTcPrice read GetPricePerSqM Write SetPricePerSqM;
    property WeightOfSqM: TTcWeight read GetWeightOfSqM Write SetWeightOfSqM;
    property PricePerMeter: TTcPrice read GetPricePerMeter Write SetPricePerMeter;
    property WeightOfMeter: TTcWeight read GetWeightOfMeter Write SetWeightOfMeter;
    property CutCostPerMeter: TTcPrice read GetCutCostPerMeter Write SetCutCostPerMeter;
    property ReuseCost: TTcPrice read GetReuseCost Write SetReuseCost;
    property UtilizationCostPerKg: TTcPrice read GetUtilizationCostPerKg Write SetUtilizationCostPerKg;
    property SegmentShiftCost: TTcPrice read GetSegmentShiftCost Write SetSegmentShiftCost;
    property SegmentRotationCost: TTcPrice read GetSegmentRotationCost Write SetSegmentRotationCost;

    property PriceToCostMultiplier: Double read GetPriceToCostMultiplier write SetPriceToCostMultiplier;
    property ReusableWasteExpectedUsage: Double read GetReusableWasteExpectedUsage write SetReusableWasteExpectedUsage;

    property CutExcess: Integer read GetCutExcess write SetCutExcess;
    property CutShiftTotalLimit: Integer read GetCutShiftTotalLimit write SetCutShiftTotalLimit;
    property CutShiftHorzLimit: Integer read GetCutShiftHorzLimit write SetCutShiftHorzLimit;
    property CutShiftVertLimit: Integer read GetCutShiftVertLimit write SetCutShiftVertLimit;

    property CustomData: WideString read GetCustomData write SetCustomData;

    property StandardSheets: IStandardSheets read GetStandardSheets;

    property OnChange: INotifyEvent read GetOnChange;
    property OnIdChange: IIdChangeEvent read GetOnIdChange;

    property OnStandardSheetAdd: IStandardSheetChangeEvent read GetOnStandardSheetAdd;
    property OnStandardSheetRemove: IStandardSheetChangeEvent read GetOnStandardSheetRemove;
    property OnStandardSheetChange: IStandardSheetChangeEvent read GetOnStandardSheetChange;
  end;

implementation

end.
