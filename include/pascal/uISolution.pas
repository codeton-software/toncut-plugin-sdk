unit uISolution;

interface

uses
  uICommon,
  uISolutionSheet,
  uIMaterial;

type
  ISolution = interface
    ['{AF96B222-66C9-4D99-B061-4C086BA10182}']

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): ISolutionSheet; safecall;
    function GetTechnologicalWasteField(): TField; safecall;
    function GetEdgingWasteField(): TField; safecall;
    function GetKerfWasteField(): TField; safecall;

    procedure CalcCutsInfoByMaterial(const aMaterial: IMaterial; var aCount: Integer; var aLength: Double); safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: ISolutionSheet read GetByIndex; default;
    property TechnologicalWasteField: TField read GetTechnologicalWasteField;
    property EdgingWasteField: TField read GetEdgingWasteField;
    property KerfWasteField: TField read GetKerfWasteField;
  end;

implementation

end.
