unit uISolutionCut;

interface

uses
  uICommon;

type
  ISolutionCut = interface
    ['{B51265B6-8BE3-4DF5-A852-C601D6839F0A}']

    function GetKind(): TCutKind; safecall;

    function GetPosX(): Integer; safecall;
    function GetPosY(): Integer; safecall;
    function GetTarX(): Integer; safecall;
    function GetTarY(): Integer; safecall;

    function GetPosXp(): Integer; safecall;
    function GetPosYp(): Integer; safecall;
    function GetTarXp(): Integer; safecall;
    function GetTarYp(): Integer; safecall;

    function GetNeedShift(): Boolean; safecall;

    function CalcLength(): Double; safecall;
    // Appended after the published method prefix to preserve the existing IID's
    // vtable slots.
    function GetShiftDistance(): Integer; safecall;

    property Kind: TCutKind read GetKind;

    property PosX: Integer read GetPosX;
    property PosY: Integer read GetPosY;
    property TarX: Integer read GetTarX;
    property TarY: Integer read GetTarY;

    property PosXp: Integer read GetPosXp;
    property PosYp: Integer read GetPosYp;
    property TarXp: Integer read GetTarXp;
    property TarYp: Integer read GetTarYp;

    property NeedShift: Boolean read GetNeedShift;
    property ShiftDistance: Integer read GetShiftDistance;
  end;

implementation

end.
