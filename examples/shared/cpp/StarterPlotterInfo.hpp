#pragma once

#include "../../../include/cpp/TonCutPluginSdk.hpp"

#include <atomic>
#include <new>

namespace toncut {

// Minimal ITcPlotterInfo implementation for plugins that advertise a result
// or plot save feature. TonCut copies this object whenever it needs the
// plugin's cutting-device description, so ITcPlugin::GetPlotterInfo must never
// return nullptr while any save or plot feature flag is set.
//
// The defaults match the host's own defaults for a device without a driver
// plugin. MaterialKinds must contain the material kinds the plugin can save:
// the Save results dialog disables sheets whose material kind is missing.
// AxisX, AxisY, DefaultRotation and DefaultMirror define the output frame the
// host uses for ISolutionSheet::GetSolutionCuts and CalcPoint: set them to
// match the coordinate system of the target machine or file format.
// MaxStripeWidth is in 0.01 mm. When this plugin is the driver of a cutting
// device, the host takes CanCrossCuts, FullCutsOnly, StripCuts and
// MaxStripeWidth from that device instead.
class StarterPlotterInfo final : public ITcPlotterInfo {
 public:
  StarterPlotterInfo() = default;
  StarterPlotterInfo(const StarterPlotterInfo&) = delete;
  StarterPlotterInfo& operator=(const StarterPlotterInfo&) = delete;

  // Returns a new object with one reference owned by the caller.
  static HRESULT Create(ITcPlotterInfo** result) noexcept {
    if (result == nullptr) {
      return E_POINTER;
    }
    *result = new (std::nothrow) StarterPlotterInfo();
    return *result != nullptr ? S_OK : E_OUTOFMEMORY;
  }

  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID riid, void** object) override {
    if (object == nullptr) {
      return E_POINTER;
    }
    *object = nullptr;
    if (riid != IID_IUnknown && riid != IID_ITcPlotterInfo) {
      return E_NOINTERFACE;
    }
    *object = static_cast<ITcPlotterInfo*>(this);
    AddRef();
    return S_OK;
  }
  ULONG STDMETHODCALLTYPE AddRef() override { return ++refCount_; }
  ULONG STDMETHODCALLTYPE Release() override {
    const ULONG remaining = --refCount_;
    if (remaining == 0) {
      delete this;
    }
    return remaining;
  }

  HRESULT STDMETHODCALLTYPE GetPlotterType(TTcPlotterType* result) override { return Get(plotterType_, result); }
  HRESULT STDMETHODCALLTYPE SetPlotterType(TTcPlotterType value) override { plotterType_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetMaterialKinds(TMaterialKinds* result) override { return Get(materialKinds_, result); }
  HRESULT STDMETHODCALLTYPE SetMaterialKinds(TMaterialKinds value) override { materialKinds_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetAxisX(TTcAxisDirection* result) override { return Get(axisX_, result); }
  HRESULT STDMETHODCALLTYPE SetAxisX(TTcAxisDirection value) override { axisX_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetAxisY(TTcAxisDirection* result) override { return Get(axisY_, result); }
  HRESULT STDMETHODCALLTYPE SetAxisY(TTcAxisDirection value) override { axisY_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetSizeX(unsigned* result) override { return Get(sizeX_, result); }
  HRESULT STDMETHODCALLTYPE SetSizeX(unsigned value) override { sizeX_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetSizeY(unsigned* result) override { return Get(sizeY_, result); }
  HRESULT STDMETHODCALLTYPE SetSizeY(unsigned value) override { sizeY_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetCanCrossCuts(DelphiBool* result) override { return Get(canCrossCuts_, result); }
  HRESULT STDMETHODCALLTYPE SetCanCrossCuts(DelphiBool value) override { canCrossCuts_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetFullCutsOnly(DelphiBool* result) override { return Get(fullCutsOnly_, result); }
  HRESULT STDMETHODCALLTYPE SetFullCutsOnly(DelphiBool value) override { fullCutsOnly_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetCanCutAnyShapes(DelphiBool* result) override { return Get(canCutAnyShapes_, result); }
  HRESULT STDMETHODCALLTYPE SetCanCutAnyShapes(DelphiBool value) override { canCutAnyShapes_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetStripCuts(TStripCutting* result) override { return Get(stripCuts_, result); }
  HRESULT STDMETHODCALLTYPE SetStripCuts(TStripCutting value) override { stripCuts_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetMaxStripeWidth(int* result) override { return Get(maxStripeWidth_, result); }
  HRESULT STDMETHODCALLTYPE SetMaxStripeWidth(int value) override { maxStripeWidth_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetCutsDepthOn(DelphiBool* result) override { return Get(cutsDepthOn_, result); }
  HRESULT STDMETHODCALLTYPE SetCutsDepthOn(DelphiBool value) override { cutsDepthOn_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetCutsDepth(unsigned* result) override { return Get(cutsDepth_, result); }
  HRESULT STDMETHODCALLTYPE SetCutsDepth(unsigned value) override { cutsDepth_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetCutsDepthIncMargins(DelphiBool* result) override { return Get(cutsDepthIncMargins_, result); }
  HRESULT STDMETHODCALLTYPE SetCutsDepthIncMargins(DelphiBool value) override { cutsDepthIncMargins_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetTwoDimensionMoves(DelphiBool* result) override { return Get(twoDimensionMoves_, result); }
  HRESULT STDMETHODCALLTYPE SetTwoDimensionMoves(DelphiBool value) override { twoDimensionMoves_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetPrefferedDirection(TTcMoveDirection* result) override { return Get(prefferedDirection_, result); }
  HRESULT STDMETHODCALLTYPE SetPrefferedDirection(TTcMoveDirection value) override { prefferedDirection_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetMarginWest(unsigned* result) override { return Get(marginWest_, result); }
  HRESULT STDMETHODCALLTYPE SetMarginWest(unsigned value) override { marginWest_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetMarginNorth(unsigned* result) override { return Get(marginNorth_, result); }
  HRESULT STDMETHODCALLTYPE SetMarginNorth(unsigned value) override { marginNorth_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetMarginEast(unsigned* result) override { return Get(marginEast_, result); }
  HRESULT STDMETHODCALLTYPE SetMarginEast(unsigned value) override { marginEast_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetMarginSouth(unsigned* result) override { return Get(marginSouth_, result); }
  HRESULT STDMETHODCALLTYPE SetMarginSouth(unsigned value) override { marginSouth_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetBridgeMoveDirection(TTcMoveDirection* result) override { return Get(bridgeMoveDirection_, result); }
  HRESULT STDMETHODCALLTYPE SetBridgeMoveDirection(TTcMoveDirection value) override { bridgeMoveDirection_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetBridgeSize(unsigned* result) override { return Get(bridgeSize_, result); }
  HRESULT STDMETHODCALLTYPE SetBridgeSize(unsigned value) override { bridgeSize_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetHeadSize(unsigned* result) override { return Get(headSize_, result); }
  HRESULT STDMETHODCALLTYPE SetHeadSize(unsigned value) override { headSize_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetHeadKnifeSpace(unsigned* result) override { return Get(headKnifeSpace_, result); }
  HRESULT STDMETHODCALLTYPE SetHeadKnifeSpace(unsigned value) override { headKnifeSpace_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetDefaultRotation(int* result) override { return Get(defaultRotation_, result); }
  HRESULT STDMETHODCALLTYPE SetDefaultRotation(int value) override { defaultRotation_ = value; return S_OK; }
  HRESULT STDMETHODCALLTYPE GetDefaultMirror(TMirrors* result) override { return Get(defaultMirror_, result); }
  HRESULT STDMETHODCALLTYPE SetDefaultMirror(TMirrors value) override { defaultMirror_ = value; return S_OK; }

  HRESULT STDMETHODCALLTYPE Assign(ITcPlotterInfo* other) override {
    if (other == nullptr) {
      return E_POINTER;
    }
    HRESULT hr = other->GetPlotterType(&plotterType_);
    hr = SUCCEEDED(hr) ? other->GetMaterialKinds(&materialKinds_) : hr;
    hr = SUCCEEDED(hr) ? other->GetAxisX(&axisX_) : hr;
    hr = SUCCEEDED(hr) ? other->GetAxisY(&axisY_) : hr;
    hr = SUCCEEDED(hr) ? other->GetSizeX(&sizeX_) : hr;
    hr = SUCCEEDED(hr) ? other->GetSizeY(&sizeY_) : hr;
    hr = SUCCEEDED(hr) ? other->GetCanCrossCuts(&canCrossCuts_) : hr;
    hr = SUCCEEDED(hr) ? other->GetFullCutsOnly(&fullCutsOnly_) : hr;
    hr = SUCCEEDED(hr) ? other->GetCanCutAnyShapes(&canCutAnyShapes_) : hr;
    hr = SUCCEEDED(hr) ? other->GetStripCuts(&stripCuts_) : hr;
    hr = SUCCEEDED(hr) ? other->GetMaxStripeWidth(&maxStripeWidth_) : hr;
    hr = SUCCEEDED(hr) ? other->GetCutsDepthOn(&cutsDepthOn_) : hr;
    hr = SUCCEEDED(hr) ? other->GetCutsDepth(&cutsDepth_) : hr;
    hr = SUCCEEDED(hr) ? other->GetCutsDepthIncMargins(&cutsDepthIncMargins_) : hr;
    hr = SUCCEEDED(hr) ? other->GetTwoDimensionMoves(&twoDimensionMoves_) : hr;
    hr = SUCCEEDED(hr) ? other->GetPrefferedDirection(&prefferedDirection_) : hr;
    hr = SUCCEEDED(hr) ? other->GetMarginWest(&marginWest_) : hr;
    hr = SUCCEEDED(hr) ? other->GetMarginNorth(&marginNorth_) : hr;
    hr = SUCCEEDED(hr) ? other->GetMarginEast(&marginEast_) : hr;
    hr = SUCCEEDED(hr) ? other->GetMarginSouth(&marginSouth_) : hr;
    hr = SUCCEEDED(hr) ? other->GetBridgeMoveDirection(&bridgeMoveDirection_) : hr;
    hr = SUCCEEDED(hr) ? other->GetBridgeSize(&bridgeSize_) : hr;
    hr = SUCCEEDED(hr) ? other->GetHeadSize(&headSize_) : hr;
    hr = SUCCEEDED(hr) ? other->GetHeadKnifeSpace(&headKnifeSpace_) : hr;
    hr = SUCCEEDED(hr) ? other->GetDefaultRotation(&defaultRotation_) : hr;
    hr = SUCCEEDED(hr) ? other->GetDefaultMirror(&defaultMirror_) : hr;
    return hr;
  }

 private:
  ~StarterPlotterInfo() = default;

  template <typename T>
  static HRESULT Get(T value, T* result) {
    if (result == nullptr) {
      return E_POINTER;
    }
    *result = value;
    return S_OK;
  }

  std::atomic<ULONG> refCount_{1};
  TTcPlotterType plotterType_ = ptUnknown;
  TMaterialKinds materialKinds_ =
    static_cast<TMaterialKinds>(MaterialKindMask(mk1D) | MaterialKindMask(mk2D));
  TTcAxisDirection axisX_ = adEast;
  TTcAxisDirection axisY_ = adSouth;
  unsigned sizeX_ = 133;
  unsigned sizeY_ = 100;
  DelphiBool canCrossCuts_ = 0;
  DelphiBool fullCutsOnly_ = 1;
  DelphiBool canCutAnyShapes_ = 1;
  TStripCutting stripCuts_ = scNone;
  int maxStripeWidth_ = 1200 * static_cast<int>(cLengthMultiplier);
  DelphiBool cutsDepthOn_ = 0;
  unsigned cutsDepth_ = 0;
  DelphiBool cutsDepthIncMargins_ = 0;
  DelphiBool twoDimensionMoves_ = 1;
  TTcMoveDirection prefferedDirection_ = mdAny;
  unsigned marginWest_ = 5;
  unsigned marginNorth_ = 5;
  unsigned marginEast_ = 5;
  unsigned marginSouth_ = 5;
  TTcMoveDirection bridgeMoveDirection_ = mdAlongX;
  unsigned bridgeSize_ = 10;
  unsigned headSize_ = 10;
  unsigned headKnifeSpace_ = 5;
  int defaultRotation_ = 0;
  TMirrors defaultMirror_ = 0;
};

}  // namespace toncut
