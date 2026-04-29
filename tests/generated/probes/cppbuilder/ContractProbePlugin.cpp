#include "ContractProbePlugin.hpp"

namespace contract_probe {

namespace {
HRESULT PutBstr(const std::wstring& value, BSTR* result) {
  if (result == nullptr) return E_POINTER;
  *result = ::SysAllocStringLen(value.data(), static_cast<UINT>(value.size()));
  return *result == nullptr ? E_OUTOFMEMORY : S_OK;
}
}  // namespace

ContractProbePlugin::ContractProbePlugin() : refCount_(1), languageId_(0), uiScale_(1.0f), tonCut_(nullptr) {}
ContractProbePlugin::~ContractProbePlugin() { if (tonCut_ != nullptr) tonCut_->Release(); }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::QueryInterface(REFIID, void** object) { if (object == nullptr) return E_POINTER; *object = static_cast<toncut::ITcPlugin*>(this); AddRef(); return S_OK; }
ULONG STDMETHODCALLTYPE ContractProbePlugin::AddRef() { return ++refCount_; }
ULONG STDMETHODCALLTYPE ContractProbePlugin::Release() { const auto value = --refCount_; if (value == 0) delete this; return value; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetEngineVersion(int* result) { if (result == nullptr) return E_POINTER; *result = toncut::cEngineVersion; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetName(BSTR* result) { return PutBstr(L"ContractProbe", result); }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetVersion(toncut::TTcpVersion* result) { if (result == nullptr) return E_POINTER; *result = toncut::MakeTcpVersion(1, 0, 0, 0); return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetTitle(BSTR* result) { return PutBstr(L"Contract Probe", result); }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetProfessional(toncut::DelphiBool* result) { if (result == nullptr) return E_POINTER; *result = 0; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetRegRoot(BSTR* result) { return PutBstr(regRoot_, result); }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetLanguageId(int* result) { if (result == nullptr) return E_POINTER; *result = languageId_; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::SetLanguageId(int value) { languageId_ = value; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetUiScale(float* result) { if (result == nullptr) return E_POINTER; *result = uiScale_; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::SetUiScale(float value) { uiScale_ = value; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetTonCut(toncut::ITonCut** result) { if (result == nullptr) return E_POINTER; *result = tonCut_; if (*result != nullptr) (*result)->AddRef(); return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetFeatures(toncut::TTcpFeatures* result) { if (result == nullptr) return E_POINTER; *result = toncut::FeatureMask(toncut::feImport) | toncut::FeatureMask(toncut::feExport) | toncut::FeatureMask(toncut::feSaveResultToFile); return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetPlotterInfo(toncut::ITcPlotterInfo** result) { if (result == nullptr) return E_POINTER; *result = nullptr; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::Initialize(BSTR aRegRoot, int aLanguageId, toncut::ITonCut* aTonCut, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; regRoot_ = toncut::FromBstr(aRegRoot); languageId_ = aLanguageId; if (tonCut_ != nullptr) tonCut_->Release(); tonCut_ = aTonCut; if (tonCut_ != nullptr) tonCut_->AddRef(); TouchAllSupportedInterfaces(tonCut_); *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::Finalize(toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::Configure(HWND, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::About(HWND, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::LoadConfig(BSTR, BSTR, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::SaveConfig(BSTR, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::BackupConfig(BSTR* aBackup, toncut::TTcpResult* result) { if (result == nullptr || aBackup == nullptr) return E_POINTER; *result = toncut::cprOK; return PutBstr(L"contract-probe-backup", aBackup); }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::RestoreConfig(BSTR, toncut::TConfigurationParts, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::EnumExtensions(toncut::TTcpExtensionType aType, toncut::ITcEnumExtensionsCallback* aEnumCb, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; if (aEnumCb != nullptr) { BSTR ext = ::SysAllocString(L".probe"); BSTR title = ::SysAllocString(L"Contract Probe"); aEnumCb->Invoke(aType, ext, title); ::SysFreeString(ext); ::SysFreeString(title); } *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::IsMyFile(BSTR, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprMaybe; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::LoadFile(HWND, BSTR, IUnknown*, toncut::IMaterials*, IUnknown*, toncut::IProjects*, toncut::IFormats*, toncut::ISheets*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::SaveFile(HWND, BSTR, toncut::IFormats*, toncut::ISheets*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::SaveResult(HWND, BSTR, toncut::ISolutionSheet*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::BatchSaveResult(HWND, toncut::TTcpSaveTarget, BSTR, toncut::ISolution*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::Plot(HWND, toncut::ISolutionSheet*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::BatchPlot(HWND, toncut::ISolution*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::SavePlot(HWND, BSTR, toncut::ISolutionSheet*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::BatchSavePlot(HWND, toncut::TTcpSaveTarget, BSTR, toncut::ISolution*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }

}  // namespace contract_probe
