#include "ContractProbePlugin.hpp"

extern "C" __declspec(dllexport) void __stdcall TcpInitializeV2(
  toncut::ITcPlugin** aResult,
  const wchar_t* aRegRoot,
  int aLanguageId,
  toncut::ITonCut* aTonCut
) {
  if (aResult == nullptr) return;
  *aResult = nullptr;
  contract_probe::ContractProbePlugin* plugin = nullptr;
  try {
    plugin = new contract_probe::ContractProbePlugin();
    toncut::BstrValue regRoot(aRegRoot == nullptr ? L"" : std::wstring(aRegRoot));
    if (!regRoot) {
      plugin->Release();
      return;
    }
    toncut::TTcpResult initResult = toncut::cprFailed;
    const HRESULT hr = plugin->Initialize(regRoot.get(), aLanguageId, aTonCut, &initResult);
    if (FAILED(hr) || initResult != toncut::cprOK) {
      plugin->Release();
      return;
    }
    *aResult = plugin;
  } catch (...) {
    if (plugin != nullptr) plugin->Release();
  }
}
