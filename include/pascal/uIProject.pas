unit uIProject;

interface

uses
  uICommon,
  uINotifyEvent,
  uIIdChangeEvent;

type
  IProject = interface
    ['{D62A183C-3C58-419E-A266-913A1D17DDAD}']

    function GetId(): Int64; safecall;
    procedure SetId(aId: Int64); safecall;

    function GetTitle(): WideString; safecall;
    procedure SetTitle(const aTitle: WideString); safecall;

    function GetDescription(): WideString; safecall;
    procedure SetDescription(const aDescription: WideString); safecall;

    function GetPriority(): TProjectPriority; safecall;
    procedure SetPriority(aPriority: TProjectPriority); safecall;

    function GetCreateDate(): TDateTime; safecall;
    procedure SetCreateDate(aCreateDate: TDateTime); safecall;

    function GetTargetDate(): TDateTime; safecall;
    procedure SetTargetDate(aTargetDate: TDateTime); safecall;

    function GetState(): TProjectState; safecall;
    procedure SetState(aState: TProjectState); safecall;

    function GetPieceCount(): Cardinal; safecall;
    procedure SetPieceCount(aCount: Cardinal); safecall;

    function GetPieceField2D(): TField; safecall;
    procedure SetPieceField2D(aField: TField); safecall;

    function GetPieceLength1D(): TField; safecall;
    procedure SetPieceLength1D(aLength: TField); safecall;

    function GetProcessedCount(): Integer; safecall;
    procedure SetProcessedCount(aCount: Integer); safecall;

    function GetProcessedField2D(): TField; safecall;
    procedure SetProcessedField2D(aField: TField); safecall;

    function GetProcessedLength1D(): TField; safecall;
    procedure SetProcessedLength1D(aLength: TField); safecall;

    function GetMaterialGroupCount(): Cardinal; safecall;
    procedure SetMaterialGroupCount(aCount: Cardinal); safecall;

    function GetLoading(): Boolean; safecall;
    procedure SetLoading(aLoading: Boolean); safecall;

    function GetLoaded(): Boolean; safecall;
    procedure SetLoaded(aLoaded: Boolean); safecall;

    function GetOnChange(): INotifyEvent; safecall;
    function GetOnIdChange(): IIdChangeEvent; safecall;

    function Clone(): IProject; safecall;
    procedure Assign(const aOther: IProject); safecall;

    procedure UpdateStats(const aAllFormats: IUnknown); safecall;

    procedure FormatAdded(aFormat: IUnknown); safecall;
    procedure FormatRemoved(aFormat: IUnknown); safecall;
    procedure FormatChanged(aFormat: IUnknown); safecall;
    procedure FormatIdChanged(aFormat: IUnknown; aNewId, aOldId: Int64); safecall;

    procedure GetFormats(aFormats: IUnknown; const aAllFormats: IUnknown; aKeepOrder: Boolean = False); safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;

    property Id: Int64 read GetId write SetId;
    property Title: WideString read GetTitle write SetTitle;
    property Description: WideString read GetDescription write SetDescription;
    property Priority: TProjectPriority read GetPriority write SetPriority;
    property CreateDate: TDateTime read GetCreateDate write SetCreateDate;
    property TargetDate: TDateTime read GetTargetDate write SetTargetDate;
    property State: TProjectState read GetState write SetState;

    property Loading: Boolean read GetLoading write SetLoading;
    property Loaded: Boolean read GetLoaded write SetLoaded;

    property PieceCount: Cardinal read GetPieceCount write SetPieceCount;
    property PieceField2D: TField read GetPieceField2D write SetPieceField2D;
    property PieceLength1D: TField read GetPieceLength1D write SetPieceLength1D;
    property ProcessedCount: Integer read GetProcessedCount write SetProcessedCount;
    property ProcessedField2D: TField read GetProcessedField2D write SetProcessedField2D;
    property ProcessedLength1D: TField read GetProcessedLength1D write SetProcessedLength1D;
    property MaterialGroupCount: Cardinal read GetMaterialGroupCount write SetMaterialGroupCount;

    property OnChange: INotifyEvent read GetOnChange;
    property OnIdChange: IIdChangeEvent read GetOnIdChange;
  end;

implementation

end.
