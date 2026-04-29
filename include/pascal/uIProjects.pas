unit uIProjects;

interface

uses
  uIProject,
  uIProjectChangeEvent,
  uINotifyEvent;

type
  IProjects = interface
    ['{6A337290-EA4F-408E-9F67-D1ECFEFDEA4B}']

    function CreateProject(): IProject; safecall;
    procedure Add(aProject: IProject); safecall;
    procedure DeleteByIndex(aIndex: Cardinal); safecall;
    procedure DeleteById(aId: Int64); safecall;
    procedure Remove(const aProject: IProject); safecall;
    function IndexOf(const aProject: IProject): Integer; overload; safecall;
    function IndexOf(aId: Int64): Integer; overload; safecall;
    function FindDuplicate(const aProject: IProject; aCheckTitle: Boolean = False): IProject; safecall;
    function FindByTitle(const aTitle: WideString): IProject; safecall;

    function FindUniqueName(const aBaseName: WideString): WideString; safecall;
    function CheckUniqueName(const aTitle: WideString; const aIgnoreProject: IProject): Boolean; overload; safecall;
    function CheckUniqueName(aProject: IProject; aAutoFix: Boolean = False): Boolean; overload; safecall;

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): IProject; safecall;
    function GetById(aId: Int64): IProject; safecall;

    function GetOnAdd(): IProjectChangeEvent; safecall;
    function GetOnRemove(): IProjectChangeEvent; safecall;
    function GetOnChange(): INotifyEvent; safecall;

    procedure Load(aStartDate: TDateTime; aIncludeCanceled, aIncludeDeleted: Boolean); safecall;
    procedure Reload(); safecall;

    procedure BeginUpdate(); safecall;
    procedure EndUpdate(); safecall;
    function IsUpdating(): Boolean; safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: IProject read GetByIndex; default;

    property OnAdd: IProjectChangeEvent read GetOnAdd;
    property OnRemove: IProjectChangeEvent read GetOnRemove;
    property OnChange: INotifyEvent read GetOnChange;
  end;

implementation

end.
