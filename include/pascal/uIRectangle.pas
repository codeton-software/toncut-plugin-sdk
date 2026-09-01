unit uIRectangle;

interface

uses
  uINotifyEvent;

type
  IRectangle = interface
    ['{1B77A717-7561-46CA-B2E9-87CC4F69B4F4}']
    // A negative side represents an inherited or unspecified edge distance.
    function GetNorth(): Integer; safecall;
    procedure SetNorth(aNorth: Integer); safecall;
    function GetSouth(): Integer; safecall;
    procedure SetSouth(aSouth: Integer); safecall;
    function GetWest(): Integer; safecall;
    procedure SetWest(aWest: Integer); safecall;
    function GetEast(): Integer; safecall;
    procedure SetEast(aEast: Integer); safecall;

    function GetOnChange(): INotifyEvent; safecall;

    procedure Assign(const aOther: IRectangle); safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;

    property North: Integer read GetNorth write SetNorth;
    property South: Integer read GetSouth write SetSouth;
    property West: Integer read GetWest write SetWest;
    property East: Integer read GetEast write SetEast;

    property Top: Integer read GetNorth write SetNorth;
    property Bottom: Integer read GetSouth write SetSouth;
    property Left: Integer read GetWest write SetWest;
    property Right: Integer read GetEast write SetEast;

    property OnChange: INotifyEvent read GetOnChange;
  end;

implementation

end.
