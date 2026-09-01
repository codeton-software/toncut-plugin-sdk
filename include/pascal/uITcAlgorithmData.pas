unit uITcAlgorithmData;

interface

uses
  uICommon,
  uINotifyEvent;

type
  // Typed, unit-aware access to an entity's opaque algorithm-data JSON.
  ITcAlgorithmData = interface
    ['{430B7FA5-19C9-46B4-BB80-35EF8EF2BBC7}']

    function GetData(): WideString; safecall;
    procedure SetData(const aData: WideString); safecall;
    function GetUnits(): TDefaultUnits; safecall;
    procedure SetUnits(const aUnits: TDefaultUnits); safecall;

    // Reads a coherent data-and-units pair.
    procedure GetState(out aData: WideString;
      out aUnits: TDefaultUnits); safecall;

    // Updates data and units atomically and emits at most one change event.
    // Empty data always uses the default units.
    procedure SetState(const aData: WideString;
      const aUnits: TDefaultUnits); safecall;

    // Dotted paths address nested object members. Missing values return aDefault.
    function GetLength(const aPath: WideString;
      aDefault: Integer = 0): Integer; safecall;
    function GetTime(const aPath: WideString;
      aDefault: Double = 0): Double; safecall;
    function GetPercent(const aPath: WideString;
      aDefault: Integer = 0): Integer; safecall;
    function GetAngle(const aPath: WideString;
      aDefault: Double = 0): Double; safecall;
    function GetPrice(const aPath: WideString;
      aDefault: TTcPrice = 0): TTcPrice; safecall;
    function GetWeight(const aPath: WideString;
      aDefault: TTcWeight = 0): TTcWeight; safecall;
    function GetValue(const aPath: WideString;
      aDefault: Double = 0): Double; overload; safecall;
    function GetValue(const aPath: WideString;
      const aDefault: WideString): WideString; overload; safecall;
    function GetValue(const aPath: WideString;
      aDefault: Boolean): Boolean; overload; safecall;

    // Equality includes both JSON text and its units.
    function SameAs(const aOther: ITcAlgorithmData): Boolean; safecall;

    // Serialization keeps the opaque JSON and its units together. Deserialize
    // replaces the complete state; an empty value resets it.
    function Serialize(): WideString; safecall;
    procedure Deserialize(const aBlob: WideString); safecall;

    function GetOnChange(): INotifyEvent; safecall;

    // Integer access has a distinct name to preserve established overload binding.
    function GetInteger(const aPath: WideString;
      aDefault: Integer = 0): Integer; safecall;

    // Indexed traversal uses RFC 6901 JSON Pointer syntax. An empty pointer
    // selects the document root; '~1' and '~0' escape '/' and '~'.
    function GetCount(const aJsonPointer: WideString): Integer; safecall;
    function GetLengthByPointer(const aJsonPointer: WideString;
      aDefault: Integer = 0): Integer; safecall;
    function GetTimeByPointer(const aJsonPointer: WideString;
      aDefault: Double = 0): Double; safecall;
    function GetPercentByPointer(const aJsonPointer: WideString;
      aDefault: Integer = 0): Integer; safecall;
    function GetAngleByPointer(const aJsonPointer: WideString;
      aDefault: Double = 0): Double; safecall;
    function GetPriceByPointer(const aJsonPointer: WideString;
      aDefault: TTcPrice = 0): TTcPrice; safecall;
    function GetWeightByPointer(const aJsonPointer: WideString;
      aDefault: TTcWeight = 0): TTcWeight; safecall;
    function GetIntegerByPointer(const aJsonPointer: WideString;
      aDefault: Integer = 0): Integer; safecall;
    function GetValueByPointer(const aJsonPointer: WideString;
      aDefault: Double = 0): Double; overload; safecall;
    function GetValueByPointer(const aJsonPointer: WideString;
      const aDefault: WideString): WideString; overload; safecall;
    function GetValueByPointer(const aJsonPointer: WideString;
      aDefault: Boolean): Boolean; overload; safecall;

    property Data: WideString read GetData write SetData;
    property Units: TDefaultUnits read GetUnits write SetUnits;

    property OnChange: INotifyEvent read GetOnChange;
  end;

implementation

end.
