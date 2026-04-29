unit uITcEnumExtensionsCallback;

interface

uses
  uITcPluginCommon;

type
  ITcEnumExtensionsCallback = interface(IUnknown)
    ['{B17490F3-F2DA-4179-8D56-39B921D9C73A}']
    procedure Invoke(aType: TTcpExtensionType; const aExtension: WideString; const aName: WideString); safecall;
  end;

implementation

end.
