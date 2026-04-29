library ContractProbe;

{$A8}

uses
  Winapi.Windows,
  uITonCut,
  uITcPlugin,
  uContractProbePlugin in 'uContractProbePlugin.pas',
  uContractProbeTouch in 'uContractProbeTouch.pas';

function TcpInitializeV2(const aRegRoot: PChar; aLanguageId: Integer; aTonCut: ITonCut): ITcPlugin; stdcall;
begin
  Result := TContractProbePlugin.Create;
  Result.Initialize(aRegRoot, aLanguageId, aTonCut);
end;

exports
  TcpInitializeV2;

begin
end.
