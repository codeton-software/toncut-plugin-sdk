unit uISolutionCuts;

interface

uses
  uISolutionCut;

type
  ISolutionCuts = interface
    ['{6D733395-4F49-4189-8325-D0E4A5CDF202}']

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): ISolutionCut; safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: ISolutionCut read GetByIndex; default;
  end;

implementation

end.
