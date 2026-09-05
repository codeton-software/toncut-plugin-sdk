#include "ContractProbeTouch.hpp"

namespace contract_probe {

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
}

void TouchISolution(toncut::ISolution* aValue) {
  if (aValue == nullptr) return;
  aValue->GetCount(nullptr);
  aValue->GetByIndex(1, nullptr);
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
}

void TouchITcEnumExtensionsCallback(toncut::ITcEnumExtensionsCallback* aValue) {
  if (aValue == nullptr) return;
  aValue->Invoke({}, {}, {});
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
