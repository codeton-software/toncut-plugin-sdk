#include "../../shared/cpp/CsvImportExportPluginBase.hpp"

// First-pass shim bootstrap:
// - exports TcpInitializeV2 on the native side
// - keeps the TonCut ABI in C++
// - leaves the managed CSV bridge as the project-specific extension point
//
// In a production C# starter, replace or extend the shared native CSV codec
// calls with a C++/CLI or COM bridge into TonCutCsv.Managed.

using toncut::BstrValue;
using toncut::CsvImportExportPluginBase;
using toncut::ITcPlugin;
using toncut::ITonCut;
using toncut::TTcpResult;
using toncut::cprFailed;
using toncut::cprOK;

namespace {

constexpr auto kPluginName = L"CsvImportExportTemplateCSharp";
constexpr auto kPluginTitle = L"CSV Import/Export + PLT Result Template (C#)";

}  // namespace

// The only export TonCut resolves. The host declares it as
//   function TcpInitializeV2(const aRegRoot: PChar; aLanguageId: Integer;
//     aTonCut: ITonCut): ITcPlugin; stdcall;
// A Delphi interface result is a hidden out parameter passed FIRST, so the
// native signature starts with ITcPlugin** aResult. aRegRoot is a temporary
// UTF-16 HKEY_CURRENT_USER-relative key path: copy it. The host never calls
// ITcPlugin::Initialize, so this export does. *aResult receives the one
// reference the host releases at unload; leave it nullptr on failure.
// Win32 __stdcall decorates the name (_TcpInitializeV2@16); the .def file
// exports it under the plain name TcpInitializeV2. Never let an exception
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
