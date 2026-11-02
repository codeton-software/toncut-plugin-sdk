#include "CsvImportExportPluginBase.hpp"

#include "StarterPlotterInfo.hpp"

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cwchar>
#include <limits>
#include <string>
#include <utility>

namespace toncut {

namespace {

// HPGL plotter units: 40 per millimeter. TonCut lengths are 0.01 mm
// (cLengthMultiplier per mm), so one internal unit is 40 / 100 = 0.4 HPGL
// units.
constexpr double kHpglUnitsPerMillimeter = 40.0;
constexpr double kHpglUnitsPerInternalUnit =
  kHpglUnitsPerMillimeter / static_cast<double>(cLengthMultiplier);

constexpr wchar_t kCsvExtension[] = L".csv";
constexpr wchar_t kPltExtension[] = L".plt";

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

// Reports a plugin result. TonCut treats a failed HRESULT as a plugin crash
// and disables the plugin, so the HRESULT stays S_OK whenever a result
// pointer exists.
HRESULT Report(TTcpResult* result, TTcpResult value) noexcept {
  *result = value;
  return S_OK;
}

bool HasExtension(const std::wstring& path, const wchar_t* extension) {
  const std::size_t length = std::char_traits<wchar_t>::length(extension);
  return path.size() >= length &&
         _wcsicmp(path.c_str() + (path.size() - length), extension) == 0;
}

unsigned EffectiveMaterialWidth(TMaterialKind kind, unsigned width) {
  return kind == mk1D ? width : 0u;
}

int ToPlotterUnit(int value) {
  return static_cast<int>(std::lround(static_cast<double>(value) * kHpglUnitsPerInternalUnit));
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

// Internal units (0.01 mm) as a millimeter decimal with two places.
std::wstring FormatMillimeters(unsigned value) {
  const unsigned hundredths = value % cLengthMultiplier;
  return std::to_wstring(value / cLengthMultiplier) +
         (hundredths < 10 ? L".0" : L".") +
         std::to_wstring(hundredths);
}

// TRotation (0.1 degree) as degrees with one decimal place.
std::wstring FormatDegrees(unsigned short rotation) {
  return std::to_wstring(rotation / 10u) + L"." + std::to_wstring(rotation % 10u);
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

// Balanced BeginUpdate/EndUpdate on a staging collection (IProjects,
// IFormats, ISheets). Optional during LoadFile; it only batches change
// notifications.
template <typename Collection>
class UpdateScope final {
 public:
  explicit UpdateScope(Collection* collection)
      : collection_(SUCCEEDED(collection->BeginUpdate()) ? collection : nullptr) {}
  ~UpdateScope() {
    if (collection_ != nullptr) {
      collection_->EndUpdate();
    }
  }
  UpdateScope(const UpdateScope&) = delete;
  UpdateScope& operator=(const UpdateScope&) = delete;

 private:
  Collection* collection_;
};

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
  // The host activates the plugin only when this equals its own value.
  *result = cEngineVersion;
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetName(BSTR* result) {
  // Unique, ASCII: the host narrows it to an ANSI ShortString.
  return PutBstr(pluginName_, result);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetVersion(TTcpVersion* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  *result = MakeTcpVersion(1, 1, 0, 0);
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
  // Advertise only what is implemented. feSaveResultToFile makes
  // GetPlotterInfo mandatory. Configure is not implemented, so its flag is
  // not set either.
  *result =
    FeatureMask(feImport) |
    FeatureMask(feExport) |
    FeatureMask(feSaveResultToFile) |
    FeatureMask(feAbout);
  return S_OK;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::GetPlotterInfo(ITcPlotterInfo** result) {
  // Never nullptr while a save or plot feature is advertised: the host copies
  // the returned object and disables the plugin on a nil pointer.
  return StarterPlotterInfo::Create(result);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::Initialize(BSTR aRegRoot, int aLanguageId, ITonCut* aTonCut, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }

  // The host never calls Initialize; TcpInitializeV2 does.
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
    return Report(result, cprOK);
  } catch (...) {
    return Report(result, cprException);
  }
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::Finalize(TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  // Called once before unload. Release every host object kept so far.
  if (tonCut_ != nullptr) {
    tonCut_->Release();
    tonCut_ = nullptr;
  }
  return Report(result, cprOK);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::Configure(HWND, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  // Not advertised through feConfigure, so the host never calls it.
  return Report(result, cprNotImplemented);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::About(HWND aWindow, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }

  try {
    if (aWindow != nullptr) {
      ::MessageBoxW(
        aWindow,
        L"CSV import/export plus single-sheet result export (HPGL cutting paths or CSV sheet layout).",
        pluginTitle_.c_str(),
        MB_OK | MB_ICONINFORMATION
      );
    }
    return Report(result, cprOK);
  } catch (...) {
    return Report(result, cprException);
  }
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::LoadConfig(BSTR, BSTR, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  return Report(result, cprOK);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::SaveConfig(BSTR, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  return Report(result, cprOK);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::BackupConfig(BSTR* aBackup, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  if (aBackup == nullptr) {
    return Report(result, cprFailed);
  }
  const HRESULT hr = ReplaceBstr(L"", aBackup);
  return Report(result, SUCCEEDED(hr) ? cprOK : cprFailed);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::RestoreConfig(BSTR, TConfigurationParts, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  return Report(result, cprOK);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::EnumExtensions(TTcpExtensionType aType, ITcEnumExtensionsCallback* aEnumCb, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  if (aEnumCb == nullptr) {
    return Report(result, cprFailed);
  }

  try {
    // Each Invoke adds one file-dialog filter "Name (*ext)|*ext". The
    // extension must include the leading dot.
    auto invoke = [&](const wchar_t* extension, const std::wstring& name) {
      BstrValue ext{std::wstring(extension)};
      BstrValue title(name);
      return (!ext || !title) ? E_OUTOFMEMORY : aEnumCb->Invoke(aType, ext.get(), title.get());
    };

    HRESULT hr = S_OK;
    if (aType == etImport || aType == etExport) {
      hr = invoke(kCsvExtension, pluginTitle_);
    } else if (aType == etExportResults) {
      hr = invoke(kPltExtension, pluginTitle_ + L" - cutting paths (HPGL)");
      hr = SUCCEEDED(hr) ? invoke(kCsvExtension, pluginTitle_ + L" - sheet layout") : hr;
    }
    return Report(result, SUCCEEDED(hr) ? cprOK : cprFailed);
  } catch (...) {
    return Report(result, cprException);
  }
}

HRESULT CsvImportExportPluginBase::ValidateHeader(const std::wstring& fileName, TTcpResult* result) {
  if (!HasExtension(fileName, kCsvExtension)) {
    return Report(result, cprNo);
  }

  std::vector<std::vector<std::wstring>> rows;
  std::wstring error;
  if (!ParseUtf8CsvFile(fileName, rows, error)) {
    return Report(result, cprFailed);
  }

  return Report(result, (!rows.empty() && HasRequiredHeader(rows.front())) ? cprOK : cprNo);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::IsMyFile(BSTR aFileName, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  try {
    return ValidateHeader(FromBstr(aFileName), result);
  } catch (...) {
    return Report(result, cprException);
  }
}

HRESULT CsvImportExportPluginBase::FindOrCreateProject(
  IProjects* projects,
  const std::wstring& title,
  ComPtr<IProject>& project
) {
  // LoadFile receives empty staging collections, so FindByTitle sees only the
  // projects this import already added.
  BstrValue bstrTitle(title);
  if (!bstrTitle) {
    return E_OUTOFMEMORY;
  }
  HRESULT hr = projects->FindByTitle(bstrTitle.get(), project.put());
  if (FAILED(hr) || project) {
    return hr;
  }

  // Plain constructor: no dialog, not inserted until Add.
  hr = projects->CreateProject(project.put());
  if (FAILED(hr) || !project) {
    return FAILED(hr) ? hr : E_FAIL;
  }
  hr = project->SetTitle(bstrTitle.get());
  return SUCCEEDED(hr) ? projects->Add(project.get()) : hr;
}

HRESULT CsvImportExportPluginBase::FindDeviceForKind(TMaterialKind kind, ComPtr<IDevice>& device) {
  // A staged material needs a cutting device from the live ITonCut::Devices;
  // devices added to the LoadFile staging collection are ignored by the host.
  ComPtr<IDevices> devices;
  HRESULT hr = tonCut_->GetDevices(devices.put());
  if (FAILED(hr) || !devices) {
    return FAILED(hr) ? hr : E_FAIL;
  }

  int count = 0;
  hr = devices->GetCount(&count);
  if (FAILED(hr)) {
    return hr;
  }

  for (int i = 0; i < count; ++i) {
    ComPtr<IDevice> candidate;
    hr = devices->GetByIndex(static_cast<unsigned>(i), candidate.put());
    if (FAILED(hr) || !candidate) {
      return FAILED(hr) ? hr : E_FAIL;
    }
    TMaterialKind deviceKind = mkUnknown;
    hr = candidate->GetMaterialKind(&deviceKind);
    if (FAILED(hr)) {
      return hr;
    }
    if (deviceKind == kind || !device) {
      // Keep the first device as a fallback; stop at the first exact match.
      device.reset();
      candidate->AddRef();
      *device.put() = candidate.get();
      if (deviceKind == kind) {
        return S_OK;
      }
    }
  }
  return device ? S_OK : HRESULT_FROM_WIN32(ERROR_NOT_FOUND);
}

HRESULT CsvImportExportPluginBase::FindOrCreateMaterial(
  IMaterials* materials,
  const std::wstring& title,
  TMaterialKind kind,
  unsigned width,
  unsigned thickness,
  ComPtr<IMaterial>& material
) {
  const std::wstring effectiveTitle = title.empty() ? L"CSV Material" : title;
  // Width is significant only for 1D materials; 2D materials use 0.
  const unsigned effectiveWidth = EffectiveMaterialWidth(kind, width);
  BstrValue bstrTitle(effectiveTitle);
  if (!bstrTitle) {
    return E_OUTOFMEMORY;
  }

  // Exact, case-sensitive match on title, kind, width and thickness within
  // the staging collection of this LoadFile call.
  HRESULT hr = materials->FindByTitle(
    bstrTitle.get(),
    kind,
    effectiveWidth,
    thickness,
    material.put());
  if (FAILED(hr) || material) {
    return hr;
  }

  ComPtr<IDevice> device;
  hr = FindDeviceForKind(kind, device);
  if (FAILED(hr)) {
    return hr;
  }

  // Plain constructor: no dialog, not inserted until Add. Never use
  // ITonCut::CreateMaterial here: it opens a dialog and commits to the live
  // database immediately.
  hr = materials->CreateMaterial(material.put());
  if (FAILED(hr) || !material) {
    return FAILED(hr) ? hr : E_FAIL;
  }
  hr = material->SetTitle(bstrTitle.get());
  hr = SUCCEEDED(hr) ? material->SetKind(kind) : hr;
  hr = SUCCEEDED(hr) ? material->SetWidth(effectiveWidth) : hr;
  hr = SUCCEEDED(hr) ? material->SetThickness(thickness) : hr;
  hr = SUCCEEDED(hr) ? material->SetDevice(device.get()) : hr;
  return SUCCEEDED(hr) ? materials->Add(material.get()) : hr;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::LoadFile(HWND, BSTR aFileName, IDevices*, IMaterials* aMaterials, IBands*, IProjects* aProjects, IFormats* aFormats, ISheets* aSheets, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  try {
  if (aMaterials == nullptr || aProjects == nullptr || aFormats == nullptr || aSheets == nullptr) {
    return Report(result, cprFailed);
  }
  if (tonCut_ == nullptr) {
    return Report(result, cprNotInitialized);
  }

  const std::wstring fileName = FromBstr(aFileName);
  TTcpResult headerResult = cprFailed;
  ValidateHeader(fileName, &headerResult);
  if (headerResult != cprOK) {
    return Report(result, cprFailed);
  }

  std::vector<std::vector<std::wstring>> rows;
  std::wstring error;
  if (!ParseUtf8CsvFile(fileName, rows, error)) {
    return Report(result, cprFailed);
  }

  std::vector<CsvRowRecord> records;
  if (!DecodeCsvRows(rows, records, error)) {
    return Report(result, cprFailed);
  }

  // Without projects mode the host assigns every piece to its single flat
  // project, so the CSV ProjectTitle is used only when projects are on.
  DelphiBool usingProjects = 0;
  if (FAILED(tonCut_->GetUsingProjects(&usingProjects))) {
    return Report(result, cprFailed);
  }

  UpdateScope<IProjects> projectsUpdate(aProjects);
  UpdateScope<IFormats> formatsUpdate(aFormats);
  UpdateScope<ISheets> sheetsUpdate(aSheets);

  for (const CsvRowRecord& record : records) {
    // CSV sizes are millimeters; TonCut lengths are 0.01 mm.
    unsigned materialWidth = 0;
    unsigned materialThickness = 0;
    unsigned length = 0;
    unsigned width = 0;
    if (!TryFromCsvMillimeters(record.materialWidth, materialWidth) ||
        !TryFromCsvMillimeters(record.materialThickness, materialThickness) ||
        !TryFromCsvMillimeters(record.length, length) ||
        !TryFromCsvMillimeters(record.width, width)) {
      return Report(result, cprFailed);
    }
    const bool isSheet = _wcsicmp(record.recordType.c_str(), L"SHEET") == 0;
    if (isSheet && record.quantity > static_cast<unsigned>((std::numeric_limits<int>::max)())) {
      return Report(result, cprFailed);
    }

    ComPtr<IMaterial> material;
    HRESULT hr = FindOrCreateMaterial(
      aMaterials,
      record.materialTitle,
      record.materialKind,
      materialWidth,
      materialThickness,
      material);
    if (FAILED(hr) || !material) {
      return Report(result, cprFailed);
    }

    BstrValue identifier(record.identifier);
    BstrValue description(record.description);
    if (!identifier || !description) {
      return Report(result, cprFailed);
    }

    if (!isSheet) {
      ComPtr<IProject> project;
      if (usingProjects != 0 && !record.projectTitle.empty()) {
        hr = FindOrCreateProject(aProjects, record.projectTitle, project);
        if (FAILED(hr) || !project) {
          return Report(result, cprFailed);
        }
      }
      // With projects on and no project, the host creates one named after
      // the imported file.

      ComPtr<IFormat> format;
      hr = aFormats->CreateFormat(format.put());
      if (FAILED(hr) || !format) {
        return Report(result, cprFailed);
      }

      // A 1D piece always has the width of its bar material.
      const unsigned pieceWidth = record.materialKind == mk1D ? materialWidth : width;
      hr = project ? format->SetProject(project.get()) : S_OK;
      hr = SUCCEEDED(hr) ? format->SetMaterial(material.get()) : hr;
      hr = SUCCEEDED(hr) ? format->SetLength(length) : hr;
      hr = SUCCEEDED(hr) ? format->SetWidth(pieceWidth) : hr;
      hr = SUCCEEDED(hr) ? format->SetQuantity(record.quantity) : hr;
      hr = SUCCEEDED(hr) ? format->SetIdentifier(identifier.get()) : hr;
      hr = SUCCEEDED(hr) ? format->SetDescription(description.get()) : hr;
      hr = SUCCEEDED(hr) ? aFormats->Add(format.get()) : hr;
      if (FAILED(hr)) {
        return Report(result, cprFailed);
      }
    } else {
      ComPtr<ISheet> sheet;
      hr = aSheets->CreateSheet(sheet.put());
      if (FAILED(hr) || !sheet) {
        return Report(result, cprFailed);
      }

      hr = sheet->SetMaterial(material.get());
      hr = SUCCEEDED(hr) ? sheet->SetLength(length) : hr;
      hr = SUCCEEDED(hr) ? sheet->SetWidth(width) : hr;
      hr = SUCCEEDED(hr) ? sheet->SetQuantity(static_cast<int>(record.quantity)) : hr;
      hr = SUCCEEDED(hr) ? sheet->SetIdentifier(identifier.get()) : hr;
      hr = SUCCEEDED(hr) ? sheet->SetDescription(description.get()) : hr;
      hr = SUCCEEDED(hr) ? aSheets->Add(sheet.get()) : hr;
      if (FAILED(hr)) {
        return Report(result, cprFailed);
      }
    }
  }

  // The host now shows its Import dialog and merges the staged data.
  return Report(result, cprOK);
  } catch (...) {
    return Report(result, cprException);
  }
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::SaveFile(HWND, BSTR aFileName, IFormats* aFormats, ISheets* aSheets, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  try {
  if (aFormats == nullptr || aSheets == nullptr) {
    return Report(result, cprFailed);
  }

  // aFormats and aSheets are the live collections: read only.
  std::vector<CsvRowRecord> records;
  int formatCount = 0;
  int sheetCount = 0;
  HRESULT hr = aFormats->GetCount(&formatCount);
  if (FAILED(hr)) {
    return Report(result, cprFailed);
  }

  for (int i = 0; i < formatCount; ++i) {
    ComPtr<IFormat> format;
    hr = aFormats->GetByIndex(static_cast<unsigned>(i), format.put());
    if (FAILED(hr) || !format) {
      return Report(result, cprFailed);
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
      return Report(result, cprFailed);
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
      return Report(result, cprFailed);
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

  std::wstring sheetLines;
  hr = aSheets->GetCount(&sheetCount);
  if (FAILED(hr)) {
    return Report(result, cprFailed);
  }

  for (int i = 0; i < sheetCount; ++i) {
    ComPtr<ISheet> sheet;
    hr = aSheets->GetByIndex(static_cast<unsigned>(i), sheet.put());
    if (FAILED(hr) || !sheet) {
      return Report(result, cprFailed);
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
      return Report(result, cprFailed);
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
      return Report(result, cprFailed);
    }

    // ISheet::GetQuantity is a signed Integer: write it unchanged. On import a
    // missing, invalid (negative included) or zero Quantity becomes 1.
    sheetLines += EncodeCsvLine({
      L"SHEET",
      L"",
      FromBstr(materialTitle.get()),
      MaterialKindToText(materialKind),
      std::to_wstring(ToCsvMillimeters(EffectiveMaterialWidth(materialKind, materialWidth))),
      std::to_wstring(ToCsvMillimeters(materialThickness)),
      std::to_wstring(ToCsvMillimeters(length)),
      std::to_wstring(ToCsvMillimeters(width)),
      std::to_wstring(quantity),
      FromBstr(identifier.get()),
      FromBstr(description.get())
    }) + L"\r\n";
  }

  std::wstring error;
  if (!WriteUtf8CsvFile(FromBstr(aFileName), EncodeCsvRows(records) + sheetLines, error)) {
    return Report(result, cprFailed);
  }

  return Report(result, cprOK);
  } catch (...) {
    return Report(result, cprException);
  }
}

bool CsvImportExportPluginBase::ExportSolutionSheetAsPlt(
  ISolutionSheet* solutionSheet,
  std::vector<std::string>& commands
) {
  // SolutionCuts are already in the effective output frame (sheet and
  // plotter rotation and mirror applied by the host). Do not pass them
  // through CalcPoint/CalcPointF; only scale 0.01 mm to HPGL units.
  ComPtr<ISolutionCuts> solutionCuts;
  HRESULT hr = solutionSheet->GetSolutionCuts(solutionCuts.put());
  if (FAILED(hr) || !solutionCuts) {
    return false;
  }

  int cutCount = 0;
  hr = solutionCuts->GetCount(&cutCount);
  if (FAILED(hr)) {
    return false;
  }

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
    int posX = 0;
    int posY = 0;
    int tarX = 0;
    int tarY = 0;
    hr = cut->GetKind(&kind);
    hr = SUCCEEDED(hr) ? cut->GetPosX(&posX) : hr;
    hr = SUCCEEDED(hr) ? cut->GetPosY(&posY) : hr;
    hr = SUCCEEDED(hr) ? cut->GetTarX(&tarX) : hr;
    hr = SUCCEEDED(hr) ? cut->GetTarY(&tarY) : hr;
    if (FAILED(hr)) {
      return false;
    }

    AppendMoveCommand(commands, "PU", ToPlotterUnit(posX), ToPlotterUnit(posY));

    if (kind == ckCurve) {
      // Cubic Bezier: start, two control points, end.
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

      AppendBezierCommand(
        commands,
        ToPlotterUnit(posXp),
        ToPlotterUnit(posYp),
        ToPlotterUnit(tarXp),
        ToPlotterUnit(tarYp),
        ToPlotterUnit(tarX),
        ToPlotterUnit(tarY)
      );
    } else {
      AppendMoveCommand(commands, "PD", ToPlotterUnit(tarX), ToPlotterUnit(tarY));
    }
  }

  commands.push_back("PU;");
  commands.push_back("SP0;");
  return true;
}

bool CsvImportExportPluginBase::ExportSolutionSheetLayout(
  ISolutionSheet* solutionSheet,
  std::wstring& content
) {
  // One layout (one ISolutionSheet) is cut SheetQuantity times: the parts and
  // waste rows describe one sheet, so totals are rows x SheetQuantity.
  // X/Y are in the native sheet frame (origin at sheet corner (0,0), X along
  // the sheet length, Y along its width, before output rotation or mirror);
  // map them with CalcPoint only if a consumer needs the output frame.
  ComPtr<ISheet> sheet;
  ComPtr<IMaterial> material;
  ComPtr<ISolutionFormats> parts;
  ComPtr<ISolutionWastes> wastes;
  int sheetIndex = 0;
  int sheetQuantity = 0;
  unsigned sheetLength = 0;
  unsigned sheetWidth = 0;
  BstrValue sheetIdentifier;
  BstrValue sheetDescription;
  BstrValue materialTitle;

  HRESULT hr = solutionSheet->GetSheet(sheet.put());
  hr = SUCCEEDED(hr) ? solutionSheet->GetIndex(&sheetIndex) : hr;
  hr = SUCCEEDED(hr) ? solutionSheet->GetQuantity(&sheetQuantity) : hr;
  hr = SUCCEEDED(hr) ? solutionSheet->GetSolutionFormats(parts.put()) : hr;
  hr = SUCCEEDED(hr) ? solutionSheet->GetSolutionWastes(wastes.put()) : hr;
  if (FAILED(hr) || !sheet || !parts || !wastes) {
    return false;
  }
  hr = sheet->GetLength(&sheetLength);
  hr = SUCCEEDED(hr) ? sheet->GetWidth(&sheetWidth) : hr;
  hr = SUCCEEDED(hr) ? sheet->GetIdentifier(sheetIdentifier.put()) : hr;
  hr = SUCCEEDED(hr) ? sheet->GetDescription(sheetDescription.put()) : hr;
  hr = SUCCEEDED(hr) ? sheet->GetMaterial(material.put()) : hr;
  if (SUCCEEDED(hr) && material) {
    hr = material->GetTitle(materialTitle.put());
  }
  if (FAILED(hr)) {
    return false;
  }

  const std::wstring index = std::to_wstring(sheetIndex);
  const std::wstring quantity = std::to_wstring(sheetQuantity);
  const std::wstring materialName = FromBstr(materialTitle.get());
  content = EncodeCsvLine({
    L"RecordType", L"SheetIndex", L"SheetQuantity", L"MaterialTitle",
    L"X", L"Y", L"Length", L"Width", L"Rotation", L"Mirrored",
    L"Identifier", L"Description"
  }) + L"\r\n";
  content += EncodeCsvLine({
    L"SHEET", index, quantity, materialName,
    FormatMillimeters(0), FormatMillimeters(0),
    FormatMillimeters(sheetLength), FormatMillimeters(sheetWidth), L"", L"",
    FromBstr(sheetIdentifier.get()), FromBstr(sheetDescription.get())
  }) + L"\r\n";

  int partCount = 0;
  hr = parts->GetCount(&partCount);
  if (FAILED(hr)) {
    return false;
  }
  for (int i = 0; i < partCount; ++i) {
    ComPtr<ISolutionFormat> part;
    ComPtr<IFormat> format;
    unsigned x = 0;
    unsigned y = 0;
    unsigned short rotation = 0;
    DelphiBool mirrored = 0;
    unsigned length = 0;
    unsigned width = 0;
    BstrValue identifier;
    BstrValue description;
    hr = parts->GetByIndex(static_cast<unsigned>(i), part.put());
    if (FAILED(hr) || !part) {
      return false;
    }
    hr = part->GetFormat(format.put());
    hr = SUCCEEDED(hr) ? part->GetX(&x) : hr;
    hr = SUCCEEDED(hr) ? part->GetY(&y) : hr;
    hr = SUCCEEDED(hr) ? part->GetRotation(&rotation) : hr;
    hr = SUCCEEDED(hr) ? part->GetMirrored(&mirrored) : hr;
    if (FAILED(hr) || !format) {
      return false;
    }
    // X/Y: lower corner of the placed footprint's bounding box.
    // Length/Width: the piece as entered, before rotation.
    hr = format->GetLength(&length);
    hr = SUCCEEDED(hr) ? format->GetWidth(&width) : hr;
    hr = SUCCEEDED(hr) ? format->GetIdentifier(identifier.put()) : hr;
    hr = SUCCEEDED(hr) ? format->GetDescription(description.put()) : hr;
    if (FAILED(hr)) {
      return false;
    }
    content += EncodeCsvLine({
      L"PART", index, quantity, materialName,
      FormatMillimeters(x), FormatMillimeters(y),
      FormatMillimeters(length), FormatMillimeters(width),
      FormatDegrees(rotation), mirrored != 0 ? L"1" : L"0",
      FromBstr(identifier.get()), FromBstr(description.get())
    }) + L"\r\n";
  }

  int wasteCount = 0;
  hr = wastes->GetCount(&wasteCount);
  if (FAILED(hr)) {
    return false;
  }
  for (int i = 0; i < wasteCount; ++i) {
    // All waste pieces, reusable or not, as rectangles along X/Y.
    ComPtr<ISolutionWaste> waste;
    unsigned x = 0;
    unsigned y = 0;
    unsigned length = 0;
    unsigned width = 0;
    BstrValue identifier;
    hr = wastes->GetByIndex(static_cast<unsigned>(i), waste.put());
    if (FAILED(hr) || !waste) {
      return false;
    }
    hr = waste->GetX(&x);
    hr = SUCCEEDED(hr) ? waste->GetY(&y) : hr;
    hr = SUCCEEDED(hr) ? waste->GetLength(&length) : hr;
    hr = SUCCEEDED(hr) ? waste->GetWidth(&width) : hr;
    hr = SUCCEEDED(hr) ? waste->GetIdentifier(identifier.put()) : hr;
    if (FAILED(hr)) {
      return false;
    }
    content += EncodeCsvLine({
      L"WASTE", index, quantity, materialName,
      FormatMillimeters(x), FormatMillimeters(y),
      FormatMillimeters(length), FormatMillimeters(width), L"", L"",
      FromBstr(identifier.get()), L""
    }) + L"\r\n";
  }
  return true;
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::SaveResult(HWND, BSTR aFileName, ISolutionSheet* aSolutionSheet, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  try {
  if (aSolutionSheet == nullptr) {
    return Report(result, cprFailed);
  }

  // The host appends the chosen filter's extension when the user typed none.
  const std::wstring fileName = FromBstr(aFileName);
  bool written = false;
  if (HasExtension(fileName, kCsvExtension)) {
    std::wstring content;
    std::wstring error;
    written = ExportSolutionSheetLayout(aSolutionSheet, content) &&
              WriteUtf8CsvFile(fileName, content, error);
  } else {
    std::vector<std::string> commands;
    written = ExportSolutionSheetAsPlt(aSolutionSheet, commands) &&
              WriteAsciiLines(fileName, commands);
  }
  if (!written) {
    return Report(result, cprFailed);
  }

  // Mark the page as saved: "Save one" and the next-unsaved selection read it.
  const HRESULT hr = aSolutionSheet->SetIsSaved(1);
  if (FAILED(hr)) {
    return Report(result, cprFailed);
  }

  return Report(result, cprOK);
  } catch (...) {
    return Report(result, cprException);
  }
}

// The callbacks below are not advertised in GetFeatures, so the host never
// calls them. They still return a valid result.
HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::BatchSaveResult(HWND, TTcpSaveTarget, BSTR, ISolution*, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  return Report(result, cprNotImplemented);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::Plot(HWND, ISolutionSheet*, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  return Report(result, cprNotImplemented);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::BatchPlot(HWND, ISolution*, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  return Report(result, cprNotImplemented);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::SavePlot(HWND, BSTR, ISolutionSheet*, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  return Report(result, cprNotImplemented);
}

HRESULT STDMETHODCALLTYPE CsvImportExportPluginBase::BatchSavePlot(HWND, TTcpSaveTarget, BSTR, ISolution*, TTcpResult* result) {
  if (result == nullptr) {
    return E_POINTER;
  }
  return Report(result, cprNotImplemented);
}

}  // namespace toncut
