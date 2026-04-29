unit uIIdChangeEvent;

interface

type
  IIdChangeEventHandler = interface(IUnknown)
    ['{11967711-8FDB-4FC5-9209-DEC1F2C16D83}']
    procedure Invoke(aSender: IUnknown; aNewId, aOldId: Int64); safecall;
  end;

  IIdChangeEvent = interface(IUnknown)
    ['{33DCA8E6-EE62-428A-99CA-A77403AF4B26}']
    procedure Add(aHandler: IIdChangeEventHandler); safecall;
    procedure Remove(aHandler: IIdChangeEventHandler); safecall;

    procedure Invoke(aSender: IUnknown; aNewId, aOldId: Int64); safecall;
  end;

implementation

end.
