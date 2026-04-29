unit uILinearShape;

interface

uses
  uICommon,
  uIShape;

type
  ILinearShape = interface(IShape)
    ['{62102D28-C799-4709-A0C4-CFF6FDB5A5FB}']

    function GetLeftAngle(): Double; safecall;
    procedure SetLeftAngle(aAngle: Double); safecall;

    function GetRightAngle(): Double; safecall;
    procedure SetRightAngle(aAngle: Double); safecall;

    property LeftAngle: Double read GetLeftAngle write SetLeftAngle;
    property RightAngle: Double read GetRightAngle write SetRightAngle;
  end;

implementation

end.
