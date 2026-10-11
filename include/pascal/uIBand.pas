unit uIBand;

interface

uses
  uICommon,
  uINotifyEvent,
  uIIdChangeEvent;

type
  IBand = interface
    ['{6377F5CF-5243-4DFB-A3D1-F671022452EA}']

    function GetId(): Int64; safecall;
    procedure SetId(aId: Int64); safecall;

    function GetTitle(): WideString; safecall;
    procedure SetTitle(const aTitle: WideString); safecall;

    function GetWidth(): Cardinal; safecall;
    procedure SetWidth(aWidth: Cardinal); safecall;

    function GetMaxMaterialThickness(): Cardinal; safecall;
    procedure SetMaxMaterialThickness(aMaterialThickness: Cardinal); safecall;

    function GetThickness(): Cardinal; safecall;
    procedure SetThickness(aThickness: Cardinal); safecall;

    function GetSurplus(): Cardinal; safecall;
    procedure SetSurplus(aSurplus: Cardinal); safecall;

    function GetOnChange(): INotifyEvent; safecall;
    function GetOnIdChange(): IIdChangeEvent; safecall;

    function Clone(): IBand; safecall;
    procedure Assign(const aOther: IBand); safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;

    // Preview color used when the item is drawn, as a TTcColor: $RRGGBB,
    // clTcNone (no preview color, the default) or clTcRandom (the host
    // derives a stable color from Id).
    // ABI NOTE: appended after EndUpdate (same GUID, engine v24) so every
    // earlier slot keeps the published plugin-API order; every implementer
    // must provide both methods.
    function GetPreviewColor(): TTcColor; safecall;
    procedure SetPreviewColor(aColor: TTcColor); safecall;

    property Id: Int64 read GetId write SetId;
    property Title: WideString read GetTitle write SetTitle;
    property Width: Cardinal read GetWidth write SetWidth;
    property MaxMaterialThickness: Cardinal read GetMaxMaterialThickness write SetMaxMaterialThickness;
    property Thickness: Cardinal read GetThickness write SetThickness;
    property Surplus: Cardinal read GetSurplus write SetSurplus;

    property PreviewColor: TTcColor read GetPreviewColor write SetPreviewColor;

    property OnChange: INotifyEvent read GetOnChange;
    property OnIdChange: IIdChangeEvent read GetOnIdChange;
  end;

implementation

end.
