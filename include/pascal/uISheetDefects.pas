unit uISheetDefects;

interface

uses
  uICommon,
  uISheetDefect,
  uISheetDefectChangeEvent;

type
  ISheetDefects = interface
    ['{0761BD5F-0F91-47E8-AA25-EDEFEEC7BEC4}']

    procedure Assign(const aOther: ISheetDefects); safecall;

    procedure Clear(); safecall;

    procedure Add(aSheetDefect: ISheetDefect); safecall;
    procedure DeleteByIndex(aIndex: Cardinal); safecall;
    procedure Remove(const aSheetDefect: ISheetDefect); safecall;
    function IndexOf(const aSheetDefect: ISheetDefect): Integer; overload; safecall;
    function Find(aPosX, aPosY, aLength, aWidth: Cardinal): ISheetDefect; overload; safecall;

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): ISheetDefect; safecall;

    function GetOnAdd(): ISheetDefectChangeEvent; safecall;
    function GetOnRemove(): ISheetDefectChangeEvent; safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: ISheetDefect read GetByIndex; default;

    property OnAdd: ISheetDefectChangeEvent read GetOnAdd;
    property OnRemove: ISheetDefectChangeEvent read GetOnRemove;
  end;

implementation

end.
