unit uIBanding;

interface

uses
  uIBand,
  uINotifyEvent;

type
  IBanding = interface
    ['{DD657F0E-605D-460B-AD6D-17028C79FDCE}']

    function GetNorth(): IBand; safecall;
    procedure SetNorth(const aNorth: IBand); safecall;
    function GetSouth(): IBand; safecall;
    procedure SetSouth(const aSouth: IBand); safecall;
    function GetWest(): IBand; safecall;
    procedure SetWest(const aWest: IBand); safecall;
    function GetEast(): IBand; safecall;
    procedure SetEast(const aEast: IBand); safecall;

    function GetOnChange(): INotifyEvent; safecall;

    procedure Assign(const aOther: IBanding); safecall;

    property North: IBand read GetNorth write SetNorth;
    property South: IBand read GetSouth write SetSouth;
    property West: IBand read GetWest write SetWest;
    property East: IBand read GetEast write SetEast;

    property Top: IBand read GetNorth write SetNorth;
    property Bottom: IBand read GetSouth write SetSouth;
    property Left: IBand read GetWest write SetWest;
    property Right: IBand read GetEast write SetEast;

    property OnChange: INotifyEvent read GetOnChange;
  end;

implementation

end.
