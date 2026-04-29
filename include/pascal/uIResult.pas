unit uIResult;

interface

uses
  System.Classes,
  uIIdChangeEvent,
  uINotifyEvent;

type
  IResult = interface
    ['{17353E5E-1398-498A-B88F-D8DAB11F3DDC}']

    function GetId(): Int64; safecall;
    procedure SetId(aId: Int64); safecall;

    function GetTitle(): WideString; safecall;
    procedure SetTitle(const aTitle: WideString); safecall;

    function GetDate(): TDateTime; safecall;
    procedure SetDate(aDate: TDateTime); safecall;

    function GetWasUsedElementsMarked(): Boolean; safecall;
    procedure SetWasUsedElementsMarked(aMarked: Boolean); safecall;

    function GetWasStockUpdated(): Boolean; safecall;
    procedure SetWasStockUpdated(aUpdated: Boolean); safecall;

    function GetWasReusableWasteAddedToStocks(): Boolean; safecall;
    procedure SetWasReusableWasteAddedToStocks(aAdded: Boolean); safecall;

    function GetCancelled(): Boolean; safecall;
    procedure SetCancelled(aCancelled: Boolean); safecall;

    // 2D & 1D.
    function GetSheetCount(): Cardinal; safecall;
    procedure SetSheetCount(aCount: Cardinal); safecall;

    function GetPieceCount(): Cardinal; safecall;
    procedure SetPieceCount(aCount: Cardinal); safecall;

    // 2D.
    function GetSheetField2d(): Int64; safecall;
    procedure SetSheetField2d(aField: Int64); safecall;

    function GetPieceField2d(): Int64; safecall;
    procedure SetPieceField2d(aField: Int64); safecall;

    function GetWasteField2d(): Int64; safecall;
    procedure SetWasteField2d(aField: Int64); safecall;

    function GetRecycledField2d(): Int64; safecall;
    procedure SetRecycledField2d(aField: Int64); safecall;

    function GetCutCount2d(): Integer; safecall;
    procedure SetCutCount2d(aCount: Integer); safecall;

    function GetCutLength2d(): Double; safecall;
    procedure SetCutLength2d(aLength: Double); safecall;

    // 1D.
    function GetSheetLength1d(): Int64; safecall;
    procedure SetSheetLength1d(aLength: Int64); safecall;

    function GetPieceLength1d(): Int64; safecall;
    procedure SetPieceLength1d(aLength: Int64); safecall;

    function GetWasteLength1d(): Int64; safecall;
    procedure SetWasteLength1d(aLength: Int64); safecall;

    function GetRecycledLength1d(): Int64; safecall;
    procedure SetRecycledLength1d(aLength: Int64); safecall;

    function GetCutCount1d(): Integer; safecall;
    procedure SetCutCount1d(aCount: Integer); safecall;

    // Events.
    function GetOnChange(): INotifyEvent; safecall;
    function GetOnIdChange(): IIdChangeEvent; safecall;

    property Id: Int64 read GetId write SetId;

    property Title: WideString read GetTitle write SetTitle;
    property Date: TDateTime read GetDate write SetDate;

    property WasUsedElementsMarked: Boolean read GetWasUsedElementsMarked write SetWasUsedElementsMarked;
    property WasStockUpdated: Boolean read GetWasStockUpdated write SetWasStockUpdated;
    property WasReusableWasteAddedToStocks: Boolean read GetWasReusableWasteAddedToStocks write SetWasReusableWasteAddedToStocks;
    property Cancelled: Boolean read GetCancelled write SetCancelled;

    // 2D & 1D.
    property SheetCount: Cardinal read GetSheetCount write SetSheetCount;
    property PieceCount: Cardinal read GetPieceCount write SetPieceCount;

    // 2D.
    property SheetField2d: Int64 read GetSheetField2d write SetSheetField2d;
    property PieceField2d: Int64 read GetPieceField2d write SetPieceField2d;
    property WasteField2d: Int64 read GetWasteField2d write SetWasteField2d;
    property RecycledField2d: Int64 read GetRecycledField2d write SetRecycledField2d;

    property CutCount2d: Integer read GetCutCount2d write SetCutCount2d;
    property CutLength2d: Double read GetCutLength2d write SetCutLength2d;

    // 1D.
    property SheetLength1d: Int64 read GetSheetLength1d write SetSheetLength1d;
    property PieceLength1d: Int64 read GetPieceLength1d write SetPieceLength1d;
    property WasteLength1d: Int64 read GetWasteLength1d write SetWasteLength1d;
    property RecycledLength1d: Int64 read GetRecycledLength1d write SetRecycledLength1d;

    property CutCount1d: Integer read GetCutCount1d write SetCutCount1d;

    // Events.
    property OnChange: INotifyEvent read GetOnChange;
    property OnIdChange: IIdChangeEvent read GetOnIdChange;
  end;

implementation

end.
