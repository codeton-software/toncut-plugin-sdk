unit uIStandardSheet;

interface

uses
  uICommon,
  uIRectangle,
  uINotifyEvent,
  uIIdChangeEvent;

type
  IStandardSheet = interface
    ['{7C43AB12-1C9C-4FB6-A076-2CC2E848DA8D}']

    function GetId(): Int64; safecall;
    procedure SetId(aId: Int64); safecall;

    function GetTitle(): WideString; safecall;
    procedure SetTitle(const aTitle: WideString); safecall;

    function GetLength(): Cardinal; safecall;
    procedure SetLength(aLength: Cardinal); safecall;

    function GetWidth(): Cardinal; safecall;
    procedure SetWidth(aWidth: Cardinal); safecall;

    function GetOrnament(): TOrnament; safecall;
    procedure SetOrnament(aOrnament: TOrnament); safecall;

    function GetEdging(): IRectangle; safecall;

    function GetOnChange(): INotifyEvent; safecall;
    function GetOnIdChange(): IIdChangeEvent; safecall;

    procedure Assign(const aStandardSheet: IStandardSheet); safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;

    property Id: Int64 read GetId write SetId;
    property Title: WideString read GetTitle write SetTitle;
    property Length: Cardinal read GetLength write SetLength;
    property Width: Cardinal read GetWidth write SetWidth;
    property Ornament: TOrnament read GetOrnament write SetOrnament;
    property Edging: IRectangle read GetEdging;

    property OnChange: INotifyEvent read GetOnChange;
    property OnIdChange: IIdChangeEvent read GetOnIdChange;
  end;


implementation

end.
