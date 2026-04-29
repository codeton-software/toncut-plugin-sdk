unit uISheetDefect;

interface

uses
  uICommon,
  uINotifyEvent;

type
  ISheetDefect = interface
    ['{3F5E61BF-595F-4213-92C4-040A9F8949C2}']

    function GetPosX(): Cardinal; safecall;
    procedure SetPosX(aPosX: Cardinal); safecall;

    function GetPosY(): Cardinal; safecall;
    procedure SetPosY(aPosY: Cardinal); safecall;

    function GetLength(): Cardinal; safecall;
    procedure SetLength(aLength: Cardinal); safecall;

    function GetWidth(): Cardinal; safecall;
    procedure SetWidth(aWidth: Cardinal); safecall;

    function GetOnChange(): INotifyEvent; safecall;

    procedure Assign(const aSheetDefect: ISheetDefect); safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;

    property PosX: Cardinal read GetPosX write SetPosX;
    property PosY: Cardinal read GetPosY write SetPosY;
    property Length: Cardinal read GetLength write SetLength;
    property Width: Cardinal read GetWidth write SetWidth;

    property OnChange: INotifyEvent read GetOnChange;
  end;


implementation

end.
