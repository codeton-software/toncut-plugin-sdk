unit uISolutionFormat;

interface

uses
  uICommon,
  uIFormat;

type
  ISolutionFormat = interface
    ['{B384074F-57F6-41C9-9514-CBF3103C3893}']

    function GetFormat(): IFormat; safecall;
    function GetX(): Cardinal; safecall;
    function GetY(): Cardinal; safecall;
    function GetRotation(): TRotation; safecall;
    function GetMirrored(): Boolean; safecall;

    property Format: IFormat read GetFormat;
    property X: Cardinal read GetX;
    property Y: Cardinal read GetY;
    property Rotation: TRotation read GetRotation;
    property Mirrored: Boolean read GetMirrored;
  end;

implementation

end.
