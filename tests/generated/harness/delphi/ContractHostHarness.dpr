program ContractHostHarness;

{$APPTYPE CONSOLE}
{$A8}

uses
  System.SysUtils,
  Winapi.Windows,
  uICommon,
  uITcPluginCommon,
  uITcEnumExtensionsCallback,
  uITonCut,
  uITcPlugin;

type
  TTcPluginInitialize = function(const aRegRoot: PChar; aLanguageId: Integer; aTonCut: ITonCut): ITcPlugin; stdcall;

  TEnumExtensionsCollector = class(TInterfacedObject, ITcEnumExtensionsCallback)
  public
    procedure Invoke(aType: TTcpExtensionType; const aExtension: WideString; const aName: WideString); safecall;
  end;

var
  LibraryHandle: THandle;
  InitFn: TTcPluginInitialize;
  Plugin: ITcPlugin;
  Backup: WideString;
  EnumCollector: ITcEnumExtensionsCallback;
  SampleCsvPath: String;
  OutputDir: String;
  HadFailure: Boolean;

procedure TEnumExtensionsCollector.Invoke(aType: TTcpExtensionType; const aExtension: WideString; const aName: WideString);
begin
  Writeln('EnumExtension[', Ord(aType), ']: ', String(aExtension), ' => ', String(aName));
end;

procedure InitializePluginFromExport;
var
  InitializedPlugin: ITcPlugin;
begin
  InitializedPlugin := InitFn('Software\TonCut\ContractHarness', 1033, nil);
  Plugin := InitializedPlugin;
  InitializedPlugin := nil;
end;

function ResultAllowed(aResult: TTcpResult; const aAllowed: array of TTcpResult): Boolean;
var
  allowed: TTcpResult;
begin
  for allowed in aAllowed do
    if aResult = allowed then
      Exit(True);
  Result := False;
end;

procedure PrintResult(const aName: String; aResult: TTcpResult; const aAllowed: array of TTcpResult);
begin
  Writeln(aName, ': ', Ord(aResult));
  if not ResultAllowed(aResult, aAllowed) then
  begin
    HadFailure := True;
    Writeln('Unexpected result for ', aName);
  end;
end;

procedure PrintException(const aName: String; const E: Exception);
begin
  HadFailure := True;
  Writeln(aName, ' exception: ', E.Message);
end;

procedure RunPluginSmoke(const aPlugin: ITcPlugin; const aSampleCsvPath, aOutputDir: String);
var
  exportCsv: String;
  exportPlt: String;
begin
  Writeln('--- Plugin Smoke Start ---');
  Writeln('EngineVersion: ', aPlugin.EngineVersion);
  Writeln('Name: ', String(aPlugin.Name));
  Writeln('Title: ', String(aPlugin.Title));
  Writeln('LanguageId: ', aPlugin.LanguageId);
  Writeln('Professional: ', BoolToStr(aPlugin.Professional, True));
  Writeln('UiScale: ', aPlugin.UiScale:0:2);
  Writeln('RegRoot: ', String(aPlugin.RegRoot));
  Writeln('Features mask enum count check only');

  PrintResult('LoadConfig', aPlugin.LoadConfig('Software\TonCut\ContractHarness', 'manual'), [cprOK]);
  PrintResult('SaveConfig', aPlugin.SaveConfig('Software\TonCut\ContractHarness'), [cprOK]);
  Backup := 'caller-owned-preexisting-backup';
  PrintResult('BackupConfig.ReplaceExisting', aPlugin.BackupConfig(Backup), [cprOK]);
  PrintResult('BackupConfig.ReplaceReturned', aPlugin.BackupConfig(Backup), [cprOK]);
  Writeln('BackupConfig value length: ', Length(Backup));
  PrintResult('RestoreConfig', aPlugin.RestoreConfig(Backup, []), [cprOK]);
  PrintResult('Configure', aPlugin.Configure(0), [cprOK, cprNotImplemented]);
  PrintResult('About', aPlugin.About(0), [cprOK]);

  EnumCollector := TEnumExtensionsCollector.Create;
  PrintResult('EnumExtensions.Import', aPlugin.EnumExtensions(etImport, EnumCollector), [cprOK]);
  PrintResult('EnumExtensions.Export', aPlugin.EnumExtensions(etExport, EnumCollector), [cprOK]);
  PrintResult('EnumExtensions.ExportResults', aPlugin.EnumExtensions(etExportResults, EnumCollector), [cprOK]);

  if aSampleCsvPath <> '' then
  begin
    Writeln('Sample CSV: ', aSampleCsvPath);
    PrintResult('IsMyFile', aPlugin.IsMyFile(aSampleCsvPath), [cprOK, cprMaybe, cprNo]);
    try
      PrintResult('LoadFile', aPlugin.LoadFile(0, aSampleCsvPath, nil, nil, nil, nil, nil, nil), [cprOK]);
    except
      on E: Exception do
        PrintException('LoadFile', E);
    end;
  end;

  if aOutputDir <> '' then
  begin
    ForceDirectories(aOutputDir);
    Writeln('OutputDir: ', aOutputDir);
    exportCsv := IncludeTrailingPathDelimiter(aOutputDir) + 'manual-export.csv';
    exportPlt := IncludeTrailingPathDelimiter(aOutputDir) + 'manual-result.plt';
    try
      PrintResult('SaveFile', aPlugin.SaveFile(0, exportCsv, nil, nil), [cprOK]);
    except
      on E: Exception do
        PrintException('SaveFile', E);
    end;
    try
      PrintResult('SaveResult', aPlugin.SaveResult(0, exportPlt, nil), [cprOK]);
    except
      on E: Exception do
        PrintException('SaveResult', E);
    end;
    try
      PrintResult('SavePlot', aPlugin.SavePlot(0, exportPlt, nil), [cprOK, cprNotImplemented]);
    except
      on E: Exception do
        PrintException('SavePlot', E);
    end;
  end;

  try
    PrintResult('BatchSaveResult.File', aPlugin.BatchSaveResult(0, stFile, aOutputDir, nil), [cprOK, cprNotImplemented]);
  except
    on E: Exception do
      PrintException('BatchSaveResult', E);
  end;
  try
    PrintResult('BatchPlot.File', aPlugin.BatchPlot(0, nil), [cprOK, cprNotImplemented]);
  except
    on E: Exception do
      PrintException('BatchPlot', E);
  end;
  try
    PrintResult('Plot', aPlugin.Plot(0, nil), [cprOK, cprNotImplemented]);
  except
    on E: Exception do
      PrintException('Plot', E);
  end;
  try
    PrintResult('BatchSavePlot.File', aPlugin.BatchSavePlot(0, stFile, aOutputDir, nil), [cprOK, cprNotImplemented]);
  except
      on E: Exception do
        PrintException('BatchSavePlot', E);
  end;
  Writeln('--- Plugin Smoke End ---');
end;

begin
  System.ExitCode := 0;
  try
    HadFailure := False;
    if ParamCount = 0 then
    begin
      Writeln(ErrOutput, 'Usage: ContractHostHarness <plugin-path> [sample-csv-path] [output-dir]');
      System.ExitCode := 2;
    end;
    if ParamCount > 0 then
    begin
      LibraryHandle := LoadLibrary(PChar(ParamStr(1)));
      if LibraryHandle = 0 then
        RaiseLastOSError;

      try
        @InitFn := GetProcAddress(LibraryHandle, 'TcpInitializeV2');
        if not Assigned(InitFn) then
          raise Exception.Create('TcpInitializeV2 not found.');

        InitializePluginFromExport;
        if not Assigned(Plugin) then
          raise Exception.Create('Initialization returned nil.');

        Writeln('Loaded plugin: ', String(Plugin.Name));
        if ParamCount >= 2 then
          SampleCsvPath := ParamStr(2)
        else
          SampleCsvPath := '';
        if ParamCount >= 3 then
          OutputDir := ParamStr(3)
        else
          OutputDir := ExtractFilePath(ParamStr(1));
        RunPluginSmoke(Plugin, SampleCsvPath, OutputDir);
        PrintResult('Finalize', Plugin.Finalize, [cprOK]);
        if HadFailure then
          System.ExitCode := 1;
      finally
        EnumCollector := nil;
        Plugin := nil;
        Backup := '';
        SampleCsvPath := '';
        OutputDir := '';
        InitFn := nil;
        if LibraryHandle <> 0 then
          FreeLibrary(LibraryHandle);
      end;
    end;
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, 'Harness exception: ', E.ClassName, ': ', E.Message);
      System.ExitCode := 1;
    end;
    else
    begin
      Writeln(ErrOutput, 'Harness exception: Unknown exception');
      System.ExitCode := 1;
    end;
  end;
end.
