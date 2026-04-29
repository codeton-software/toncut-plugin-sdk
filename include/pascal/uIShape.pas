unit uIShape;

interface

uses
  uICommon,
  uINotifyEvent,
  uIBand;

type
  TShapeParamType = (sptLength, sptAngle, sptInt, sptEnum);

  IShape = interface
    ['{D9FB6E15-5D6A-46A8-8391-9BC4722A22DC}']

    function GetShapeType(): TShapeType; safecall;

    function SaveToString(aLengthUnit: TLengthUnits = luMillimeters; aAngleUnit: TAngleUnits = auRadians): WideString; safecall;
    function LoadFromString(const aString: WideString; aDefLengthUnit: TLengthUnits = luMillimeters; aDefAngleUnit: TAngleUnits = auRadians): Boolean; safecall;

    function GetNetPath(aNetLength, aNetWidth, aSurplus, aMargin: Integer): WideString; safecall;
    function GetGrossPath(aNetLength, aNetWidth, aSurplus, aMargin: Integer): WideString; safecall;

    function GetEdgeCount(): Integer; safecall;
    function GetEdgeInfo(aIndex: Integer; var aName, aTitle: WideString): Boolean; safecall;
    function GetEdgeBandByIndex(aIndex: Integer): IBand; safecall;
    procedure SetEdgeBandByIndex(aIndex: Integer; const aBand: IBand); safecall;
    function GetEdgeBandByName(const aName: WideString): IBand; safecall;
    procedure SetEdgeBandByName(const aName: WideString; const aBand: IBand); safecall;

    function GetParamCount(): Integer; safecall;
    function GetParamInfo(aIndex: Integer; var aName, aTitle: WideString; var aType: TShapeParamType): Boolean; safecall;
    function GetParamByIndex(aIndex: Integer): Integer; safecall;
    procedure SetParamByIndex(aIndex: Integer; aValue: Integer); safecall;
    function GetParamByName(const aName: WideString): Integer; safecall;
    procedure SetParamByName(const aName: WideString; aValue: Integer); safecall;

    function IsSame(const aOther: IShape): Boolean; safecall;

    function GetOnChange(): INotifyEvent; safecall;

    property ShapeType: TShapeType read GetShapeType;
    property EdgeCount: Integer read GetEdgeCount;
    property ParamCount: Integer read GetParamCount;

    property OnChange: INotifyEvent read GetOnChange;
  end;

implementation

end.
