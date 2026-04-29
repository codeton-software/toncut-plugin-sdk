library CsvImportExportDelphi;

{$A8}

uses
  System.SysUtils,
  Winapi.Windows,
  System.Classes,
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
begin
  Result := TCsvImportExportPlugin.Create;
  Result.Initialize(aRegRoot, aLanguageId, aTonCut);
end;

exports
  TcpInitializeV2;

begin
end.
