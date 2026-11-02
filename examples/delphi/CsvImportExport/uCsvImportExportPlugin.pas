unit uCsvImportExportPlugin;

// Delphi starter plugin:
// - CSV import (LoadFile) and export (SaveFile) of pieces and stock sheets;
// - result export (SaveResult) of one solution sheet, either as HPGL cutting
//   paths (.plt) or as a CSV sheet layout with placed parts and waste (.csv).
//
// Every safecall method returns a TTcpResult and catches its own exceptions:
// an exception escaping a safecall method reaches TonCut as a failed HRESULT,
// and TonCut then disables the plugin.

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  uICommon,
  uITcPluginCommon,
  uITcPlotterInfo,
  uITcEnumExtensionsCallback,
  uITonCut,
  uITcPlugin,
  uIDevice,
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
  uISolutionFormat,
  uISolutionFormats,
  uISolutionWaste,
  uISolutionWastes,
  uCsvCommon;

type
  TCsvImportExportPlugin = class(TInterfacedObject, ITcPlugin)
  private
    FRegRoot: WideString;
    FLanguageId: Integer;
    FUiScale: Single;
    FTonCut: ITonCut;

    function FindOrCreateProject(
      const AProjects: IProjects;
      const ATitle: string
    ): IProject;
    function FindDeviceForKind(AKind: TMaterialKind): IDevice;
    function FindOrCreateMaterial(
      const AMaterials: IMaterials;
      const ATitle: string;
      AKind: TMaterialKind;
      AWidth: Cardinal;
      AThickness: Cardinal
    ): IMaterial;
    function ValidateHeader(const AFileName: WideString): TTcpResult;
    function ExportSolutionSheetAsPlt(
      const ASolutionSheet: ISolutionSheet;
      ACommands: TStrings
    ): Boolean;
    function ExportSolutionSheetLayout(
      const ASolutionSheet: ISolutionSheet;
      ALines: TStrings
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

const
  // HPGL plotter units: 40 per millimeter. TonCut lengths are 0.01 mm
  // (cLengthMultiplier per mm), so one internal unit is 0.4 HPGL units.
  cHpglUnitsPerMillimeter = 40.0;

type
  // Minimal ITcPlotterInfo. GetPlotterInfo must never return nil while a
  // save or plot feature is advertised: the host copies the returned object.
  // The defaults match the host's defaults for a device without a driver
  // plugin. MaterialKinds must list the kinds this plugin can save; the Save
  // results dialog disables sheets of any other kind.
  // AxisX, AxisY, DefaultRotation and DefaultMirror define the output frame
  // the host uses for ISolutionSheet.SolutionCuts and CalcPoint: set them to
  // match the coordinate system of the target machine or file format.
  TStarterPlotterInfo = class(TInterfacedObject, ITcPlotterInfo)
  private
    FPlotterType: TTcPlotterType;
    FMaterialKinds: TMaterialKinds;
    FAxisX: TTcAxisDirection;
    FAxisY: TTcAxisDirection;
    FSizeX: Cardinal;
    FSizeY: Cardinal;
    FCanCrossCuts: Boolean;
    FFullCutsOnly: Boolean;
    FCanCutAnyShapes: Boolean;
    FStripCuts: TStripCutting;
    FMaxStripeWidth: Integer;
    FCutsDepthOn: Boolean;
    FCutsDepth: Cardinal;
    FCutsDepthIncMargins: Boolean;
    FTwoDimensionMoves: Boolean;
    FPrefferedDirection: TTcMoveDirection;
    FMarginWest: Cardinal;
    FMarginNorth: Cardinal;
    FMarginEast: Cardinal;
    FMarginSouth: Cardinal;
    FBridgeMoveDirection: TTcMoveDirection;
    FBridgeSize: Cardinal;
    FHeadSize: Cardinal;
    FHeadKnifeSpace: Cardinal;
    FDefaultRotation: Integer;
    FDefaultMirror: TMirrors;
  public
    constructor Create();

    function GetPlotterType(): TTcPlotterType; safecall;
    procedure SetPlotterType(aPlotterType: TTcPlotterType); safecall;
    function GetMaterialKinds(): TMaterialKinds; safecall;
    procedure SetMaterialKinds(aMaterialKinds: TMaterialKinds); safecall;
    function GetAxisX(): TTcAxisDirection; safecall;
    procedure SetAxisX(aAxisX: TTcAxisDirection); safecall;
    function GetAxisY(): TTcAxisDirection; safecall;
    procedure SetAxisY(aAxisY: TTcAxisDirection); safecall;
    function GetSizeX(): Cardinal; safecall;
    procedure SetSizeX(aSizeX: Cardinal); safecall;
    function GetSizeY(): Cardinal; safecall;
    procedure SetSizeY(aSizeY: Cardinal); safecall;
    function GetCanCrossCuts(): Boolean; safecall;
    procedure SetCanCrossCuts(aCanCrossCuts: Boolean); safecall;
    function GetFullCutsOnly(): Boolean; safecall;
    procedure SetFullCutsOnly(aFullCutsOnly: Boolean); safecall;
    function GetCanCutAnyShapes(): Boolean; safecall;
    procedure SetCanCutAnyShapes(aCanCutAnyShapes: Boolean); safecall;
    function GetStripCuts(): TStripCutting; safecall;
    procedure SetStripCuts(aStripCuts: TStripCutting); safecall;
    function GetMaxStripeWidth(): Integer; safecall;
    procedure SetMaxStripeWidth(aMaxWidth: Integer); safecall;
    function GetCutsDepthOn(): Boolean; safecall;
    procedure SetCutsDepthOn(aCutsDepthOn: Boolean); safecall;
    function GetCutsDepth(): Cardinal; safecall;
    procedure SetCutsDepth(aCutsDepth: Cardinal); safecall;
    function GetCutsDepthIncMargins(): Boolean; safecall;
    procedure SetCutsDepthIncMargins(aCutsDepthIncMargins: Boolean); safecall;
    function GetTwoDimensionMoves(): Boolean; safecall;
    procedure SetTwoDimensionMoves(aTwoDimensionMoves: Boolean); safecall;
    function GetPrefferedDirection(): TTcMoveDirection; safecall;
    procedure SetPrefferedDirection(aPrefferedDirection: TTcMoveDirection); safecall;
    function GetMarginWest(): Cardinal; safecall;
    procedure SetMarginWest(aMarginWest: Cardinal); safecall;
    function GetMarginNorth(): Cardinal; safecall;
    procedure SetMarginNorth(aMarginNorth: Cardinal); safecall;
    function GetMarginEast(): Cardinal; safecall;
    procedure SetMarginEast(aMarginEast: Cardinal); safecall;
    function GetMarginSouth(): Cardinal; safecall;
    procedure SetMarginSouth(aMarginSouth: Cardinal); safecall;
    function GetBridgeMoveDirection(): TTcMoveDirection; safecall;
    procedure SetBridgeMoveDirection(aBridgeMoveDirection: TTcMoveDirection); safecall;
    function GetBridgeSize(): Cardinal; safecall;
    procedure SetBridgeSize(aBridgeSize: Cardinal); safecall;
    function GetHeadSize(): Cardinal; safecall;
    procedure SetHeadSize(aHeadSize: Cardinal); safecall;
    function GetHeadKnifeSpace(): Cardinal; safecall;
    procedure SetHeadKnifeSpace(aHeadKnifeSpace: Cardinal); safecall;
    function GetDefaultRotation(): Integer; safecall;
    procedure SetDefaultRotation(aDefaultRotation: Integer); safecall;
    function GetDefaultMirror(): TMirrors; safecall;
    procedure SetDefaultMirror(aDefaultMirror: TMirrors); safecall;
    procedure Assign(const aOther: ITcPlotterInfo); safecall;
  end;

constructor TStarterPlotterInfo.Create();
begin
  inherited Create();
  FPlotterType := ptUnknown;
  FMaterialKinds := [mk1D, mk2D];
  FAxisX := adEast;
  FAxisY := adSouth;
  FSizeX := 133;
  FSizeY := 100;
  FCanCrossCuts := False;
  FFullCutsOnly := True;
  FCanCutAnyShapes := True;
  FStripCuts := scNone;
  FMaxStripeWidth := 1200 * cLengthMultiplier;
  FCutsDepthOn := False;
  FCutsDepth := 0;
  FCutsDepthIncMargins := False;
  FTwoDimensionMoves := True;
  FPrefferedDirection := mdAny;
  FMarginWest := 5;
  FMarginNorth := 5;
  FMarginEast := 5;
  FMarginSouth := 5;
  FBridgeMoveDirection := mdAlongX;
  FBridgeSize := 10;
  FHeadSize := 10;
  FHeadKnifeSpace := 5;
  FDefaultRotation := 0;
  FDefaultMirror := [];
end;

function TStarterPlotterInfo.GetPlotterType(): TTcPlotterType; begin Result := FPlotterType; end;
procedure TStarterPlotterInfo.SetPlotterType(aPlotterType: TTcPlotterType); begin FPlotterType := aPlotterType; end;
function TStarterPlotterInfo.GetMaterialKinds(): TMaterialKinds; begin Result := FMaterialKinds; end;
procedure TStarterPlotterInfo.SetMaterialKinds(aMaterialKinds: TMaterialKinds); begin FMaterialKinds := aMaterialKinds; end;
function TStarterPlotterInfo.GetAxisX(): TTcAxisDirection; begin Result := FAxisX; end;
procedure TStarterPlotterInfo.SetAxisX(aAxisX: TTcAxisDirection); begin FAxisX := aAxisX; end;
function TStarterPlotterInfo.GetAxisY(): TTcAxisDirection; begin Result := FAxisY; end;
procedure TStarterPlotterInfo.SetAxisY(aAxisY: TTcAxisDirection); begin FAxisY := aAxisY; end;
function TStarterPlotterInfo.GetSizeX(): Cardinal; begin Result := FSizeX; end;
procedure TStarterPlotterInfo.SetSizeX(aSizeX: Cardinal); begin FSizeX := aSizeX; end;
function TStarterPlotterInfo.GetSizeY(): Cardinal; begin Result := FSizeY; end;
procedure TStarterPlotterInfo.SetSizeY(aSizeY: Cardinal); begin FSizeY := aSizeY; end;
function TStarterPlotterInfo.GetCanCrossCuts(): Boolean; begin Result := FCanCrossCuts; end;
procedure TStarterPlotterInfo.SetCanCrossCuts(aCanCrossCuts: Boolean); begin FCanCrossCuts := aCanCrossCuts; end;
function TStarterPlotterInfo.GetFullCutsOnly(): Boolean; begin Result := FFullCutsOnly; end;
procedure TStarterPlotterInfo.SetFullCutsOnly(aFullCutsOnly: Boolean); begin FFullCutsOnly := aFullCutsOnly; end;
function TStarterPlotterInfo.GetCanCutAnyShapes(): Boolean; begin Result := FCanCutAnyShapes; end;
procedure TStarterPlotterInfo.SetCanCutAnyShapes(aCanCutAnyShapes: Boolean); begin FCanCutAnyShapes := aCanCutAnyShapes; end;
function TStarterPlotterInfo.GetStripCuts(): TStripCutting; begin Result := FStripCuts; end;
procedure TStarterPlotterInfo.SetStripCuts(aStripCuts: TStripCutting); begin FStripCuts := aStripCuts; end;
function TStarterPlotterInfo.GetMaxStripeWidth(): Integer; begin Result := FMaxStripeWidth; end;
procedure TStarterPlotterInfo.SetMaxStripeWidth(aMaxWidth: Integer); begin FMaxStripeWidth := aMaxWidth; end;
function TStarterPlotterInfo.GetCutsDepthOn(): Boolean; begin Result := FCutsDepthOn; end;
procedure TStarterPlotterInfo.SetCutsDepthOn(aCutsDepthOn: Boolean); begin FCutsDepthOn := aCutsDepthOn; end;
function TStarterPlotterInfo.GetCutsDepth(): Cardinal; begin Result := FCutsDepth; end;
procedure TStarterPlotterInfo.SetCutsDepth(aCutsDepth: Cardinal); begin FCutsDepth := aCutsDepth; end;
function TStarterPlotterInfo.GetCutsDepthIncMargins(): Boolean; begin Result := FCutsDepthIncMargins; end;
procedure TStarterPlotterInfo.SetCutsDepthIncMargins(aCutsDepthIncMargins: Boolean); begin FCutsDepthIncMargins := aCutsDepthIncMargins; end;
function TStarterPlotterInfo.GetTwoDimensionMoves(): Boolean; begin Result := FTwoDimensionMoves; end;
procedure TStarterPlotterInfo.SetTwoDimensionMoves(aTwoDimensionMoves: Boolean); begin FTwoDimensionMoves := aTwoDimensionMoves; end;
function TStarterPlotterInfo.GetPrefferedDirection(): TTcMoveDirection; begin Result := FPrefferedDirection; end;
procedure TStarterPlotterInfo.SetPrefferedDirection(aPrefferedDirection: TTcMoveDirection); begin FPrefferedDirection := aPrefferedDirection; end;
function TStarterPlotterInfo.GetMarginWest(): Cardinal; begin Result := FMarginWest; end;
procedure TStarterPlotterInfo.SetMarginWest(aMarginWest: Cardinal); begin FMarginWest := aMarginWest; end;
function TStarterPlotterInfo.GetMarginNorth(): Cardinal; begin Result := FMarginNorth; end;
procedure TStarterPlotterInfo.SetMarginNorth(aMarginNorth: Cardinal); begin FMarginNorth := aMarginNorth; end;
function TStarterPlotterInfo.GetMarginEast(): Cardinal; begin Result := FMarginEast; end;
procedure TStarterPlotterInfo.SetMarginEast(aMarginEast: Cardinal); begin FMarginEast := aMarginEast; end;
function TStarterPlotterInfo.GetMarginSouth(): Cardinal; begin Result := FMarginSouth; end;
procedure TStarterPlotterInfo.SetMarginSouth(aMarginSouth: Cardinal); begin FMarginSouth := aMarginSouth; end;
function TStarterPlotterInfo.GetBridgeMoveDirection(): TTcMoveDirection; begin Result := FBridgeMoveDirection; end;
procedure TStarterPlotterInfo.SetBridgeMoveDirection(aBridgeMoveDirection: TTcMoveDirection); begin FBridgeMoveDirection := aBridgeMoveDirection; end;
function TStarterPlotterInfo.GetBridgeSize(): Cardinal; begin Result := FBridgeSize; end;
procedure TStarterPlotterInfo.SetBridgeSize(aBridgeSize: Cardinal); begin FBridgeSize := aBridgeSize; end;
function TStarterPlotterInfo.GetHeadSize(): Cardinal; begin Result := FHeadSize; end;
procedure TStarterPlotterInfo.SetHeadSize(aHeadSize: Cardinal); begin FHeadSize := aHeadSize; end;
function TStarterPlotterInfo.GetHeadKnifeSpace(): Cardinal; begin Result := FHeadKnifeSpace; end;
procedure TStarterPlotterInfo.SetHeadKnifeSpace(aHeadKnifeSpace: Cardinal); begin FHeadKnifeSpace := aHeadKnifeSpace; end;
function TStarterPlotterInfo.GetDefaultRotation(): Integer; begin Result := FDefaultRotation; end;
procedure TStarterPlotterInfo.SetDefaultRotation(aDefaultRotation: Integer); begin FDefaultRotation := aDefaultRotation; end;
function TStarterPlotterInfo.GetDefaultMirror(): TMirrors; begin Result := FDefaultMirror; end;
procedure TStarterPlotterInfo.SetDefaultMirror(aDefaultMirror: TMirrors); begin FDefaultMirror := aDefaultMirror; end;

procedure TStarterPlotterInfo.Assign(const aOther: ITcPlotterInfo);
begin
  FPlotterType := aOther.PlotterType;
  FMaterialKinds := aOther.MaterialKinds;
  FAxisX := aOther.AxisX;
  FAxisY := aOther.AxisY;
  FSizeX := aOther.SizeX;
  FSizeY := aOther.SizeY;
  FCanCrossCuts := aOther.CanCrossCuts;
  FFullCutsOnly := aOther.FullCutsOnly;
  FCanCutAnyShapes := aOther.CanCutAnyShapes;
  FStripCuts := aOther.StripCuts;
  FMaxStripeWidth := aOther.MaxStripeWidth;
  FCutsDepthOn := aOther.CutsDepthOn;
  FCutsDepth := aOther.CutsDepth;
  FCutsDepthIncMargins := aOther.CutsDepthIncMargins;
  FTwoDimensionMoves := aOther.TwoDimensionMoves;
  FPrefferedDirection := aOther.PrefferedDirection;
  FMarginWest := aOther.MarginWest;
  FMarginNorth := aOther.MarginNorth;
  FMarginEast := aOther.MarginEast;
  FMarginSouth := aOther.MarginSouth;
  FBridgeMoveDirection := aOther.BridgeMoveDirection;
  FBridgeSize := aOther.BridgeSize;
  FHeadSize := aOther.HeadSize;
  FHeadKnifeSpace := aOther.HeadKnifeSpace;
  FDefaultRotation := aOther.DefaultRotation;
  FDefaultMirror := aOther.DefaultMirror;
end;

function EffectiveMaterialWidth(AKind: TMaterialKind; AWidth: Cardinal): Cardinal;
begin
  // Width is significant only for 1D materials; 2D materials use 0.
  if AKind = mk1D then
    Result := AWidth
  else
    Result := 0;
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

// 0.01 mm internal units as a millimeter decimal with two places.
function MillimetersText(const AValue: Cardinal): string;
begin
  Result :=
    IntToStr(Int64(AValue div cLengthMultiplier)) + '.' +
    System.SysUtils.Format('%.2d', [Integer(AValue mod cLengthMultiplier)]);
end;

// TRotation (0.1 degree) as degrees with one decimal place.
function DegreesText(const ARotation: TRotation): string;
begin
  Result := IntToStr(ARotation div 10) + '.' + IntToStr(ARotation mod 10);
end;

// SolutionCuts coordinates (0.01 mm) to HPGL plotter units.
function HpglUnits(const AValue: Integer): Integer;
begin
  Result := Round(AValue * cHpglUnitsPerMillimeter / cLengthMultiplier);
end;

function TCsvImportExportPlugin.FindOrCreateProject(
  const AProjects: IProjects;
  const ATitle: string
): IProject;
begin
  // LoadFile receives empty staging collections, so FindByTitle sees only
  // the projects this import already added.
  Result := AProjects.FindByTitle(ATitle);
  if Result <> nil then
    Exit;

  // Plain constructor: no dialog, not inserted until Add. Never use
  // ITonCut.CreateProject here: it opens a dialog and commits immediately.
  Result := AProjects.CreateProject();
  Result.Title := ATitle;
  AProjects.Add(Result);
end;

function TCsvImportExportPlugin.FindDeviceForKind(AKind: TMaterialKind): IDevice;
var
  devices: IDevices;
  device: IDevice;
  i: Integer;
begin
  // A staged material needs a device from the live ITonCut.Devices; devices
  // added to the LoadFile staging collection are ignored by the host.
  Result := nil;
  devices := FTonCut.Devices;
  if devices = nil then
    Exit;

  for i := 0 to devices.Count - 1 do
    begin
      device := devices[i];
      if device = nil then
        Continue;
      if device.MaterialKind = AKind then
        Exit(device);
      if Result = nil then
        Result := device;
    end;
end;

function TCsvImportExportPlugin.FindOrCreateMaterial(
  const AMaterials: IMaterials;
  const ATitle: string;
  AKind: TMaterialKind;
  AWidth: Cardinal;
  AThickness: Cardinal
): IMaterial;
var
  device: IDevice;
  effectiveWidth: Cardinal;
  title: string;
begin
  title := Trim(ATitle);
  if title = '' then
    title := 'CSV Material';
  effectiveWidth := EffectiveMaterialWidth(AKind, AWidth);

  // Exact, case-sensitive match on title, kind, width and thickness within
  // the staging collection of this LoadFile call.
  Result := AMaterials.FindByTitle(title, AKind, effectiveWidth, AThickness);
  if Result <> nil then
    Exit;

  device := FindDeviceForKind(AKind);
  if device = nil then
    Exit(nil);

  // Plain constructor: no dialog, not inserted until Add. Never use
  // ITonCut.CreateMaterial here: it opens a dialog and commits immediately.
  Result := AMaterials.CreateMaterial();
  Result.Title := title;
  Result.Kind := AKind;
  Result.Width := effectiveWidth;
  Result.Thickness := AThickness;
  Result.Device := device;
  AMaterials.Add(Result);
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
  // The host activates the plugin only when this equals its own value.
  Result := cEngineVersion;
end;

function TCsvImportExportPlugin.GetName(): WideString;
begin
  // Unique and ASCII: the host narrows it to an ANSI ShortString.
  Result := 'CsvImportExportTemplateDelphi';
end;

function TCsvImportExportPlugin.GetVersion(): TTcpVersion;
begin
  Result := MakeTcpVersion(1, 1, 0, 0);
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
  // Advertise only what is implemented. feSaveResultToFile makes
  // GetPlotterInfo mandatory. Configure is not implemented: no feConfigure.
  Result := [feImport, feExport, feSaveResultToFile, feAbout];
end;

function TCsvImportExportPlugin.GetPlotterInfo: ITcPlotterInfo;
begin
  // Never nil while a save or plot feature is advertised, and never let an
  // exception escape (the host would disable the plugin either way).
  try
    Result := TStarterPlotterInfo.Create();
  except
    Result := nil;
  end;
end;

function TCsvImportExportPlugin.Initialize(
  const aRegRoot: WideString;
  aLanguageId: Integer;
  aTonCut: ITonCut
): TTcpResult;
begin
  // The host never calls Initialize; TcpInitializeV2 does.
  try
    FRegRoot := aRegRoot;
    FLanguageId := aLanguageId;
    FTonCut := aTonCut;
    Result := cprOK;
  except
    Result := cprException;
  end;
end;

function TCsvImportExportPlugin.Finalize(): TTcpResult;
begin
  // Called once before unload. Release every host object kept so far.
  FTonCut := nil;
  Result := cprOK;
end;

function TCsvImportExportPlugin.Configure(aWindow: THandle): TTcpResult;
begin
  // Not advertised through feConfigure, so the host never calls it.
  Result := cprNotImplemented;
end;

function TCsvImportExportPlugin.About(aWindow: THandle): TTcpResult;
begin
  try
    if aWindow <> 0 then
      MessageBoxW(
        aWindow,
        PWideChar(WideString('CSV import/export plus single-sheet result export (HPGL cutting paths or CSV sheet layout).')),
        PWideChar(GetTitle()),
        MB_OK or MB_ICONINFORMATION
      );
    Result := cprOK;
  except
    Result := cprException;
  end;
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
  try
    aBackup := '';
    Result := cprOK;
  except
    Result := cprException;
  end;
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
  try
    if aEnumCb = nil then
      Exit(cprFailed);

    // Each Invoke adds one file-dialog filter "Name (*ext)|*ext". The
    // extension must include the leading dot.
    case aType of
      etImport,
      etExport:
        aEnumCb.Invoke(aType, '.csv', GetTitle());
      etExportResults:
        begin
          aEnumCb.Invoke(aType, '.plt', GetTitle() + ' - cutting paths (HPGL)');
          aEnumCb.Invoke(aType, '.csv', GetTitle() + ' - sheet layout');
        end;
    end;
    Result := cprOK;
  except
    Result := cprException;
  end;
end;

function TCsvImportExportPlugin.IsMyFile(const aFileName: WideString): TTcpResult;
begin
  try
    Result := ValidateHeader(aFileName);
  except
    Result := cprException;
  end;
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
  projectTitle: string;
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
  usingProjects: Boolean;
  headerResult: TTcpResult;
begin
  // aMaterials, aProjects, aFormats and aSheets are new, empty staging
  // collections. After cprOK TonCut shows its Import dialog and merges them;
  // on any other result everything staged here is discarded.
  try
    if FTonCut = nil then
      Exit(cprNotInitialized);

    if (aProjects = nil) or (aMaterials = nil) or (aFormats = nil) or (aSheets = nil) then
      Exit(cprFailed);

    headerResult := ValidateHeader(aFileName);
    if headerResult <> cprOK then
      Exit(cprFailed);

    text := TFile.ReadAllText(aFileName, TEncoding.UTF8);
    table := ParseCsvText(text);
    if (Length(table) = 0) or not HasRequiredHeader(table[0]) then
      Exit(cprFailed);

    // Without projects mode the host assigns every piece to its single flat
    // project, so the CSV ProjectTitle is used only when projects are on.
    usingProjects := FTonCut.UsingProjects;

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

              // CSV sizes are millimeters; TonCut lengths are 0.01 mm.
              if not TryFromCsvMillimeters(materialWidth, materialWidth) then
                Exit(cprFailed);
              if not TryFromCsvMillimeters(materialThickness, materialThickness) then
                Exit(cprFailed);
              if not TryFromCsvMillimeters(itemLength, itemLength) then
                Exit(cprFailed);
              if not TryFromCsvMillimeters(itemWidth, itemWidth) then
                Exit(cprFailed);

              material := FindOrCreateMaterial(
                aMaterials,
                CellByName(table[0], row, 'MaterialTitle'),
                materialKind,
                materialWidth,
                materialThickness
              );
              if material = nil then
                Exit(cprFailed);

              if recordType = 'FORMAT' then
                begin
                  // With projects on and no project, the host creates one
                  // named after the imported file.
                  project := nil;
                  projectTitle := Trim(CellByName(table[0], row, 'ProjectTitle'));
                  if usingProjects and (projectTitle <> '') then
                    begin
                      project := FindOrCreateProject(aProjects, projectTitle);
                      if project = nil then
                        Exit(cprFailed);
                    end;

                  format := aFormats.CreateFormat();
                  if format = nil then
                    Exit(cprFailed);

                  if project <> nil then
                    format.Project := project;
                  format.Material := material;
                  format.Length := itemLength;
                  // A 1D piece always has the width of its bar material.
                  if materialKind = mk1D then
                    format.Width := materialWidth
                  else
                    format.Width := itemWidth;
                  format.Quantity := quantity;
                  format.Identifier := CellByName(table[0], row, 'Identifier');
                  format.Description := CellByName(table[0], row, 'Description');
                  aFormats.Add(format);
                end
              else
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
                end;
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

    Result := cprOK;
  except
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
  piece: IFormat;
  sheet: ISheet;
  projectTitle: string;
begin
  // aFormats and aSheets are the live collections: read only.
  try
    if (aFormats = nil) or (aSheets = nil) then
      Exit(cprFailed);

    lines := TStringList.Create;
    try
      lines.LineBreak := #13#10;
      lines.Add(CsvHeaderLine());

      for i := 0 to aFormats.Count - 1 do
        begin
          piece := aFormats[i];
          if (piece = nil) or (piece.Material = nil) then
            Continue;
          if piece.Project <> nil then
            projectTitle := piece.Project.Title
          else
            projectTitle := '';

          lines.Add(BuildCsvLine([
            'FORMAT',
            projectTitle,
            piece.Material.Title,
            MaterialKindToText(piece.Material.Kind),
            IntToStr(ToCsvMillimeters(
              EffectiveMaterialWidth(piece.Material.Kind, piece.Material.Width)
            )),
            IntToStr(ToCsvMillimeters(piece.Material.Thickness)),
            IntToStr(ToCsvMillimeters(piece.Length)),
            IntToStr(ToCsvMillimeters(piece.Width)),
            IntToStr(piece.Quantity),
            piece.Identifier,
            piece.Description
          ]));
        end;

      for i := 0 to aSheets.Count - 1 do
        begin
          sheet := aSheets[i];
          if (sheet = nil) or (sheet.Material = nil) then
            Continue;

          lines.Add(BuildCsvLine([
            'SHEET',
            '',
            sheet.Material.Title,
            MaterialKindToText(sheet.Material.Kind),
            IntToStr(ToCsvMillimeters(
              EffectiveMaterialWidth(sheet.Material.Kind, sheet.Material.Width)
            )),
            IntToStr(ToCsvMillimeters(sheet.Material.Thickness)),
            IntToStr(ToCsvMillimeters(sheet.Length)),
            IntToStr(ToCsvMillimeters(sheet.Width)),
            // ISheet.Quantity is a signed Integer: written unchanged. On import a
            // missing, invalid (negative included) or zero Quantity becomes 1.
            IntToStr(sheet.Quantity),
            sheet.Identifier,
            sheet.Description
          ]));
        end;

      TFile.WriteAllText(aFileName, lines.Text, TEncoding.UTF8);
      Result := cprOK;
    finally
      lines.Free;
    end;
  except
    Result := cprException;
  end;
end;

function TCsvImportExportPlugin.SaveResult(
  aWindow: THandle;
  const aFileName: WideString;
  const aSolutionSheet: ISolutionSheet
): TTcpResult;
var
  commands: TStringList;
begin
  // The host appends the chosen filter's extension when the user typed none.
  try
    commands := TStringList.Create;
    try
      commands.LineBreak := #13#10;
      if aSolutionSheet = nil then
        Result := cprFailed
      else if SameText(ExtractFileExt(aFileName), '.csv') then
        begin
          if ExportSolutionSheetLayout(aSolutionSheet, commands) then
            begin
              commands.SaveToFile(aFileName, TEncoding.UTF8);
              // "Save one" and the next-unsaved selection read this flag.
              aSolutionSheet.IsSaved := True;
              Result := cprOK;
            end
          else
            Result := cprFailed;
        end
      else if ExportSolutionSheetAsPlt(aSolutionSheet, commands) then
        begin
          commands.SaveToFile(aFileName, TEncoding.ASCII);
          aSolutionSheet.IsSaved := True;
          Result := cprOK;
        end
      else
        Result := cprFailed;
    finally
      commands.Free;
    end;
  except
    Result := cprException;
  end;
end;

// The callbacks below are not advertised in GetFeatures, so the host never
// calls them.
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
  cuts: ISolutionCuts;
  cut: ISolutionCut;
  i: Integer;
begin
  // SolutionCuts are already in the effective output frame (sheet and plotter
  // rotation and mirror applied by the host). Do not pass them through
  // CalcPoint/CalcPointF; only scale 0.01 mm to HPGL units.
  Result := False;
  if (ASolutionSheet = nil) or (ACommands = nil) then
    Exit;

  cuts := ASolutionSheet.SolutionCuts;
  if cuts = nil then
    Exit;

  ACommands.Clear;
  ACommands.Add('IN;');
  ACommands.Add('PA;');

  for i := 0 to cuts.Count - 1 do
    begin
      cut := cuts[i];
      if cut = nil then
        Exit;

      ACommands.Add(System.SysUtils.Format('PU%d,%d;', [HpglUnits(cut.PosX), HpglUnits(cut.PosY)]));
      if cut.Kind = ckCurve then
        // Cubic Bezier: start, two control points, end.
        ACommands.Add(System.SysUtils.Format(
          'BZ%d,%d,%d,%d,%d,%d;',
          [
            HpglUnits(cut.PosXp), HpglUnits(cut.PosYp),
            HpglUnits(cut.TarXp), HpglUnits(cut.TarYp),
            HpglUnits(cut.TarX), HpglUnits(cut.TarY)
          ]
        ))
      else
        ACommands.Add(System.SysUtils.Format('PD%d,%d;', [HpglUnits(cut.TarX), HpglUnits(cut.TarY)]));
    end;

  ACommands.Add('PU;');
  ACommands.Add('SP0;');
  Result := True;
end;

function TCsvImportExportPlugin.ExportSolutionSheetLayout(
  const ASolutionSheet: ISolutionSheet;
  ALines: TStrings
): Boolean;
var
  sheet: ISheet;
  parts: ISolutionFormats;
  part: ISolutionFormat;
  piece: IFormat;
  wastes: ISolutionWastes;
  waste: ISolutionWaste;
  sheetIndex: string;
  sheetQuantity: string;
  materialTitle: string;
  mirrored: string;
  i: Integer;
begin
  // One layout (one ISolutionSheet) is cut SheetQuantity times: the part and
  // waste rows describe one sheet, so totals are rows x SheetQuantity.
  // X/Y are in the native sheet frame (origin at sheet corner (0,0), X along
  // the sheet length, Y along its width, before output rotation or mirror);
  // map them with CalcPoint only if a consumer needs the output frame.
  Result := False;
  if (ASolutionSheet = nil) or (ALines = nil) then
    Exit;

  sheet := ASolutionSheet.Sheet;
  parts := ASolutionSheet.SolutionFormats;
  wastes := ASolutionSheet.SolutionWastes;
  if (sheet = nil) or (parts = nil) or (wastes = nil) then
    Exit;

  sheetIndex := IntToStr(ASolutionSheet.Index);
  sheetQuantity := IntToStr(ASolutionSheet.Quantity);
  if sheet.Material <> nil then
    materialTitle := sheet.Material.Title
  else
    materialTitle := '';

  ALines.Clear;
  ALines.Add(BuildCsvLine([
    'RecordType', 'SheetIndex', 'SheetQuantity', 'MaterialTitle',
    'X', 'Y', 'Length', 'Width', 'Rotation', 'Mirrored',
    'Identifier', 'Description'
  ]));
  ALines.Add(BuildCsvLine([
    'SHEET', sheetIndex, sheetQuantity, materialTitle,
    MillimetersText(0), MillimetersText(0),
    MillimetersText(sheet.Length), MillimetersText(sheet.Width), '', '',
    sheet.Identifier, sheet.Description
  ]));

  for i := 0 to parts.Count - 1 do
    begin
      part := parts[i];
      if part = nil then
        Exit;
      piece := part.Format;
      if piece = nil then
        Exit;
      if part.Mirrored then
        mirrored := '1'
      else
        mirrored := '0';
      // X/Y: lower corner of the placed footprint's bounding box.
      // Length/Width: the piece as entered, before rotation.
      ALines.Add(BuildCsvLine([
        'PART', sheetIndex, sheetQuantity, materialTitle,
        MillimetersText(part.X), MillimetersText(part.Y),
        MillimetersText(piece.Length), MillimetersText(piece.Width),
        DegreesText(part.Rotation), mirrored,
        piece.Identifier, piece.Description
      ]));
    end;

  // All waste pieces, reusable or not, as rectangles along X/Y.
  for i := 0 to wastes.Count - 1 do
    begin
      waste := wastes[i];
      if waste = nil then
        Exit;
      ALines.Add(BuildCsvLine([
        'WASTE', sheetIndex, sheetQuantity, materialTitle,
        MillimetersText(waste.X), MillimetersText(waste.Y),
        MillimetersText(waste.Length), MillimetersText(waste.Width), '', '',
        waste.Identifier, ''
      ]));
    end;

  Result := True;
end;

end.
