unit uIFormat;

interface

uses
  uICommon,
  uIRectangle,
  uIShape,
  uIProject,
  uIMaterial,
  uIBanding,
  uIGrinds,
  uINotifyEvent,
  uIIdChangeEvent,
  uITcAlgorithmData;

type
  IFormat = interface
    ['{9B47E250-1F63-4A8D-97C2-6E05B3D81A94}']

    function GetId(): Int64; safecall;
    procedure SetId(aId: Int64); safecall;

    function GetProject(): IProject; safecall;
    procedure SetProject(const aProject: IProject); safecall;

    function GetLength(): Cardinal; safecall;
    procedure SetLength(aLength: Cardinal); safecall;

    function GetWidth(): Cardinal; safecall;
    procedure SetWidth(aWidth: Cardinal); safecall;

    function GetQuantity(): Cardinal; safecall;
    procedure SetQuantity(aQuantity: Cardinal); safecall;

    function GetProcessedQuantity(): Cardinal; safecall;
    procedure SetProcessedQuantity(aQuantity: Cardinal); safecall;

    function GetOrnament(): TOrnaments; safecall;
    procedure SetOrnament(aOrnament: TOrnaments); safecall;

    function GetIdentifier(): WideString; safecall;
    procedure SetIdentifier(const aIdentifier: WideString); safecall;

    function GetDescription(): WideString; safecall;
    procedure SetDescription(const aDescription: WideString); safecall;

    function GetShape(): IShape; safecall;
    procedure SetShape(const aShape: IShape); safecall;

    function GetRotationStep(): TRotation; safecall;
    procedure SetRotationStep(aStep: TRotation); safecall;

    function GetRotation(): TRotation; safecall;
    procedure SetRotation(aRotation: TRotation); safecall;

    function GetMirror(): Boolean; safecall;
    procedure SetMirror(aMirror: Boolean); safecall;

    function GetMaterial(): IMaterial; safecall;
    procedure SetMaterial(const aMaterial: IMaterial); safecall;

    function GetSurplus(): Cardinal; safecall;
    procedure SetSurplus(aSurplus: Cardinal); safecall;

    function GetMargin(): Cardinal; safecall;
    procedure SetMargin(aMargin: Cardinal); safecall;

    function GetBanding(): IBanding; safecall;

    function GetGrinds(): IGrinds; safecall;

    function GetColor(): WideString; safecall;
    procedure SetColor(const aColor: WideString); safecall;

    function GetPriority(): Integer; safecall;
    procedure SetPriority(aPriority: Integer); safecall;

    function GetWeight(): Double; safecall;
    procedure SetWeight(aWeight: Double); safecall;

    function GetWeightModifier(): Double; safecall;
    procedure SetWeightModifier(aModifier: Double); safecall;

    function GetGroup(): Word; safecall;
    procedure SetGroup(aGroup: Word); safecall;
    function GetOrder(): Word; safecall;
    procedure SetOrder(aOrder: Word); safecall;

    function GetSellingPrice(): TTcPrice; safecall;
    procedure SetSellingPrice(aPrice: TTcPrice); safecall;
    function GetStorageCost(): TTcPrice; safecall;
    procedure SetStorageCost(aCost: TTcPrice); safecall;

    function GetCustomData(): WideString; safecall;
    procedure SetCustomData(const aData: WideString); safecall;
    function GetAlgorithmData(): ITcAlgorithmData; safecall;

    function GetEffectivePriority(): Integer; safecall;

    function GetLeftQuantity(): Cardinal; safecall;

    function GetTotalSurplus(): Cardinal; safecall;
    function GetTotalMargin(): Cardinal; safecall;
    function GetTotalLength(): Cardinal; safecall;
    function GetTotalWidth(): Cardinal; safecall;
    function GetTotalField(): TField; safecall;

    function GetGrossLength(): Cardinal; safecall;
    function GetGrossWidth(): Cardinal; safecall;

    function GetShapePathAsString(aRotation: Double; aMirror: Boolean; aWithOffset, aBBoxOrigin: Boolean): WideString; safecall;
    procedure GetShapeOffsetInsideBoundingBox(aRotation: Double; aMirror: Boolean; var aX, aY: Double); safecall;

    procedure Assign(const aOther: IFormat; aProject: IProject); safecall;

    function GetOnChange(): INotifyEvent; safecall;
    function GetOnIdChange(): IIdChangeEvent; safecall;

    procedure UpdateEffectivePriority(aTriggerChange: Boolean); safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;

    property Id: Int64 read GetId write SetId;
    property Project: IProject read GetProject write SetProject;
    property Length: Cardinal read GetLength write SetLength;
    property Width: Cardinal read GetWidth write SetWidth;
    property Quantity: Cardinal read GetQuantity write SetQuantity;
    property ProcessedQuantity: Cardinal read GetProcessedQuantity write SetProcessedQuantity;
    property Ornament: TOrnaments read GetOrnament write SetOrnament;
    property Identifier: WideString read GetIdentifier write SetIdentifier;
    property Description: WideString read GetDescription write SetDescription;

    property Shape: IShape read GetShape write SetShape;
    property RotationStep: TRotation read GetRotationStep write SetRotationStep;
    property Rotation: TRotation read GetRotation write SetRotation;
    property Mirror: Boolean read GetMirror write SetMirror;

    property Material: IMaterial read GetMaterial write SetMaterial;
    property Surplus: Cardinal read GetSurplus write SetSurplus;
    property Margin: Cardinal read GetMargin write SetMargin;
    property Banding: IBanding read GetBanding;
    property Grinds: IGrinds read GetGrinds;
    property Color: WideString read GetColor write SetColor;
    property Priority: Integer read GetPriority write SetPriority;

    property Weight: Double read GetWeight write SetWeight;
    property WeightModifier: Double read GetWeightModifier write SetWeightModifier;

    property Group: Word read GetGroup write SetGroup;
    property Order: Word read GetOrder write SetOrder;

    property SellingPrice: TTcPrice read GetSellingPrice write SetSellingPrice;
    property StorageCost: TTcPrice read GetStorageCost write SetStorageCost;

    property CustomData: WideString read GetCustomData write SetCustomData;
    // Mutable, typed access to the unit-aware algorithm data owned by this format.
    property AlgorithmData: ITcAlgorithmData read GetAlgorithmData;

    property EffectivePriority: Integer read GetEffectivePriority;

    property LeftQuantity: Cardinal read GetLeftQuantity;

    property TotalSurplus: Cardinal read GetTotalSurplus;
    property TotalMargin: Cardinal read GetTotalMargin;
    property TotalLength: Cardinal read GetTotalLength;
    property TotalWidth: Cardinal read GetTotalWidth;
    property TotalField: TField read GetTotalField;

    property GrossLength: Cardinal read GetGrossLength;
    property GrossWidth: Cardinal read GetGrossWidth;

    property OnChange: INotifyEvent read GetOnChange;
    property OnIdChange: IIdChangeEvent read GetOnIdChange;
  end;


implementation

end.
