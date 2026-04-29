#pragma once

#include "ContractProbeTouch.hpp"

#include <atomic>
#include <string>

namespace contract_probe {

class ContractProbePlugin : public toncut::ITcPlugin {
 public:
  ContractProbePlugin();
  ~ContractProbePlugin();
  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID riid, void** object) override;
  ULONG STDMETHODCALLTYPE AddRef() override;
  ULONG STDMETHODCALLTYPE Release() override;
  HRESULT STDMETHODCALLTYPE GetEngineVersion(int* result) override;
  HRESULT STDMETHODCALLTYPE GetName(BSTR* result) override;
  HRESULT STDMETHODCALLTYPE GetVersion(toncut::TTcpVersion* result) override;
  HRESULT STDMETHODCALLTYPE GetTitle(BSTR* result) override;
  HRESULT STDMETHODCALLTYPE GetProfessional(toncut::DelphiBool* result) override;
  HRESULT STDMETHODCALLTYPE GetRegRoot(BSTR* result) override;
  HRESULT STDMETHODCALLTYPE GetLanguageId(int* result) override;
  HRESULT STDMETHODCALLTYPE SetLanguageId(int value) override;
  HRESULT STDMETHODCALLTYPE GetUiScale(float* result) override;
  HRESULT STDMETHODCALLTYPE SetUiScale(float value) override;
  HRESULT STDMETHODCALLTYPE GetTonCut(toncut::ITonCut** result) override;
  HRESULT STDMETHODCALLTYPE GetFeatures(toncut::TTcpFeatures* result) override;
  HRESULT STDMETHODCALLTYPE GetPlotterInfo(toncut::ITcPlotterInfo** result) override;
  HRESULT STDMETHODCALLTYPE Initialize(BSTR aRegRoot, int aLanguageId, toncut::ITonCut* aTonCut, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE Finalize(toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE Configure(HWND aWindow, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE About(HWND aWindow, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE LoadConfig(BSTR aKey, BSTR aVersion, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE SaveConfig(BSTR aKey, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE BackupConfig(BSTR* aBackup, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE RestoreConfig(BSTR aBackup, toncut::TConfigurationParts aScope, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE EnumExtensions(toncut::TTcpExtensionType aType, toncut::ITcEnumExtensionsCallback* aEnumCb, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE IsMyFile(BSTR aFileName, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE LoadFile(HWND aWindow, BSTR aFileName, IUnknown* aDevices, toncut::IMaterials* aMaterials, IUnknown* aBands, toncut::IProjects* aProjects, toncut::IFormats* aFormats, toncut::ISheets* aSheets, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE SaveFile(HWND aWindow, BSTR aFileName, toncut::IFormats* aFormats, toncut::ISheets* aSheets, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE SaveResult(HWND aWindow, BSTR aFileName, toncut::ISolutionSheet* aSolutionSheet, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE BatchSaveResult(HWND aWindow, toncut::TTcpSaveTarget aSaveTarget, BSTR aPath, toncut::ISolution* aSolution, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE Plot(HWND aWindow, toncut::ISolutionSheet* aSolutionSheet, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE BatchPlot(HWND aWindow, toncut::ISolution* aSolution, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE SavePlot(HWND aWindow, BSTR aFileName, toncut::ISolutionSheet* aSolutionSheet, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE BatchSavePlot(HWND aWindow, toncut::TTcpSaveTarget aSaveTarget, BSTR aPath, toncut::ISolution* aSolution, toncut::TTcpResult* result) override;
 private:
  std::atomic<ULONG> refCount_;
  std::wstring regRoot_;
  int languageId_;
  float uiScale_;
  toncut::ITonCut* tonCut_;
};

}  // namespace contract_probe
