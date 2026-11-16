unit uIResults;

interface

uses
  uINotifyEvent,
  uIResult,
  uIResultChangeEvent;

type
  IResults = interface
    ['{473F9048-B682-44EF-8151-91A280FCA879}']

    function CreateResult(): IResult; safecall;
    procedure Add(aResult: IResult); safecall;
    procedure DeleteByIndex(aIndex: Cardinal); safecall;
    procedure DeleteById(aId: Int64); safecall;
    procedure Remove(const aResult: IResult); safecall;
    function IndexOf(const aResult: IResult): Integer; overload; safecall;
    function IndexOf(aId: Int64): Integer; overload; safecall;

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): IResult; safecall;
    function GetById(aId: Int64): IResult; safecall;

    function GetOnAdd(): IResultChangeEvent; safecall;
    function GetOnRemove(): IResultChangeEvent; safecall;

    procedure Reload(); safecall;

    // Nested updates suppress OnAdd/OnRemove; changed batches emit one OnChange.
    // Balance BeginUpdate with EndUpdate in finally; IsUpdating tracks nesting.
    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;
    function IsUpdating(): Boolean; safecall;
    function GetOnChange(): INotifyEvent; safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: IResult read GetByIndex; default;

    property OnAdd: IResultChangeEvent read GetOnAdd;
    property OnRemove: IResultChangeEvent read GetOnRemove;
    property OnChange: INotifyEvent read GetOnChange;
  end;

implementation

end.
