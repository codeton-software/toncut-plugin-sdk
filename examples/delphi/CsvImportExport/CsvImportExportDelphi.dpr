library CsvImportExportDelphi;

{$A8}

uses
  System.SysUtils,
  Winapi.Windows,
  System.Classes,
  uITcPluginCommon,
  uITonCut,
  uITcPlugin,
  uCsvImportExportPlugin in 'uCsvImportExportPlugin.pas',
  uCsvCommon in 'uCsvCommon.pas';

{$R 'CsvImportExport.res'}

function TcpInitializeV2(
  const aRegRoot: PChar;
  aLanguageId: Integer;
  aTonCut: ITonCut
): ITcPlugin; stdcall;
var
  Plugin: ITcPlugin;
begin
  Result := nil;
  try
    Plugin := TCsvImportExportPlugin.Create;
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
