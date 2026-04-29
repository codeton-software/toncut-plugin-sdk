unit uIStandardSheets;

interface

uses
  uICommon,
  uIStandardSheet,
  uIStandardSheetChangeEvent;

type
  IStandardSheets = interface
    ['{5CD3AAB4-8764-431B-B32D-06815C9B4B79}']

    procedure Assign(const aOther: IStandardSheets); safecall;

    procedure Clear(); safecall;

    procedure Add(aStandardSheet: IStandardSheet); safecall;
    procedure DeleteByIndex(aIndex: Cardinal); safecall;
    procedure Remove(const aStandardSheet: IStandardSheet); safecall;
    function IndexOf(const aStandardSheet: IStandardSheet): Integer; overload; safecall;
    function Find(aLength, aWidth: Cardinal; aOrnament: TOrnament; aMarginLeft, aMarginTop, aMarginRight, aMarginBottom: Cardinal): IStandardSheet; overload; safecall;
    function Find(aLength, aWidth: Cardinal; aMarginLeft, aMarginTop, aMarginRight, aMarginBottom: Cardinal): IStandardSheet; overload; safecall;

    function CheckUniqueName(const aTitle: WideString; const aIgnoreStandardSheet: IStandardSheet): Boolean; safecall;

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): IStandardSheet; safecall;

    function GetOnAdd(): IStandardSheetChangeEvent; safecall;
    function GetOnRemove(): IStandardSheetChangeEvent; safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: IStandardSheet read GetByIndex; default;

    property OnAdd: IStandardSheetChangeEvent read GetOnAdd;
    property OnRemove: IStandardSheetChangeEvent read GetOnRemove;
  end;

implementation

end.
