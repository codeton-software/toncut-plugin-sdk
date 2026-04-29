unit uISheetDefectChangeEvent;

interface

uses
  uISheetDefect;

type
  ISheetDefectChangeEventHandler = interface(IUnknown)
    ['{E0280F1A-F065-4CDF-8AF6-99898C55BBD4}']
    procedure Invoke(aSender: IUnknown; aSheetDefect: ISheetDefect; aIndex: Integer); safecall;
  end;

  ISheetDefectChangeEvent = interface(IUnknown)
    ['{EF2DD7A4-1957-4C72-AC8F-EC6D6793E30D}']
    procedure Add(aHandler: ISheetDefectChangeEventHandler); safecall;
    procedure Remove(aHandler: ISheetDefectChangeEventHandler); safecall;

    procedure Invoke(aSender: IUnknown; aSheetDefect: ISheetDefect; aIndex: Integer); safecall;
  end;

implementation

end.
