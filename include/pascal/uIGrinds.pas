unit uIGrinds;

interface

uses
  uIGrind;

type
  IGrinds = interface
    function GetNorth(): IGrind; safecall;
    procedure SetNorth(const aNorth: IGrind); safecall;
    function GetSouth(): IGrind; safecall;
    procedure SetSouth(const aSouth: IGrind); safecall;
    function GetWest(): IGrind; safecall;
    procedure SetWest(const aWest: IGrind); safecall;
    function GetEast(): IGrind; safecall;
    procedure SetEast(const aEast: IGrind); safecall;

    property North: IGrind read GetNorth write SetNorth;
    property South: IGrind read GetSouth write SetSouth;
    property West: IGrind read GetWest write SetWest;
    property East: IGrind read GetEast write SetEast;

    property Top: IGrind read GetNorth write SetNorth;
    property Bottom: IGrind read GetSouth write SetSouth;
    property Left: IGrind read GetWest write SetWest;
    property Right: IGrind read GetEast write SetEast;
  end;

implementation

end.
