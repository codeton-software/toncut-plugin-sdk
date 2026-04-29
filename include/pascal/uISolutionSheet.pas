unit uISolutionSheet;

interface

uses
  uICommon,
  uISheet,
  uISolutionFormats,
  uISolutionWastes,
  uISolutionCuts;

type
  ISolutionSheet = interface
    ['{15810B79-2824-4D23-8EF5-19D6BA6A2606}']

    function GetSheet(): ISheet; safecall;
    function GetSolutionFormats(): ISolutionFormats; safecall;
    function GetSolutionWastes(): ISolutionWastes; safecall;
    function GetSolutionCuts(): ISolutionCuts; safecall;

    function GetQuantity(): Integer; safecall;

    function GetIndex(): Integer; safecall;
    function GetRotation(): Integer; safecall;
    function GetMirror(): TMirrors; safecall;

    function GetIsSaved(): Boolean; safecall;
    procedure SetIsSaved(aSaved: Boolean); safecall;

    function GetIsPlotted(): Boolean; safecall;
    procedure SetIsPlotted(aPlotted: Boolean); safecall;

    procedure GetEffectiveModificator(var aRotation: Integer; var aMirror: TMirrors); safecall;

    procedure GetOriginPoint(var aX, aY: Integer); safecall;
    procedure CalcPoint(var aX, aY: Integer); safecall;
    procedure UnCalcPoint(var aX, aY: Integer); safecall;
    procedure CalcPointF(var aX, aY: Double); safecall;
    procedure UnCalcPointF(var aX, aY: Double); safecall;
    procedure GetDirection(var aX, aY: Integer); safecall;

    procedure CalcEffectiveLayout(var aLength, aWidth: Cardinal; var aMarginLeft, aMarginTop, aMarginRight, aMarginBottom: Cardinal); safecall;

    function CalcRecycledField(aMinShorterRecycleSize, aMinLongerRecycleSize: Integer): TField; safecall;
    procedure CalcCutsInfo(var aCount: Integer; var aLength: Double); safecall;

    property Sheet: ISheet read GetSheet;
    property SolutionFormats: ISolutionFormats read GetSolutionFormats;
    property SolutionWastes: ISolutionWastes read GetSolutionWastes;
    property SolutionCuts: ISolutionCuts read GetSolutionCuts;

    property Quantity: Integer read GetQuantity;

    property Index: Integer read GetIndex;
    property Rotation: Integer read GetRotation;
    property Mirror: TMirrors read GetMirror;
    property IsSaved: Boolean read GetIsSaved write SetIsSaved;
    property IsPlotted: Boolean read GetIsPlotted write SetIsPlotted;
  end;

implementation

end.
