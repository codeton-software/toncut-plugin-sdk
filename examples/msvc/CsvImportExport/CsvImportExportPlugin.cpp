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

  auto* plugin = new CsvImportExportPluginBase(kPluginName, kPluginTitle);
  TTcpResult initResult = cprFailed;
  BstrValue regRoot(aRegRoot == nullptr ? L"" : std::wstring(aRegRoot));
  plugin->Initialize(regRoot.get(), aLanguageId, aTonCut, &initResult);
  if (initResult != cprOK) {
    plugin->Release();
    return;
  }
  *aResult = plugin;
}
