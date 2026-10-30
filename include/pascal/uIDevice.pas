unit uIDevice;

interface

uses
  System.Classes,
  uICommon,
  uIRectangle,
  uINotifyEvent,
  uIIdChangeEvent,
  uITcAlgorithmData;

type
  IDevice = interface
    ['{2A6F1B84-9C37-4E52-B1D6-4F8A0C97E361}']

    function Clone(): IDevice; safecall;
    procedure Assign(const aOther: IDevice); safecall;

    function GetId(): Int64; safecall;
    procedure SetId(aId: Int64); safecall;

    function GetTitle(): WideString; safecall;
    procedure SetTitle(const aTitle: WideString); safecall;

    function GetDriver(): WideString; safecall;
    procedure SetDriver(const aDriver: WideString); safecall;

    function GetCanCutAnyShapes(): Boolean; safecall;
    procedure SetCanCutAnyShapes(aCanCutAnyShapes: Boolean); safecall;

    function GetCanCrossCuts(): Boolean; safecall;
    procedure SetCanCrossCuts(aCanCrossCuts: Boolean); safecall;

    function GetFullCutsOnly(): Boolean; safecall;
    procedure SetFullCutsOnly(aFullCutsOnly: Boolean); safecall;

    function GetStripCuts(): TStripCutting; safecall;
    procedure SetStripCuts(aStripCuts: TStripCutting); safecall;

    function GetMaxStripeWidth(): Integer; safecall;
    procedure SetMaxStripeWidth(aMaxWidth: Integer); safecall;

    function GetMinCutSize(): Cardinal; safecall;
    procedure SetMinCutSize(aSize: Cardinal); safecall;
    function GetMinCutDistance(): Cardinal; safecall;
    procedure SetMinCutDistance(aDistance: Cardinal); safecall;
    function GetMinEdgeDistance(): IRectangle; safecall;

    function GetEdgingCuts(): TEdgingCuts; safecall;
    procedure SetEdgingCuts(aEdgingCuts: TEdgingCuts); safecall;

    function GetOriginEdgingCuts(): TOriginEdgingCuts; safecall;
    procedure SetOriginEdgingCuts(aOriginEdgingCuts: TOriginEdgingCuts); safecall;

    function GetMaxCutDepthOn(): Boolean; safecall;
    procedure SetMaxCutDepthOn(aOn: Boolean); safecall;

    function GetMaxCutDepth(): Cardinal; safecall;
    procedure SetMaxCutDepth(aDepth: Cardinal); safecall;

    function GetFirstCutDirection(): TCutDirections; safecall;
    procedure SetFirstCutDirection(aDirection: TCutDirections); safecall;

    function GetMaxCutDepthIncludeSheetEdging(): Boolean; safecall;
    procedure SetMaxCutDepthIncludeSheetEdging(aInclude: Boolean); safecall;

    function GetMaxCutLengthByLengthOn(): Boolean; safecall;
    procedure SetMaxCutLengthByLengthOn(aOn: Boolean); safecall;

    function GetMaxCutLengthByLength(): Cardinal; safecall;
    procedure SetMaxCutLengthByLength(aLength: Cardinal); safecall;

    function GetMaxCutLengthByWidthOn(): Boolean; safecall;
    procedure SetMaxCutLengthByWidthOn(aOn: Boolean); safecall;

    function GetMaxCutLengthByWidth(): Cardinal; safecall;
    procedure SetMaxCutLengthByWidth(aLength: Cardinal); safecall;

    function GetMaterialKind(): TMaterialKind; safecall;
    procedure SetMaterialKind(aKind: TMaterialKind); safecall;

    function GetCanCutSlants(): Boolean; safecall;
    procedure SetCanCutSlants(aCan: Boolean); safecall;

    function GetLeftSlantMeasurement(): TSlantMeasurement; safecall;
    procedure SetLeftSlantMeasurement(aSlantMeasurement: TSlantMeasurement); safecall;

    function GetRightSlantMeasurement(): TSlantMeasurement; safecall;
    procedure SetRightSlantMeasurement(aSlantMeasurement: TSlantMeasurement); safecall;

    function GetCutCostPerMeter(): TTcPrice; safecall;
    procedure SetCutCostPerMeter(aCost: TTcPrice); safecall;
    function GetReuseCost(): TTcPrice; safecall;
    procedure SetReuseCost(aCost: TTcPrice); safecall;
    function GetUtilizationCost(): TTcPrice; safecall;
    procedure SetUtilizationCost(aCost: TTcPrice); safecall;
    function GetSegmentShiftCost(): TTcPrice; safecall;
    procedure SetSegmentShiftCost(aCost: TTcPrice); safecall;
    function GetSegmentRotationCost(): TTcPrice; safecall;
    procedure SetSegmentRotationCost(aCost: TTcPrice); safecall;

    function GetCustomData(): WideString; safecall;
    procedure SetCustomData(const aData: WideString); safecall;
    function GetAlgorithmData(): ITcAlgorithmData; safecall;

    function GetOnChange(): INotifyEvent; safecall;
    function GetOnIdChange(): IIdChangeEvent; safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;

    // Append interface methods to preserve existing vtable slots.
    function GetDefaultRotation(): Integer; safecall;
    procedure SetDefaultRotation(aRotation: Integer); safecall;
    function GetDefaultMirror(): TMirrors; safecall;
    procedure SetDefaultMirror(aMirror: TMirrors); safecall;

    property DefaultRotation: Integer read GetDefaultRotation write SetDefaultRotation;
    property DefaultMirror: TMirrors read GetDefaultMirror write SetDefaultMirror;

    property Id: Int64 read GetId write SetId;
    property Title: WideString read GetTitle write SetTitle;
    property Driver: WideString read GetDriver write SetDriver;
    property CanCutAnyShapes: Boolean read GetCanCutAnyShapes write SetCanCutAnyShapes;
    property CanCrossCuts: Boolean read GetCanCrossCuts write SetCanCrossCuts;
    property FullCutsOnly: Boolean read GetFullCutsOnly write SetFullCutsOnly;

    property StripCuts: TStripCutting read GetStripCuts write SetStripCuts;
    property MaxStripeWidth: Integer read GetMaxStripeWidth write SetMaxStripeWidth;

    property MinCutSize: Cardinal read GetMinCutSize write SetMinCutSize;
    property MinCutDistance: Cardinal read GetMinCutDistance write SetMinCutDistance;
    property MinEdgeDistance: IRectangle read GetMinEdgeDistance;
    property EdgingCuts: TEdgingCuts read GetEdgingCuts write SetEdgingCuts;
    property OriginEdgingCuts: TOriginEdgingCuts read GetOriginEdgingCuts write SetOriginEdgingCuts;
    property MaxCutDepthOn: Boolean read GetMaxCutDepthOn write SetMaxCutDepthOn;
    property MaxCutDepth: Cardinal read GetMaxCutDepth write SetMaxCutDepth;
    property FirstCutDirection: TCutDirections read GetFirstCutDirection write SetFirstCutDirection;
    property MaxCutDepthIncludeSheetEdging: Boolean read GetMaxCutDepthIncludeSheetEdging write SetMaxCutDepthIncludeSheetEdging;
    property MaxCutLengthByLengthOn: Boolean read GetMaxCutLengthByLengthOn write SetMaxCutLengthByLengthOn;
    property MaxCutLengthByLength: Cardinal read GetMaxCutLengthByLength write SetMaxCutLengthByLength;
    property MaxCutLengthByWidthOn: Boolean read GetMaxCutLengthByWidthOn write SetMaxCutLengthByWidthOn;
    property MaxCutLengthByWidth: Cardinal read GetMaxCutLengthByWidth write SetMaxCutLengthByWidth;

    property MaterialKind: TMaterialKind read GetMaterialKind write SetMaterialKind;
    property CanCutSlants: Boolean read GetCanCutSlants write SetCanCutSlants;
    property LeftSlantMeasurement: TSlantMeasurement read GetLeftSlantMeasurement write SetLeftSlantMeasurement;
    property RightSlantMeasurement: TSlantMeasurement read GetRightSlantMeasurement write SetRightSlantMeasurement;

    property CutCostPerMeter: TTcPrice read GetCutCostPerMeter write SetCutCostPerMeter;
    property ReuseCost: TTcPrice read GetReuseCost write SetReuseCost;
    property UtilizationCost: TTcPrice read GetUtilizationCost write SetUtilizationCost;
    property SegmentShiftCost: TTcPrice read GetSegmentShiftCost write SetSegmentShiftCost;
    property SegmentRotationCost: TTcPrice read GetSegmentRotationCost write SetSegmentRotationCost;

    property CustomData: WideString read GetCustomData write SetCustomData;
    // Mutable, typed access to the unit-aware algorithm data owned by this device.
    property AlgorithmData: ITcAlgorithmData read GetAlgorithmData;

    property OnChange: INotifyEvent read GetOnChange;
    property OnIdChange: IIdChangeEvent read GetOnIdChange;
  end;

implementation

end.
