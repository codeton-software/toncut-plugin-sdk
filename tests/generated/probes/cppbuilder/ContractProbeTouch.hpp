#pragma once

#include "../../../SDK/include/cpp/TonCutPluginSdk.hpp"

namespace contract_probe {

void TouchIDevice(toncut::IDevice* aValue);
void TouchIDevices(toncut::IDevices* aValue);
void TouchIFormat(toncut::IFormat* aValue);
void TouchIFormats(toncut::IFormats* aValue);
void TouchIMaterial(toncut::IMaterial* aValue);
void TouchIMaterials(toncut::IMaterials* aValue);
void TouchIProject(toncut::IProject* aValue);
void TouchIProjects(toncut::IProjects* aValue);
void TouchISheet(toncut::ISheet* aValue);
void TouchISheets(toncut::ISheets* aValue);
void TouchISolution(toncut::ISolution* aValue);
void TouchISolutionCut(toncut::ISolutionCut* aValue);
void TouchISolutionCuts(toncut::ISolutionCuts* aValue);
void TouchISolutionFormat(toncut::ISolutionFormat* aValue);
void TouchISolutionFormats(toncut::ISolutionFormats* aValue);
void TouchISolutionSheet(toncut::ISolutionSheet* aValue);
void TouchISolutionWaste(toncut::ISolutionWaste* aValue);
void TouchISolutionWastes(toncut::ISolutionWastes* aValue);
void TouchITcEnumExtensionsCallback(toncut::ITcEnumExtensionsCallback* aValue);
void TouchITcPlotterInfo(toncut::ITcPlotterInfo* aValue);
void TouchITcPlugin(toncut::ITcPlugin* aValue);
void TouchITonCut(toncut::ITonCut* aValue);
void TouchAllSupportedInterfaces(toncut::ITonCut* aTonCut);

}  // namespace contract_probe
