#pragma once

#include <Unknwn.h>
#include <OleAuto.h>
#include <Windows.h>

#include <cstdint>
#include <string>

// TonCut Desktop plugin contract, C++ view of the Pascal units in ../pascal.
//
// ABI rules used by every declaration below (Win32 only):
// - Every Pascal `safecall` method becomes `HRESULT STDMETHODCALLTYPE` with the
//   Pascal parameters in order; `var`/`out` parameters become pointers and a
//   function result becomes one trailing out pointer.
// - Methods occupy vtable slots in Pascal declaration order, overloads
//   included, after the three IUnknown slots. A struct either projects a
//   contiguous prefix of its Pascal interface (usually all of it) or is
//   opaque (IUnknown only). Pascal overloads get distinct C++ names because
//   MSVC may reorder same-named virtual overloads.
// - A `Reserved...` slot exists only to keep later slots aligned. Never call
//   it from a plugin.
// - Lengths and positions are integers in 0.01 mm (mm x cLengthMultiplier).
// - Out interface pointers carry one reference the caller must Release; set
//   them to nullptr before the call. Out BSTRs are allocated by the callee and
//   freed by the caller with SysFreeString.
//
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
using TMaterialKinds = std::uint8_t;
using TField = std::int64_t;
using TTcColor = int;

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
static_assert(sizeof(TMaterialKinds) == 1, "Delphi TMaterialKinds set ABI must remain one byte");
static_assert(sizeof(TField) == 8, "Delphi TField (Int64) ABI must remain eight bytes");
static_assert(sizeof(TTcColor) == 4, "Delphi TTcColor (Integer) ABI must remain four bytes");

// Plugin engine interface version. The host activates a plugin only when
// GetEngineVersion returns exactly this value (24 = TonCut Desktop 8.5).
constexpr int cEngineVersion = 24;
// Internal length unit: 1 mm = 100 units (0.01 mm), for every length and
// position in this contract regardless of ITonCut::GetUnits.
constexpr unsigned cLengthMultiplier = 100;
// Area unit (TField): 1 mm^2 = 10000 units.
constexpr std::int64_t cFieldMultiplier = 10000;
// TRotation (unsigned short) is in 0.1 degree.
constexpr unsigned short cRotation90 = 900;
constexpr unsigned short cRotation180 = 1800;
constexpr unsigned short cRotation270 = 2700;
constexpr unsigned short cRotation360 = 3600;
// IFormat::GetPriority / SetPriority values.
constexpr int cPiecePriorityDefault = 0;
constexpr int cPiecePriorityNormal = 1;
constexpr int cPiecePriorityHigh = 10;
constexpr int cPiecePriorityCritical = 100;
// ISheet::GetPriority / SetPriority range: higher is consumed earlier.
constexpr int cStockPriorityMin = 0;
constexpr int cStockPriorityLow = 0;
constexpr int cStockPriorityNormal = 10;
constexpr int cStockPriorityMax = 100;
// ISheet::GetPricePerSqM value meaning "no own price; use the material's".
constexpr TTcPrice cStockPriceAbsent = -1;
// Special TTcColor values (IFormat::GetPreviewColor / SetPreviewColor).
constexpr TTcColor clTcNone = -1;
constexpr TTcColor clTcRandom = -2;
static_assert(cFieldMultiplier == static_cast<std::int64_t>(cLengthMultiplier) * cLengthMultiplier, "cFieldMultiplier must be cLengthMultiplier squared");

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

// Bit positions in TMirrors (a Delphi set of TMirror).
enum TMirror : std::uint8_t {
  mHorizontal = 0,
  mVertical = 1
};

enum TQualityLevel : std::uint8_t {
  qlPrecission = 0,
  qlCompromise = 1,
  qlSpeed = 2
};

enum TCuttingDimensions : std::uint8_t {
  cdNet = 0,
  cdGross = 1
};

enum TProjectPriority : std::uint8_t {
  prpDefault = 0,
  prpNormal = 1,
  prpHigh = 2,
  prpCritical = 3
};

enum TProjectState : std::uint8_t {
  prsNew = 0,
  prsReady = 1,
  prsPending = 2,
  prsDone = 3,
  prsCanceled = 4,
  prsDeleted = 5
};

enum TStripCutting : std::uint8_t {
  scNone = 0,
  scByLength = 1,
  scByWidth = 2
};

enum TEdgingCuts : std::uint8_t {
  ecOptimal = 0,
  ecHorizontalFirst = 1,
  ecVerticalFirst = 2
};

enum TCutDirections : std::uint8_t {
  cdHorizontal = 0,
  cdVertical = 1,
  cdAny = 2
};

enum TOriginEdgingCuts : std::uint8_t {
  oecDefault = 0,
  oecTwoFullCuts = 1
};

enum TSlantMeasurement : std::uint8_t {
  smFromMiddleToLeft = 0,
  smFromMiddleToRight = 1,
  smFromLeft = 2,
  smFromRight = 3
};

enum TTcPlotterType : std::uint8_t {
  ptUnknown = 0,
  ptCNC = 1
};

enum TTcAxisDirection : std::uint8_t {
  adWest = 0,
  adNorth = 1,
  adEast = 2,
  adSouth = 3
};

enum TTcMoveDirection : std::uint8_t {
  mdAlongX = 0,
  mdAlongY = 1,
  mdAny = 2
};

static_assert(sizeof(TMirror) == 1, "Delphi TMirror enum ABI must remain one byte");
static_assert(sizeof(TQualityLevel) == 1, "Delphi TQualityLevel enum ABI must remain one byte");
static_assert(sizeof(TCuttingDimensions) == 1, "Delphi TCuttingDimensions enum ABI must remain one byte");
static_assert(sizeof(TProjectPriority) == 1, "Delphi TProjectPriority enum ABI must remain one byte");
static_assert(sizeof(TProjectState) == 1, "Delphi TProjectState enum ABI must remain one byte");
static_assert(sizeof(TStripCutting) == 1, "Delphi TStripCutting enum ABI must remain one byte");
static_assert(sizeof(TEdgingCuts) == 1, "Delphi TEdgingCuts enum ABI must remain one byte");
static_assert(sizeof(TCutDirections) == 1, "Delphi TCutDirections enum ABI must remain one byte");
static_assert(sizeof(TOriginEdgingCuts) == 1, "Delphi TOriginEdgingCuts enum ABI must remain one byte");
static_assert(sizeof(TSlantMeasurement) == 1, "Delphi TSlantMeasurement enum ABI must remain one byte");
static_assert(sizeof(TTcPlotterType) == 1, "Delphi TTcPlotterType enum ABI must remain one byte");
static_assert(sizeof(TTcAxisDirection) == 1, "Delphi TTcAxisDirection enum ABI must remain one byte");
static_assert(sizeof(TTcMoveDirection) == 1, "Delphi TTcMoveDirection enum ABI must remain one byte");

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

inline TMaterialKinds MaterialKindMask(TMaterialKind value) {
  return static_cast<TMaterialKinds>(1u << static_cast<unsigned>(value));
}

inline TMirrors MirrorMask(TMirror value) {
  return static_cast<TMirrors>(1u << static_cast<unsigned>(value));
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

// uITcEnumExtensionsCallback.pas {B17490F3-F2DA-4179-8D56-39B921D9C73A}: complete projection, 1 Pascal method in vtable slot 3.
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
struct IBand : IUnknown {};
struct IBands : IUnknown {};
struct IBanding : IUnknown {};
struct IGrinds : IUnknown {};
struct IRectangle : IUnknown {};
struct IResults : IUnknown {};
struct IShape : IUnknown {};
struct ISheetDefect : IUnknown {};
struct ISheetDefects : IUnknown {};
struct IStandardSheet : IUnknown {};
struct IStandardSheets : IUnknown {};
struct ITemplates : IUnknown {};
struct ITcAlgorithmData : IUnknown {};
struct INotifyEvent : IUnknown {};
struct IIdChangeEvent : IUnknown {};
struct IDeviceChangeEvent : IUnknown {};
struct IFormatChangeEvent : IUnknown {};
struct IMaterialChangeEvent : IUnknown {};
struct IProjectChangeEvent : IUnknown {};
struct ISheetChangeEvent : IUnknown {};
struct ISheetDefectChangeEvent : IUnknown {};
struct IStandardSheetChangeEvent : IUnknown {};

// Projected interfaces, defined below.
struct IDevice;
struct IDevices;
struct IProject;
struct IProjects;
struct IMaterial;
struct IMaterials;
struct IFormat;
struct IFormats;
struct ISheet;
struct ISheets;
struct ITcPlotterInfo;
struct ISolution;
struct ISolutionCut;
struct ISolutionCuts;
struct ISolutionFormat;
struct ISolutionFormats;
struct ISolutionSheet;
struct ISolutionWaste;
struct ISolutionWastes;

// Interface IDs of the projected interfaces, copied from the Pascal GUIDs.
// ITcPlugin has no GUID. TonCut never calls QueryInterface on the plugin
// object; an object the plugin hands to the host (for example an
// ITcPlotterInfo) should answer IID_IUnknown and its own IID.
constexpr GUID IID_ITcEnumExtensionsCallback = {0xB17490F3, 0xF2DA, 0x4179, {0x8D, 0x56, 0x39, 0xB9, 0x21, 0xD9, 0xC7, 0x3A}};
constexpr GUID IID_ITonCut = {0xFF6C1A96, 0x46C2, 0x4E06, {0xA7, 0x79, 0x43, 0xDA, 0xA3, 0x6D, 0xFB, 0xE1}};
constexpr GUID IID_IMaterial = {0x5C81D3A6, 0x7E42, 0x4B19, {0x8F, 0x63, 0x2D, 0x9B, 0x5A, 0x14, 0xC7, 0x08}};
constexpr GUID IID_IProject = {0xD62A183C, 0x3C58, 0x419E, {0xA2, 0x66, 0x91, 0x3A, 0x1D, 0x17, 0xDD, 0xAD}};
constexpr GUID IID_IFormat = {0x9B47E250, 0x1F63, 0x4A8D, {0x97, 0xC2, 0x6E, 0x05, 0xB3, 0xD8, 0x1A, 0x94}};
constexpr GUID IID_ISheet = {0x3D92A70F, 0x6B18, 0x45C4, {0xA8, 0xE1, 0x7C, 0x20, 0x4F, 0x6B, 0x9D, 0x35}};
constexpr GUID IID_IProjects = {0x6A337290, 0xEA4F, 0x408E, {0x9F, 0x67, 0xD1, 0xEC, 0xFE, 0xFD, 0xEA, 0x4B}};
constexpr GUID IID_IMaterials = {0x49E95AA5, 0x2437, 0x47E1, {0x8D, 0x38, 0x21, 0xBE, 0xC1, 0x46, 0xC6, 0xAD}};
constexpr GUID IID_IFormats = {0x42199936, 0x3DD0, 0x4680, {0x93, 0xDE, 0x43, 0x3D, 0x43, 0xE6, 0x57, 0x3B}};
constexpr GUID IID_ISheets = {0x66C5F864, 0x69D6, 0x43A0, {0x84, 0x6B, 0xC8, 0xAF, 0x73, 0xDA, 0x21, 0xE3}};
constexpr GUID IID_ISolutionCut = {0xB51265B6, 0x8BE3, 0x4DF5, {0xA8, 0x52, 0xC6, 0x01, 0xD6, 0x83, 0x9F, 0x0A}};
constexpr GUID IID_ISolutionCuts = {0x6D733395, 0x4F49, 0x4189, {0x83, 0x25, 0xD0, 0xE4, 0xA5, 0xCD, 0xF2, 0x02}};
constexpr GUID IID_ISolutionFormat = {0xB384074F, 0x57F6, 0x41C9, {0x95, 0x14, 0xCB, 0xF3, 0x10, 0x3C, 0x38, 0x93}};
constexpr GUID IID_ISolutionFormats = {0x4F98B50C, 0x4007, 0x40A1, {0xA2, 0x28, 0x15, 0xD7, 0x78, 0xF5, 0xED, 0xBD}};
constexpr GUID IID_ISolutionWaste = {0x653C0065, 0x1BD3, 0x419F, {0x94, 0xF2, 0xCA, 0x6D, 0xED, 0x23, 0x4C, 0xE8}};
constexpr GUID IID_ISolutionWastes = {0xFF78D6B0, 0x32F7, 0x4999, {0x83, 0xD3, 0xC1, 0xB7, 0x14, 0x21, 0x05, 0xF3}};
constexpr GUID IID_ISolutionSheet = {0xCFC00E48, 0x9137, 0x4606, {0x83, 0x84, 0x3D, 0xAF, 0xE1, 0x74, 0xA0, 0x58}};
constexpr GUID IID_ISolution = {0xAF96B222, 0x66C9, 0x4D99, {0xB0, 0x61, 0x4C, 0x08, 0x6B, 0xA1, 0x01, 0x82}};
constexpr GUID IID_IDevice = {0x2A6F1B84, 0x9C37, 0x4E52, {0xB1, 0xD6, 0x4F, 0x8A, 0x0C, 0x97, 0xE3, 0x61}};
constexpr GUID IID_IDevices = {0x3384FFDE, 0x7FF9, 0x4B30, {0x8C, 0x4E, 0xF4, 0xF7, 0x23, 0xFA, 0x08, 0xE2}};
constexpr GUID IID_ITcPlotterInfo = {0x6706EAE7, 0x3E78, 0x4841, {0xAA, 0xD0, 0x7B, 0x2D, 0x3F, 0x85, 0x55, 0x1E}};

// uITonCut.pas {FF6C1A96-46C2-4E06-A779-43DAA36DFBE1}: complete projection, 28 Pascal methods in vtable slots 3-30.
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
  // Binds the Pascal FormatLength(aValue: Double) overload; the name is historical.
  virtual HRESULT STDMETHODCALLTYPE FormatLengthFromExtended(double aValue, DelphiBool aShort, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE HumanReadableLength(double aValue, DelphiBool aShort, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FormatField(std::int64_t aValue, DelphiBool aShort, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE HumanReadableFieldFromInt64(std::int64_t aValue, DelphiBool aShort, BSTR* result) = 0;
  // Binds the Pascal HumanReadableField(aValue: Double) overload; the name is historical.
  virtual HRESULT STDMETHODCALLTYPE HumanReadableFieldFromExtended(double aValue, DelphiBool aShort, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FormatDegrees(double aAngle, DelphiBool aShort, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FormatRadians(double aAngle, DelphiBool aShort, BSTR* result) = 0;
};

// uIMaterial.pas {5C81D3A6-7E42-4B19-8F63-2D9B5A14C708}: complete projection, 119 Pascal methods in vtable slots 3-121.
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
  virtual HRESULT STDMETHODCALLTYPE GetHasOrnament(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetHasOrnament(DelphiBool aHasOrnament) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCanRotate(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCanRotate(DelphiBool aCanRotate) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCanMirror(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCanMirror(DelphiBool aCanMirror) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSurplus(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetSurplus(unsigned aSurplus) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSurplusEditable(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetSurplusEditable(DelphiBool aEditable) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMargin(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMargin(unsigned aMargin) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMarginEditable(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMarginEditable(DelphiBool aEditable) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDefaultEdging(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetDefaultEdging(unsigned aEdging) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCuttingDimensions(TCuttingDimensions* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCuttingDimensions(TCuttingDimensions aCuttingDimensions) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetBandable(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetBandable(DelphiBool aBandable) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetGrindable(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetGrindable(DelphiBool aGrindable) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetColorable(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetColorable(DelphiBool aColorable) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDevice(IDevice** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetDevice(IDevice* aDevice) = 0;
  // Slots 39/40: WideString (BSTR) since the 2026-11 contract correction at
  // engine version 24; earlier SDKs declared a Delphi String here.
  virtual HRESULT STDMETHODCALLTYPE GetAlgorithm(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetAlgorithm(BSTR aAlgorithm) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetQualityLevel(TQualityLevel* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetQualityLevel(TQualityLevel aQualityLevel) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetReuseWaste(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetReuseWaste(DelphiBool aReuse) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMinShorterRecycleSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMinShorterRecycleSize(unsigned aSize) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMinLongerRecycleSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMinLongerRecycleSize(unsigned aSize) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaxShorterRecycleSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaxShorterRecycleSize(unsigned aSize) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaxLongerRecycleSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaxLongerRecycleSize(unsigned aSize) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPrefShorterRecycleSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPrefShorterRecycleSize(unsigned aSize) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPrefLongerRecycleSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPrefLongerRecycleSize(unsigned aSize) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEffectiveMinShorterRecycleSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEffectiveMinLongerRecycleSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEffectiveMaxShorterRecycleSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEffectiveMaxLongerRecycleSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEffectivePrefShorterRecycleSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEffectivePrefLongerRecycleSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetKerf(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetKerf(unsigned aKerf) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMinEdgeDistance(IRectangle** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetAllowEdgeCuts(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetAllowEdgeCuts(DelphiBool aAllow) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetRecycleEdgingOn(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetRecycleEdgingOn(DelphiBool aOn) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetRecycleEdging(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetRecycleEdging(unsigned aMargins) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetStackCutting(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetStackCutting(DelphiBool aStackCutting) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetStackSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetStackSize(unsigned aSize) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetAllowPartialStack(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetAllowPartialStack(DelphiBool aAllow) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMinStackSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMinStackSize(unsigned aSize) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPricePerSqM(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPricePerSqM(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetWeightOfSqM(TTcWeight* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetWeightOfSqM(TTcWeight aWeight) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPricePerMeter(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPricePerMeter(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetWeightOfMeter(TTcWeight* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetWeightOfMeter(TTcWeight aWeight) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCutCostPerMeter(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCutCostPerMeter(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetReuseCost(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetReuseCost(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetUtilizationCostPerKg(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetUtilizationCostPerKg(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSegmentShiftCost(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetSegmentShiftCost(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSegmentRotationCost(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetSegmentRotationCost(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPriceToCostMultiplier(double* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPriceToCostMultiplier(double aMultiplier) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetReusableWasteExpectedUsage(double* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetReusableWasteExpectedUsage(double aExpectedUsage) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCutExcess(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCutExcess(int aCutExcess) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCutShiftTotalLimit(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCutShiftTotalLimit(int aLimit) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCutShiftHorzLimit(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCutShiftHorzLimit(int aLimit) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCutShiftVertLimit(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCutShiftVertLimit(int aLimit) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCustomData(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCustomData(BSTR aData) = 0;
  // Reserved slot 112: Not part of the published C++ surface; kept for slot alignment.
  virtual HRESULT STDMETHODCALLTYPE ReservedGetAlgorithmData(ITcAlgorithmData** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetStandardSheets(IStandardSheets** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnChange(INotifyEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnIdChange(IIdChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnStandardSheetAdd(IStandardSheetChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnStandardSheetRemove(IStandardSheetChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnStandardSheetChange(IStandardSheetChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Assign(IMaterial* aOther) = 0;
  virtual HRESULT STDMETHODCALLTYPE BeginUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE EndUpdate() = 0;
};

// uIProject.pas {D62A183C-3C58-419E-A266-913A1D17DDAD}: complete projection, 44 Pascal methods in vtable slots 3-46.
struct IProject : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetId(std::int64_t* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetId(std::int64_t value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTitle(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetTitle(BSTR value) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDescription(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetDescription(BSTR aDescription) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPriority(TProjectPriority* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPriority(TProjectPriority aPriority) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCreateDate(TDateTime* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCreateDate(TDateTime aCreateDate) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTargetDate(TDateTime* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetTargetDate(TDateTime aTargetDate) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetState(TProjectState* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetState(TProjectState aState) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPieceCount(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPieceCount(unsigned aCount) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPieceField2D(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPieceField2D(TField aField) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPieceLength1D(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPieceLength1D(TField aLength) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetProcessedCount(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetProcessedCount(int aCount) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetProcessedField2D(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetProcessedField2D(TField aField) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetProcessedLength1D(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetProcessedLength1D(TField aLength) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaterialGroupCount(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaterialGroupCount(unsigned aCount) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetLoading(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetLoading(DelphiBool aLoading) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetLoaded(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetLoaded(DelphiBool aLoaded) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnChange(INotifyEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnIdChange(IIdChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Clone(IProject** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Assign(IProject* aOther) = 0;
  virtual HRESULT STDMETHODCALLTYPE UpdateStats(IUnknown* aAllFormats) = 0;
  virtual HRESULT STDMETHODCALLTYPE FormatAdded(IUnknown* aFormat) = 0;
  virtual HRESULT STDMETHODCALLTYPE FormatRemoved(IUnknown* aFormat) = 0;
  virtual HRESULT STDMETHODCALLTYPE FormatChanged(IUnknown* aFormat) = 0;
  virtual HRESULT STDMETHODCALLTYPE FormatIdChanged(IUnknown* aFormat, std::int64_t aNewId, std::int64_t aOldId) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetFormats(IUnknown* aFormats, IUnknown* aAllFormats, DelphiBool aKeepOrder) = 0;
  virtual HRESULT STDMETHODCALLTYPE BeginUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE EndUpdate() = 0;
};

// uIFormat.pas {9B47E250-1F63-4A8D-97C2-6E05B3D81A94}: complete projection, 72 Pascal methods in vtable slots 3-74.
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
  virtual HRESULT STDMETHODCALLTYPE GetSurplus(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetSurplus(unsigned aSurplus) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMargin(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMargin(unsigned aMargin) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetBanding(IBanding** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetGrinds(IGrinds** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetColor(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetColor(BSTR aColor) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPriority(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPriority(int aPriority) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetWeight(double* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetWeight(double aWeight) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetWeightModifier(double* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetWeightModifier(double aModifier) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetGroup(unsigned short* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetGroup(unsigned short aGroup) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOrder(unsigned short* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetOrder(unsigned short aOrder) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSellingPrice(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetSellingPrice(TTcPrice aPrice) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetStorageCost(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetStorageCost(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCustomData(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCustomData(BSTR aData) = 0;
  // Reserved slot 55: Not part of the published C++ surface; kept for slot alignment.
  virtual HRESULT STDMETHODCALLTYPE ReservedGetAlgorithmData(ITcAlgorithmData** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEffectivePriority(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetLeftQuantity(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTotalSurplus(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTotalMargin(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTotalLength(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTotalWidth(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTotalField(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetGrossLength(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetGrossWidth(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetShapePathAsString(double aRotation, DelphiBool aMirror, DelphiBool aWithOffset, DelphiBool aBBoxOrigin, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetShapeOffsetInsideBoundingBox(double aRotation, DelphiBool aMirror, double* aX, double* aY) = 0;
  virtual HRESULT STDMETHODCALLTYPE Assign(IFormat* aOther, IProject* aProject) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnChange(INotifyEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnIdChange(IIdChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE UpdateEffectivePriority(DelphiBool aTriggerChange) = 0;
  virtual HRESULT STDMETHODCALLTYPE BeginUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE EndUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPreviewColor(TTcColor* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPreviewColor(TTcColor aColor) = 0;
};

// uISheet.pas {3D92A70F-6B18-45C4-A8E1-7C204F6B9D35}: complete projection, 49 Pascal methods in vtable slots 3-51.
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
  virtual HRESULT STDMETHODCALLTYPE GetEdging(IRectangle** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMinEdgeDistance(IRectangle** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPriority(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPriority(int aPriority) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCutShiftHorzLimit(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCutShiftHorzLimit(int aLimit) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCutShiftVertLimit(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCutShiftVertLimit(int aLimit) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEffectiveCutShiftHorzLimit(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEffectiveCutShiftVertLimit(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetExtractionCost(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetExtractionCost(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCustomData(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCustomData(BSTR aData) = 0;
  // Reserved slot 35: Not part of the published C++ surface; kept for slot alignment.
  virtual HRESULT STDMETHODCALLTYPE ReservedGetAlgorithmData(ITcAlgorithmData** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDefects(ISheetDefects** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetHoles(ISheetDefects** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetAvailableQuantity(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetField(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetFieldOfAll(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE IsStandard(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Assign(ISheet* aSheet) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnChange(INotifyEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnIdChange(IIdChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnDefectAdd(ISheetDefectChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnDefectRemove(ISheetDefectChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnDefectChange(ISheetDefectChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE BeginUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE EndUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPricePerSqM(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPricePerSqM(TTcPrice aPrice) = 0;
};

// uIProjects.pas {6A337290-EA4F-408E-9F67-D1ECFEFDEA4B}: complete projection, 23 Pascal methods in vtable slots 3-25.
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

// uIMaterials.pas {49E95AA5-2437-47E1-8D38-21BEC146C6AD}: complete projection, 19 Pascal methods in vtable slots 3-21.
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

// uIFormats.pas {42199936-3DD0-4680-93DE-433D43E6573B}: complete projection, 32 Pascal methods in vtable slots 3-34.
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
  virtual HRESULT STDMETHODCALLTYPE GetById(std::int64_t aId, IFormat** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE LoadByProjectInto(IProject* aProject, IFormats* aFormats) = 0;
  virtual HRESULT STDMETHODCALLTYPE LoadByProject(IProject* aProject) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetByProject(IProject* aProject, IFormats** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE UnloadByProject(IProject* aProject) = 0;
  virtual HRESULT STDMETHODCALLTYPE UnloadFormat(IFormat* aFormat) = 0;
  virtual HRESULT STDMETHODCALLTYPE CalcMaxLength(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetField(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetQuantity(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetLoading(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetLoading(DelphiBool aLoading) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnAdd(IFormatChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnRemove(IFormatChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnChange(INotifyEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE BeginUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE EndUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE IsUpdating(DelphiBool* result) = 0;
};

// uISheets.pas {66C5F864-69D6-43A0-846B-C8AF73DA21E3}: complete projection, 22 Pascal methods in vtable slots 3-24.
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
  virtual HRESULT STDMETHODCALLTYPE GetById(std::int64_t aId, ISheet** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CalcMaxLength(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetField(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetAvailableQuantity(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnAdd(ISheetChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnRemove(ISheetChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnChange(INotifyEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE BeginUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE EndUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE IsUpdating(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Reload() = 0;
};

// uISolutionCut.pas {B51265B6-8BE3-4DF5-A852-C601D6839F0A}: complete projection, 12 Pascal methods in vtable slots 3-14.
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

// uISolutionCuts.pas {6D733395-4F49-4189-8325-D0E4A5CDF202}: complete projection, 2 Pascal methods in vtable slots 3-4.
struct ISolutionCuts : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetCount(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetByIndex(unsigned value, ISolutionCut** result) = 0;
};

// uISolutionFormat.pas {B384074F-57F6-41C9-9514-CBF3103C3893}: complete projection, 5 Pascal methods in vtable slots 3-7.
struct ISolutionFormat : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetFormat(IFormat** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetX(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetY(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetRotation(unsigned short* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMirrored(DelphiBool* result) = 0;
};

// uISolutionFormats.pas {4F98B50C-4007-40A1-A228-15D778F5EDBD}: complete projection, 2 Pascal methods in vtable slots 3-4.
struct ISolutionFormats : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetCount(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetByIndex(unsigned aIndex, ISolutionFormat** result) = 0;
};

// uISolutionWaste.pas {653C0065-1BD3-419F-94F2-CA6DED234CE8}: complete projection, 9 Pascal methods in vtable slots 3-11.
struct ISolutionWaste : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetX(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetY(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetLength(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetWidth(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetShape(IShape** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetField(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetIdentifier(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetShapePathAsString(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetHoles(ISheetDefects** result) = 0;
};

// uISolutionWastes.pas {FF78D6B0-32F7-4999-83D3-C1B7142105F3}: complete projection, 2 Pascal methods in vtable slots 3-4.
struct ISolutionWastes : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetCount(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetByIndex(unsigned aIndex, ISolutionWaste** result) = 0;
};

// uISolutionSheet.pas {CFC00E48-9137-4606-8384-3DAFE174A058}: complete projection, 25 Pascal methods in vtable slots 3-27.
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
  virtual HRESULT STDMETHODCALLTYPE CalcRecycledField(int aMinShorterRecycleSize, int aMinLongerRecycleSize, TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CalcCutsInfo(int* aCount, double* aLength) = 0;
};

// uISolution.pas {AF96B222-66C9-4D99-B061-4C086BA10182}: complete projection, 6 Pascal methods in vtable slots 3-8.
struct ISolution : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetCount(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetByIndex(unsigned value, ISolutionSheet** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTechnologicalWasteField(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEdgingWasteField(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetKerfWasteField(TField* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CalcCutsInfoByMaterial(IMaterial* aMaterial, int* aCount, double* aLength) = 0;
};

// uIDevice.pas {2A6F1B84-9C37-4E52-B1D6-4F8A0C97E361}: complete projection, 72 Pascal methods in vtable slots 3-74.
struct IDevice : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE Clone(IDevice** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Assign(IDevice* aOther) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetId(std::int64_t* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetId(std::int64_t aId) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTitle(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetTitle(BSTR aTitle) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDriver(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetDriver(BSTR aDriver) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCanCutAnyShapes(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCanCutAnyShapes(DelphiBool aCanCutAnyShapes) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCanCrossCuts(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCanCrossCuts(DelphiBool aCanCrossCuts) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetFullCutsOnly(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetFullCutsOnly(DelphiBool aFullCutsOnly) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetStripCuts(TStripCutting* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetStripCuts(TStripCutting aStripCuts) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaxStripeWidth(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaxStripeWidth(int aMaxWidth) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMinCutSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMinCutSize(unsigned aSize) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMinCutDistance(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMinCutDistance(unsigned aDistance) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMinEdgeDistance(IRectangle** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetEdgingCuts(TEdgingCuts* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetEdgingCuts(TEdgingCuts aEdgingCuts) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOriginEdgingCuts(TOriginEdgingCuts* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetOriginEdgingCuts(TOriginEdgingCuts aOriginEdgingCuts) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaxCutDepthOn(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaxCutDepthOn(DelphiBool aOn) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaxCutDepth(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaxCutDepth(unsigned aDepth) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetFirstCutDirection(TCutDirections* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetFirstCutDirection(TCutDirections aDirection) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaxCutDepthIncludeSheetEdging(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaxCutDepthIncludeSheetEdging(DelphiBool aInclude) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaxCutLengthByLengthOn(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaxCutLengthByLengthOn(DelphiBool aOn) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaxCutLengthByLength(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaxCutLengthByLength(unsigned aLength) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaxCutLengthByWidthOn(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaxCutLengthByWidthOn(DelphiBool aOn) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaxCutLengthByWidth(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaxCutLengthByWidth(unsigned aLength) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaterialKind(TMaterialKind* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaterialKind(TMaterialKind aKind) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCanCutSlants(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCanCutSlants(DelphiBool aCan) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetLeftSlantMeasurement(TSlantMeasurement* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetLeftSlantMeasurement(TSlantMeasurement aSlantMeasurement) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetRightSlantMeasurement(TSlantMeasurement* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetRightSlantMeasurement(TSlantMeasurement aSlantMeasurement) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCutCostPerMeter(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCutCostPerMeter(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetReuseCost(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetReuseCost(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetUtilizationCost(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetUtilizationCost(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSegmentShiftCost(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetSegmentShiftCost(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSegmentRotationCost(TTcPrice* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetSegmentRotationCost(TTcPrice aCost) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCustomData(BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCustomData(BSTR aData) = 0;
  // Reserved slot 66: Not part of the published C++ surface; kept for slot alignment.
  virtual HRESULT STDMETHODCALLTYPE ReservedGetAlgorithmData(ITcAlgorithmData** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnChange(INotifyEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnIdChange(IIdChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE BeginUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE EndUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDefaultRotation(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetDefaultRotation(int aRotation) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDefaultMirror(TMirrors* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetDefaultMirror(TMirrors aMirror) = 0;
};

// uIDevices.pas {3384FFDE-7FF9-4B30-8C4E-F4F723FA08E2}: complete projection, 22 Pascal methods in vtable slots 3-24.
struct IDevices : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE CreateDevice(IDevice** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Add(IDevice* aDevice) = 0;
  virtual HRESULT STDMETHODCALLTYPE DeleteByIndex(unsigned aIndex) = 0;
  virtual HRESULT STDMETHODCALLTYPE DeleteById(std::int64_t aId) = 0;
  virtual HRESULT STDMETHODCALLTYPE Remove(IDevice* aDevice) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfByObject(IDevice* aDevice, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE IndexOfById(std::int64_t aId, int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FindDuplicate(IDevice* aDevice, DelphiBool aCheckTitle, IDevice** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FindByTitle(BSTR aTitle, IDevice** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE FindUniqueName(BSTR aBaseName, BSTR* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CheckUniqueName(BSTR aTitle, IDevice* aIgnoreDevice, DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE CheckUniqueNameByDevice(IDevice* aDevice, DelphiBool aAutoFix, DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCount(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetByIndex(unsigned aIndex, IDevice** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetById(std::int64_t aId, IDevice** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnAdd(IDeviceChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnRemove(IDeviceChangeEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetOnChange(INotifyEvent** result) = 0;
  virtual HRESULT STDMETHODCALLTYPE BeginUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE EndUpdate() = 0;
  virtual HRESULT STDMETHODCALLTYPE IsUpdating(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE Reload() = 0;
};

// uITcPlotterInfo.pas {6706EAE7-3E78-4841-AAD0-7B2D3F85551E}: complete projection, 53 Pascal methods in vtable slots 3-55.
struct ITcPlotterInfo : IUnknown {
  virtual HRESULT STDMETHODCALLTYPE GetPlotterType(TTcPlotterType* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPlotterType(TTcPlotterType aPlotterType) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaterialKinds(TMaterialKinds* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaterialKinds(TMaterialKinds aMaterialKinds) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetAxisX(TTcAxisDirection* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetAxisX(TTcAxisDirection aAxisX) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetAxisY(TTcAxisDirection* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetAxisY(TTcAxisDirection aAxisY) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSizeX(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetSizeX(unsigned aSizeX) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetSizeY(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetSizeY(unsigned aSizeY) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCanCrossCuts(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCanCrossCuts(DelphiBool aCanCrossCuts) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetFullCutsOnly(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetFullCutsOnly(DelphiBool aFullCutsOnly) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCanCutAnyShapes(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCanCutAnyShapes(DelphiBool aCanCutAnyShapes) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetStripCuts(TStripCutting* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetStripCuts(TStripCutting aStripCuts) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMaxStripeWidth(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMaxStripeWidth(int aMaxWidth) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCutsDepthOn(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCutsDepthOn(DelphiBool aCutsDepthOn) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCutsDepth(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCutsDepth(unsigned aCutsDepth) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetCutsDepthIncMargins(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetCutsDepthIncMargins(DelphiBool aCutsDepthIncMargins) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetTwoDimensionMoves(DelphiBool* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetTwoDimensionMoves(DelphiBool aTwoDimensionMoves) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetPrefferedDirection(TTcMoveDirection* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetPrefferedDirection(TTcMoveDirection aPrefferedDirection) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMarginWest(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMarginWest(unsigned aMarginWest) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMarginNorth(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMarginNorth(unsigned aMarginNorth) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMarginEast(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMarginEast(unsigned aMarginEast) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetMarginSouth(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetMarginSouth(unsigned aMarginSouth) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetBridgeMoveDirection(TTcMoveDirection* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetBridgeMoveDirection(TTcMoveDirection aBridgeMoveDirection) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetBridgeSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetBridgeSize(unsigned aBridgeSize) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetHeadSize(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetHeadSize(unsigned aHeadSize) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetHeadKnifeSpace(unsigned* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetHeadKnifeSpace(unsigned aHeadKnifeSpace) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDefaultRotation(int* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetDefaultRotation(int aDefaultRotation) = 0;
  virtual HRESULT STDMETHODCALLTYPE GetDefaultMirror(TMirrors* result) = 0;
  virtual HRESULT STDMETHODCALLTYPE SetDefaultMirror(TMirrors aDefaultMirror) = 0;
  virtual HRESULT STDMETHODCALLTYPE Assign(ITcPlotterInfo* aOther) = 0;
};

// uITcPlugin.pas: complete projection, 31 Pascal methods in vtable slots 3-33.
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
