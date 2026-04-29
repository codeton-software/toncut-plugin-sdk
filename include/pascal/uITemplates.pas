unit uITemplates;

interface

uses
  uICommon,
  uITemplate,
  uIFormat,
  uITemplateChangeEvent;

type
  ITemplates = interface
    ['{EDBF1B3E-F26E-49C9-807A-C2D5601849BF}']

    function CreateTemplate(): ITemplate; safecall;
    function CreateFormat(): IFormat; safecall;

    procedure Add(aTemplate: ITemplate); safecall;
    procedure DeleteByIndex(aIndex: Cardinal); safecall;
    procedure DeleteById(aId: Int64); safecall;
    procedure Remove(const aTemplate: ITemplate); safecall;
    function IndexOf(const aTemplate: ITemplate): Integer; overload; safecall;
    function IndexOf(aId: Int64): Integer; overload; safecall;

    function CheckUniqueName(const aTitle: WideString; const aIgnoreTemplate: ITemplate): Boolean; overload; safecall;
    function CheckUniqueName(aTemplate: ITemplate): Boolean; overload; safecall;

    function GetCount(): Integer; safecall;
    function GetByIndex(aIndex: Cardinal): ITemplate; safecall;
    function GetById(aId: Int64): ITemplate; safecall;

    function GetOnAdd(): ITemplateChangeEvent; safecall;
    function GetOnRemove(): ITemplateChangeEvent; safecall;

    procedure Reload(); safecall;

    property Count: Integer read GetCount;
    property Items[aIndex: Cardinal]: ITemplate read GetByIndex; default;

    property OnAdd: ITemplateChangeEvent read GetOnAdd;
    property OnRemove: ITemplateChangeEvent read GetOnRemove;
  end;

implementation

end.
