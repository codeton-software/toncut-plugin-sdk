unit uIBandList;

interface

uses
  uIBand;

type
  IBandList = interface
    ['{AB6DCA6E-10B5-40A9-AC00-D3C141AC3EB8}']

    procedure Add(aBand: IBand); safecall;
    procedure DeleteByIndex(aIndex: Cardinal); safecall;
    procedure Remove(const aBand: IBand); safecall;
    function IndexOf(const aBand: IBand): Integer; overload; safecall;

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): IBand; safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: IBand read GetByIndex; default;
  end;

implementation

end.
