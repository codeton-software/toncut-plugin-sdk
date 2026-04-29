unit uIMaterialChangeEvent;

interface

uses
  uIMaterial;

type
  IMaterialChangeEventHandler = interface(IUnknown)
    ['{8E22DAE9-39E6-4E8F-9CB8-603BDE907D1A}']
    procedure Invoke(aSender: IUnknown; aMaterial: IMaterial; aIndex: Integer); safecall;
  end;

  IMaterialChangeEvent = interface(IUnknown)
    ['{E4C2B53C-3012-4CF5-953F-483F7E4E01ED}']
    procedure Add(aHandler: IMaterialChangeEventHandler); safecall;
    procedure Remove(aHandler: IMaterialChangeEventHandler); safecall;

    procedure Invoke(aSender: IUnknown; aMaterial: IMaterial; aIndex: Integer); safecall;
  end;

implementation

end.
