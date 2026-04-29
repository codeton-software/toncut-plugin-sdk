unit uISolutionFormats;

interface

uses
  uISolutionFormat;

type
  ISolutionFormats = interface
    ['{4F98B50C-4007-40A1-A228-15D778F5EDBD}']

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): ISolutionFormat; safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: ISolutionFormat read GetByIndex; default;
  end;

implementation

end.
