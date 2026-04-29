program tmp_tvi_test;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Rtti,
  uIProject;

var
  Project: IProject;
begin
  Project := TVirtualInterface.Create(
    TypeInfo(IProject),
    procedure(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue)
    begin
      if Method.Name = 'GetTitle' then
        Result := WideString('ok')
      else if Method.Name = 'SetTitle' then
        Writeln('set=', Args[1].AsString)
      else
        raise Exception.Create(Method.Name);
    end
  ) as IProject;

  Writeln(Project.Title);
  Project.Title := 'changed';
end.
