unit uISolution;

interface

uses
  uISolutionSheet,
  uIMaterial;

type
  ISolution = interface
    ['{F78A8983-567D-48DE-860F-AF50BE0D923D}']

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): ISolutionSheet; safecall;

    procedure CalcCutsInfoByMaterial(const aMaterial: IMaterial; var aCount: Integer; var aLength: Double); safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: ISolutionSheet read GetByIndex; default;
  end;

implementation

end.
