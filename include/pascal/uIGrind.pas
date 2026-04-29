unit uIGrind;

interface

type
  IGrind = interface
    function GetId(): Int64; safecall;

    function GetTitle(): WideString; safecall;
    procedure SetTitle(const aTitle: WideString); safecall;

    function GetThickness(): Cardinal; safecall;
    procedure SetThickness(aThickness: Cardinal); safecall;

    procedure Assign(const aOther: IGrind); safecall;

    property Id: Int64 read GetId;
    property Title: WideString read GetTitle write SetTitle;
    property Thickness: Cardinal read GetThickness write SetThickness;
  end;

implementation

end.
