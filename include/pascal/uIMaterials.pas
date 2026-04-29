unit uIMaterials;

interface

uses
  uICommon,
  uIMaterial,
  uIStandardSheet,
  uIMaterialChangeEvent;

type
  IMaterials = interface
    ['{49E95AA5-2437-47E1-8D38-21BEC146C6AD}']

    function CreateMaterial(): IMaterial; safecall;
    function CreateStandardSheet(): IStandardSheet; safecall;

    procedure Add(aMaterial: IMaterial); safecall;
    procedure DeleteByIndex(aIndex: Cardinal); safecall;
    procedure DeleteById(aId: Int64); safecall;
    procedure Remove(const aMaterial: IMaterial); safecall;
    function IndexOf(const aMaterial: IMaterial): Integer; overload; safecall;
    function IndexOf(aId: Int64): Integer; overload; safecall;
    function FindDuplicate(const aMaterial: IMaterial; aCheckTitle: Boolean = False): IMaterial; safecall;
    function FindByTitle(const aTitle: WideString; aKind: TMaterialKind; aWidth, aThickness: Cardinal): IMaterial; safecall;

    function FindUniqueName(const aBaseName: WideString; aKind: TMaterialKind; aWidth, aThickness: Cardinal): WideString; safecall;
    function CheckUniqueName(const aTitle: WideString; aKind: TMaterialKind; aWidth, aThickness: Cardinal; const aIgnoreMaterial: IMaterial): Boolean; overload; safecall;
    function CheckUniqueName(aMaterial: IMaterial; aAutoFix: Boolean = False): Boolean; overload; safecall;

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): IMaterial; safecall;
    function GetById(aId: Int64): IMaterial; safecall;

    function GetOnAdd(): IMaterialChangeEvent; safecall;
    function GetOnRemove(): IMaterialChangeEvent; safecall;

    procedure Reload(); safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: IMaterial read GetByIndex; default;

    property OnAdd: IMaterialChangeEvent read GetOnAdd;
    property OnRemove: IMaterialChangeEvent read GetOnRemove;
  end;

implementation

end.
