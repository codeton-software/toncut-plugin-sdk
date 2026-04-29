unit uIDeviceChangeEvent;

interface

uses
  uIDevice;

type
  IDeviceChangeEventHandler = interface(IUnknown)
    ['{C86D52C2-9AE9-4181-AF01-AB38187F3DAD}']
    procedure Invoke(aSender: IUnknown; aDevice: IDevice; aIndex: Integer); safecall;
  end;

  IDeviceChangeEvent = interface(IUnknown)
    ['{45FD90F2-ED2D-4C35-A89E-33B61C12DBB4}']
    procedure Add(aHandler: IDeviceChangeEventHandler); safecall;
    procedure Remove(aHandler: IDeviceChangeEventHandler); safecall;

    procedure Invoke(aSender: IUnknown; aDevice: IDevice; aIndex: Integer); safecall;
  end;

implementation

end.
