unit uIRectangle;

interface

uses
  uINotifyEvent;

type
  IRectangle = interface
    ['{1B77A717-7561-46CA-B2E9-87CC4F69B4F4}']
    function GetNorth(): Cardinal; safecall;
    procedure SetNorth(aNorth: Cardinal); safecall;
    function GetSouth(): Cardinal; safecall;
    procedure SetSouth(aSouth: Cardinal); safecall;
    function GetWest(): Cardinal; safecall;
    procedure SetWest(aWest: Cardinal); safecall;
    function GetEast(): Cardinal; safecall;
    procedure SetEast(aEast: Cardinal); safecall;

    function GetOnChange(): INotifyEvent; safecall;

    procedure Assign(const aOther: IRectangle); safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;

    property North: Cardinal read GetNorth write SetNorth;
    property South: Cardinal read GetSouth write SetSouth;
    property West: Cardinal read GetWest write SetWest;
    property East: Cardinal read GetEast write SetEast;

    property Top: Cardinal read GetNorth write SetNorth;
    property Bottom: Cardinal read GetSouth write SetSouth;
    property Left: Cardinal read GetWest write SetWest;
    property Right: Cardinal read GetEast write SetEast;

    property OnChange: INotifyEvent read GetOnChange;
  end;

implementation

end.
