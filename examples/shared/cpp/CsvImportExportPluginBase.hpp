#pragma once

#include "CsvCodec.hpp"

#include <atomic>
#include <string>
#include <vector>

namespace toncut {

// Shared starter plugin used by the MSVC, C++Builder and C# shim examples.
//
// - CSV import (LoadFile) and export (SaveFile) of pieces and stock sheets.
// - Result export (SaveResult) of one solution sheet, either as HPGL cutting
//   paths (.plt) or as a CSV sheet layout with placed parts and waste (.csv).
//
// Every method that returns a TTcpResult reports failures through that
// result and returns S_OK: a failed HRESULT or an escaping C++ exception makes
// TonCut disable the plugin.
class CsvImportExportPluginBase final : public ITcPlugin {
 public:
  CsvImportExportPluginBase(std::wstring pluginName, std::wstring pluginTitle);

  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID riid, void** object) override;
  ULONG STDMETHODCALLTYPE AddRef() override;
  ULONG STDMETHODCALLTYPE Release() override;

  HRESULT STDMETHODCALLTYPE GetEngineVersion(int* result) override;
  HRESULT STDMETHODCALLTYPE GetName(BSTR* result) override;
  HRESULT STDMETHODCALLTYPE GetVersion(TTcpVersion* result) override;
  HRESULT STDMETHODCALLTYPE GetTitle(BSTR* result) override;
  HRESULT STDMETHODCALLTYPE GetProfessional(DelphiBool* result) override;
  HRESULT STDMETHODCALLTYPE GetRegRoot(BSTR* result) override;
  HRESULT STDMETHODCALLTYPE GetLanguageId(int* result) override;
  HRESULT STDMETHODCALLTYPE SetLanguageId(int value) override;
  HRESULT STDMETHODCALLTYPE GetUiScale(float* result) override;
  HRESULT STDMETHODCALLTYPE SetUiScale(float value) override;
  HRESULT STDMETHODCALLTYPE GetTonCut(ITonCut** result) override;
  HRESULT STDMETHODCALLTYPE GetFeatures(TTcpFeatures* result) override;
  HRESULT STDMETHODCALLTYPE GetPlotterInfo(ITcPlotterInfo** result) override;
  HRESULT STDMETHODCALLTYPE Initialize(BSTR aRegRoot, int aLanguageId, ITonCut* aTonCut, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE Finalize(TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE Configure(HWND aWindow, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE About(HWND aWindow, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE LoadConfig(BSTR aKey, BSTR aVersion, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE SaveConfig(BSTR aKey, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE BackupConfig(BSTR* aBackup, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE RestoreConfig(BSTR aBackup, TConfigurationParts aScope, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE EnumExtensions(TTcpExtensionType aType, ITcEnumExtensionsCallback* aEnumCb, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE IsMyFile(BSTR aFileName, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE LoadFile(HWND aWindow, BSTR aFileName, IDevices* aDevices, IMaterials* aMaterials, IBands* aBands, IProjects* aProjects, IFormats* aFormats, ISheets* aSheets, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE SaveFile(HWND aWindow, BSTR aFileName, IFormats* aFormats, ISheets* aSheets, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE SaveResult(HWND aWindow, BSTR aFileName, ISolutionSheet* aSolutionSheet, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE BatchSaveResult(HWND aWindow, TTcpSaveTarget aSaveTarget, BSTR aPath, ISolution* aSolution, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE Plot(HWND aWindow, ISolutionSheet* aSolutionSheet, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE BatchPlot(HWND aWindow, ISolution* aSolution, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE SavePlot(HWND aWindow, BSTR aFileName, ISolutionSheet* aSolutionSheet, TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE BatchSavePlot(HWND aWindow, TTcpSaveTarget aSaveTarget, BSTR aPath, ISolution* aSolution, TTcpResult* result) override;

 private:
  // Destroyed only by the final Release().
  ~CsvImportExportPluginBase();

  HRESULT ValidateHeader(const std::wstring& fileName, TTcpResult* result);
  HRESULT FindOrCreateProject(IProjects* projects, const std::wstring& title, ComPtr<IProject>& project);
  HRESULT FindOrCreateMaterial(IMaterials* materials, const std::wstring& title, TMaterialKind kind, unsigned width, unsigned thickness, ComPtr<IMaterial>& material);
  HRESULT FindDeviceForKind(TMaterialKind kind, ComPtr<IDevice>& device);
  bool ExportSolutionSheetAsPlt(ISolutionSheet* solutionSheet, std::vector<std::string>& commands);
  bool ExportSolutionSheetLayout(ISolutionSheet* solutionSheet, std::wstring& content);

  std::atomic<ULONG> refCount_;
  std::wstring pluginName_;
  std::wstring pluginTitle_;
  std::wstring regRoot_;
  int languageId_;
  float uiScale_;
  ITonCut* tonCut_;
};

}  // namespace toncut
