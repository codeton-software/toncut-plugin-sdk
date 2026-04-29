unit uIFormats;

interface

uses
  uICommon,
  uIFormat,
  uIFormatChangeEvent,
  uIProject,
  uIMaterial,
  uINotifyEvent;

type
  IFormats = interface
    ['{42199936-3DD0-4680-93DE-433D43E6573B}']

    procedure Assign(const aOther: IFormats); safecall;

    procedure Clear(); safecall;
    procedure Reload(); safecall;

    function CreateFormat(): IFormat; safecall;
    procedure Add(aFormat: IFormat); safecall;
    procedure DeleteByIndex(aIndex: Cardinal); safecall;
    procedure DeleteById(aId: Int64); safecall;
    procedure Remove(const aFormat: IFormat); safecall;
    function IndexOf(const aFormat: IFormat): Integer; overload; safecall;
    function IndexOf(aId: Int64): Integer; overload; safecall;
    function IndexOf(aList: array of Int64; const aMaterial: IMaterial; aLength, aWidth: Cardinal; aOrnament: TOrnament; var aRotated: Boolean; var aListIndex: Integer): Integer; overload; safecall;
    function IndexOf(const aOtherFormat: IFormat; aSkipId: Int64; var aRotated: Boolean): Integer; overload; safecall;
    function Find(aLength, aWidth: Cardinal; var aRotated: Boolean): IFormat; safecall;

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): IFormat; safecall;
    function GetById(aId: Int64): IFormat; safecall;

    procedure LoadByProject(aProject: IProject; aFormats: IFormats); overload; safecall;
    procedure LoadByProject(aProject: IProject); overload; safecall;
    function GetByProject(aProject: IProject): IFormats; safecall;
    procedure UnloadByProject(const aProject: IProject); safecall;
    procedure UnloadFormat(const aFormat: IFormat); safecall;

    function CalcMaxLength(): Cardinal; safecall;

    function GetField(): TField; safecall;
    function GetQuantity(): Cardinal; safecall;

    function GetLoading(): Boolean; safecall;
    procedure SetLoading(aLoading: Boolean); safecall;

    function GetOnAdd(): IFormatChangeEvent; safecall;
    function GetOnRemove(): IFormatChangeEvent; safecall;
    function GetOnChange(): INotifyEvent; safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;
    function IsUpdating(): Boolean; safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: IFormat read GetByIndex; default;

    property Field: TField read GetField;
    property Quantity: Cardinal read GetQuantity;

    property Loading: Boolean read GetLoading write SetLoading;

    property OnAdd: IFormatChangeEvent read GetOnAdd;
    property OnRemove: IFormatChangeEvent read GetOnRemove;
    property OnChange: INotifyEvent read GetOnChange;
  end;

implementation

end.
