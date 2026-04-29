unit uISheets;

interface

uses
  uICommon,
  uISheet,
  uISheetChangeEvent,
  uIMaterial,
  uINotifyEvent,
  uISheetDefect;

type
  ISheets = interface
    ['{66C5F864-69D6-43A0-846B-C8AF73DA21E3}']

    function CreateSheet(): ISheet; safecall;
    procedure Add(aSheet: ISheet); safecall;
    procedure DeleteByIndex(aIndex: Cardinal); safecall;
    procedure DeleteById(aId: Int64); safecall;
    procedure Remove(const aSheet: ISheet); safecall;
    function IndexOf(const aSheet: ISheet): Integer; overload; safecall;
    function IndexOf(aId: Int64): Integer; overload; safecall;
    function IndexOf(const aOtherSheet: ISheet; aSkipId: Int64; var aRotated: Boolean): Integer; overload; safecall;

    function CreateDefect(): ISheetDefect; safecall;

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): ISheet; safecall;
    function GetById(aId: Int64): ISheet; safecall;

    function CalcMaxLength(): Cardinal; safecall;

    function GetField(): TField; safecall;
    function GetAvailableQuantity(): Cardinal; safecall;

    function GetOnAdd(): ISheetChangeEvent; safecall;
    function GetOnRemove(): ISheetChangeEvent; safecall;
    function GetOnChange(): INotifyEvent; safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;
    function IsUpdating(): Boolean; safecall;

    procedure Reload(); safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: ISheet read GetByIndex; default;

    property Field: TField read GetField;
    property AvailableQuantity: Cardinal read GetAvailableQuantity;

    property OnAdd: ISheetChangeEvent read GetOnAdd;
    property OnRemove: ISheetChangeEvent read GetOnRemove;
    property OnChange: INotifyEvent read GetOnChange;
  end;

implementation

end.
