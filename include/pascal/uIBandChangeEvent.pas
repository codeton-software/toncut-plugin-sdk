unit uIBandChangeEvent;

interface

uses
  uIBand;

type
  IBandChangeEventHandler = interface(IUnknown)
    ['{2064046C-FDD8-4759-B456-C29A3F4BB0EC}']
    procedure Invoke(aSender: IUnknown; aBand: IBand; aIndex: Integer); safecall;
  end;

  IBandChangeEvent = interface(IUnknown)
    ['{329C87ED-017A-47F2-9304-80EC3E9DDEF7}']
    procedure Add(aHandler: IBandChangeEventHandler); safecall;
    procedure Remove(aHandler: IBandChangeEventHandler); safecall;

    procedure Invoke(aSender: IUnknown; aBand: IBand; aIndex: Integer); safecall;
  end;

implementation

end.
