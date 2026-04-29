unit uIResultChangeEvent;

interface

uses
  uIResult;

type
  IResultChangeEventHandler = interface(IUnknown)
    ['{284F4647-1FBD-467F-8B27-3D7A1D6D3E6D}']
    procedure Invoke(aSender: IUnknown; aResult: IResult; aIndex: Integer); safecall;
  end;

  IResultChangeEvent = interface(IUnknown)
    ['{76638535-78D5-4E30-902F-C61868B9D9DE}']
    procedure Add(aHandler: IResultChangeEventHandler); safecall;
    procedure Remove(aHandler: IResultChangeEventHandler); safecall;

    procedure Invoke(aSender: IUnknown; aResult: IResult; aIndex: Integer); safecall;
  end;

implementation

end.
