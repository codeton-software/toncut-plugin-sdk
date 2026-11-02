#include "ContractProbeTouch.hpp"

namespace contract_probe {

void TouchIDevice(toncut::IDevice* aValue) {
  if (aValue == nullptr) return;
  aValue->Clone(nullptr);
  aValue->Assign(nullptr);
  aValue->GetId(nullptr);
  aValue->SetId(1);
  aValue->GetTitle(nullptr);
  aValue->SetTitle({});
  aValue->GetDriver(nullptr);
  aValue->SetDriver({});
  aValue->GetCanCutAnyShapes(nullptr);
  aValue->SetCanCutAnyShapes(1);
  aValue->GetCanCrossCuts(nullptr);
  aValue->SetCanCrossCuts(1);
  aValue->GetFullCutsOnly(nullptr);
  aValue->SetFullCutsOnly(1);
  aValue->GetStripCuts(nullptr);
  aValue->SetStripCuts({});
  aValue->GetMaxStripeWidth(nullptr);
  aValue->SetMaxStripeWidth(1);
  aValue->GetMinCutSize(nullptr);
  aValue->SetMinCutSize(1);
  aValue->GetMinCutDistance(nullptr);
  aValue->SetMinCutDistance(1);
  aValue->GetMinEdgeDistance(nullptr);
  aValue->GetEdgingCuts(nullptr);
  aValue->SetEdgingCuts({});
  aValue->GetOriginEdgingCuts(nullptr);
  aValue->SetOriginEdgingCuts({});
  aValue->GetMaxCutDepthOn(nullptr);
  aValue->SetMaxCutDepthOn(1);
  aValue->GetMaxCutDepth(nullptr);
  aValue->SetMaxCutDepth(1);
  aValue->GetFirstCutDirection(nullptr);
  aValue->SetFirstCutDirection({});
  aValue->GetMaxCutDepthIncludeSheetEdging(nullptr);
  aValue->SetMaxCutDepthIncludeSheetEdging(1);
  aValue->GetMaxCutLengthByLengthOn(nullptr);
  aValue->SetMaxCutLengthByLengthOn(1);
  aValue->GetMaxCutLengthByLength(nullptr);
  aValue->SetMaxCutLengthByLength(1);
  aValue->GetMaxCutLengthByWidthOn(nullptr);
  aValue->SetMaxCutLengthByWidthOn(1);
  aValue->GetMaxCutLengthByWidth(nullptr);
  aValue->SetMaxCutLengthByWidth(1);
  aValue->GetMaterialKind(nullptr);
  aValue->SetMaterialKind({});
  aValue->GetCanCutSlants(nullptr);
  aValue->SetCanCutSlants(1);
  aValue->GetLeftSlantMeasurement(nullptr);
  aValue->SetLeftSlantMeasurement({});
  aValue->GetRightSlantMeasurement(nullptr);
  aValue->SetRightSlantMeasurement({});
  aValue->GetCutCostPerMeter(nullptr);
  aValue->SetCutCostPerMeter({});
  aValue->GetReuseCost(nullptr);
  aValue->SetReuseCost({});
  aValue->GetUtilizationCost(nullptr);
  aValue->SetUtilizationCost({});
  aValue->GetSegmentShiftCost(nullptr);
  aValue->SetSegmentShiftCost({});
  aValue->GetSegmentRotationCost(nullptr);
  aValue->SetSegmentRotationCost({});
  aValue->GetCustomData(nullptr);
  aValue->SetCustomData({});
  aValue->ReservedGetAlgorithmData(nullptr);
  aValue->GetOnChange(nullptr);
  aValue->GetOnIdChange(nullptr);
  aValue->BeginUpdate();
  aValue->EndUpdate();
  aValue->GetDefaultRotation(nullptr);
  aValue->SetDefaultRotation(1);
  aValue->GetDefaultMirror(nullptr);
  aValue->SetDefaultMirror({});
}

void TouchIDevices(toncut::IDevices* aValue) {
  if (aValue == nullptr) return;
  aValue->CreateDevice(nullptr);
  aValue->Add(nullptr);
  aValue->DeleteByIndex(1);
  aValue->DeleteById(1);
  aValue->Remove(nullptr);
  aValue->IndexOfByObject(nullptr, nullptr);
  aValue->IndexOfById(1, nullptr);
  aValue->FindDuplicate(nullptr, 1, nullptr);
  aValue->FindByTitle({}, nullptr);
  aValue->FindUniqueName({}, nullptr);
  aValue->CheckUniqueName({}, nullptr, nullptr);
  aValue->CheckUniqueNameByDevice(nullptr, 1, nullptr);
  aValue->GetCount(nullptr);
  aValue->GetByIndex(1, nullptr);
  aValue->GetById(1, nullptr);
  aValue->GetOnAdd(nullptr);
  aValue->GetOnRemove(nullptr);
  aValue->GetOnChange(nullptr);
  aValue->BeginUpdate();
  aValue->EndUpdate();
  aValue->IsUpdating(nullptr);
  aValue->Reload();
}

void TouchIFormat(toncut::IFormat* aValue) {
  if (aValue == nullptr) return;
  aValue->GetId(nullptr);
  aValue->SetId(1);
  aValue->GetProject(nullptr);
  aValue->SetProject(nullptr);
  aValue->GetLength(nullptr);
  aValue->SetLength(1);
  aValue->GetWidth(nullptr);
  aValue->SetWidth(1);
  aValue->GetQuantity(nullptr);
  aValue->SetQuantity(1);
  aValue->GetProcessedQuantity(nullptr);
  aValue->SetProcessedQuantity(1);
  aValue->GetOrnament(nullptr);
  aValue->SetOrnament({});
  aValue->GetIdentifier(nullptr);
  aValue->SetIdentifier({});
  aValue->GetDescription(nullptr);
  aValue->SetDescription({});
  aValue->GetShape(nullptr);
  aValue->SetShape(nullptr);
  aValue->GetRotationStep(nullptr);
  aValue->SetRotationStep(1);
  aValue->GetRotation(nullptr);
  aValue->SetRotation(1);
  aValue->GetMirror(nullptr);
  aValue->SetMirror(1);
  aValue->GetMaterial(nullptr);
  aValue->SetMaterial(nullptr);
  aValue->GetSurplus(nullptr);
  aValue->SetSurplus(1);
  aValue->GetMargin(nullptr);
  aValue->SetMargin(1);
  aValue->GetBanding(nullptr);
  aValue->GetGrinds(nullptr);
  aValue->GetColor(nullptr);
  aValue->SetColor({});
  aValue->GetPriority(nullptr);
  aValue->SetPriority(1);
  aValue->GetWeight(nullptr);
  aValue->SetWeight(1.5);
  aValue->GetWeightModifier(nullptr);
  aValue->SetWeightModifier(1.5);
  aValue->GetGroup(nullptr);
  aValue->SetGroup(1);
  aValue->GetOrder(nullptr);
  aValue->SetOrder(1);
  aValue->GetSellingPrice(nullptr);
  aValue->SetSellingPrice({});
  aValue->GetStorageCost(nullptr);
  aValue->SetStorageCost({});
  aValue->GetCustomData(nullptr);
  aValue->SetCustomData({});
  aValue->ReservedGetAlgorithmData(nullptr);
  aValue->GetEffectivePriority(nullptr);
  aValue->GetLeftQuantity(nullptr);
  aValue->GetTotalSurplus(nullptr);
  aValue->GetTotalMargin(nullptr);
  aValue->GetTotalLength(nullptr);
  aValue->GetTotalWidth(nullptr);
  aValue->GetTotalField(nullptr);
  aValue->GetGrossLength(nullptr);
  aValue->GetGrossWidth(nullptr);
  aValue->GetShapePathAsString(1.5, 1, 1, 1, nullptr);
  aValue->GetShapeOffsetInsideBoundingBox(1.5, 1, nullptr, nullptr);
  aValue->Assign(nullptr, nullptr);
  aValue->GetOnChange(nullptr);
  aValue->GetOnIdChange(nullptr);
  aValue->UpdateEffectivePriority(1);
  aValue->BeginUpdate();
  aValue->EndUpdate();
  aValue->GetPreviewColor(nullptr);
  aValue->SetPreviewColor({});
}

void TouchIFormats(toncut::IFormats* aValue) {
  if (aValue == nullptr) return;
  aValue->Assign(nullptr);
  aValue->Clear();
  aValue->Reload();
  aValue->CreateFormat(nullptr);
  aValue->Add(nullptr);
  aValue->DeleteByIndex(1);
  aValue->DeleteById(1);
  aValue->Remove(nullptr);
  aValue->IndexOfByObject(nullptr, nullptr);
  aValue->IndexOfById(1, nullptr);
  aValue->IndexOfByList(nullptr, 1, nullptr, 1, 1, {}, nullptr, nullptr, nullptr);
  aValue->IndexOfByOther(nullptr, 1, nullptr, nullptr);
  aValue->Find(1, 1, nullptr, nullptr);
  aValue->GetCount(nullptr);
  aValue->GetByIndex(1, nullptr);
  aValue->GetById(1, nullptr);
  aValue->LoadByProjectInto(nullptr, nullptr);
  aValue->LoadByProject(nullptr);
  aValue->GetByProject(nullptr, nullptr);
  aValue->UnloadByProject(nullptr);
  aValue->UnloadFormat(nullptr);
  aValue->CalcMaxLength(nullptr);
  aValue->GetField(nullptr);
  aValue->GetQuantity(nullptr);
  aValue->GetLoading(nullptr);
  aValue->SetLoading(1);
  aValue->GetOnAdd(nullptr);
  aValue->GetOnRemove(nullptr);
  aValue->GetOnChange(nullptr);
  aValue->BeginUpdate();
  aValue->EndUpdate();
  aValue->IsUpdating(nullptr);
}

void TouchIMaterial(toncut::IMaterial* aValue) {
  if (aValue == nullptr) return;
  aValue->GetId(nullptr);
  aValue->SetId(1);
  aValue->GetTitle(nullptr);
  aValue->SetTitle({});
  aValue->GetKind(nullptr);
  aValue->SetKind({});
  aValue->GetWidth(nullptr);
  aValue->SetWidth(1);
  aValue->GetThickness(nullptr);
  aValue->SetThickness(1);
  aValue->GetHasOrnament(nullptr);
  aValue->SetHasOrnament(1);
  aValue->GetCanRotate(nullptr);
  aValue->SetCanRotate(1);
  aValue->GetCanMirror(nullptr);
  aValue->SetCanMirror(1);
  aValue->GetSurplus(nullptr);
  aValue->SetSurplus(1);
  aValue->GetSurplusEditable(nullptr);
  aValue->SetSurplusEditable(1);
  aValue->GetMargin(nullptr);
  aValue->SetMargin(1);
  aValue->GetMarginEditable(nullptr);
  aValue->SetMarginEditable(1);
  aValue->GetDefaultEdging(nullptr);
  aValue->SetDefaultEdging(1);
  aValue->GetCuttingDimensions(nullptr);
  aValue->SetCuttingDimensions({});
  aValue->GetBandable(nullptr);
  aValue->SetBandable(1);
  aValue->GetGrindable(nullptr);
  aValue->SetGrindable(1);
  aValue->GetColorable(nullptr);
  aValue->SetColorable(1);
  aValue->GetDevice(nullptr);
  aValue->SetDevice(nullptr);
  aValue->GetAlgorithm(nullptr);
  aValue->SetAlgorithm({});
  aValue->GetQualityLevel(nullptr);
  aValue->SetQualityLevel({});
  aValue->GetReuseWaste(nullptr);
  aValue->SetReuseWaste(1);
  aValue->GetMinShorterRecycleSize(nullptr);
  aValue->SetMinShorterRecycleSize(1);
  aValue->GetMinLongerRecycleSize(nullptr);
  aValue->SetMinLongerRecycleSize(1);
  aValue->GetMaxShorterRecycleSize(nullptr);
  aValue->SetMaxShorterRecycleSize(1);
  aValue->GetMaxLongerRecycleSize(nullptr);
  aValue->SetMaxLongerRecycleSize(1);
  aValue->GetPrefShorterRecycleSize(nullptr);
  aValue->SetPrefShorterRecycleSize(1);
  aValue->GetPrefLongerRecycleSize(nullptr);
  aValue->SetPrefLongerRecycleSize(1);
  aValue->GetEffectiveMinShorterRecycleSize(nullptr);
  aValue->GetEffectiveMinLongerRecycleSize(nullptr);
  aValue->GetEffectiveMaxShorterRecycleSize(nullptr);
  aValue->GetEffectiveMaxLongerRecycleSize(nullptr);
  aValue->GetEffectivePrefShorterRecycleSize(nullptr);
  aValue->GetEffectivePrefLongerRecycleSize(nullptr);
  aValue->GetKerf(nullptr);
  aValue->SetKerf(1);
  aValue->GetMinEdgeDistance(nullptr);
  aValue->GetAllowEdgeCuts(nullptr);
  aValue->SetAllowEdgeCuts(1);
  aValue->GetRecycleEdgingOn(nullptr);
  aValue->SetRecycleEdgingOn(1);
  aValue->GetRecycleEdging(nullptr);
  aValue->SetRecycleEdging(1);
  aValue->GetStackCutting(nullptr);
  aValue->SetStackCutting(1);
  aValue->GetStackSize(nullptr);
  aValue->SetStackSize(1);
  aValue->GetAllowPartialStack(nullptr);
  aValue->SetAllowPartialStack(1);
  aValue->GetMinStackSize(nullptr);
  aValue->SetMinStackSize(1);
  aValue->GetPricePerSqM(nullptr);
  aValue->SetPricePerSqM({});
  aValue->GetWeightOfSqM(nullptr);
  aValue->SetWeightOfSqM({});
  aValue->GetPricePerMeter(nullptr);
  aValue->SetPricePerMeter({});
  aValue->GetWeightOfMeter(nullptr);
  aValue->SetWeightOfMeter({});
  aValue->GetCutCostPerMeter(nullptr);
  aValue->SetCutCostPerMeter({});
  aValue->GetReuseCost(nullptr);
  aValue->SetReuseCost({});
  aValue->GetUtilizationCostPerKg(nullptr);
  aValue->SetUtilizationCostPerKg({});
  aValue->GetSegmentShiftCost(nullptr);
  aValue->SetSegmentShiftCost({});
  aValue->GetSegmentRotationCost(nullptr);
  aValue->SetSegmentRotationCost({});
  aValue->GetPriceToCostMultiplier(nullptr);
  aValue->SetPriceToCostMultiplier(1.5);
  aValue->GetReusableWasteExpectedUsage(nullptr);
  aValue->SetReusableWasteExpectedUsage(1.5);
  aValue->GetCutExcess(nullptr);
  aValue->SetCutExcess(1);
  aValue->GetCutShiftTotalLimit(nullptr);
  aValue->SetCutShiftTotalLimit(1);
  aValue->GetCutShiftHorzLimit(nullptr);
  aValue->SetCutShiftHorzLimit(1);
  aValue->GetCutShiftVertLimit(nullptr);
  aValue->SetCutShiftVertLimit(1);
  aValue->GetCustomData(nullptr);
  aValue->SetCustomData({});
  aValue->ReservedGetAlgorithmData(nullptr);
  aValue->GetStandardSheets(nullptr);
  aValue->GetOnChange(nullptr);
  aValue->GetOnIdChange(nullptr);
  aValue->GetOnStandardSheetAdd(nullptr);
  aValue->GetOnStandardSheetRemove(nullptr);
  aValue->GetOnStandardSheetChange(nullptr);
  aValue->Assign(nullptr);
  aValue->BeginUpdate();
  aValue->EndUpdate();
}

void TouchIMaterials(toncut::IMaterials* aValue) {
  if (aValue == nullptr) return;
  aValue->CreateMaterial(nullptr);
  aValue->CreateStandardSheet(nullptr);
  aValue->Add(nullptr);
  aValue->DeleteByIndex(1);
  aValue->DeleteById(1);
  aValue->Remove(nullptr);
  aValue->IndexOfByObject(nullptr, nullptr);
  aValue->IndexOfById(1, nullptr);
  aValue->FindDuplicate(nullptr, 1, nullptr);
  aValue->FindByTitle({}, {}, 1, 1, nullptr);
  aValue->FindUniqueName({}, {}, 1, 1, nullptr);
  aValue->CheckUniqueName({}, {}, 1, 1, nullptr, nullptr);
  aValue->CheckUniqueNameByMaterial(nullptr, 1, nullptr);
  aValue->GetCount(nullptr);
  aValue->GetByIndex(1, nullptr);
  aValue->GetById(1, nullptr);
  aValue->GetOnAdd(nullptr);
  aValue->GetOnRemove(nullptr);
  aValue->Reload();
}

void TouchIProject(toncut::IProject* aValue) {
  if (aValue == nullptr) return;
  aValue->GetId(nullptr);
  aValue->SetId(1);
  aValue->GetTitle(nullptr);
  aValue->SetTitle({});
  aValue->GetDescription(nullptr);
  aValue->SetDescription({});
  aValue->GetPriority(nullptr);
  aValue->SetPriority({});
  aValue->GetCreateDate(nullptr);
  aValue->SetCreateDate({});
  aValue->GetTargetDate(nullptr);
  aValue->SetTargetDate({});
  aValue->GetState(nullptr);
  aValue->SetState({});
  aValue->GetPieceCount(nullptr);
  aValue->SetPieceCount(1);
  aValue->GetPieceField2D(nullptr);
  aValue->SetPieceField2D({});
  aValue->GetPieceLength1D(nullptr);
  aValue->SetPieceLength1D({});
  aValue->GetProcessedCount(nullptr);
  aValue->SetProcessedCount(1);
  aValue->GetProcessedField2D(nullptr);
  aValue->SetProcessedField2D({});
  aValue->GetProcessedLength1D(nullptr);
  aValue->SetProcessedLength1D({});
  aValue->GetMaterialGroupCount(nullptr);
  aValue->SetMaterialGroupCount(1);
  aValue->GetLoading(nullptr);
  aValue->SetLoading(1);
  aValue->GetLoaded(nullptr);
  aValue->SetLoaded(1);
  aValue->GetOnChange(nullptr);
  aValue->GetOnIdChange(nullptr);
  aValue->Clone(nullptr);
  aValue->Assign(nullptr);
  aValue->UpdateStats(nullptr);
  aValue->FormatAdded(nullptr);
  aValue->FormatRemoved(nullptr);
  aValue->FormatChanged(nullptr);
  aValue->FormatIdChanged(nullptr, 1, 1);
  aValue->GetFormats(nullptr, nullptr, 1);
  aValue->BeginUpdate();
  aValue->EndUpdate();
}

void TouchIProjects(toncut::IProjects* aValue) {
  if (aValue == nullptr) return;
  aValue->CreateProject(nullptr);
  aValue->Add(nullptr);
  aValue->DeleteByIndex(1);
  aValue->DeleteById(1);
  aValue->Remove(nullptr);
  aValue->IndexOfByObject(nullptr, nullptr);
  aValue->IndexOfById(1, nullptr);
  aValue->FindDuplicate(nullptr, 1, nullptr);
  aValue->FindByTitle({}, nullptr);
  aValue->FindUniqueName({}, nullptr);
  aValue->CheckUniqueName({}, nullptr, nullptr);
  aValue->CheckUniqueNameByProject(nullptr, 1, nullptr);
  aValue->GetCount(nullptr);
  aValue->GetByIndex(1, nullptr);
  aValue->GetById(1, nullptr);
  aValue->GetOnAdd(nullptr);
  aValue->GetOnRemove(nullptr);
  aValue->GetOnChange(nullptr);
  aValue->Load({}, 1, 1);
  aValue->Reload();
  aValue->BeginUpdate();
  aValue->EndUpdate();
  aValue->IsUpdating(nullptr);
}

void TouchISheet(toncut::ISheet* aValue) {
  if (aValue == nullptr) return;
  aValue->GetId(nullptr);
  aValue->SetId(1);
  aValue->GetWidth(nullptr);
  aValue->SetWidth(1);
  aValue->GetLength(nullptr);
  aValue->SetLength(1);
  aValue->GetQuantity(nullptr);
  aValue->SetQuantity(1);
  aValue->GetStackSize(nullptr);
  aValue->SetStackSize(1);
  aValue->GetOrnament(nullptr);
  aValue->SetOrnament({});
  aValue->GetIdentifier(nullptr);
  aValue->SetIdentifier({});
  aValue->GetDescription(nullptr);
  aValue->SetDescription({});
  aValue->GetMaterial(nullptr);
  aValue->SetMaterial(nullptr);
  aValue->GetEdging(nullptr);
  aValue->GetMinEdgeDistance(nullptr);
  aValue->GetPriority(nullptr);
  aValue->SetPriority(1);
  aValue->GetCutShiftHorzLimit(nullptr);
  aValue->SetCutShiftHorzLimit(1);
  aValue->GetCutShiftVertLimit(nullptr);
  aValue->SetCutShiftVertLimit(1);
  aValue->GetEffectiveCutShiftHorzLimit(nullptr);
  aValue->GetEffectiveCutShiftVertLimit(nullptr);
  aValue->GetExtractionCost(nullptr);
  aValue->SetExtractionCost({});
  aValue->GetCustomData(nullptr);
  aValue->SetCustomData({});
  aValue->ReservedGetAlgorithmData(nullptr);
  aValue->GetDefects(nullptr);
  aValue->GetHoles(nullptr);
  aValue->GetAvailableQuantity(nullptr);
  aValue->GetField(nullptr);
  aValue->GetFieldOfAll(nullptr);
  aValue->IsStandard(nullptr);
  aValue->Assign(nullptr);
  aValue->GetOnChange(nullptr);
  aValue->GetOnIdChange(nullptr);
  aValue->GetOnDefectAdd(nullptr);
  aValue->GetOnDefectRemove(nullptr);
  aValue->GetOnDefectChange(nullptr);
  aValue->BeginUpdate();
  aValue->EndUpdate();
  aValue->GetPricePerSqM(nullptr);
  aValue->SetPricePerSqM({});
}

void TouchISheets(toncut::ISheets* aValue) {
  if (aValue == nullptr) return;
  aValue->CreateSheet(nullptr);
  aValue->Add(nullptr);
  aValue->DeleteByIndex(1);
  aValue->DeleteById(1);
  aValue->Remove(nullptr);
  aValue->IndexOfByObject(nullptr, nullptr);
  aValue->IndexOfById(1, nullptr);
  aValue->IndexOfByOther(nullptr, 1, nullptr, nullptr);
  aValue->CreateDefect(nullptr);
  aValue->GetCount(nullptr);
  aValue->GetByIndex(1, nullptr);
  aValue->GetById(1, nullptr);
  aValue->CalcMaxLength(nullptr);
  aValue->GetField(nullptr);
  aValue->GetAvailableQuantity(nullptr);
  aValue->GetOnAdd(nullptr);
  aValue->GetOnRemove(nullptr);
  aValue->GetOnChange(nullptr);
  aValue->BeginUpdate();
  aValue->EndUpdate();
  aValue->IsUpdating(nullptr);
  aValue->Reload();
}

void TouchISolution(toncut::ISolution* aValue) {
  if (aValue == nullptr) return;
  aValue->GetCount(nullptr);
  aValue->GetByIndex(1, nullptr);
  aValue->GetTechnologicalWasteField(nullptr);
  aValue->GetEdgingWasteField(nullptr);
  aValue->GetKerfWasteField(nullptr);
  aValue->CalcCutsInfoByMaterial(nullptr, nullptr, nullptr);
}

void TouchISolutionCut(toncut::ISolutionCut* aValue) {
  if (aValue == nullptr) return;
  aValue->GetKind(nullptr);
  aValue->GetPosX(nullptr);
  aValue->GetPosY(nullptr);
  aValue->GetTarX(nullptr);
  aValue->GetTarY(nullptr);
  aValue->GetPosXp(nullptr);
  aValue->GetPosYp(nullptr);
  aValue->GetTarXp(nullptr);
  aValue->GetTarYp(nullptr);
  aValue->GetNeedShift(nullptr);
  aValue->CalcLength(nullptr);
  aValue->GetShiftDistance(nullptr);
}

void TouchISolutionCuts(toncut::ISolutionCuts* aValue) {
  if (aValue == nullptr) return;
  aValue->GetCount(nullptr);
  aValue->GetByIndex(1, nullptr);
}

void TouchISolutionFormat(toncut::ISolutionFormat* aValue) {
  if (aValue == nullptr) return;
  aValue->GetFormat(nullptr);
  aValue->GetX(nullptr);
  aValue->GetY(nullptr);
  aValue->GetRotation(nullptr);
  aValue->GetMirrored(nullptr);
}

void TouchISolutionFormats(toncut::ISolutionFormats* aValue) {
  if (aValue == nullptr) return;
  aValue->GetCount(nullptr);
  aValue->GetByIndex(1, nullptr);
}

void TouchISolutionSheet(toncut::ISolutionSheet* aValue) {
  if (aValue == nullptr) return;
  aValue->GetSheet(nullptr);
  aValue->GetSolutionFormats(nullptr);
  aValue->GetSolutionWastes(nullptr);
  aValue->GetSolutionCuts(nullptr);
  aValue->GetQuantity(nullptr);
  aValue->GetTechnologicalWasteField(nullptr);
  aValue->GetEdgingWasteField(nullptr);
  aValue->GetKerfWasteField(nullptr);
  aValue->GetIndex(nullptr);
  aValue->GetRotation(nullptr);
  aValue->GetMirror(nullptr);
  aValue->GetIsSaved(nullptr);
  aValue->SetIsSaved(1);
  aValue->GetIsPlotted(nullptr);
  aValue->SetIsPlotted(1);
  aValue->GetEffectiveModificator(nullptr, nullptr);
  aValue->GetOriginPoint(nullptr, nullptr);
  aValue->CalcPoint(nullptr, nullptr);
  aValue->UnCalcPoint(nullptr, nullptr);
  aValue->CalcPointF(nullptr, nullptr);
  aValue->UnCalcPointF(nullptr, nullptr);
  aValue->GetDirection(nullptr, nullptr);
  aValue->CalcEffectiveLayout(nullptr, nullptr, nullptr, nullptr, nullptr, nullptr);
  aValue->CalcRecycledField(1, 1, nullptr);
  aValue->CalcCutsInfo(nullptr, nullptr);
}

void TouchISolutionWaste(toncut::ISolutionWaste* aValue) {
  if (aValue == nullptr) return;
  aValue->GetX(nullptr);
  aValue->GetY(nullptr);
  aValue->GetLength(nullptr);
  aValue->GetWidth(nullptr);
  aValue->GetShape(nullptr);
  aValue->GetField(nullptr);
  aValue->GetIdentifier(nullptr);
  aValue->GetShapePathAsString(nullptr);
  aValue->GetHoles(nullptr);
}

void TouchISolutionWastes(toncut::ISolutionWastes* aValue) {
  if (aValue == nullptr) return;
  aValue->GetCount(nullptr);
  aValue->GetByIndex(1, nullptr);
}

void TouchITcEnumExtensionsCallback(toncut::ITcEnumExtensionsCallback* aValue) {
  if (aValue == nullptr) return;
  aValue->Invoke({}, {}, {});
}

void TouchITcPlotterInfo(toncut::ITcPlotterInfo* aValue) {
  if (aValue == nullptr) return;
  aValue->GetPlotterType(nullptr);
  aValue->SetPlotterType({});
  aValue->GetMaterialKinds(nullptr);
  aValue->SetMaterialKinds({});
  aValue->GetAxisX(nullptr);
  aValue->SetAxisX({});
  aValue->GetAxisY(nullptr);
  aValue->SetAxisY({});
  aValue->GetSizeX(nullptr);
  aValue->SetSizeX(1);
  aValue->GetSizeY(nullptr);
  aValue->SetSizeY(1);
  aValue->GetCanCrossCuts(nullptr);
  aValue->SetCanCrossCuts(1);
  aValue->GetFullCutsOnly(nullptr);
  aValue->SetFullCutsOnly(1);
  aValue->GetCanCutAnyShapes(nullptr);
  aValue->SetCanCutAnyShapes(1);
  aValue->GetStripCuts(nullptr);
  aValue->SetStripCuts({});
  aValue->GetMaxStripeWidth(nullptr);
  aValue->SetMaxStripeWidth(1);
  aValue->GetCutsDepthOn(nullptr);
  aValue->SetCutsDepthOn(1);
  aValue->GetCutsDepth(nullptr);
  aValue->SetCutsDepth(1);
  aValue->GetCutsDepthIncMargins(nullptr);
  aValue->SetCutsDepthIncMargins(1);
  aValue->GetTwoDimensionMoves(nullptr);
  aValue->SetTwoDimensionMoves(1);
  aValue->GetPrefferedDirection(nullptr);
  aValue->SetPrefferedDirection({});
  aValue->GetMarginWest(nullptr);
  aValue->SetMarginWest(1);
  aValue->GetMarginNorth(nullptr);
  aValue->SetMarginNorth(1);
  aValue->GetMarginEast(nullptr);
  aValue->SetMarginEast(1);
  aValue->GetMarginSouth(nullptr);
  aValue->SetMarginSouth(1);
  aValue->GetBridgeMoveDirection(nullptr);
  aValue->SetBridgeMoveDirection({});
  aValue->GetBridgeSize(nullptr);
  aValue->SetBridgeSize(1);
  aValue->GetHeadSize(nullptr);
  aValue->SetHeadSize(1);
  aValue->GetHeadKnifeSpace(nullptr);
  aValue->SetHeadKnifeSpace(1);
  aValue->GetDefaultRotation(nullptr);
  aValue->SetDefaultRotation(1);
  aValue->GetDefaultMirror(nullptr);
  aValue->SetDefaultMirror({});
  aValue->Assign(nullptr);
}

void TouchITcPlugin(toncut::ITcPlugin* aValue) {
  if (aValue == nullptr) return;
  aValue->GetEngineVersion(nullptr);
  aValue->GetName(nullptr);
  aValue->GetVersion(nullptr);
  aValue->GetTitle(nullptr);
  aValue->GetProfessional(nullptr);
  aValue->GetRegRoot(nullptr);
  aValue->GetLanguageId(nullptr);
  aValue->SetLanguageId(1);
  aValue->GetUiScale(nullptr);
  aValue->SetUiScale(1.5);
  aValue->GetTonCut(nullptr);
  aValue->GetFeatures(nullptr);
  aValue->GetPlotterInfo(nullptr);
  aValue->Initialize({}, 1, nullptr, nullptr);
  aValue->Finalize(nullptr);
  aValue->Configure({}, nullptr);
  aValue->About({}, nullptr);
  aValue->LoadConfig({}, {}, nullptr);
  aValue->SaveConfig({}, nullptr);
  aValue->BackupConfig(nullptr, nullptr);
  aValue->RestoreConfig({}, {}, nullptr);
  aValue->EnumExtensions({}, nullptr, nullptr);
  aValue->IsMyFile({}, nullptr);
  aValue->LoadFile({}, {}, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr);
  aValue->SaveFile({}, {}, nullptr, nullptr, nullptr);
  aValue->SaveResult({}, {}, nullptr, nullptr);
  aValue->BatchSaveResult({}, {}, {}, nullptr, nullptr);
  aValue->Plot({}, nullptr, nullptr);
  aValue->BatchPlot({}, nullptr, nullptr);
  aValue->SavePlot({}, {}, nullptr, nullptr);
  aValue->BatchSavePlot({}, {}, {}, nullptr, nullptr);
}

void TouchITonCut(toncut::ITonCut* aValue) {
  if (aValue == nullptr) return;
  aValue->GetUnits(nullptr);
  aValue->GetPrecision(nullptr);
  aValue->GetPieceIdentification(nullptr);
  aValue->GetDevices(nullptr);
  aValue->GetMaterials(nullptr);
  aValue->GetBands(nullptr);
  aValue->GetSheets(nullptr);
  aValue->GetTemplates(nullptr);
  aValue->GetProjects(nullptr);
  aValue->GetFormats(nullptr);
  aValue->GetResults(nullptr);
  aValue->GetSolution(nullptr);
  aValue->GetUsingProjects(nullptr);
  aValue->GetSelectedProject(nullptr);
  aValue->CreateSolution();
  aValue->ReleaseSolution();
  aValue->CreateMaterial({}, {}, 1, 1, nullptr);
  aValue->CreateBand({}, 1, 1, 1, 1, nullptr);
  aValue->CreateProject({}, nullptr);
  aValue->CanCutAnyShapes(nullptr, nullptr);
  aValue->FormatLengthFromInt(1, 1, nullptr);
  aValue->FormatLengthFromExtended(1.5, 1, nullptr);
  aValue->HumanReadableLength(1.5, 1, nullptr);
  aValue->FormatField(1, 1, nullptr);
  aValue->HumanReadableFieldFromInt64(1, 1, nullptr);
  aValue->HumanReadableFieldFromExtended(1.5, 1, nullptr);
  aValue->FormatDegrees(1.5, 1, nullptr);
  aValue->FormatRadians(1.5, 1, nullptr);
}

void TouchAllSupportedInterfaces(toncut::ITonCut* aTonCut) {
  TouchITonCut(aTonCut);
  if (aTonCut != nullptr) { toncut::IProjects* value = nullptr; aTonCut->GetProjects(&value); TouchIProjects(value); if (value != nullptr) value->Release(); }
  if (aTonCut != nullptr) { toncut::IMaterials* value = nullptr; aTonCut->GetMaterials(&value); TouchIMaterials(value); if (value != nullptr) value->Release(); }
  if (aTonCut != nullptr) { toncut::IFormats* value = nullptr; aTonCut->GetFormats(&value); TouchIFormats(value); if (value != nullptr) value->Release(); }
  if (aTonCut != nullptr) { toncut::ISheets* value = nullptr; aTonCut->GetSheets(&value); TouchISheets(value); if (value != nullptr) value->Release(); }
  if (aTonCut != nullptr) { toncut::ISolution* value = nullptr; aTonCut->GetSolution(&value); TouchISolution(value); if (value != nullptr) value->Release(); }
}

}  // namespace contract_probe
