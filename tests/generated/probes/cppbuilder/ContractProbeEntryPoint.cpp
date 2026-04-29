#include "ContractProbePlugin.hpp"

extern "C" __declspec(dllexport) void __stdcall TcpInitializeV2(
  toncut::ITcPlugin** aResult,
  const wchar_t* aRegRoot,
  int aLanguageId,
  toncut::ITonCut* aTonCut
) {
  if (aResult == nullptr) return;
  auto* plugin = new contract_probe::ContractProbePlugin();
  toncut::TTcpResult initResult = toncut::cprOK;
  plugin->Initialize(::SysAllocString(aRegRoot == nullptr ? L"" : aRegRoot), aLanguageId, aTonCut, &initResult);
  *aResult = plugin;
}
