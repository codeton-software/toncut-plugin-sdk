unit uISheetChangeEvent;

interface

uses
  uISheet;

type
  ISheetChangeEventHandler = interface(IUnknown)
    ['{F6388A56-8F89-4635-BFAC-BAA45913138B}']
    procedure Invoke(aSender: IUnknown; aSheet: ISheet; aIndex: Integer); safecall;
  end;

  ISheetChangeEvent = interface(IUnknown)
    ['{A740ABB2-3DA4-4DA8-904E-893B9AD65CFB}']
    procedure Add(aHandler: ISheetChangeEventHandler); safecall;
    procedure Remove(aHandler: ISheetChangeEventHandler); safecall;

    procedure Invoke(aSender: IUnknown; aSheet: ISheet; aIndex: Integer); safecall;
  end;

implementation

end.
