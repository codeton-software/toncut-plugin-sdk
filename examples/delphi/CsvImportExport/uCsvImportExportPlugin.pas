unit uCsvImportExportPlugin;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  uICommon,
  uITcPluginCommon,
  uITcPlotterInfo,
  uITcEnumExtensionsCallback,
  uITonCut,
  uITcPlugin,
  uIDevices,
  uIMaterials,
  uIBands,
  uIProjects,
  uIProject,
  uIFormats,
  uIFormat,
  uISheets,
  uISheet,
  uIMaterial,
  uISolution,
  uISolutionSheet,
  uISolutionCut,
  uISolutionCuts,
  uCsvCommon;

type
  TCsvImportExportPlugin = class(TInterfacedObject, ITcPlugin)
  private
    FRegRoot: WideString;
    FLanguageId: Integer;
    FUiScale: Single;
    FTonCut: ITonCut;

    function FindMaterialByTitle(
      const AMaterials: IMaterials;
      const ATitle: string;
      AKind: TMaterialKind;
      AWidth: Cardinal;
      AThickness: Cardinal
    ): IMaterial;
    function EnsureProject(
      const AProjects: IProjects;
      const ATitle: string;
      const AProjectCache: TDictionary<string, IProject>
    ): IProject;
    function EnsureMaterial(
      const AMaterials: IMaterials;
      const ATitle: string;
      AKind: TMaterialKind;
      AWidth: Cardinal;
      AThickness: Cardinal;
      const AMaterialCache: TDictionary<string, IMaterial>
    ): IMaterial;
    function ValidateHeader(const AFileName: WideString): TTcpResult;
    function ExportSolutionSheetAsPlt(
      const ASolutionSheet: ISolutionSheet;
      ACommands: TStrings
    ): Boolean;
  private
    function GetEngineVersion(): Integer; safecall;
    function GetName(): WideString; safecall;
    function GetVersion(): TTcpVersion; safecall;
    function GetTitle(): WideString; safecall;
    function GetProfessional(): Boolean; safecall;
    function GetRegRoot(): WideString; safecall;
    function GetLanguageId(): Integer; safecall;
    procedure SetLanguageId(aLanguageId: Integer); safecall;
    function GetUiScale(): Single; safecall;
    procedure SetUiScale(aScale: Single); safecall;
    function GetTonCut(): ITonCut; safecall;
    function GetFeatures(): TTcpFeatures; safecall;
    function GetPlotterInfo: ITcPlotterInfo; safecall;
  public
    function Initialize(const aRegRoot: WideString; aLanguageId: Integer; aTonCut: ITonCut): TTcpResult; safecall;
    function Finalize(): TTcpResult; safecall;
    function Configure(aWindow: THandle): TTcpResult; safecall;
    function About(aWindow: THandle): TTcpResult; safecall;
    function LoadConfig(const aKey, aVersion: WideString): TTcpResult; safecall;
    function SaveConfig(const aKey: WideString): TTcpResult; safecall;
    function BackupConfig(var aBackup: WideString): TTcpResult; safecall;
    function RestoreConfig(const aBackup: WideString; aScope: TConfigurationParts): TTcpResult; safecall;
    function EnumExtensions(aType: TTcpExtensionType; aEnumCb: ITcEnumExtensionsCallback): TTcpResult; safecall;
    function IsMyFile(const aFileName: WideString): TTcpResult; safecall;
    function LoadFile(aWindow: THandle; const aFileName: WideString; aDevices: IDevices; aMaterials: IMaterials; aBands: IBands; aProjects: IProjects; aFormats: IFormats; aSheets: ISheets): TTcpResult; safecall;
    function SaveFile(aWindow: THandle; const aFileName: WideString; const aFormats: IFormats; const aSheets: ISheets): TTcpResult; safecall;
    function SaveResult(aWindow: THandle; const aFileName: WideString; const aSolutionSheet: ISolutionSheet): TTcpResult; safecall;
    function BatchSaveResult(aWindow: THandle; aSaveTarget: TTcpSaveTarget; const aPath: WideString; const aSolution: ISolution): TTcpResult; safecall;
    function Plot(aWindow: THandle; const aSolutionSheet: ISolutionSheet): TTcpResult; safecall;
    function BatchPlot(aWindow: THandle; const aSolution: ISolution): TTcpResult; safecall;
    function SavePlot(aWindow: THandle; const aFileName: WideString; const aSolutionSheet: ISolutionSheet): TTcpResult; safecall;
    function BatchSavePlot(aWindow: THandle; aSaveTarget: TTcpSaveTarget; const aPath: WideString; const aSolution: ISolution): TTcpResult; safecall;
  end;

implementation

function NormalizeMaterialKey(const ATitle: string): string;
begin
  Result := LowerCase(Trim(ATitle));
end;

function EffectiveMaterialWidth(AKind: TMaterialKind; AWidth: Cardinal): Cardinal;
begin
  if AKind = mk1D then
    Result := AWidth
  else
    Result := 0;
end;

function MakeMaterialKey(
  const ATitle: string;
  AKind: TMaterialKind;
  AWidth: Cardinal;
  AThickness: Cardinal
): string;
begin
  Result := Format(
    '%s|%d|%d|%d',
    [
      NormalizeMaterialKey(ATitle),
      Integer(AKind),
      EffectiveMaterialWidth(AKind, AWidth),
      AThickness
    ]
  );
end;

function TryFromCsvMillimeters(const AValue: Cardinal; out AScaled: Cardinal): Boolean;
var
  scaledValue: UInt64;
begin
  scaledValue := UInt64(AValue) * UInt64(cLengthMultiplier);
  Result := scaledValue <= High(Cardinal);
  if Result then
    AScaled := Cardinal(scaledValue)
  else
    AScaled := 0;
end;

function ToCsvMillimeters(const AValue: Cardinal): Cardinal;
begin
  Result := Cardinal(
    (UInt64(AValue) + UInt64(cLengthMultiplier div 2)) div
    UInt64(cLengthMultiplier)
  );
end;

function TCsvImportExportPlugin.FindMaterialByTitle(
  const AMaterials: IMaterials;
  const ATitle: string;
  AKind: TMaterialKind;
  AWidth: Cardinal;
  AThickness: Cardinal
): IMaterial;
begin
  Result := nil;
  if (AMaterials = nil) or (Trim(ATitle) = '') then
    Exit;

  Result := AMaterials.FindByTitle(
    Trim(ATitle),
    AKind,
    EffectiveMaterialWidth(AKind, AWidth),
    AThickness
  );
end;

function TCsvImportExportPlugin.EnsureProject(
  const AProjects: IProjects;
  const ATitle: string;
  const AProjectCache: TDictionary<string, IProject>
): IProject;
var
  key: string;
  title: string;
begin
  title := Trim(ATitle);
  if title = '' then
    title := 'CSV Import';
  key := NormalizeMaterialKey(title);

  if AProjects = nil then
    Exit(nil);

  if (AProjectCache <> nil) and AProjectCache.TryGetValue(key, Result) and (Result <> nil) then
    Exit;

  Result := nil;
  if FTonCut <> nil then
    begin
      Result := FTonCut.CreateProject(title);
      if Result <> nil then
        AProjects.Add(Result);
    end;

  if (AProjectCache <> nil) and (Result <> nil) then
    AProjectCache.AddOrSetValue(key, Result);
end;

function TCsvImportExportPlugin.EnsureMaterial(
  const AMaterials: IMaterials;
  const ATitle: string;
  AKind: TMaterialKind;
  AWidth: Cardinal;
  AThickness: Cardinal;
  const AMaterialCache: TDictionary<string, IMaterial>
): IMaterial;
var
  effectiveWidth: Cardinal;
  key: string;
  title: string;
begin
  title := Trim(ATitle);
  if title = '' then
    title := 'CSV Material';
  effectiveWidth := EffectiveMaterialWidth(AKind, AWidth);
  key := MakeMaterialKey(title, AKind, effectiveWidth, AThickness);

  if AMaterials = nil then
    Exit(nil);

  if (AMaterialCache <> nil) and AMaterialCache.TryGetValue(key, Result) and (Result <> nil) then
    Exit;

  Result := FindMaterialByTitle(AMaterials, title, AKind, effectiveWidth, AThickness);

  if (Result = nil) and (FTonCut <> nil) then
    begin
      if not AMaterials.CheckUniqueName(title, AKind, effectiveWidth, AThickness, nil) then
        Exit(nil);
      Result := FTonCut.CreateMaterial(title, AKind, effectiveWidth, AThickness);
    end;

  if (AMaterialCache <> nil) and (Result <> nil) then
    begin
      AMaterialCache.AddOrSetValue(key, Result);
      if Trim(Result.Title) <> '' then
        AMaterialCache.AddOrSetValue(
          MakeMaterialKey(Result.Title, Result.Kind, Result.Width, Result.Thickness),
          Result
        );
    end;
end;

function TCsvImportExportPlugin.ValidateHeader(const AFileName: WideString): TTcpResult;
var
  text: string;
  table: TCsvTable;
begin
  if not SameText(ExtractFileExt(AFileName), '.csv') then
    Exit(cprNo);

  if not FileExists(AFileName) then
    Exit(cprFailed);

  try
    text := TFile.ReadAllText(AFileName, TEncoding.UTF8);
    table := ParseCsvText(text);
    if (Length(table) > 0) and HasRequiredHeader(table[0]) then
      Result := cprOK
    else
      Result := cprNo;
  except
    Result := cprFailed;
  end;
end;

function TCsvImportExportPlugin.GetEngineVersion(): Integer;
begin
  Result := cEngineVersion;
end;

function TCsvImportExportPlugin.GetName(): WideString;
begin
  Result := 'CsvImportExportTemplateDelphi';
end;

function TCsvImportExportPlugin.GetVersion(): TTcpVersion;
begin
  Result := MakeTcpVersion(1, 0, 0, 0);
end;

function TCsvImportExportPlugin.GetTitle(): WideString;
begin
  Result := 'CSV Import/Export + PLT Result Template (Delphi)';
end;

function TCsvImportExportPlugin.GetProfessional(): Boolean;
begin
  Result := False;
end;

function TCsvImportExportPlugin.GetRegRoot(): WideString;
begin
  Result := FRegRoot;
end;

function TCsvImportExportPlugin.GetLanguageId(): Integer;
begin
  Result := FLanguageId;
end;

procedure TCsvImportExportPlugin.SetLanguageId(aLanguageId: Integer);
begin
  FLanguageId := aLanguageId;
end;

function TCsvImportExportPlugin.GetUiScale(): Single;
begin
  Result := FUiScale;
end;

procedure TCsvImportExportPlugin.SetUiScale(aScale: Single);
begin
  FUiScale := aScale;
end;

function TCsvImportExportPlugin.GetTonCut(): ITonCut;
begin
  Result := FTonCut;
end;

function TCsvImportExportPlugin.GetFeatures(): TTcpFeatures;
begin
  Result := [feImport, feExport, feSaveResultToFile, feConfigure, feAbout];
end;

function TCsvImportExportPlugin.GetPlotterInfo: ITcPlotterInfo;
begin
  Result := nil;
end;

function TCsvImportExportPlugin.Initialize(
  const aRegRoot: WideString;
  aLanguageId: Integer;
  aTonCut: ITonCut
): TTcpResult;
begin
  FRegRoot := aRegRoot;
  FLanguageId := aLanguageId;
  FTonCut := aTonCut;
  Result := cprOK;
end;

function TCsvImportExportPlugin.Finalize(): TTcpResult;
begin
  FTonCut := nil;
  Result := cprOK;
end;

function TCsvImportExportPlugin.Configure(aWindow: THandle): TTcpResult;
begin
  if aWindow <> 0 then
    MessageBoxW(
      aWindow,
      PWideChar(WideString('This starter plugin does not expose configurable options yet.')),
      PWideChar(GetTitle()),
      MB_OK or MB_ICONINFORMATION
    );
  Result := cprOK;
end;

function TCsvImportExportPlugin.About(aWindow: THandle): TTcpResult;
begin
  if aWindow <> 0 then
    MessageBoxW(
      aWindow,
      PWideChar(WideString('CSV import/export plus single-sheet PLT result export.')),
      PWideChar(GetTitle()),
      MB_OK or MB_ICONINFORMATION
    );
  Result := cprOK;
end;

function TCsvImportExportPlugin.LoadConfig(
  const aKey, aVersion: WideString
): TTcpResult;
begin
  Result := cprOK;
end;

function TCsvImportExportPlugin.SaveConfig(const aKey: WideString): TTcpResult;
begin
  Result := cprOK;
end;

function TCsvImportExportPlugin.BackupConfig(var aBackup: WideString): TTcpResult;
begin
  aBackup := '';
  Result := cprOK;
end;

function TCsvImportExportPlugin.RestoreConfig(
  const aBackup: WideString;
  aScope: TConfigurationParts
): TTcpResult;
begin
  Result := cprOK;
end;

function TCsvImportExportPlugin.EnumExtensions(
  aType: TTcpExtensionType;
  aEnumCb: ITcEnumExtensionsCallback
): TTcpResult;
begin
  case aType of
    etImport,
    etExport:
      aEnumCb.Invoke(aType, '.csv', GetTitle());
    etExportResults:
      aEnumCb.Invoke(aType, '.plt', GetTitle());
  end;
  Result := cprOK;
end;

function TCsvImportExportPlugin.IsMyFile(const aFileName: WideString): TTcpResult;
begin
  Result := ValidateHeader(aFileName);
end;

function TCsvImportExportPlugin.LoadFile(
  aWindow: THandle;
  const aFileName: WideString;
  aDevices: IDevices;
  aMaterials: IMaterials;
  aBands: IBands;
  aProjects: IProjects;
  aFormats: IFormats;
  aSheets: ISheets
): TTcpResult;
var
  text: string;
  table: TCsvTable;
  row: TCsvRow;
  i: Integer;
  recordType: string;
  material: IMaterial;
  project: IProject;
  format: IFormat;
  sheet: ISheet;
  materialKind: TMaterialKind;
  materialWidth: Cardinal;
  materialThickness: Cardinal;
  itemLength: Cardinal;
  itemWidth: Cardinal;
  quantity: Cardinal;
  projectCache: TDictionary<string, IProject>;
  materialCache: TDictionary<string, IMaterial>;
  headerResult: TTcpResult;
begin
  if FTonCut = nil then
    Exit(cprNotInitialized);

  if (aProjects = nil) or (aMaterials = nil) or (aFormats = nil) or (aSheets = nil) then
    Exit(cprFailed);

  headerResult := ValidateHeader(aFileName);
  if headerResult <> cprOK then
    Exit(headerResult);

  try
    text := TFile.ReadAllText(aFileName, TEncoding.UTF8);
    table := ParseCsvText(text);
    if (Length(table) = 0) or not HasRequiredHeader(table[0]) then
      Exit(cprNo);
    projectCache := TDictionary<string, IProject>.Create;
    try
      materialCache := TDictionary<string, IMaterial>.Create;
      try
        aProjects.BeginUpdate();
        try
          aFormats.BeginUpdate();
          try
            aSheets.BeginUpdate();
            try
              for i := 1 to Length(table) - 1 do
                begin
              row := table[i];
              if Length(row) = 0 then
                Continue;

              recordType := UpperCase(CellByName(table[0], row, 'RecordType'));
              if recordType = '' then
                Continue;
              if (recordType <> 'FORMAT') and (recordType <> 'SHEET') then
                Exit(cprFailed);

              if not TryParseMaterialKind(CellByName(table[0], row, 'MaterialKind'), materialKind) then
                Exit(cprFailed);
              if not TryParseCardinalField(CellByName(table[0], row, 'MaterialWidth'), materialWidth) then
                Exit(cprFailed);
              if not TryParseCardinalField(CellByName(table[0], row, 'MaterialThickness'), materialThickness) then
                Exit(cprFailed);
              if not TryParseCardinalField(CellByName(table[0], row, 'Length'), itemLength) then
                Exit(cprFailed);
              if not TryParseCardinalField(CellByName(table[0], row, 'Width'), itemWidth) then
                Exit(cprFailed);

              if not TryParseCardinalField(CellByName(table[0], row, 'Quantity'), quantity) then
                quantity := 1;
              if quantity = 0 then
                quantity := 1;
              if (recordType = 'SHEET') and (quantity > Cardinal(MaxInt)) then
                Exit(cprFailed);
              if not TryFromCsvMillimeters(materialWidth, materialWidth) then
                Exit(cprFailed);
              if not TryFromCsvMillimeters(materialThickness, materialThickness) then
                Exit(cprFailed);
              if not TryFromCsvMillimeters(itemLength, itemLength) then
                Exit(cprFailed);
              if not TryFromCsvMillimeters(itemWidth, itemWidth) then
                Exit(cprFailed);

              if recordType = 'FORMAT' then
                begin
                  project := EnsureProject(
                    aProjects,
                    CellByName(table[0], row, 'ProjectTitle'),
                    projectCache
                  );
                  if project = nil then
                    Exit(cprFailed);
                end;

              material := EnsureMaterial(
                aMaterials,
                CellByName(table[0], row, 'MaterialTitle'),
                materialKind,
                materialWidth,
                materialThickness,
                materialCache
              );
              if material = nil then
                Exit(cprFailed);

              if recordType = 'FORMAT' then
                begin
                  format := aFormats.CreateFormat();
                  if format = nil then
                    Exit(cprFailed);

                  format.Project := project;
                  format.Material := material;
                  format.Length := itemLength;
                  format.Width := itemWidth;
                  format.Quantity := quantity;
                  format.Identifier := CellByName(table[0], row, 'Identifier');
                  format.Description := CellByName(table[0], row, 'Description');
                  aFormats.Add(format);
                end
              else if recordType = 'SHEET' then
                begin
                  sheet := aSheets.CreateSheet();
                  if sheet = nil then
                    Exit(cprFailed);

                  sheet.Material := material;
                  sheet.Length := itemLength;
                  sheet.Width := itemWidth;
                  sheet.Quantity := Integer(quantity);
                  sheet.Identifier := CellByName(table[0], row, 'Identifier');
                  sheet.Description := CellByName(table[0], row, 'Description');
                  aSheets.Add(sheet);
                end
              else
                Exit(cprFailed);
                end;
            finally
              aSheets.EndUpdate();
            end;
          finally
            aFormats.EndUpdate();
          end;
        finally
          aProjects.EndUpdate();
        end;
      finally
        materialCache.Free;
      end;
    finally
      projectCache.Free;
    end;

    Result := cprOK;
  except
    on E: Exception do
      Result := cprException;
  end;
end;

function TCsvImportExportPlugin.SaveFile(
  aWindow: THandle;
  const aFileName: WideString;
  const aFormats: IFormats;
  const aSheets: ISheets
): TTcpResult;
var
  lines: TStringList;
  i: Integer;
  format: IFormat;
  sheet: ISheet;
  projectTitle: string;
  materialTitle: string;
  materialKind: string;
begin
  lines := TStringList.Create;
  try
    lines.LineBreak := #13#10;
    lines.Add(CsvHeaderLine());

    for i := 0 to aFormats.Count - 1 do
      begin
        format := aFormats[i];
        if format.Project <> nil then
          projectTitle := format.Project.Title
        else
          projectTitle := '';

        if format.Material <> nil then
          begin
            materialTitle := format.Material.Title;
            materialKind := MaterialKindToText(format.Material.Kind);
            lines.Add(BuildCsvLine([
              'FORMAT',
              projectTitle,
              materialTitle,
              materialKind,
              IntToStr(ToCsvMillimeters(
                EffectiveMaterialWidth(format.Material.Kind, format.Material.Width)
              )),
              IntToStr(ToCsvMillimeters(format.Material.Thickness)),
              IntToStr(ToCsvMillimeters(format.Length)),
              IntToStr(ToCsvMillimeters(format.Width)),
              IntToStr(format.Quantity),
              format.Identifier,
              format.Description
            ]));
          end;
      end;

    for i := 0 to aSheets.Count - 1 do
      begin
        sheet := aSheets[i];
        if sheet.Material <> nil then
          begin
            materialTitle := sheet.Material.Title;
            materialKind := MaterialKindToText(sheet.Material.Kind);
            lines.Add(BuildCsvLine([
              'SHEET',
              '',
              materialTitle,
              materialKind,
              IntToStr(ToCsvMillimeters(
                EffectiveMaterialWidth(sheet.Material.Kind, sheet.Material.Width)
              )),
              IntToStr(ToCsvMillimeters(sheet.Material.Thickness)),
              IntToStr(ToCsvMillimeters(sheet.Length)),
              IntToStr(ToCsvMillimeters(sheet.Width)),
              IntToStr(sheet.Quantity),
              sheet.Identifier,
              sheet.Description
            ]));
          end;
      end;

    TFile.WriteAllText(aFileName, lines.Text, TEncoding.UTF8);
    Result := cprOK;
  except
    Result := cprException;
  end;
  lines.Free;
end;

function TCsvImportExportPlugin.SaveResult(
  aWindow: THandle;
  const aFileName: WideString;
  const aSolutionSheet: ISolutionSheet
): TTcpResult;
var
  commands: TStringList;
begin
  commands := TStringList.Create;
  try
    try
      if not ExportSolutionSheetAsPlt(aSolutionSheet, commands) then
        Result := cprFailed
      else
        begin
          commands.SaveToFile(aFileName, TEncoding.ASCII);
          if aSolutionSheet <> nil then
            aSolutionSheet.IsSaved := True;
          Result := cprOK;
        end;
    except
      Result := cprException;
    end;
  finally
    commands.Free;
  end;
end;

function TCsvImportExportPlugin.BatchSaveResult(
  aWindow: THandle;
  aSaveTarget: TTcpSaveTarget;
  const aPath: WideString;
  const aSolution: ISolution
): TTcpResult;
begin
  Result := cprNotImplemented;
end;

function TCsvImportExportPlugin.Plot(
  aWindow: THandle;
  const aSolutionSheet: ISolutionSheet
): TTcpResult;
begin
  Result := cprNotImplemented;
end;

function TCsvImportExportPlugin.BatchPlot(
  aWindow: THandle;
  const aSolution: ISolution
): TTcpResult;
begin
  Result := cprNotImplemented;
end;

function TCsvImportExportPlugin.SavePlot(
  aWindow: THandle;
  const aFileName: WideString;
  const aSolutionSheet: ISolutionSheet
): TTcpResult;
begin
  Result := cprNotImplemented;
end;

function TCsvImportExportPlugin.BatchSavePlot(
  aWindow: THandle;
  aSaveTarget: TTcpSaveTarget;
  const aPath: WideString;
  const aSolution: ISolution
): TTcpResult;
begin
  Result := cprNotImplemented;
end;

function TCsvImportExportPlugin.ExportSolutionSheetAsPlt(
  const ASolutionSheet: ISolutionSheet;
  ACommands: TStrings
): Boolean;
var
  sheetLength, sheetWidth: Cardinal;
  marginLeft, marginTop, marginRight, marginBottom: Cardinal;
  scale: Double;
  i: Integer;
  cut: ISolutionCut;
  x0, y0, x1, y1, x2, y2, x3, y3: Double;

  function ToPlotterUnit(const AValue: Double): Integer;
  begin
    Result := Round(AValue * scale);
  end;

  procedure Transform(var AX, AY: Double);
  begin
    ASolutionSheet.CalcPointF(AX, AY);
  end;
begin
  Result := False;
  if (ASolutionSheet = nil) or (ACommands = nil) then
    Exit;

  ASolutionSheet.CalcEffectiveLayout(
    sheetLength,
    sheetWidth,
    marginLeft,
    marginTop,
    marginRight,
    marginBottom
  );
  if (sheetLength = 0) or (sheetWidth = 0) then
    Exit;

  scale := 40.0 / 25.4;
  ACommands.Clear;
  ACommands.Add('IN;');
  ACommands.Add('PA;');

  for i := 0 to ASolutionSheet.SolutionCuts.Count - 1 do
    begin
      cut := ASolutionSheet.SolutionCuts[i];
      if cut = nil then
        Exit;

      case cut.Kind of
        ckLine:
          begin
            x0 := cut.PosX;
            y0 := cut.PosY;
            x3 := cut.TarX;
            y3 := cut.TarY;

            Transform(x0, y0);
            Transform(x3, y3);

            ACommands.Add(Format('PU%d,%d;', [ToPlotterUnit(x0), ToPlotterUnit(y0)]));
            ACommands.Add(Format('PD%d,%d;', [ToPlotterUnit(x3), ToPlotterUnit(y3)]));
          end;

        ckCurve:
          begin
            x0 := cut.PosX;
            y0 := cut.PosY;
            x1 := cut.PosXp;
            y1 := cut.PosYp;
            x2 := cut.TarXp;
            y2 := cut.TarYp;
            x3 := cut.TarX;
            y3 := cut.TarY;

            Transform(x0, y0);
            Transform(x1, y1);
            Transform(x2, y2);
            Transform(x3, y3);

            ACommands.Add(Format('PU%d,%d;', [ToPlotterUnit(x0), ToPlotterUnit(y0)]));
            ACommands.Add(Format(
              'BZ%d,%d,%d,%d,%d,%d;',
              [
                ToPlotterUnit(x1), ToPlotterUnit(y1),
                ToPlotterUnit(x2), ToPlotterUnit(y2),
                ToPlotterUnit(x3), ToPlotterUnit(y3)
              ]
            ));
          end;
      end;
    end;

  ACommands.Add('PU;');
  ACommands.Add('SP0;');
  Result := True;
end;

end.
