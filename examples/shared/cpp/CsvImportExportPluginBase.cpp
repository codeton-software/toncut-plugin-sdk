#include "CsvImportExportPluginBase.hpp"

#include <algorithm>
#include <cmath>
#include <cwctype>
#include <limits>

namespace toncut {

namespace {

std::wstring NormalizeTitleKey(const std::wstring& value) {
  std::wstring normalized = value;
  std::transform(
    normalized.begin(),
    normalized.end(),
    normalized.begin(),
    [](wchar_t ch) { return static_cast<wchar_t>(std::towlower(ch)); });
  return normalized;
}

unsigned EffectiveMaterialWidth(TMaterialKind kind, unsigned width) {
  return kind == mk1D ? width : 0u;
}

std::wstring MakeMaterialKey(
  const std::wstring& title,
  TMaterialKind kind,
  unsigned width,
  unsigned thickness
) {
  return NormalizeTitleKey(title) +
         L"|" +
         std::to_wstring(static_cast<unsigned>(kind)) +
         L"|" +
         std::to_wstring(EffectiveMaterialWidth(kind, width)) +
         L"|" +
         std::to_wstring(thickness);
}

std::shared_ptr<IMaterial> ShareMaterial(IMaterial* material) {
  if (material == nullptr) {
    return {};
  }

  material->AddRef();
  return std::shared_ptr<IMaterial>(
    material,
    [](IMaterial* value) {
      if (value != nullptr) {
        value->Release();
      }
    });
}

std::shared_ptr<IProject> ShareProject(IProject* project) {
  if (project == nullptr) {
    return {};
  }

  project->AddRef();
  return std::shared_ptr<IProject>(
    project,
    [](IProject* value) {
      if (value != nullptr) {
        value->Release();
      }
    });
}

HRESULT PutBstr(const std::wstring& value, BSTR* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = nullptr;
  BstrValue bstr(value);
  if (!bstr) {
    return E_OUTOFMEMORY;
  }
  *result = bstr.release();
  return S_OK;
}

HRESULT ReplaceBstr(const std::wstring& value, BSTR* target) {
  if (target == nullptr) {
    return E_POINTER;
  }
  BstrValue replacement(value);
  if (!replacement) {
    return E_OUTOFMEMORY;
  }
  BSTR previous = *target;
  *target = replacement.release();
  ::SysFreeString(previous);
  return S_OK;
}

HRESULT UnexpectedPluginException(TTcpResult* result) noexcept {
  if (result != nullptr) {
    *result = cprException;
  }
  return E_UNEXPECTED;
}

int ToPlotterUnit(double value, double scale) {
  return static_cast<int>(std::lround(value * scale));
}

bool TryFromCsvMillimeters(unsigned value, unsigned& scaled) {
  const std::uint64_t scaledValue = static_cast<std::uint64_t>(value) * cLengthMultiplier;
  if (scaledValue > (std::numeric_limits<unsigned>::max)()) {
    return false;
  }
  scaled = static_cast<unsigned>(scaledValue);
  return true;
}

unsigned ToCsvMillimeters(unsigned value) {
  return static_cast<unsigned>(
    (static_cast<std::uint64_t>(value) + (cLengthMultiplier / 2u)) /
    cLengthMultiplier
  );
}

void AppendMoveCommand(
  std::vector<std::string>& commands,
  const char* command,
  int x,
  int y
) {
  commands.push_back(
    std::string(command) +
    std::to_string(x) +
    "," +
    std::to_string(y) +
    ";"
  );
}

void AppendBezierCommand(
  std::vector<std::string>& commands,
  int x1,
  int y1,
  int x2,
  int y2,
  int x3,
  int y3
) {
  commands.push_back(
    "BZ" +
    std::to_string(x1) +
    "," +
    std::to_string(y1) +
    "," +
    std::to_string(x2) +
    "," +
    std::to_string(y2) +
    "," +
    std::to_string(x3) +
    "," +
    std::to_string(y3) +
    ";"
  );
}

bool WriteAsciiLines(
  const std::wstring& path,
  const std::vector<std::string>& lines
) {
  std::string content;
  for (const std::string& line : lines) {
    content.append(line);
    content.append("\r\n");
  }

  HANDLE handle = ::CreateFileW(
    path.c_str(),
    GENERIC_WRITE,
    0,
    nullptr,
    CREATE_ALWAYS,
    FILE_ATTRIBUTE_NORMAL,
    nullptr
  );
  if (handle == INVALID_HANDLE_VALUE) {
    return false;
  }

  const auto* next = reinterpret_cast<const unsigned char*>(content.data());
  std::size_t remaining = content.size();
  bool ok = true;
  while (remaining > 0) {
    const DWORD requested = static_cast<DWORD>(
      (std::min)(
        remaining,
        static_cast<std::size_t>((std::numeric_limits<DWORD>::max)())
      )
    );
    DWORD written = 0;
    if (::WriteFile(handle, next, requested, &written, nullptr) == 0 || written == 0 || written > requested) {
      ok = false;
      break;
    }
    next += written;
    remaining -= written;
  }
  if (ok && ::FlushFileBuffers(handle) == 0) {
    ok = false;
  }
  const BOOL closed = ::CloseHandle(handle);

  return ok && closed != 0;
}

}  // namespace

CsvImportExportPluginBase::CsvImportExportPluginBase(
    std::wstring pluginName,
    std::wstring pluginTitle)
    : refCount_(1),
      pluginName_(std::move(pluginName)),
      pluginTitle_(std::move(pluginTitle)),
      languageId_(0),
      uiScale_(1.0f),
      tonCut_(nullptr) {
}

CsvImportExportPluginBase::~CsvImportExportPluginBase() {
  if (tonCut_ != nullptr) {
    tonCut_->Release();
    tonCut_ = nullptr;
  }
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::QueryInterface(REFIID riid, void** object) {
  if (object == nullptr) {
    return E_POINTER;
  }

  *object = nullptr;
  if (riid == IID_IUnknown) {
    *object = static_cast<ITcPlugin*>(this);
    AddRef();
    return S_OK;
  }

  return E_NOINTERFACE;
}

ULONG STDMETHODCALLTYPE CsvImportExportPluginBase::AddRef() {
  return ++refCount_;
}

ULONG STDMETHODCALLTYPE CsvImportExportPluginBase::Release() {
  const ULONG remaining = --refCount_;
  if (remaining == 0) {
    delete this;
  }
  return remaining;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetEngineVersion(int* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = cEngineVersion;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetName(BSTR* result) {
  return PutBstr(pluginName_, result);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetVersion(TTcpVersion* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = MakeTcpVersion(1, 0, 0, 0);
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetTitle(BSTR* result) {
  return PutBstr(pluginTitle_, result);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetProfessional(DelphiBool* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = 0;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetRegRoot(BSTR* result) {
  return PutBstr(regRoot_, result);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetLanguageId(int* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = languageId_;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::SetLanguageId(int value) {
  languageId_ = value;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetUiScale(float* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = uiScale_;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::SetUiScale(float value) {
  uiScale_ = value;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetTonCut(ITonCut** result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = tonCut_;
  if (tonCut_ != nullptr) {
    tonCut_->AddRef();
  }
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetFeatures(TTcpFeatures* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result =
    FeatureMask(feImport) |
    FeatureMask(feExport) |
    FeatureMask(feSaveResultToFile) |
    FeatureMask(feConfigure) |
    FeatureMask(feAbout);
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetPlotterInfo(ITcPlotterInfo** result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = nullptr;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::Initialize(BSTR aRegRoot, int aLanguageId, ITonCut* aTonCut, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }

  try {
    regRoot_ = FromBstr(aRegRoot);
    languageId_ = aLanguageId;
    if (aTonCut != nullptr) {
      aTonCut->AddRef();
    }
    if (tonCut_ != nullptr) {
      tonCut_->Release();
    }
    tonCut_ = aTonCut;
    *result = cprOK;
    return S_OK;
  } catch (...) {
    return UnexpectedPluginException(result);
  }
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::Finalize(TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  if (tonCut_ != nullptr) {
    tonCut_->Release();
    tonCut_ = nullptr;
  }
  *result = cprOK;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::Configure(HWND aWindow, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }

  if (aWindow != nullptr) {
    ::MessageBoxW(
      aWindow,
      L"This starter plugin does not expose configurable options yet.",
      pluginTitle_.c_str(),
      MB_OK | MB_ICONINFORMATION
    );
  }
  *result = cprOK;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::About(HWND aWindow, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }

  if (aWindow != nullptr) {
    ::MessageBoxW(
      aWindow,
      L"CSV import/export plus single-sheet PLT result export.",
      pluginTitle_.c_str(),
      MB_OK | MB_ICONINFORMATION
    );
  }
  *result = cprOK;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::LoadConfig(BSTR, BSTR, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = cprOK;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::SaveConfig(BSTR, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = cprOK;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::BackupConfig(BSTR* aBackup, TTcpResult* result) {
  if (aBackup == nullptr || result == nullptr) {
    return E_POINTER;
  }
  const HRESULT hr = ReplaceBstr(L"", aBackup);
  *result = SUCCEEDED(hr) ? cprOK : cprFailed;
  return hr;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::RestoreConfig(BSTR, TConfigurationParts, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = cprOK;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::EnumExtensions(TTcpExtensionType aType, ITcEnumExtensionsCallback* aEnumCb, TTcpResult* result) {
  if (aEnumCb == nullptr || result == nullptr) {
    return E_POINTER;
  }

  if (aType == etImport || aType == etExport) {
    BstrValue ext(L".csv");
    BstrValue name(pluginTitle_);
    if (!ext || !name) {
      *result = cprFailed;
      return E_OUTOFMEMORY;
    }
    const HRESULT hr = aEnumCb->Invoke(aType, ext.get(), name.get());
    if (FAILED(hr)) {
      *result = cprFailed;
      return hr;
    }
  } else if (aType == etExportResults) {
    BstrValue ext(L".plt");
    BstrValue name(pluginTitle_);
    if (!ext || !name) {
      *result = cprFailed;
      return E_OUTOFMEMORY;
    }
    const HRESULT hr = aEnumCb->Invoke(aType, ext.get(), name.get());
    if (FAILED(hr)) {
      *result = cprFailed;
      return hr;
    }
  }

  *result = cprOK;
  return S_OK;
}

HRESULT CsvImportExportPluginBase::ValidateHeader(const std::wstring& fileName, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }

  if (fileName.size() < 4 || _wcsicmp(fileName.substr(fileName.size() - 4).c_str(), L".csv") != 0) {
    *result = cprNo;
    return S_OK;
  }

  std::vector<std::vector<std::wstring>> rows;
  std::wstring error;
  if (!ParseUtf8CsvFile(fileName, rows, error)) {
    *result = cprFailed;
    return S_OK;
  }

  *result = (!rows.empty() && HasRequiredHeader(rows.front())) ? cprOK : cprNo;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::IsMyFile(BSTR aFileName, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  try {
    return ValidateHeader(FromBstr(aFileName), result);
  } catch (...) {
    return UnexpectedPluginException(result);
  }
}

HRESULT CsvImportExportPluginBase::EnsureProject(
  IProjects* projects,
  const std::wstring& title,
  ProjectCache& projectCache,
  ComPtr<IProject>& project
) {
  const std::wstring effectiveTitle = title.empty() ? L"CSV Import" : title;
  const std::wstring requestedKey = NormalizeTitleKey(effectiveTitle);
  auto cacheIt = projectCache.find(requestedKey);
  if (cacheIt != projectCache.end() && cacheIt->second) {
    IProject* cachedProject = cacheIt->second.get();
    cachedProject->AddRef();
    *project.put() = cachedProject;
    return S_OK;
  }

  BstrValue bstrTitle(effectiveTitle);
  if (!bstrTitle) {
    return E_OUTOFMEMORY;
  }
  HRESULT hr = tonCut_->CreateProject(bstrTitle.get(), project.put());
  if (FAILED(hr) || !project) {
    return FAILED(hr) ? hr : E_FAIL;
  }
  hr = projects->Add(project.get());
  if (FAILED(hr)) {
    return hr;
  }

  projectCache[requestedKey] = ShareProject(project.get());
  return S_OK;
}

HRESULT CsvImportExportPluginBase::FindMaterialByTitle(
  IMaterials* materials,
  const std::wstring& title,
  TMaterialKind kind,
  unsigned width,
  unsigned thickness,
  ComPtr<IMaterial>& material
) {
  if (materials == nullptr) {
    return E_POINTER;
  }

  BstrValue bstrTitle(title);
  if (!bstrTitle) {
    return E_OUTOFMEMORY;
  }
  return materials->FindByTitle(
    bstrTitle.get(),
    kind,
    EffectiveMaterialWidth(kind, width),
    thickness,
    material.put());
}

HRESULT CsvImportExportPluginBase::EnsureMaterial(
  IMaterials* materials,
  const std::wstring& title,
  TMaterialKind kind,
  unsigned width,
  unsigned thickness,
  MaterialCache& materialCache,
  ComPtr<IMaterial>& material
) {
  const std::wstring effectiveTitle = title.empty() ? L"CSV Material" : title;
  const unsigned effectiveWidth = EffectiveMaterialWidth(kind, width);
  const std::wstring requestedKey = MakeMaterialKey(effectiveTitle, kind, effectiveWidth, thickness);
  auto cacheIt = materialCache.find(requestedKey);
  if (cacheIt != materialCache.end() && cacheIt->second) {
    IMaterial* cachedMaterial = cacheIt->second.get();
    cachedMaterial->AddRef();
    *material.put() = cachedMaterial;
    return S_OK;
  }

  BstrValue bstrTitle(effectiveTitle);
  if (!bstrTitle) {
    return E_OUTOFMEMORY;
  }
  HRESULT hr = FindMaterialByTitle(materials, effectiveTitle, kind, effectiveWidth, thickness, material);
  if (FAILED(hr)) {
    return hr;
  }
  if (material) {
    auto sharedMaterial = ShareMaterial(material.get());
    materialCache[requestedKey] = sharedMaterial;
    BstrValue materialTitle;
    TMaterialKind actualKind = mkUnknown;
    unsigned actualWidth = 0;
    unsigned actualThickness = 0;
    hr = material->GetTitle(materialTitle.put());
    hr = SUCCEEDED(hr) ? material->GetKind(&actualKind) : hr;
    hr = SUCCEEDED(hr) ? material->GetWidth(&actualWidth) : hr;
    hr = SUCCEEDED(hr) ? material->GetThickness(&actualThickness) : hr;
    if (SUCCEEDED(hr)) {
      const std::wstring actualTitle = FromBstr(materialTitle.get());
      if (!actualTitle.empty()) {
        materialCache[MakeMaterialKey(actualTitle, actualKind, actualWidth, actualThickness)] = sharedMaterial;
      }
    }
    return S_OK;
  }

  DelphiBool isUnique = 0;
  hr = materials->CheckUniqueName(
    bstrTitle.get(),
    kind,
    effectiveWidth,
    thickness,
    nullptr,
    &isUnique);
  if (FAILED(hr)) {
    return hr;
  }
  if (isUnique == 0) {
    return HRESULT_FROM_WIN32(ERROR_ALREADY_EXISTS);
  }

  hr = tonCut_->CreateMaterial(
    bstrTitle.get(),
    kind,
    effectiveWidth,
    thickness,
    material.put());
  if (FAILED(hr) || !material) {
    return FAILED(hr) ? hr : E_FAIL;
  }

  auto sharedMaterial = ShareMaterial(material.get());
  materialCache[requestedKey] = sharedMaterial;
  BstrValue materialTitle;
  TMaterialKind actualKind = mkUnknown;
  unsigned actualWidth = 0;
  unsigned actualThickness = 0;
  hr = material->GetTitle(materialTitle.put());
  hr = SUCCEEDED(hr) ? material->GetKind(&actualKind) : hr;
  hr = SUCCEEDED(hr) ? material->GetWidth(&actualWidth) : hr;
  hr = SUCCEEDED(hr) ? material->GetThickness(&actualThickness) : hr;
  if (SUCCEEDED(hr)) {
    const std::wstring actualTitle = FromBstr(materialTitle.get());
    if (!actualTitle.empty()) {
      materialCache[MakeMaterialKey(actualTitle, actualKind, actualWidth, actualThickness)] = sharedMaterial;
    }
  }
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::LoadFile(HWND, BSTR aFileName, IDevices*, IMaterials* aMaterials, IBands*, IProjects* aProjects, IFormats* aFormats, ISheets* aSheets, TTcpResult* result) {
  if (aMaterials == nullptr || aProjects == nullptr || aFormats == nullptr || aSheets == nullptr || result == nullptr) {
    return E_POINTER;
  }
  try {
  if (tonCut_ == nullptr) {
    *result = cprNotInitialized;
    return S_OK;
  }

  TTcpResult headerResult = cprFailed;
  ValidateHeader(FromBstr(aFileName), &headerResult);
  if (headerResult != cprOK) {
    *result = headerResult;
    return S_OK;
  }

  std::vector<std::vector<std::wstring>> rows;
  std::wstring error;
  if (!ParseUtf8CsvFile(FromBstr(aFileName), rows, error)) {
    *result = cprFailed;
    return S_OK;
  }

  std::vector<CsvRowRecord> records;
  if (!DecodeCsvRows(rows, records, error)) {
    *result = cprFailed;
    return S_OK;
  }

  ProjectCache projectCache;
  MaterialCache materialCache;
  for (const CsvRowRecord& record : records) {
    unsigned materialWidth = 0;
    unsigned materialThickness = 0;
    unsigned length = 0;
    unsigned width = 0;
    if (!TryFromCsvMillimeters(record.materialWidth, materialWidth) ||
        !TryFromCsvMillimeters(record.materialThickness, materialThickness) ||
        !TryFromCsvMillimeters(record.length, length) ||
        !TryFromCsvMillimeters(record.width, width)) {
      *result = cprFailed;
      return S_OK;
    }
    if (
      _wcsicmp(record.recordType.c_str(), L"SHEET") == 0 &&
      record.quantity > static_cast<unsigned>((std::numeric_limits<int>::max)())
    ) {
      *result = cprFailed;
      return S_OK;
    }

    if (_wcsicmp(record.recordType.c_str(), L"FORMAT") == 0) {
      ComPtr<IProject> project;
      HRESULT hr = EnsureProject(aProjects, record.projectTitle, projectCache, project);
      if (FAILED(hr)) {
        *result = cprFailed;
        return S_OK;
      }

      ComPtr<IMaterial> material;
      hr = EnsureMaterial(
        aMaterials,
        record.materialTitle,
        record.materialKind,
        materialWidth,
        materialThickness,
        materialCache,
        material);
      if (FAILED(hr) || !material) {
        *result = cprFailed;
        return S_OK;
      }

      ComPtr<IFormat> format;
      hr = aFormats->CreateFormat(format.put());
      if (FAILED(hr) || !format) {
        *result = cprFailed;
        return S_OK;
      }

      BstrValue identifier(record.identifier);
      BstrValue description(record.description);
      if (!identifier || !description) {
        *result = cprFailed;
        return E_OUTOFMEMORY;
      }
      hr = format->SetProject(project.get());
      hr = SUCCEEDED(hr) ? format->SetMaterial(material.get()) : hr;
      hr = SUCCEEDED(hr) ? format->SetLength(length) : hr;
      hr = SUCCEEDED(hr) ? format->SetWidth(width) : hr;
      hr = SUCCEEDED(hr) ? format->SetQuantity(record.quantity) : hr;
      hr = SUCCEEDED(hr) ? format->SetIdentifier(identifier.get()) : hr;
      hr = SUCCEEDED(hr) ? format->SetDescription(description.get()) : hr;
      hr = SUCCEEDED(hr) ? aFormats->Add(format.get()) : hr;
      if (FAILED(hr)) {
        *result = cprFailed;
        return S_OK;
      }
    } else {
      ComPtr<IMaterial> material;
      HRESULT hr = EnsureMaterial(
        aMaterials,
        record.materialTitle,
        record.materialKind,
        materialWidth,
        materialThickness,
        materialCache,
        material);
      if (FAILED(hr) || !material) {
        *result = cprFailed;
        return S_OK;
      }

      ComPtr<ISheet> sheet;
      hr = aSheets->CreateSheet(sheet.put());
      if (FAILED(hr) || !sheet) {
        *result = cprFailed;
        return S_OK;
      }

      BstrValue identifier(record.identifier);
      BstrValue description(record.description);
      if (!identifier || !description) {
        *result = cprFailed;
        return E_OUTOFMEMORY;
      }
      hr = sheet->SetMaterial(material.get());
      hr = SUCCEEDED(hr) ? sheet->SetLength(length) : hr;
      hr = SUCCEEDED(hr) ? sheet->SetWidth(width) : hr;
      hr = SUCCEEDED(hr) ? sheet->SetQuantity(static_cast<int>(record.quantity)) : hr;
      hr = SUCCEEDED(hr) ? sheet->SetIdentifier(identifier.get()) : hr;
      hr = SUCCEEDED(hr) ? sheet->SetDescription(description.get()) : hr;
      hr = SUCCEEDED(hr) ? aSheets->Add(sheet.get()) : hr;
      if (FAILED(hr)) {
        *result = cprFailed;
        return S_OK;
      }
    }
  }

  *result = cprOK;
  return S_OK;
  } catch (...) {
    return UnexpectedPluginException(result);
  }
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::SaveFile(HWND, BSTR aFileName, IFormats* aFormats, ISheets* aSheets, TTcpResult* result) {
  if (aFormats == nullptr || aSheets == nullptr || result == nullptr) {
    return E_POINTER;
  }
  try {

  std::vector<CsvRowRecord> records;
  int formatCount = 0;
  int sheetCount = 0;
  HRESULT hr = aFormats->GetCount(&formatCount);
  if (FAILED(hr)) {
    *result = cprFailed;
    return S_OK;
  }

  for (int i = 0; i < formatCount; ++i) {
    ComPtr<IFormat> format;
    hr = aFormats->GetByIndex(static_cast<unsigned>(i), format.put());
    if (FAILED(hr) || !format) {
      *result = cprFailed;
      return S_OK;
    }

    ComPtr<IProject> project;
    ComPtr<IMaterial> material;
    unsigned length = 0;
    unsigned width = 0;
    unsigned quantity = 0;
    BstrValue identifier;
    BstrValue description;

    hr = format->GetProject(project.put());
    hr = SUCCEEDED(hr) ? format->GetMaterial(material.put()) : hr;
    hr = SUCCEEDED(hr) ? format->GetLength(&length) : hr;
    hr = SUCCEEDED(hr) ? format->GetWidth(&width) : hr;
    hr = SUCCEEDED(hr) ? format->GetQuantity(&quantity) : hr;
    hr = SUCCEEDED(hr) ? format->GetIdentifier(identifier.put()) : hr;
    hr = SUCCEEDED(hr) ? format->GetDescription(description.put()) : hr;
    if (FAILED(hr) || !material) {
      *result = cprFailed;
      return S_OK;
    }

    BstrValue projectTitle;
    BstrValue materialTitle;
    TMaterialKind materialKind = mkUnknown;
    unsigned materialWidth = 0;
    unsigned materialThickness = 0;
    if (project) {
      hr = project->GetTitle(projectTitle.put());
    }
    hr = SUCCEEDED(hr) ? material->GetTitle(materialTitle.put()) : hr;
    hr = SUCCEEDED(hr) ? material->GetKind(&materialKind) : hr;
    hr = SUCCEEDED(hr) ? material->GetWidth(&materialWidth) : hr;
    hr = SUCCEEDED(hr) ? material->GetThickness(&materialThickness) : hr;
    if (FAILED(hr)) {
      *result = cprFailed;
      return S_OK;
    }

    records.push_back({
      L"FORMAT",
      FromBstr(projectTitle.get()),
      FromBstr(materialTitle.get()),
      materialKind,
      ToCsvMillimeters(EffectiveMaterialWidth(materialKind, materialWidth)),
      ToCsvMillimeters(materialThickness),
      ToCsvMillimeters(length),
      ToCsvMillimeters(width),
      quantity,
      FromBstr(identifier.get()),
      FromBstr(description.get())
    });
  }

  hr = aSheets->GetCount(&sheetCount);
  if (FAILED(hr)) {
    *result = cprFailed;
    return S_OK;
  }

  for (int i = 0; i < sheetCount; ++i) {
    ComPtr<ISheet> sheet;
    hr = aSheets->GetByIndex(static_cast<unsigned>(i), sheet.put());
    if (FAILED(hr) || !sheet) {
      *result = cprFailed;
      return S_OK;
    }

    ComPtr<IMaterial> material;
    unsigned length = 0;
    unsigned width = 0;
    int quantity = 0;
    BstrValue identifier;
    BstrValue description;

    hr = sheet->GetMaterial(material.put());
    hr = SUCCEEDED(hr) ? sheet->GetLength(&length) : hr;
    hr = SUCCEEDED(hr) ? sheet->GetWidth(&width) : hr;
    hr = SUCCEEDED(hr) ? sheet->GetQuantity(&quantity) : hr;
    hr = SUCCEEDED(hr) ? sheet->GetIdentifier(identifier.put()) : hr;
    hr = SUCCEEDED(hr) ? sheet->GetDescription(description.put()) : hr;
    if (FAILED(hr) || !material) {
      *result = cprFailed;
      return S_OK;
    }

    BstrValue materialTitle;
    TMaterialKind materialKind = mkUnknown;
    unsigned materialWidth = 0;
    unsigned materialThickness = 0;
    hr = material->GetTitle(materialTitle.put());
    hr = SUCCEEDED(hr) ? material->GetKind(&materialKind) : hr;
    hr = SUCCEEDED(hr) ? material->GetWidth(&materialWidth) : hr;
    hr = SUCCEEDED(hr) ? material->GetThickness(&materialThickness) : hr;
    if (FAILED(hr)) {
      *result = cprFailed;
      return S_OK;
    }

    records.push_back({
      L"SHEET",
      L"",
      FromBstr(materialTitle.get()),
      materialKind,
      ToCsvMillimeters(EffectiveMaterialWidth(materialKind, materialWidth)),
      ToCsvMillimeters(materialThickness),
      ToCsvMillimeters(length),
      ToCsvMillimeters(width),
      static_cast<unsigned>(quantity > 0 ? quantity : 1),
      FromBstr(identifier.get()),
      FromBstr(description.get())
    });
  }

  std::wstring error;
  if (!WriteUtf8CsvFile(FromBstr(aFileName), EncodeCsvRows(records), error)) {
    *result = cprFailed;
    return S_OK;
  }

  *result = cprOK;
  return S_OK;
  } catch (...) {
    return UnexpectedPluginException(result);
  }
}

bool CsvImportExportPluginBase::ExportSolutionSheetAsPlt(
  ISolutionSheet* solutionSheet,
  std::vector<std::string>& commands
) {
  if (solutionSheet == nullptr) {
    return false;
  }

  unsigned sheetLength = 0;
  unsigned sheetWidth = 0;
  unsigned marginLeft = 0;
  unsigned marginTop = 0;
  unsigned marginRight = 0;
  unsigned marginBottom = 0;
  HRESULT hr = solutionSheet->CalcEffectiveLayout(
    &sheetLength,
    &sheetWidth,
    &marginLeft,
    &marginTop,
    &marginRight,
    &marginBottom
  );
  if (FAILED(hr) || sheetLength == 0 || sheetWidth == 0) {
    return false;
  }

  ComPtr<ISolutionCuts> solutionCuts;
  hr = solutionSheet->GetSolutionCuts(solutionCuts.put());
  if (FAILED(hr) || !solutionCuts) {
    return false;
  }

  int cutCount = 0;
  hr = solutionCuts->GetCount(&cutCount);
  if (FAILED(hr)) {
    return false;
  }

  const double scale = 40.0 / 25.4;
  commands.clear();
  commands.push_back("IN;");
  commands.push_back("PA;");

  for (int i = 0; i < cutCount; ++i) {
    ComPtr<ISolutionCut> cut;
    hr = solutionCuts->GetByIndex(static_cast<unsigned>(i), cut.put());
    if (FAILED(hr) || !cut) {
      return false;
    }

    TCutKind kind = ckLine;
    hr = cut->GetKind(&kind);
    if (FAILED(hr)) {
      return false;
    }

    int posX = 0;
    int posY = 0;
    int tarX = 0;
    int tarY = 0;
    hr = cut->GetPosX(&posX);
    hr = SUCCEEDED(hr) ? cut->GetPosY(&posY) : hr;
    hr = SUCCEEDED(hr) ? cut->GetTarX(&tarX) : hr;
    hr = SUCCEEDED(hr) ? cut->GetTarY(&tarY) : hr;
    if (FAILED(hr)) {
      return false;
    }

    double x0 = static_cast<double>(posX);
    double y0 = static_cast<double>(posY);
    double x3 = static_cast<double>(tarX);
    double y3 = static_cast<double>(tarY);

    hr = solutionSheet->CalcPointF(&x0, &y0);
    hr = SUCCEEDED(hr) ? solutionSheet->CalcPointF(&x3, &y3) : hr;
    if (FAILED(hr)) {
      return false;
    }

    AppendMoveCommand(commands, "PU", ToPlotterUnit(x0, scale), ToPlotterUnit(y0, scale));

    if (kind == ckCurve) {
      int posXp = 0;
      int posYp = 0;
      int tarXp = 0;
      int tarYp = 0;
      hr = cut->GetPosXp(&posXp);
      hr = SUCCEEDED(hr) ? cut->GetPosYp(&posYp) : hr;
      hr = SUCCEEDED(hr) ? cut->GetTarXp(&tarXp) : hr;
      hr = SUCCEEDED(hr) ? cut->GetTarYp(&tarYp) : hr;
      if (FAILED(hr)) {
        return false;
      }

      double x1 = static_cast<double>(posXp);
      double y1 = static_cast<double>(posYp);
      double x2 = static_cast<double>(tarXp);
      double y2 = static_cast<double>(tarYp);

      hr = solutionSheet->CalcPointF(&x1, &y1);
      hr = SUCCEEDED(hr) ? solutionSheet->CalcPointF(&x2, &y2) : hr;
      if (FAILED(hr)) {
        return false;
      }

      AppendBezierCommand(
        commands,
        ToPlotterUnit(x1, scale),
        ToPlotterUnit(y1, scale),
        ToPlotterUnit(x2, scale),
        ToPlotterUnit(y2, scale),
        ToPlotterUnit(x3, scale),
        ToPlotterUnit(y3, scale)
      );
    } else {
      AppendMoveCommand(commands, "PD", ToPlotterUnit(x3, scale), ToPlotterUnit(y3, scale));
    }
  }

  commands.push_back("PU;");
  commands.push_back("SP0;");
  return true;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::SaveResult(HWND, BSTR aFileName, ISolutionSheet* aSolutionSheet, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  try {

  std::vector<std::string> commands;
  if (!ExportSolutionSheetAsPlt(aSolutionSheet, commands)) {
    *result = cprFailed;
    return S_OK;
  }

  if (!WriteAsciiLines(FromBstr(aFileName), commands)) {
    *result = cprFailed;
    return S_OK;
  }

  if (aSolutionSheet != nullptr) {
    const HRESULT hr = aSolutionSheet->SetIsSaved(1);
    if (FAILED(hr)) {
      *result = cprException;
      return hr;
    }
  }

  *result = cprOK;
  return S_OK;
  } catch (...) {
    return UnexpectedPluginException(result);
  }
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::BatchSaveResult(HWND, TTcpSaveTarget, BSTR, ISolution*, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = cprNotImplemented;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::Plot(HWND, ISolutionSheet*, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = cprNotImplemented;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::BatchPlot(HWND, ISolution*, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = cprNotImplemented;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::SavePlot(HWND, BSTR, ISolutionSheet*, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = cprNotImplemented;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::BatchSavePlot(HWND, TTcpSaveTarget, BSTR, ISolution*, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = cprNotImplemented;
  return S_OK;
}

}  // namespace toncut
