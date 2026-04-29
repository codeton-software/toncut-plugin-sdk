unit uIProjectChangeEvent;

interface

uses
  uIProject;

type
  IProjectChangeEventHandler = interface(IUnknown)
    ['{FE8C043B-F245-40BF-AAB2-352D902546F6}']
    procedure Invoke(aSender: IUnknown; aProject: IProject; aIndex: Integer); safecall;
  end;

  IProjectChangeEvent = interface(IUnknown)
    ['{479C92D6-81C2-43DA-BA12-2DFECBC2B9CA}']
    procedure Add(aHandler: IProjectChangeEventHandler); safecall;
    procedure Remove(aHandler: IProjectChangeEventHandler); safecall;

    procedure Invoke(aSender: IUnknown; aProject: IProject; aIndex: Integer); safecall;
  end;

implementation

end.
