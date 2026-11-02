#include "../../shared/cpp/CsvImportExportPluginBase.hpp"

using toncut::BstrValue;
using toncut::CsvImportExportPluginBase;
using toncut::ITcPlugin;
using toncut::ITonCut;
using toncut::TTcpResult;
using toncut::cprFailed;
using toncut::cprOK;

namespace {

constexpr auto kPluginName = L"CsvImportExportTemplateCppBuilder";
constexpr auto kPluginTitle = L"CSV Import/Export + PLT Result Template (C++Builder)";

}  // namespace

// The only export TonCut resolves. The host declares it as
//   function TcpInitializeV2(const aRegRoot: PChar; aLanguageId: Integer;
//     aTonCut: ITonCut): ITcPlugin; stdcall;
// A Delphi interface result is a hidden out parameter passed FIRST, so the
// native signature starts with ITcPlugin** aResult. aRegRoot is a temporary
// UTF-16 HKEY_CURRENT_USER-relative key path: copy it. The host never calls
// ITcPlugin::Initialize, so this export does. *aResult receives the one
// reference the host releases at unload; leave it nullptr on failure.
// The exported name must be exactly TcpInitializeV2. This untested
// C++Builder project has no .def file: check the built .plg with tdump and add
// a module definition file if the name is decorated. Never let an exception
// escape this function.
extern "C" __declspec(dllexport) void __stdcall TcpInitializeV2(
  ITcPlugin** aResult,
  const wchar_t* aRegRoot,
  int aLanguageId,
  ITonCut* aTonCut
) {
  if (aResult == nullptr) {
    return;
  }
  *aResult = nullptr;

  CsvImportExportPluginBase* plugin = nullptr;
  try {
    plugin = new CsvImportExportPluginBase(kPluginName, kPluginTitle);
    BstrValue regRoot(aRegRoot == nullptr ? L"" : std::wstring(aRegRoot));
    if (!regRoot) {
      plugin->Release();
      return;
    }
    TTcpResult initResult = cprFailed;
    const HRESULT hr = plugin->Initialize(regRoot.get(), aLanguageId, aTonCut, &initResult);
    if (FAILED(hr) || initResult != cprOK) {
      plugin->Release();
      return;
    }
    *aResult = plugin;
  } catch (...) {
    if (plugin != nullptr) {
      plugin->Release();
    }
  }
}
