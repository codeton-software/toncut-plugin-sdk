unit uITcPlotterInfo;

interface

uses
  uICommon;

type
  ITcPlotterInfo = interface
    ['{6706EAE7-3E78-4841-AAD0-7B2D3F85551E}']

    // Getters & setters.
    function GetPlotterType(): TTcPlotterType; safecall;
    procedure SetPlotterType(aPlotterType: TTcPlotterType); safecall;

    function GetMaterialKinds(): TMaterialKinds; safecall;
    procedure SetMaterialKinds(aMaterialKinds: TMaterialKinds); safecall;

    function GetAxisX(): TTcAxisDirection; safecall;
    procedure SetAxisX(aAxisX: TTcAxisDirection); safecall;
    function GetAxisY(): TTcAxisDirection; safecall;
    procedure SetAxisY(aAxisY: TTcAxisDirection); safecall;
    function GetSizeX(): Cardinal; safecall;
    procedure SetSizeX(aSizeX: Cardinal); safecall;
    function GetSizeY(): Cardinal; safecall;
    procedure SetSizeY(aSizeY: Cardinal); safecall;

    function GetCanCrossCuts(): Boolean; safecall;
    procedure SetCanCrossCuts(aCanCrossCuts: Boolean); safecall;
    function GetFullCutsOnly(): Boolean; safecall;
    procedure SetFullCutsOnly(aFullCutsOnly: Boolean); safecall;

    function GetCanCutAnyShapes(): Boolean; safecall;
    procedure SetCanCutAnyShapes(aCanCutAnyShapes: Boolean); safecall;

    function GetStripCuts(): TStripCutting; safecall;
    procedure SetStripCuts(aStripCuts: TStripCutting); safecall;
    function GetMaxStripeWidth(): Integer; safecall;
    procedure SetMaxStripeWidth(aMaxWidth: Integer); safecall;

    function GetCutsDepthOn(): Boolean; safecall;
    procedure SetCutsDepthOn(aCutsDepthOn: Boolean); safecall;
    function GetCutsDepth(): Cardinal; safecall;
    procedure SetCutsDepth(aCutsDepth: Cardinal); safecall;
    function GetCutsDepthIncMargins(): Boolean; safecall;
    procedure SetCutsDepthIncMargins(aCutsDepthIncMargins: Boolean); safecall;

    function GetTwoDimensionMoves(): Boolean; safecall;
    procedure SetTwoDimensionMoves(aTwoDimensionMoves: Boolean); safecall;
    function GetPrefferedDirection(): TTcMoveDirection; safecall;
    procedure SetPrefferedDirection(aPrefferedDirection: TTcMoveDirection); safecall;

    function GetMarginWest(): Cardinal; safecall;
    procedure SetMarginWest(aMarginWest: Cardinal); safecall;
    function GetMarginNorth(): Cardinal; safecall;
    procedure SetMarginNorth(aMarginNorth: Cardinal); safecall;
    function GetMarginEast(): Cardinal; safecall;
    procedure SetMarginEast(aMarginEast: Cardinal); safecall;
    function GetMarginSouth(): Cardinal; safecall;
    procedure SetMarginSouth(aMarginSouth: Cardinal); safecall;

    function GetBridgeMoveDirection(): TTcMoveDirection; safecall;
    procedure SetBridgeMoveDirection(aBridgeMoveDirection: TTcMoveDirection); safecall;
    function GetBridgeSize(): Cardinal; safecall;
    procedure SetBridgeSize(aBridgeSize: Cardinal); safecall;
    function GetHeadSize(): Cardinal; safecall;
    procedure SetHeadSize(aHeadSize: Cardinal); safecall;
    function GetHeadKnifeSpace(): Cardinal; safecall;
    procedure SetHeadKnifeSpace(aHeadKnifeSpace: Cardinal); safecall;

    function GetDefaultRotation(): Integer; safecall;
    procedure SetDefaultRotation(aDefaultRotation: Integer); safecall;
    function GetDefaultMirror(): TMirrors; safecall;
    procedure SetDefaultMirror(aDefaultMirror: TMirrors); safecall;

    // Others.
    procedure Assign(const aOther: ITcPlotterInfo); safecall;

    // Properties.
    property PlotterType: TTcPlotterType read GetPlotterType write SetPlotterType;
    property MaterialKinds: TMaterialKinds read GetMaterialKinds write SetMaterialKinds;

    property AxisX: TTcAxisDirection read GetAxisX write SetAxisX;
    property AxisY: TTcAxisDirection read GetAxisY write SetAxisY;
    property SizeX: Cardinal read GetSizeX write SetSizeX;
    property SizeY: Cardinal read GetSizeY write SetSizeY;

    property CanCrossCuts: Boolean read GetCanCrossCuts write SetCanCrossCuts;
    property FullCutsOnly: Boolean read GetFullCutsOnly write SetFullCutsOnly;
    property CanCutAnyShapes: Boolean read GetCanCutAnyShapes write SetCanCutAnyShapes;

    property StripCuts: TStripCutting read GetStripCuts write SetStripCuts;
    property MaxStripeWidth: Integer read GetMaxStripeWidth write SetMaxStripeWidth;

    property CutsDepthOn: Boolean read GetCutsDepthOn write SetCutsDepthOn;
    property CutsDepth: Cardinal read GetCutsDepth write SetCutsDepth;
    property CutsDepthIncMargins: Boolean read GetCutsDepthIncMargins write SetCutsDepthIncMargins;

    property TwoDimensionMoves: Boolean read GetTwoDimensionMoves write SetTwoDimensionMoves;
    property PrefferedDirection: TTcMoveDirection read GetPrefferedDirection write SetPrefferedDirection;

    property MarginWest: Cardinal read GetMarginWest write SetMarginWest;
    property MarginNorth: Cardinal read GetMarginNorth write SetMarginNorth;
    property MarginEast: Cardinal read GetMarginEast write SetMarginEast;
    property MarginSouth: Cardinal read GetMarginSouth write SetMarginSouth;

    property BridgeMoveDirection: TTcMoveDirection read GetBridgeMoveDirection write SetBridgeMoveDirection;
    property BridgeSize: Cardinal read GetBridgeSize write SetBridgeSize;
    property HeadSize: Cardinal read GetHeadSize write SetHeadSize;
    property HeadKnifeSpace: Cardinal read GetHeadKnifeSpace write SetHeadKnifeSpace;

    property DefaultRotation: Integer read GetDefaultRotation write SetDefaultRotation;
    property DefaultMirror: TMirrors read GetDefaultMirror write SetDefaultMirror;
  end;

implementation

end.
