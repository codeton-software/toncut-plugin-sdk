unit uITemplateChangeEvent;

interface

uses
  uITemplate;

type
  ITemplateChangeEventHandler = interface(IUnknown)
    ['{E8FE8BF5-57E6-4A4A-B643-1856BA84EF66}']
    procedure Invoke(aSender: IUnknown; aTemplate: ITemplate; aIndex: Integer); safecall;
  end;

  ITemplateChangeEvent = interface(IUnknown)
    ['{EBFFBF8E-66C3-4401-8A2B-6E7419D58BD3}']
    procedure Add(aHandler: ITemplateChangeEventHandler); safecall;
    procedure Remove(aHandler: ITemplateChangeEventHandler); safecall;

    procedure Invoke(aSender: IUnknown; aTemplate: ITemplate; aIndex: Integer); safecall;
  end;

implementation

end.
