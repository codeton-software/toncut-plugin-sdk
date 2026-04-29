unit uINotifyEvent;

interface

type
  INotifyEventHandler = interface(IUnknown)
    ['{4564AAF5-060B-4985-86CB-B20191FFC83C}']
    procedure Invoke(aSender: IUnknown); safecall;
  end;

  INotifyEvent = interface(IUnknown)
    ['{1D44C9AA-5D42-4D2B-ACC6-A5F518CC6BB6}']
    procedure Add(aHandler: INotifyEventHandler); safecall;
    procedure Remove(aHandler: INotifyEventHandler); safecall;

    procedure Invoke(aSender: IUnknown); safecall;
  end;

implementation

end.
