unit uContractProbePlugin;

interface

uses
  Winapi.Windows,
  uICommon,
  uITonCut,
  uITcPlugin,
  uITcPluginCommon,
  uITcPlotterInfo,
  uITcEnumExtensionsCallback,
  uIDevices,
  uIMaterials,
  uIBands,
  uIProjects,
  uIFormats,
  uISheets,
  uISolution,
  uISolutionSheet,
  uContractProbeTouch;

type
  TContractProbePlugin = class(TInterfacedObject, ITcPlugin)
  private
    FRegRoot: WideString;
    FLanguageId: Integer;
    FUiScale: Single;
    FTonCut: ITonCut;
  public
    function GetEngineVersion(): Integer; safecall;
    function GetName(): WideString; safecall;
    function GetVersion(): TTcpVersion; safecall;
    function GetTitle(): WideString; safecall;
    function GetProfessional(): Boolean; safecall;
    function GetRegRoot(): WideString; safecall;
    function GetLanguageId(): Integer; safecall;
    procedure SetLanguageId(aValue: Integer); safecall;
    function GetUiScale(): Single; safecall;
    procedure SetUiScale(aValue: Single); safecall;
    function GetTonCut(): ITonCut; safecall;
    function GetFeatures(): TTcpFeatures; safecall;
    function GetPlotterInfo(): ITcPlotterInfo; safecall;
    function Initialize(const aRegRoot: WideString; aLanguageId: Integer; aTonCut: ITonCut): TTcpResult; safecall;
    function Finalize(): TTcpResult; safecall;
    function Configure(aWindow: THandle): TTcpResult; safecall;
    function About(aWindow: THandle): TTcpResult; safecall;
    function LoadConfig(const aKey: WideString; const aVersion: WideString): TTcpResult; safecall;
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

function TContractProbePlugin.GetEngineVersion(): Integer; begin Result := cEngineVersion; end;
function TContractProbePlugin.GetName(): WideString; begin Result := 'ContractProbe'; end;
function TContractProbePlugin.GetVersion(): TTcpVersion; begin Result := TTcpVersion(1) shl 48; end;
function TContractProbePlugin.GetTitle(): WideString; begin Result := 'Contract Probe'; end;
function TContractProbePlugin.GetProfessional(): Boolean; begin Result := False; end;
function TContractProbePlugin.GetRegRoot(): WideString; begin Result := FRegRoot; end;
function TContractProbePlugin.GetLanguageId(): Integer; begin Result := FLanguageId; end;
procedure TContractProbePlugin.SetLanguageId(aValue: Integer); begin FLanguageId := aValue; end;
function TContractProbePlugin.GetUiScale(): Single; begin Result := FUiScale; end;
procedure TContractProbePlugin.SetUiScale(aValue: Single); begin FUiScale := aValue; end;
function TContractProbePlugin.GetTonCut(): ITonCut; begin Result := FTonCut; end;
function TContractProbePlugin.GetFeatures(): TTcpFeatures; begin Result := [feImport, feExport, feSaveResultToFile]; end;
function TContractProbePlugin.GetPlotterInfo(): ITcPlotterInfo; begin Result := nil; end;
function TContractProbePlugin.Initialize(const aRegRoot: WideString; aLanguageId: Integer; aTonCut: ITonCut): TTcpResult; begin FRegRoot := aRegRoot; FLanguageId := aLanguageId; FTonCut := aTonCut; Result := cprOK; end;
function TContractProbePlugin.Finalize(): TTcpResult; begin FTonCut := nil; Result := cprOK; end;
function TContractProbePlugin.Configure(aWindow: THandle): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.About(aWindow: THandle): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.LoadConfig(const aKey: WideString; const aVersion: WideString): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.SaveConfig(const aKey: WideString): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.BackupConfig(var aBackup: WideString): TTcpResult; begin aBackup := 'contract-probe-backup'; Result := cprOK; end;
function TContractProbePlugin.RestoreConfig(const aBackup: WideString; aScope: TConfigurationParts): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.EnumExtensions(aType: TTcpExtensionType; aEnumCb: ITcEnumExtensionsCallback): TTcpResult; begin if Assigned(aEnumCb) then aEnumCb.Invoke(aType, '.probe', 'Contract Probe'); Result := cprOK; end;
function TContractProbePlugin.IsMyFile(const aFileName: WideString): TTcpResult; begin Result := cprMaybe; end;
function TContractProbePlugin.LoadFile(aWindow: THandle; const aFileName: WideString; aDevices: IDevices; aMaterials: IMaterials; aBands: IBands; aProjects: IProjects; aFormats: IFormats; aSheets: ISheets): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.SaveFile(aWindow: THandle; const aFileName: WideString; const aFormats: IFormats; const aSheets: ISheets): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.SaveResult(aWindow: THandle; const aFileName: WideString; const aSolutionSheet: ISolutionSheet): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.BatchSaveResult(aWindow: THandle; aSaveTarget: TTcpSaveTarget; const aPath: WideString; const aSolution: ISolution): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.Plot(aWindow: THandle; const aSolutionSheet: ISolutionSheet): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.BatchPlot(aWindow: THandle; const aSolution: ISolution): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.SavePlot(aWindow: THandle; const aFileName: WideString; const aSolutionSheet: ISolutionSheet): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.BatchSavePlot(aWindow: THandle; aSaveTarget: TTcpSaveTarget; const aPath: WideString; const aSolution: ISolution): TTcpResult; begin Result := cprOK; end;

end.
