library ContractProbe;

{$A8}

uses
  Winapi.Windows,
  uITcPluginCommon,
  uITonCut,
  uITcPlugin,
  uContractProbePlugin in 'uContractProbePlugin.pas',
  uContractProbeTouch in 'uContractProbeTouch.pas';

function TcpInitializeV2(const aRegRoot: PChar; aLanguageId: Integer; aTonCut: ITonCut): ITcPlugin; stdcall;
var
  Plugin: ITcPlugin;
begin
  Result := nil;
  try
    Plugin := TContractProbePlugin.Create;
    if Plugin.Initialize(aRegRoot, aLanguageId, aTonCut) = cprOK then
      Result := Plugin;
  except
    Result := nil;
  end;
end;

exports
  TcpInitializeV2;

begin
end.
