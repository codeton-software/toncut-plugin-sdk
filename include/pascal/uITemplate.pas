unit uITemplate;

interface

uses
  System.Classes,
  uICommon,
  uIFormat,
  uIFormats,
  uINotifyEvent,
  uIIdChangeEvent,
  uIFormatChangeEvent;

type
  ITemplate = interface
    ['{13F64158-F0FF-4D5A-AFE4-D8AB7969D82E}']

    function GetId(): Int64; safecall;
    procedure SetId(aId: Int64); safecall;

    function GetTitle(): WideString; safecall;
    procedure SetTitle(const aTitle: WideString); safecall;

    function GetDescription(): WideString; safecall;
    procedure SetDescription(const aDescription: WideString); safecall;

    function GetFormats(): IFormats; safecall;

    function GetOnChange(): INotifyEvent; safecall;
    function GetOnIdChange(): IIdChangeEvent; safecall;

    function GetOnFormatAdd(): IFormatChangeEvent; safecall;
    function GetOnFormatRemove(): IFormatChangeEvent; safecall;
    function GetOnFormatChange(): IFormatChangeEvent; safecall;

    procedure Assign(const aOther: ITemplate); safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;

    property Id: Int64 read GetId write SetId;
    property Title: WideString read GetTitle write SetTitle;
    property Description: WideString read GetDescription write SetDescription;

    property Formats: IFormats read GetFormats;

    property OnChange: INotifyEvent read GetOnChange;
    property OnIdChange: IIdChangeEvent read GetOnIdChange;

    property OnFormatAdd: IFormatChangeEvent read GetOnFormatAdd;
    property OnFormatRemove: IFormatChangeEvent read GetOnFormatRemove;
    property OnFormatChange: IFormatChangeEvent read GetOnFormatChange;
  end;

implementation

end.
