unit uIFormatChangeEvent;

interface

uses
  uIFormat;

type
  IFormatChangeEventHandler = interface(IUnknown)
    ['{02973286-E67D-4469-8502-70BCE455FE4B}']
    procedure Invoke(aSender: IUnknown; aFormat: IFormat; aIndex: Integer); safecall;
  end;

  IFormatChangeEvent = interface(IUnknown)
    ['{87F91622-3567-415E-9765-CB562911773F}']
    procedure Add(aHandler: IFormatChangeEventHandler); safecall;
    procedure Remove(aHandler: IFormatChangeEventHandler); safecall;

    procedure Invoke(aSender: IUnknown; aFormat: IFormat; aIndex: Integer); safecall;
  end;

implementation

end.
