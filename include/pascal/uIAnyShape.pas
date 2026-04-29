unit uIAnyShape;

interface

uses
  uICommon,
  uIShape;

type
  IAnyShape = interface(IShape)
    ['{814BFA57-1A8A-4459-8C6B-00FF9F5E1223}']

    function GetPath(): WideString; safecall;
    procedure SetPath(const aPath: WideString); safecall;

    property Path: WideString read GetPath write SetPath;
  end;

implementation

end.
