unit uISolutionWaste;

interface

uses
  uICommon,
  uIShape,
  uISheetDefects,
  uIMaterial;

type
  ISolutionWaste = interface
    ['{653C0065-1BD3-419F-94F2-CA6DED234CE8}']

    function GetX(): Cardinal; safecall;
    function GetY(): Cardinal; safecall;
    function GetLength(): Cardinal; safecall;
    function GetWidth(): Cardinal; safecall;
    function GetShape(): IShape; safecall;
    function GetField(): TField; safecall;
    function GetIdentifier(): WideString; safecall;

    function GetShapePathAsString(): WideString; safecall;
    // Appended after the published method prefix to preserve the existing IID's
    // vtable slots.
    function GetHoles(): ISheetDefects; safecall;

    property X: Cardinal read GetX;
    property Y: Cardinal read GetY;
    property Length: Cardinal read GetLength;
    property Width: Cardinal read GetWidth;
    property Shape  : IShape read GetShape;
    property Holes  : ISheetDefects read GetHoles;
    property Field  : TField read GetField;
    property Identifier : WideString read GetIdentifier;
  end;

implementation

end.
