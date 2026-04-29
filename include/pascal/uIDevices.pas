unit uIDevices;

interface

uses
  uIDevice,
  uIDeviceChangeEvent,
  uINotifyEvent;

type
  IDevices = interface
    ['{3384FFDE-7FF9-4B30-8C4E-F4F723FA08E2}']

    function CreateDevice(): IDevice; safecall;
    procedure Add(aDevice: IDevice); safecall;
    procedure DeleteByIndex(aIndex: Cardinal); safecall;
    procedure DeleteById(aId: Int64); safecall;
    procedure Remove(const aDevice: IDevice); safecall;
    function IndexOf(const aDevice: IDevice): Integer; overload; safecall;
    function IndexOf(aId: Int64): Integer; overload; safecall;
    function FindDuplicate(const aDevice: IDevice; aCheckTitle: Boolean = False): IDevice; safecall;
    function FindByTitle(const aTitle: WideString): IDevice; safecall;

    function FindUniqueName(const aBaseName: WideString): WideString; safecall;
    function CheckUniqueName(const aTitle: WideString; const aIgnoreDevice: IDevice): Boolean; overload; safecall;
    function CheckUniqueName(aDevice: IDevice; aAutoFix: Boolean = False): Boolean; overload; safecall;

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): IDevice; safecall;
    function GetById(aId: Int64): IDevice; safecall;

    function GetOnAdd(): IDeviceChangeEvent; safecall;
    function GetOnRemove(): IDeviceChangeEvent; safecall;
    function GetOnChange(): INotifyEvent; safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;
    function IsUpdating(): Boolean; safecall;

    procedure Reload(); safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: IDevice read GetByIndex; default;

    property OnAdd: IDeviceChangeEvent read GetOnAdd;
    property OnRemove: IDeviceChangeEvent read GetOnRemove;
    property OnChange: INotifyEvent read GetOnChange;
  end;

implementation

end.
