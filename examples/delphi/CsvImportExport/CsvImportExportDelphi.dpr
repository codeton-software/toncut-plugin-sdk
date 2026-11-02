library CsvImportExportDelphi;

// TonCut Desktop loads lowercase *.plg files from the Plugins\ folder next to
// TonCut.exe. The host is a 32-bit (Win32) process.
{$IFNDEF WIN32}
  {$MESSAGE FATAL 'TonCut plugins must be built for the Win32 platform.'}
{$ENDIF}
{$E plg}
// Quad-word record alignment, as in the TonCut host.
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

// The only export TonCut resolves. aRegRoot is a temporary UTF-16
// HKEY_CURRENT_USER-relative key path (copied here by the WideString
// conversion). The host never calls ITcPlugin.Initialize, so this function
// does; the returned interface carries the one reference the host releases at
// unload. Return nil on failure and never let an exception escape.
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
    if Plugin.Initialize(WideString(aRegRoot), aLanguageId, aTonCut) = cprOK then
      Result := Plugin;
  except
    Result := nil;
  end;
end;

exports
  TcpInitializeV2;

begin
end.
