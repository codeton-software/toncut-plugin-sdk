#pragma once

#include <Unknwn.h>
#include <OleAuto.h>
#include <Windows.h>

#include <cstdint>
#include <string>

// TonCut's Delphi Win32 plugins use quad-word record alignment.
// Keep the translated native SDK view on the same packing boundary.
#pragma pack(push, 8)

namespace toncut {

using TTcpVersion = std::uint64_t;
using TTcpFeatures = std::uint16_t;
using TConfigurationParts = std::uint8_t;
using DelphiBool = unsigned char;
using TDateTime = double;
using TTcPrice = double;
using TTcWeight = double;
using TOrnaments = std::uint8_t;
using TMirrors = std::uint8_t;

static_assert(sizeof(void*) == 4, "TonCut plugin ABI requires a Win32 target");
static_assert(sizeof(int) == 4, "Delphi Integer ABI must remain four bytes");
static_assert(sizeof(unsigned) == 4, "Delphi Cardinal ABI must remain four bytes");
static_assert(sizeof(unsigned short) == 2, "Delphi Word ABI must remain two bytes");
static_assert(sizeof(float) == 4, "Delphi Single ABI must remain four bytes");
static_assert(sizeof(double) == 8, "Delphi Double ABI must remain eight bytes");
static_assert(sizeof(DelphiBool) == 1, "Delphi Boolean ABI must remain one byte");
static_assert(sizeof(TTcpVersion) == 8, "Delphi UInt64 ABI must remain eight bytes");
static_assert(sizeof(TTcpFeatures) == 2, "Delphi TTcpFeatures set ABI must remain two bytes");
static_assert(sizeof(TConfigurationParts) == 1, "Delphi TConfigurationParts set ABI must remain one byte");
static_assert(sizeof(TDateTime) == 8, "Delphi TDateTime ABI must remain eight bytes");
static_assert(sizeof(TTcPrice) == 8, "Delphi TTcPrice ABI must remain eight bytes");
static_assert(sizeof(TTcWeight) == 8, "Delphi TTcWeight ABI must remain eight bytes");
static_assert(sizeof(TOrnaments) == 1, "Delphi TOrnaments set ABI must remain one byte");
static_assert(sizeof(TMirrors) == 1, "Delphi TMirrors set ABI must remain one byte");

constexpr int cEngineVersion = 23;
constexpr unsigned cLengthMultiplier = 100;

enum TTcpResult : std::uint8_t {
  cprFailed = 0,
  cprOK = 1,
  cprNotImplemented = 2,
  cprException = 3,
  cprNothing = 4,
  cprNotInitialized = 5,
  cprMoreData = 6,
  cprCancel = 7,
  cprMaybe = 8,
  cprNo = 9
};

enum TTcpExtensionType : std::uint8_t {
  etImport = 0,
  etExport = 1,
  etExportResults = 2
};

enum TTcpSaveTarget : std::uint8_t {
  stFile = 0,
  stFolder = 1
};

enum TTcpFeature : std::uint8_t {
  feImport = 0,
  feExport = 1,
  feSaveResultToFile = 2,
  feBatchSaveResultToFile = 3,
  feBatchSaveResultToFolder = 4,
  fePlot = 5,
  feBatchPlot = 6,
  feSavePlotToFile = 7,
  feBatchSavePlotToFile = 8,
  feBatchSavePlotToFolder = 9,
  feConfigure = 10,
  feAbout = 11
};

enum TMaterialKind : std::uint8_t {
  mkUnknown = 0,
  mk1D = 1,
  mk2D = 2
};

enum TUnits : std::uint8_t {
  uMillimeters = 0,
  uCentimeters = 1,
  uInches = 2
};

enum TPieceIdentification : std::uint8_t {
  piDescriptionOnly = 0,
  piIdentifierAndDescription = 1,
  piBarcodeAndDescription = 2
};

enum TOrnament : std::uint8_t {
  oNone = 0,
  oByWidth = 1,
  oByLength = 2
};

enum TCutKind : std::uint8_t {
  ckLine = 0,
  ckCurve = 1
};

static_assert(sizeof(TTcpResult) == 1, "Delphi TTcpResult enum ABI must remain one byte");
static_assert(sizeof(TTcpExtensionType) == 1, "Delphi TTcpExtensionType enum ABI must remain one byte");
static_assert(sizeof(TTcpSaveTarget) == 1, "Delphi TTcpSaveTarget enum ABI must remain one byte");
static_assert(sizeof(TTcpFeature) == 1, "Delphi TTcpFeature enum ABI must remain one byte");
static_assert(sizeof(TMaterialKind) == 1, "Delphi TMaterialKind enum ABI must remain one byte");
static_assert(sizeof(TUnits) == 1, "Delphi TUnits enum ABI must remain one byte");
static_assert(sizeof(TPieceIdentification) == 1, "Delphi TPieceIdentification enum ABI must remain one byte");
static_assert(sizeof(TOrnament) == 1, "Delphi TOrnament enum ABI must remain one byte");
static_assert(sizeof(TCutKind) == 1, "Delphi TCutKind enum ABI must remain one byte");

inline TTcpVersion MakeTcpVersion(
  std::uint16_t major,
  std::uint16_t minor,
  std::uint16_t build,
  std::uint16_t revision
) {
  return (static_cast<TTcpVersion>(major) << 48) |
         (static_cast<TTcpVersion>(minor) << 32) |
         (static_cast<TTcpVersion>(build) << 16) |
         static_cast<TTcpVersion>(revision);
}

inline TTcpFeatures FeatureMask(TTcpFeature value) {
  return static_cast<TTcpFeatures>(1u << static_cast<unsigned>(value));
}

class BstrValue {
 public:
  BstrValue() = default;
  explicit BstrValue(const std::wstring& value)
      : value_(::SysAllocStringLen(value.data(), static_cast<UINT>(value.size()))) {}

  ~BstrValue() {
    reset();
  }

  BstrValue(const BstrValue&) = delete;
  BstrValue& operator=(const BstrValue&) = delete;

  BSTR get() const { return value_; }
  explicit operator bool() const { return value_ != nullptr; }

  BSTR* put() {
    reset();
    return &value_;
  }

  void reset() {
    if (value_ != nullptr) {
      ::SysFreeString(value_);
      value_ = nullptr;
    }
  }

  BSTR release() {
    BSTR tmp = value_;
    value_ = nullptr;
    return tmp;
  }

 private:
  BSTR value_ = nullptr;
};

template <typename T>
class ComPtr {
 public:
  ComPtr() = default;
  ComPtr(const ComPtr&) = delete;
  ComPtr& operator=(const ComPtr&) = delete;

  ~ComPtr() {
    reset();
  }

  T* get() const { return value_; }
  T** put() {
    reset();
    return &value_;
  }
  T* operator->() const { return value_; }
  explicit operator bool() const { return value_ != nullptr; }

  void reset() {
    if (value_ != nullptr) {
      value_->Release();
      value_ = nullptr;
    }
  }

 private:
  T* value_ = nullptr;
};

inline std::wstring FromBstr(BSTR value) {
  if (value == nullptr) {
    return L"";
  }
  return std::wstring(value, value + ::SysStringLen(value));
}

struct ITcEnumExtensionsCallback : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE Invoke(
    TTcpExtensionType aType,
    BSTR aExtension,
    BSTR aName
  ) = 0;
};

// Exact interface pointer types that are not otherwise projected expose only
// their universal IUnknown prefix. This keeps ownership operations usable
// without guessing any Pascal slots beyond IUnknown.
struct IDevice : IUnknown {};
struct IDevices : IUnknown {};
struct IBand : IUnknown {};
struct IBands : IUnknown {};
struct IProject;
struct IProjects;
struct IMaterial;
struct IMaterials;
struct IFormat;
struct IFormats;
struct IResults : IUnknown {};
struct IShape : IUnknown {};
struct ISheet;
struct ISheetDefect : IUnknown {};
struct ISheets;
struct IStandardSheet : IUnknown {};
struct ITemplates : IUnknown {};
struct INotifyEvent : IUnknown {};
struct IProjectChangeEvent : IUnknown {};
struct IMaterialChangeEvent : IUnknown {};
struct ITcPlotterInfo : IUnknown {};
struct ISolution;
struct ISolutionCut;
struct ISolutionCuts;
struct ISolutionFormats : IUnknown {};
struct ISolutionSheet;
struct ISolutionWastes : IUnknown {};

struct ITonCut : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetUnits(TUnits* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPrecision(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPieceIdentification(TPieceIdentification* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDevices(IDevices** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaterials(IMaterials** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetBands(IBands** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSheets(ISheets** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTemplates(ITemplates** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetProjects(IProjects** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetFormats(IFormats** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetResults(IResults** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSolution(ISolution** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetUsingProjects(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSelectedProject(IProject** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CreateSolution() = 0;
  virtual HRESULT STDMETHODCALLTYPE ReleaseSolution() = 0;
  virtual HRESULT STDMETHODCALLTYPE CreateMaterial(BSTR aTitle, TMaterialKind aKind, unsigned aWidth, unsigned aThickness, IMaterial** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CreateBand(BSTR aTitle, unsigned aWidth, unsigned aThickness, unsigned aMaterialThickness, unsigned aSurplus, IBand** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CreateProject(BSTR aTitle, IProject** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CanCutAnyShapes(IDevice* aDevice, DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FormatLengthFromInt(int aValue, DelphiBool aShort, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FormatLengthFromExtended(double aValue, DelphiBool aShort, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE HumanReadableLength(double aValue, DelphiBool aShort, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FormatField(std::int64_t aValue, DelphiBool aShort, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE HumanReadableFieldFromInt64(std::int64_t aValue, DelphiBool aShort, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE HumanReadableFieldFromExtended(double aValue, DelphiBool aShort, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FormatDegrees(double aAngle, DelphiBool aShort, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FormatRadians(double aAngle, DelphiBool aShort, BSTR* result) = 0;
};

struct IMaterial : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetId(std::int64_t* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetId(std::int64_t value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTitle(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetTitle(BSTR value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetKind(TMaterialKind* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetKind(TMaterialKind value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetWidth(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetWidth(unsigned value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetThickness(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetThickness(unsigned value) = 0;
};

struct IProject : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetId(std::int64_t* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetId(std::int64_t value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTitle(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetTitle(BSTR value) = 0;
};

struct IFormat : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetId(std::int64_t* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetId(std::int64_t value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetProject(IProject** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetProject(IProject* value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetLength(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetLength(unsigned value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetWidth(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetWidth(unsigned value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetQuantity(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetQuantity(unsigned value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetProcessedQuantity(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetProcessedQuantity(unsigned value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOrnament(TOrnaments* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetOrnament(TOrnaments value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetIdentifier(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetIdentifier(BSTR value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDescription(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetDescription(BSTR value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetShape(IShape** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetShape(IShape* value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetRotationStep(unsigned short* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetRotationStep(unsigned short value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetRotation(unsigned short* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetRotation(unsigned short value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMirror(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMirror(DelphiBool value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaterial(IMaterial** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaterial(IMaterial* value) = 0;
};

struct ISheet : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetId(std::int64_t* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetId(std::int64_t value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetWidth(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetWidth(unsigned value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetLength(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetLength(unsigned value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetQuantity(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetQuantity(int value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetStackSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetStackSize(unsigned value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOrnament(TOrnament* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetOrnament(TOrnament value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetIdentifier(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetIdentifier(BSTR value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDescription(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetDescription(BSTR value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaterial(IMaterial** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaterial(IMaterial* value) = 0;
};

struct IProjects : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE CreateProject(IProject** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Add(IProject* value) = 0;
  virtual HRESULT STDMETHODCALLTYPE DeleteByIndex(unsigned value) = 0;
  virtual HRESULT STDMETHODCALLTYPE DeleteById(std::int64_t value) = 0;
  virtual HRESULT STDMETHODCALLTYPE Remove(IProject* value) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfByObject(IProject* value, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfById(std::int64_t value, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FindDuplicate(IProject* value, DelphiBool aCheckTitle, IProject** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FindByTitle(BSTR value, IProject** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FindUniqueName(BSTR aBaseName, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CheckUniqueName(BSTR aTitle, IProject* aIgnoreProject, DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CheckUniqueNameByProject(IProject* aProject, DelphiBool aAutoFix, DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCount(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetByIndex(unsigned value, IProject** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetById(std::int64_t value, IProject** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnAdd(IProjectChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnRemove(IProjectChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnChange(INotifyEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Load(TDateTime aStartDate, DelphiBool aIncludeCanceled, DelphiBool aIncludeDeleted) = 0;
  virtual HRESULT STDMETHODCALLTYPE Reload() = 0;
  virtual HRESULT STDMETHODCALLTYPE BeginUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE EndUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE IsUpdating(DelphiBool* result) = 0;
};

struct IMaterials : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE CreateMaterial(IMaterial** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CreateStandardSheet(IStandardSheet** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Add(IMaterial* value) = 0;
  virtual HRESULT STDMETHODCALLTYPE DeleteByIndex(unsigned value) = 0;
  virtual HRESULT STDMETHODCALLTYPE DeleteById(std::int64_t value) = 0;
  virtual HRESULT STDMETHODCALLTYPE Remove(IMaterial* value) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfByObject(IMaterial* value, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfById(std::int64_t value, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FindDuplicate(IMaterial* value, DelphiBool aCheckTitle, IMaterial** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FindByTitle(BSTR title, TMaterialKind kind, unsigned width, unsigned thickness, IMaterial** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FindUniqueName(BSTR aBaseName, TMaterialKind aKind, unsigned aWidth, unsigned aThickness, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CheckUniqueName(BSTR aTitle, TMaterialKind aKind, unsigned aWidth, unsigned aThickness, IMaterial* aIgnoreMaterial, DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CheckUniqueNameByMaterial(IMaterial* aMaterial, DelphiBool aAutoFix, DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCount(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetByIndex(unsigned value, IMaterial** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetById(std::int64_t value, IMaterial** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnAdd(IMaterialChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnRemove(IMaterialChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Reload() = 0;
};

struct IFormats : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE Assign(IFormats* value) = 0;
  virtual HRESULT STDMETHODCALLTYPE Clear() = 0;
  virtual HRESULT STDMETHODCALLTYPE Reload() = 0;
  virtual HRESULT STDMETHODCALLTYPE CreateFormat(IFormat** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Add(IFormat* value) = 0;
  virtual HRESULT STDMETHODCALLTYPE DeleteByIndex(unsigned value) = 0;
  virtual HRESULT STDMETHODCALLTYPE DeleteById(std::int64_t value) = 0;
  virtual HRESULT STDMETHODCALLTYPE Remove(IFormat* value) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfByObject(IFormat* value, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfById(std::int64_t value, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfByList(std::int64_t* list, int listHigh, IMaterial* material, unsigned length, unsigned width, TOrnament ornament, DelphiBool* rotated, int* listIndex, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfByOther(IFormat* other, std::int64_t skipId, DelphiBool* rotated, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Find(unsigned length, unsigned width, DelphiBool* rotated, IFormat** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCount(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetByIndex(unsigned value, IFormat** result) = 0;
};

struct ISheets : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE CreateSheet(ISheet** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Add(ISheet* value) = 0;
  virtual HRESULT STDMETHODCALLTYPE DeleteByIndex(unsigned value) = 0;
  virtual HRESULT STDMETHODCALLTYPE DeleteById(std::int64_t value) = 0;
  virtual HRESULT STDMETHODCALLTYPE Remove(ISheet* value) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfByObject(ISheet* value, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfById(std::int64_t value, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfByOther(ISheet* other, std::int64_t skipId, DelphiBool* rotated, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CreateDefect(ISheetDefect** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCount(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetByIndex(unsigned value, ISheet** result) = 0;
};

struct ISolutionCut : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetKind(TCutKind* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPosX(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPosY(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTarX(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTarY(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPosXp(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPosYp(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTarXp(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTarYp(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetNeedShift(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CalcLength(double* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetShiftDistance(int* result) = 0;
};

struct ISolutionCuts : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetCount(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetByIndex(unsigned value, ISolutionCut** result) = 0;
};

struct ISolutionSheet : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetSheet(ISheet** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSolutionFormats(ISolutionFormats** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSolutionWastes(ISolutionWastes** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSolutionCuts(ISolutionCuts** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetQuantity(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTechnologicalWasteField(std::int64_t* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEdgingWasteField(std::int64_t* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetKerfWasteField(std::int64_t* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetIndex(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetRotation(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMirror(TMirrors* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetIsSaved(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetIsSaved(DelphiBool aSaved) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetIsPlotted(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetIsPlotted(DelphiBool aPlotted) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEffectiveModificator(
    int* aRotation,
    TMirrors* aMirror
  ) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOriginPoint(int* aX, int* aY) = 0;
  virtual HRESULT STDMETHODCALLTYPE CalcPoint(int* aX, int* aY) = 0;
  virtual HRESULT STDMETHODCALLTYPE UnCalcPoint(int* aX, int* aY) = 0;
  virtual HRESULT STDMETHODCALLTYPE CalcPointF(double* aX, double* aY) = 0;
  virtual HRESULT STDMETHODCALLTYPE UnCalcPointF(double* aX, double* aY) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDirection(int* aX, int* aY) = 0;
  virtual HRESULT STDMETHODCALLTYPE CalcEffectiveLayout(
    unsigned* aLength,
    unsigned* aWidth,
    unsigned* aMarginLeft,
    unsigned* aMarginTop,
    unsigned* aMarginRight,
    unsigned* aMarginBottom
  ) = 0;
};

struct ISolution : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetCount(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetByIndex(unsigned value, ISolutionSheet** result) = 0;
};

struct ITcPlugin : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetEngineVersion(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetName(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetVersion(TTcpVersion* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTitle(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetProfessional(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetRegRoot(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetLanguageId(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetLanguageId(int value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetUiScale(float* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetUiScale(float value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTonCut(ITonCut** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetFeatures(TTcpFeatures* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPlotterInfo(ITcPlotterInfo** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Initialize(BSTR aRegRoot, int aLanguageId, ITonCut* aTonCut, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Finalize(TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Configure(HWND aWindow, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE About(HWND aWindow, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE LoadConfig(BSTR aKey, BSTR aVersion, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SaveConfig(BSTR aKey, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE BackupConfig(BSTR* aBackup, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE RestoreConfig(BSTR aBackup, TConfigurationParts aScope, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE EnumExtensions(TTcpExtensionType aType, ITcEnumExtensionsCallback* aEnumCb, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE IsMyFile(BSTR aFileName, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE LoadFile(HWND aWindow, BSTR aFileName, IDevices* aDevices, IMaterials* aMaterials, IBands* aBands, IProjects* aProjects, IFormats* aFormats, ISheets* aSheets, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SaveFile(HWND aWindow, BSTR aFileName, IFormats* aFormats, ISheets* aSheets, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SaveResult(HWND aWindow, BSTR aFileName, ISolutionSheet* aSolutionSheet, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE BatchSaveResult(HWND aWindow, TTcpSaveTarget aSaveTarget, BSTR aPath, ISolution* aSolution, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Plot(HWND aWindow, ISolutionSheet* aSolutionSheet, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE BatchPlot(HWND aWindow, ISolution* aSolution, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SavePlot(HWND aWindow, BSTR aFileName, ISolutionSheet* aSolutionSheet, TTcpResult* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE BatchSavePlot(HWND aWindow, TTcpSaveTarget aSaveTarget, BSTR aPath, ISolution* aSolution, TTcpResult* result) = 0;
};

// Delphi calls TcpInitializeV2 as a function returning an interface, which
// means native exports must accept the hidden result pointer first.
using TTcPluginInitialize = void(__stdcall*)(ITcPlugin** aResult, const wchar_t* aRegRoot, int aLanguageId, ITonCut* aTonCut);

}  // namespace toncut

#pragma pack(pop)
