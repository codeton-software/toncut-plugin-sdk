unit uITcPlugin;

interface

uses
  uICommon,
  uITcPluginCommon,
  uITcPlotterInfo,
  uITcEnumExtensionsCallback,
  uITonCut,
  uIDevices,
  uIMaterials,
  uIBands,
  uIProjects,
  uIFormats,
  uISheets,
  uISolution,
  uISolutionSheet;

type
  ITcPlugin = interface
  // private
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

  // public
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

  // properties
    property EngineVersion: Integer read GetEngineVersion;

    property Name: WideString read GetName;
    property Version: TTcpVersion read  GetVersion;
    property Title: WideString read GetTitle;
    property RegRoot: WideString read GetRegRoot;
    property LanguageId: Integer read GetLanguageId write SetLanguageId;
    property Professional: Boolean read GetProfessional;
    property UiScale: Single read GetUiScale write SetUiScale;

    property TonCut: ITonCut read GetTonCut;

    property Features: TTcpFeatures read GetFeatures;
    property PlotterInfo: ITcPlotterInfo read GetPlotterInfo;
  end;

implementation

end.
