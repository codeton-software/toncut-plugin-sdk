unit uISolutionWastes;

interface

uses
  uISolutionWaste;

type
  ISolutionWastes = interface
    ['{FF78D6B0-32F7-4999-83D3-C1B7142105F3}']

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): ISolutionWaste; safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: ISolutionWaste read GetByIndex; default;
  end;

implementation

end.
