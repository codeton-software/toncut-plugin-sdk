#include "../../shared/cpp/CsvImportExportPluginBase.hpp"

using toncut::BstrValue;
using toncut::CsvImportExportPluginBase;
using toncut::ITcPlugin;
using toncut::ITonCut;
using toncut::TTcpResult;
using toncut::cprFailed;
using toncut::cprOK;

namespace {

constexpr auto kPluginName = L"CsvImportExportTemplateMsvc";
constexpr auto kPluginTitle = L"CSV Import/Export + PLT Result Template (MSVC)";

}  // namespace

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
