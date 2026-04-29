unit uITonCut;

interface

uses
  System.Classes,
  uICommon,
  uIDevice,
  uIDevices,
  uIMaterial,
  uIMaterials,
  uIBand,
  uIBandList,
  uIBands,
  uIResults,
  uIProject,
  uIProjects,
  uITemplates,
  uIFormats,
  uISheets,
  uISolution;

type
  ITonCut = interface
    ['{FF6C1A96-46C2-4E06-A779-43DAA36DFBE1}']

    function GetUnits(): TUnits; safecall;
    function GetPrecision(): Integer; safecall;

    function GetPieceIdentification(): TPieceIdentification; safecall;

    function GetDevices(): IDevices; safecall;
    function GetMaterials(): IMaterials; safecall;
    function GetBands(): IBands; safecall;
    function GetSheets(): ISheets; safecall;
    function GetTemplates(): ITemplates; safecall;
    function GetProjects(): IProjects; safecall;
    function GetFormats(): IFormats; safecall;
    function GetResults(): IResults; safecall;
    function GetSolution(): ISolution; safecall;

    function GetUsingProjects(): Boolean; safecall;
    function GetSelectedProject(): IProject; safecall;

    procedure CreateSolution(); safecall;
    procedure ReleaseSolution(); safecall;

    function CreateMaterial(const aTitle: WideString; aKind: TMaterialKind; aWidth, aThickness: Cardinal): IMaterial; safecall;
    function CreateBand(const aTitle: WideString; aWidth, aThickness, aMaterialThickness, aSurplus: Cardinal): IBand; safecall;
    function CreateProject(const aTitle: WideString): IProject; safecall;

    function CanCutAnyShapes(const aDevice: IDevice): Boolean; safecall;

    function FormatLength(aValue: Integer; aShort: Boolean = False): WideString; overload; safecall;
    function FormatLength(aValue: Double; aShort: Boolean = False): WideString; overload; safecall;
    function HumanReadableLength(aValue: Double; aShort: Boolean = False): WideString; safecall;

    function FormatField(aValue: TField; aShort: Boolean = False): WideString; safecall;
    function HumanReadableField(aValue: TField; aShort: Boolean = False): WideString; overload; safecall;
    function HumanReadableField(aValue: Double; aShort: Boolean = False): WideString; overload; safecall;

    function FormatDegrees(aAngle: Double; aShort: Boolean = False): WideString; safecall;
    function FormatRadians(aAngle: Double; aShort: Boolean = False): WideString; safecall;

    property Units: TUnits read GetUnits;
    property Precision: Integer read GetPrecision;

    property PieceIdentification: TPieceIdentification read GetPieceIdentification;

    property UsingProjects: Boolean read GetUsingProjects;
    property SelectedProject: IProject read GetSelectedProject;

    property Devices: IDevices read GetDevices;
    property Materials: IMaterials read GetMaterials;
    property Bands: IBands read GetBands;
    property Sheets: ISheets read GetSheets;
    property Templates: ITemplates read GetTemplates;
    property Projects: IProjects read GetProjects;
    property Formats: IFormats read GetFormats;
    property Results: IResults read GetResults;
    property Solution: ISolution read GetSolution;
  end;

implementation

end.
