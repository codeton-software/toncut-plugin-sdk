unit uIStandardSheetChangeEvent;

interface

uses
  uIStandardSheet;

type
  IStandardSheetChangeEventHandler = interface(IUnknown)
    ['{7D9FE7E4-F2D7-463E-9231-80075963506E}']
    procedure Invoke(aSender: IUnknown; aStandardSheet: IStandardSheet; aIndex: Integer); safecall;
  end;

  IStandardSheetChangeEvent = interface(IUnknown)
    ['{656C4695-86AD-4DC3-BC31-A37FD9F01D5E}']
    procedure Add(aHandler: IStandardSheetChangeEventHandler); safecall;
    procedure Remove(aHandler: IStandardSheetChangeEventHandler); safecall;

    procedure Invoke(aSender: IUnknown; aStandardSheet: IStandardSheet; aIndex: Integer); safecall;
  end;

implementation

end.
