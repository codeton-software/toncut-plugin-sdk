unit uIBands;

interface

uses
  uIBand,
  uIBandChangeEvent,
  uIMaterial,
  uIBandList;

type
  IBands = interface
    ['{8011666D-AA9D-4A8B-8B1B-16779133FE1A}']

    function CreateBand(): IBand; safecall;
    procedure Add(aBand: IBand); safecall;
    procedure DeleteByIndex(aIndex: Cardinal); safecall;
    procedure DeleteById(aId: Int64); safecall;
    procedure Remove(const aBand: IBand); safecall;
    function IndexOf(const aBand: IBand): Integer; overload; safecall;
    function IndexOf(aId: Int64): Integer; overload; safecall;
    function FindDuplicate(const aBand: IBand; aCheckTitle: Boolean = False): IBand; safecall;
    function FindByTitle(const aTitle: WideString; aWidth, aThickness: Cardinal): IBand; safecall;

    function FindUniqueName(const aBaseName: WideString; aWidth, aThickness: Cardinal): WideString; safecall;
    function CheckUniqueName(const aTitle: WideString; aWidth, aThickness: Cardinal; const aIgnoreBand: IBand): Boolean; overload; safecall;
    function CheckUniqueName(aBand: IBand; aAutoFix: Boolean = False): Boolean; overload; safecall;

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): IBand; safecall;
    function GetById(aId: Int64): IBand; safecall;

    function GetOnAdd(): IBandChangeEvent; safecall;
    function GetOnRemove(): IBandChangeEvent; safecall;

    procedure AddMaterialBandToHistory(aMaterial: IMaterial; aBand: IBand); safecall;
    function LoadMaterialBandsFromHistory(aMaterial: IMaterial; aLimit: Integer = 5): IBandList; safecall;
    function LoadMaterialBands(aMaterial: IMaterial): IBandList; safecall;

    procedure Reload(); safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: IBand read GetByIndex; default;

    property OnAdd: IBandChangeEvent read GetOnAdd;
    property OnRemove: IBandChangeEvent read GetOnRemove;
  end;

implementation

end.
