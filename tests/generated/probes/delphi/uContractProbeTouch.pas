unit uContractProbeTouch;

interface

uses
  System.SysUtils,
  uICommon,
  uITcPluginCommon,
  uIAnyShape,
  uIBand,
  uIBandChangeEvent,
  uIBandList,
  uIBanding,
  uIBands,
  uIDevice,
  uIDeviceChangeEvent,
  uIDevices,
  uIFormat,
  uIFormatChangeEvent,
  uIFormats,
  uIGrind,
  uIGrinds,
  uIIdChangeEvent,
  uILinearShape,
  uIMaterial,
  uIMaterialChangeEvent,
  uIMaterials,
  uINotifyEvent,
  uIProject,
  uIProjectChangeEvent,
  uIProjects,
  uIRectangle,
  uIResult,
  uIResultChangeEvent,
  uIResults,
  uIShape,
  uISheet,
  uISheetChangeEvent,
  uISheetDefect,
  uISheetDefectChangeEvent,
  uISheetDefects,
  uISheets,
  uISolution,
  uISolutionCut,
  uISolutionCuts,
  uISolutionFormat,
  uISolutionFormats,
  uISolutionSheet,
  uISolutionWaste,
  uISolutionWastes,
  uIStandardSheet,
  uIStandardSheetChangeEvent,
  uIStandardSheets,
  uITcEnumExtensionsCallback,
  uITcPlotterInfo,
  uITcPlugin,
  uITemplate,
  uITemplateChangeEvent,
  uITemplates,
  uITonCut;

procedure TouchAllSupportedInterfaces(const aTonCut: ITonCut);

implementation

procedure TouchIAnyShape(const aValue: IAnyShape);
begin
  if not Assigned(aValue) then Exit;
  aValue.Path := 'IAnyShape.Path';
  var __Path0Value := aValue.Path;
end;

procedure TouchIBand(const aValue: IBand);
begin
  if not Assigned(aValue) then Exit;
  aValue.Id := 1;
  var __Id0Value := aValue.Id;
  aValue.Title := 'IBand.Title';
  var __Title1Value := aValue.Title;
  aValue.Width := 1;
  var __Width2Value := aValue.Width;
  aValue.MaxMaterialThickness := 1;
  var __MaxMaterialThickness3Value := aValue.MaxMaterialThickness;
  aValue.Thickness := 1;
  var __Thickness4Value := aValue.Thickness;
  aValue.Surplus := 1;
  var __Surplus5Value := aValue.Surplus;
  var __OnChange6Value := aValue.OnChange;
  var __OnIdChange7Value := aValue.OnIdChange;
  var __Clone14Result := aValue.Clone();
  aValue.Assign(Default(IBand));
  aValue.BeginUpdate();
  aValue.EndUpdate();
end;

procedure TouchIBandChangeEvent(const aValue: IBandChangeEvent);
begin
  if not Assigned(aValue) then Exit;
  aValue.Add(Default(IBandChangeEventHandler));
  aValue.Remove(Default(IBandChangeEventHandler));
  aValue.Invoke(Default(IUnknown), Default(IBand), 1);
end;

procedure TouchIBandChangeEventHandler(const aValue: IBandChangeEventHandler);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(IUnknown), Default(IBand), 1);
end;

procedure TouchIBandList(const aValue: IBandList);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
  aValue.Add(Default(IBand));
  aValue.DeleteByIndex(1);
  aValue.Remove(Default(IBand));
  var __IndexOf3Result := aValue.IndexOf(Default(IBand));
end;

procedure TouchIBanding(const aValue: IBanding);
begin
  if not Assigned(aValue) then Exit;
  aValue.North := Default(IBand);
  var __North0Value := aValue.North;
  aValue.South := Default(IBand);
  var __South1Value := aValue.South;
  aValue.West := Default(IBand);
  var __West2Value := aValue.West;
  aValue.East := Default(IBand);
  var __East3Value := aValue.East;
  aValue.Top := Default(IBand);
  var __Top4Value := aValue.Top;
  aValue.Bottom := Default(IBand);
  var __Bottom5Value := aValue.Bottom;
  aValue.Left := Default(IBand);
  var __Left6Value := aValue.Left;
  aValue.Right := Default(IBand);
  var __Right7Value := aValue.Right;
  var __OnChange8Value := aValue.OnChange;
  aValue.Assign(Default(IBanding));
end;

procedure TouchIBands(const aValue: IBands);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
  var __OnAdd2Value := aValue.OnAdd;
  var __OnRemove3Value := aValue.OnRemove;
  var __CreateBand0Result := aValue.CreateBand();
  aValue.Add(Default(IBand));
  aValue.DeleteByIndex(1);
  aValue.DeleteById(1);
  aValue.Remove(Default(IBand));
  var __IndexOf5Result := aValue.IndexOf(Default(IBand));
  var __IndexOf6Result := aValue.IndexOf(1);
  var __FindDuplicate7Result := aValue.FindDuplicate(Default(IBand), True);
  var __FindByTitle8Result := aValue.FindByTitle('aTitle1', 1, 1);
  var __FindUniqueName9Result := aValue.FindUniqueName('aBaseName1', 1, 1);
  var __CheckUniqueName10Result := aValue.CheckUniqueName('aTitle1', 1, 1, Default(IBand));
  var __CheckUniqueName11Result := aValue.CheckUniqueName(Default(IBand), True);
  var __GetById14Result := aValue.GetById(1);
  aValue.AddMaterialBandToHistory(Default(IMaterial), Default(IBand));
  var __LoadMaterialBandsFromHistory18Result := aValue.LoadMaterialBandsFromHistory(Default(IMaterial), 1);
  var __LoadMaterialBands19Result := aValue.LoadMaterialBands(Default(IMaterial));
  aValue.Reload();
end;

procedure TouchIDevice(const aValue: IDevice);
begin
  if not Assigned(aValue) then Exit;
  aValue.Id := 1;
  var __Id0Value := aValue.Id;
  aValue.Title := 'IDevice.Title';
  var __Title1Value := aValue.Title;
  aValue.Driver := 'IDevice.Driver';
  var __Driver2Value := aValue.Driver;
  aValue.CanCutAnyShapes := True;
  var __CanCutAnyShapes3Value := aValue.CanCutAnyShapes;
  aValue.CanCrossCuts := True;
  var __CanCrossCuts4Value := aValue.CanCrossCuts;
  aValue.FullCutsOnly := True;
  var __FullCutsOnly5Value := aValue.FullCutsOnly;
  aValue.StripCuts := Default(TStripCutting);
  var __StripCuts6Value := aValue.StripCuts;
  aValue.MaxStripeWidth := 1;
  var __MaxStripeWidth7Value := aValue.MaxStripeWidth;
  aValue.MinCutWidth := 1;
  var __MinCutWidth8Value := aValue.MinCutWidth;
  aValue.EdgingCuts := Default(TEdgingCuts);
  var __EdgingCuts9Value := aValue.EdgingCuts;
  aValue.OriginEdgingCuts := Default(TOriginEdgingCuts);
  var __OriginEdgingCuts10Value := aValue.OriginEdgingCuts;
  aValue.MaxCutDepthOn := True;
  var __MaxCutDepthOn11Value := aValue.MaxCutDepthOn;
  aValue.MaxCutDepth := 1;
  var __MaxCutDepth12Value := aValue.MaxCutDepth;
  aValue.FirstCutDirection := Default(TCutDirections);
  var __FirstCutDirection13Value := aValue.FirstCutDirection;
  aValue.MaxCutDepthIncludeSheetEdging := True;
  var __MaxCutDepthIncludeSheetEdging14Value := aValue.MaxCutDepthIncludeSheetEdging;
  aValue.MaxCutLengthByLengthOn := True;
  var __MaxCutLengthByLengthOn15Value := aValue.MaxCutLengthByLengthOn;
  aValue.MaxCutLengthByLength := 1;
  var __MaxCutLengthByLength16Value := aValue.MaxCutLengthByLength;
  aValue.MaxCutLengthByWidthOn := True;
  var __MaxCutLengthByWidthOn17Value := aValue.MaxCutLengthByWidthOn;
  aValue.MaxCutLengthByWidth := 1;
  var __MaxCutLengthByWidth18Value := aValue.MaxCutLengthByWidth;
  aValue.MaterialKind := Default(TMaterialKind);
  var __MaterialKind19Value := aValue.MaterialKind;
  aValue.CanCutSlants := True;
  var __CanCutSlants20Value := aValue.CanCutSlants;
  aValue.LeftSlantMeasurement := Default(TSlantMeasurement);
  var __LeftSlantMeasurement21Value := aValue.LeftSlantMeasurement;
  aValue.RightSlantMeasurement := Default(TSlantMeasurement);
  var __RightSlantMeasurement22Value := aValue.RightSlantMeasurement;
  aValue.CutCostPerMeter := 1.5;
  var __CutCostPerMeter23Value := aValue.CutCostPerMeter;
  aValue.ReuseCost := 1.5;
  var __ReuseCost24Value := aValue.ReuseCost;
  aValue.UtilizationCost := 1.5;
  var __UtilizationCost25Value := aValue.UtilizationCost;
  aValue.SegmentShiftCost := 1.5;
  var __SegmentShiftCost26Value := aValue.SegmentShiftCost;
  aValue.SegmentRotationCost := 1.5;
  var __SegmentRotationCost27Value := aValue.SegmentRotationCost;
  aValue.CustomData := 'IDevice.CustomData';
  var __CustomData28Value := aValue.CustomData;
  var __OnChange29Value := aValue.OnChange;
  var __OnIdChange30Value := aValue.OnIdChange;
  var __Clone0Result := aValue.Clone();
  aValue.Assign(Default(IDevice));
  aValue.BeginUpdate();
  aValue.EndUpdate();
end;

procedure TouchIDeviceChangeEvent(const aValue: IDeviceChangeEvent);
begin
  if not Assigned(aValue) then Exit;
  aValue.Add(Default(IDeviceChangeEventHandler));
  aValue.Remove(Default(IDeviceChangeEventHandler));
  aValue.Invoke(Default(IUnknown), Default(IDevice), 1);
end;

procedure TouchIDeviceChangeEventHandler(const aValue: IDeviceChangeEventHandler);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(IUnknown), Default(IDevice), 1);
end;

procedure TouchIDevices(const aValue: IDevices);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
  var __OnAdd2Value := aValue.OnAdd;
  var __OnRemove3Value := aValue.OnRemove;
  var __OnChange4Value := aValue.OnChange;
  var __CreateDevice0Result := aValue.CreateDevice();
  aValue.Add(Default(IDevice));
  aValue.DeleteByIndex(1);
  aValue.DeleteById(1);
  aValue.Remove(Default(IDevice));
  var __IndexOf5Result := aValue.IndexOf(Default(IDevice));
  var __IndexOf6Result := aValue.IndexOf(1);
  var __FindDuplicate7Result := aValue.FindDuplicate(Default(IDevice), True);
  var __FindByTitle8Result := aValue.FindByTitle('aTitle1');
  var __FindUniqueName9Result := aValue.FindUniqueName('aBaseName1');
  var __CheckUniqueName10Result := aValue.CheckUniqueName('aTitle1', Default(IDevice));
  var __CheckUniqueName11Result := aValue.CheckUniqueName(Default(IDevice), True);
  var __GetById14Result := aValue.GetById(1);
  aValue.BeginUpdate();
  aValue.EndUpdate();
  var __IsUpdating20Result := aValue.IsUpdating();
  aValue.Reload();
end;

procedure TouchIFormat(const aValue: IFormat);
begin
  if not Assigned(aValue) then Exit;
  aValue.Id := 1;
  var __Id0Value := aValue.Id;
  aValue.Project := Default(IProject);
  var __Project1Value := aValue.Project;
  aValue.Length := 1;
  var __Length2Value := aValue.Length;
  aValue.Width := 1;
  var __Width3Value := aValue.Width;
  aValue.Quantity := 1;
  var __Quantity4Value := aValue.Quantity;
  aValue.ProcessedQuantity := 1;
  var __ProcessedQuantity5Value := aValue.ProcessedQuantity;
  aValue.Ornament := Default(TOrnaments);
  var __Ornament6Value := aValue.Ornament;
  aValue.Identifier := 'IFormat.Identifier';
  var __Identifier7Value := aValue.Identifier;
  aValue.Description := 'IFormat.Description';
  var __Description8Value := aValue.Description;
  aValue.Shape := Default(IShape);
  var __Shape9Value := aValue.Shape;
  aValue.RotationStep := Default(TRotation);
  var __RotationStep10Value := aValue.RotationStep;
  aValue.Rotation := Default(TRotation);
  var __Rotation11Value := aValue.Rotation;
  aValue.Mirror := True;
  var __Mirror12Value := aValue.Mirror;
  aValue.Material := Default(IMaterial);
  var __Material13Value := aValue.Material;
  aValue.Surplus := 1;
  var __Surplus14Value := aValue.Surplus;
  aValue.Margin := 1;
  var __Margin15Value := aValue.Margin;
  var __Banding16Value := aValue.Banding;
  var __Grinds17Value := aValue.Grinds;
  aValue.Color := 'IFormat.Color';
  var __Color18Value := aValue.Color;
  aValue.Priority := 1;
  var __Priority19Value := aValue.Priority;
  aValue.Weight := 1.5;
  var __Weight20Value := aValue.Weight;
  aValue.WeightModifier := 1.5;
  var __WeightModifier21Value := aValue.WeightModifier;
  aValue.Group := 1;
  var __Group22Value := aValue.Group;
  aValue.Order := 1;
  var __Order23Value := aValue.Order;
  aValue.SellingPrice := 1.5;
  var __SellingPrice24Value := aValue.SellingPrice;
  aValue.StorageCost := 1.5;
  var __StorageCost25Value := aValue.StorageCost;
  aValue.CustomData := 'IFormat.CustomData';
  var __CustomData26Value := aValue.CustomData;
  var __EffectivePriority27Value := aValue.EffectivePriority;
  var __LeftQuantity28Value := aValue.LeftQuantity;
  var __TotalSurplus29Value := aValue.TotalSurplus;
  var __TotalMargin30Value := aValue.TotalMargin;
  var __TotalLength31Value := aValue.TotalLength;
  var __TotalWidth32Value := aValue.TotalWidth;
  var __TotalField33Value := aValue.TotalField;
  var __GrossLength34Value := aValue.GrossLength;
  var __GrossWidth35Value := aValue.GrossWidth;
  var __OnChange36Value := aValue.OnChange;
  var __OnIdChange37Value := aValue.OnIdChange;
  var __GetShapePathAsString61Result := aValue.GetShapePathAsString(1.5, True, True, True);
  var __GetShapeOffsetInsideBoundingBox62Arg2: Double := 1.5;
  var __GetShapeOffsetInsideBoundingBox62Arg3: Double := 1.5;
  aValue.GetShapeOffsetInsideBoundingBox(1.5, True, __GetShapeOffsetInsideBoundingBox62Arg2, __GetShapeOffsetInsideBoundingBox62Arg3);
  aValue.Assign(Default(IFormat), Default(IProject));
  aValue.UpdateEffectivePriority(True);
  aValue.BeginUpdate();
  aValue.EndUpdate();
end;

procedure TouchIFormatChangeEvent(const aValue: IFormatChangeEvent);
begin
  if not Assigned(aValue) then Exit;
  aValue.Add(Default(IFormatChangeEventHandler));
  aValue.Remove(Default(IFormatChangeEventHandler));
  aValue.Invoke(Default(IUnknown), Default(IFormat), 1);
end;

procedure TouchIFormatChangeEventHandler(const aValue: IFormatChangeEventHandler);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(IUnknown), Default(IFormat), 1);
end;

procedure TouchIFormats(const aValue: IFormats);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
  var __Field2Value := aValue.Field;
  var __Quantity3Value := aValue.Quantity;
  aValue.Loading := True;
  var __Loading4Value := aValue.Loading;
  var __OnAdd5Value := aValue.OnAdd;
  var __OnRemove6Value := aValue.OnRemove;
  var __OnChange7Value := aValue.OnChange;
  aValue.Assign(Default(IFormats));
  aValue.Clear();
  aValue.Reload();
  var __CreateFormat3Result := aValue.CreateFormat();
  aValue.Add(Default(IFormat));
  aValue.DeleteByIndex(1);
  aValue.DeleteById(1);
  aValue.Remove(Default(IFormat));
  var __IndexOf8Result := aValue.IndexOf(Default(IFormat));
  var __IndexOf9Result := aValue.IndexOf(1);
  var __IndexOf10Arg5: Boolean := True;
  var __IndexOf10Arg6: Integer := 1;
  var __IndexOf10Result := aValue.IndexOf([1], Default(IMaterial), 1, 1, Default(TOrnament), __IndexOf10Arg5, __IndexOf10Arg6);
  var __IndexOf11Arg2: Boolean := True;
  var __IndexOf11Result := aValue.IndexOf(Default(IFormat), 1, __IndexOf11Arg2);
  var __Find12Arg2: Boolean := True;
  var __Find12Result := aValue.Find(1, 1, __Find12Arg2);
  var __GetById15Result := aValue.GetById(1);
  var __GetByProject18Result := aValue.GetByProject(Default(IProject));
  aValue.UnloadByProject(Default(IProject));
  aValue.UnloadFormat(Default(IFormat));
  var __CalcMaxLength21Result := aValue.CalcMaxLength();
  aValue.BeginUpdate();
  aValue.EndUpdate();
  var __IsUpdating31Result := aValue.IsUpdating();
end;

procedure TouchIGrind(const aValue: IGrind);
begin
  if not Assigned(aValue) then Exit;
  var __Id0Value := aValue.Id;
  aValue.Title := 'IGrind.Title';
  var __Title1Value := aValue.Title;
  aValue.Thickness := 1;
  var __Thickness2Value := aValue.Thickness;
  aValue.Assign(Default(IGrind));
end;

procedure TouchIGrinds(const aValue: IGrinds);
begin
  if not Assigned(aValue) then Exit;
  aValue.North := Default(IGrind);
  var __North0Value := aValue.North;
  aValue.South := Default(IGrind);
  var __South1Value := aValue.South;
  aValue.West := Default(IGrind);
  var __West2Value := aValue.West;
  aValue.East := Default(IGrind);
  var __East3Value := aValue.East;
  aValue.Top := Default(IGrind);
  var __Top4Value := aValue.Top;
  aValue.Bottom := Default(IGrind);
  var __Bottom5Value := aValue.Bottom;
  aValue.Left := Default(IGrind);
  var __Left6Value := aValue.Left;
  aValue.Right := Default(IGrind);
  var __Right7Value := aValue.Right;
end;

procedure TouchIIdChangeEvent(const aValue: IIdChangeEvent);
begin
  if not Assigned(aValue) then Exit;
  aValue.Add(Default(IIdChangeEventHandler));
  aValue.Remove(Default(IIdChangeEventHandler));
  aValue.Invoke(Default(IUnknown), 1, 1);
end;

procedure TouchIIdChangeEventHandler(const aValue: IIdChangeEventHandler);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(IUnknown), 1, 1);
end;

procedure TouchILinearShape(const aValue: ILinearShape);
begin
  if not Assigned(aValue) then Exit;
  aValue.LeftAngle := 1.5;
  var __LeftAngle0Value := aValue.LeftAngle;
  aValue.RightAngle := 1.5;
  var __RightAngle1Value := aValue.RightAngle;
end;

procedure TouchIMaterial(const aValue: IMaterial);
begin
  if not Assigned(aValue) then Exit;
  aValue.Id := 1;
  var __Id0Value := aValue.Id;
  aValue.Title := 'IMaterial.Title';
  var __Title1Value := aValue.Title;
  aValue.Kind := Default(TMaterialKind);
  var __Kind2Value := aValue.Kind;
  aValue.Width := 1;
  var __Width3Value := aValue.Width;
  aValue.Thickness := 1;
  var __Thickness4Value := aValue.Thickness;
  aValue.HasOrnament := True;
  var __HasOrnament5Value := aValue.HasOrnament;
  aValue.CanRotate := True;
  var __CanRotate6Value := aValue.CanRotate;
  aValue.CanMirror := True;
  var __CanMirror7Value := aValue.CanMirror;
  aValue.Surplus := 1;
  var __Surplus8Value := aValue.Surplus;
  aValue.SurplusEditable := True;
  var __SurplusEditable9Value := aValue.SurplusEditable;
  aValue.Margin := 1;
  var __Margin10Value := aValue.Margin;
  aValue.MarginEditable := True;
  var __MarginEditable11Value := aValue.MarginEditable;
  aValue.DefaultEdging := 1;
  var __DefaultEdging12Value := aValue.DefaultEdging;
  aValue.CuttingDimensions := Default(TCuttingDimensions);
  var __CuttingDimensions13Value := aValue.CuttingDimensions;
  aValue.Bandable := True;
  var __Bandable14Value := aValue.Bandable;
  aValue.Grindable := True;
  var __Grindable15Value := aValue.Grindable;
  aValue.Colorable := True;
  var __Colorable16Value := aValue.Colorable;
  aValue.Device := Default(IDevice);
  var __Device17Value := aValue.Device;
  aValue.Algorithm := 'IMaterial.Algorithm';
  var __Algorithm18Value := aValue.Algorithm;
  aValue.QualityLevel := Default(TQualityLevel);
  var __QualityLevel19Value := aValue.QualityLevel;
  aValue.ReuseWaste := True;
  var __ReuseWaste20Value := aValue.ReuseWaste;
  aValue.MinShorterRecycleSize := 1;
  var __MinShorterRecycleSize21Value := aValue.MinShorterRecycleSize;
  aValue.MinLongerRecycleSize := 1;
  var __MinLongerRecycleSize22Value := aValue.MinLongerRecycleSize;
  aValue.PrefShorterRecycleSize := 1;
  var __PrefShorterRecycleSize23Value := aValue.PrefShorterRecycleSize;
  aValue.PrefLongerRecycleSize := 1;
  var __PrefLongerRecycleSize24Value := aValue.PrefLongerRecycleSize;
  var __EffectiveMinShorterRecycleSize25Value := aValue.EffectiveMinShorterRecycleSize;
  var __EffectiveMinLongerRecycleSize26Value := aValue.EffectiveMinLongerRecycleSize;
  var __EffectivePrefShorterRecycleSize27Value := aValue.EffectivePrefShorterRecycleSize;
  var __EffectivePrefLongerRecycleSize28Value := aValue.EffectivePrefLongerRecycleSize;
  aValue.Kerf := 1;
  var __Kerf29Value := aValue.Kerf;
  aValue.AllowEdgeCuts := True;
  var __AllowEdgeCuts30Value := aValue.AllowEdgeCuts;
  aValue.RecycleEdgingOn := True;
  var __RecycleEdgingOn31Value := aValue.RecycleEdgingOn;
  aValue.RecycleEdging := 1;
  var __RecycleEdging32Value := aValue.RecycleEdging;
  aValue.StackCutting := True;
  var __StackCutting33Value := aValue.StackCutting;
  aValue.StackSize := 1;
  var __StackSize34Value := aValue.StackSize;
  aValue.AllowPartialStack := True;
  var __AllowPartialStack35Value := aValue.AllowPartialStack;
  aValue.MinStackSize := 1;
  var __MinStackSize36Value := aValue.MinStackSize;
  aValue.PricePerSqM := 1.5;
  var __PricePerSqM37Value := aValue.PricePerSqM;
  aValue.WeightOfSqM := 1.5;
  var __WeightOfSqM38Value := aValue.WeightOfSqM;
  aValue.PricePerMeter := 1.5;
  var __PricePerMeter39Value := aValue.PricePerMeter;
  aValue.WeightOfMeter := 1.5;
  var __WeightOfMeter40Value := aValue.WeightOfMeter;
  aValue.CutCostPerMeter := 1.5;
  var __CutCostPerMeter41Value := aValue.CutCostPerMeter;
  aValue.ReuseCost := 1.5;
  var __ReuseCost42Value := aValue.ReuseCost;
  aValue.UtilizationCostPerKg := 1.5;
  var __UtilizationCostPerKg43Value := aValue.UtilizationCostPerKg;
  aValue.SegmentShiftCost := 1.5;
  var __SegmentShiftCost44Value := aValue.SegmentShiftCost;
  aValue.SegmentRotationCost := 1.5;
  var __SegmentRotationCost45Value := aValue.SegmentRotationCost;
  aValue.PriceToCostMultiplier := 1.5;
  var __PriceToCostMultiplier46Value := aValue.PriceToCostMultiplier;
  aValue.ReusableWasteExpectedUsage := 1.5;
  var __ReusableWasteExpectedUsage47Value := aValue.ReusableWasteExpectedUsage;
  aValue.CutExcess := 1;
  var __CutExcess48Value := aValue.CutExcess;
  aValue.CutShiftTotalLimit := 1;
  var __CutShiftTotalLimit49Value := aValue.CutShiftTotalLimit;
  aValue.CutShiftHorzLimit := 1;
  var __CutShiftHorzLimit50Value := aValue.CutShiftHorzLimit;
  aValue.CutShiftVertLimit := 1;
  var __CutShiftVertLimit51Value := aValue.CutShiftVertLimit;
  aValue.CustomData := 'IMaterial.CustomData';
  var __CustomData52Value := aValue.CustomData;
  var __StandardSheets53Value := aValue.StandardSheets;
  var __OnChange54Value := aValue.OnChange;
  var __OnIdChange55Value := aValue.OnIdChange;
  var __OnStandardSheetAdd56Value := aValue.OnStandardSheetAdd;
  var __OnStandardSheetRemove57Value := aValue.OnStandardSheetRemove;
  var __OnStandardSheetChange58Value := aValue.OnStandardSheetChange;
  aValue.Assign(Default(IMaterial));
  aValue.BeginUpdate();
  aValue.EndUpdate();
end;

procedure TouchIMaterialChangeEvent(const aValue: IMaterialChangeEvent);
begin
  if not Assigned(aValue) then Exit;
  aValue.Add(Default(IMaterialChangeEventHandler));
  aValue.Remove(Default(IMaterialChangeEventHandler));
  aValue.Invoke(Default(IUnknown), Default(IMaterial), 1);
end;

procedure TouchIMaterialChangeEventHandler(const aValue: IMaterialChangeEventHandler);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(IUnknown), Default(IMaterial), 1);
end;

procedure TouchIMaterials(const aValue: IMaterials);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
  var __OnAdd2Value := aValue.OnAdd;
  var __OnRemove3Value := aValue.OnRemove;
  var __CreateMaterial0Result := aValue.CreateMaterial();
  var __CreateStandardSheet1Result := aValue.CreateStandardSheet();
  aValue.Add(Default(IMaterial));
  aValue.DeleteByIndex(1);
  aValue.DeleteById(1);
  aValue.Remove(Default(IMaterial));
  var __IndexOf6Result := aValue.IndexOf(Default(IMaterial));
  var __IndexOf7Result := aValue.IndexOf(1);
  var __FindDuplicate8Result := aValue.FindDuplicate(Default(IMaterial), True);
  var __FindByTitle9Result := aValue.FindByTitle('aTitle1', Default(TMaterialKind), 1, 1);
  var __FindUniqueName10Result := aValue.FindUniqueName('aBaseName1', Default(TMaterialKind), 1, 1);
  var __CheckUniqueName11Result := aValue.CheckUniqueName('aTitle1', Default(TMaterialKind), 1, 1, Default(IMaterial));
  var __CheckUniqueName12Result := aValue.CheckUniqueName(Default(IMaterial), True);
  var __GetById15Result := aValue.GetById(1);
  aValue.Reload();
end;

procedure TouchINotifyEvent(const aValue: INotifyEvent);
begin
  if not Assigned(aValue) then Exit;
  aValue.Add(Default(INotifyEventHandler));
  aValue.Remove(Default(INotifyEventHandler));
  aValue.Invoke(Default(IUnknown));
end;

procedure TouchINotifyEventHandler(const aValue: INotifyEventHandler);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(IUnknown));
end;

procedure TouchIProject(const aValue: IProject);
begin
  if not Assigned(aValue) then Exit;
  aValue.Id := 1;
  var __Id0Value := aValue.Id;
  aValue.Title := 'IProject.Title';
  var __Title1Value := aValue.Title;
  aValue.Description := 'IProject.Description';
  var __Description2Value := aValue.Description;
  aValue.Priority := Default(TProjectPriority);
  var __Priority3Value := aValue.Priority;
  aValue.CreateDate := 1.5;
  var __CreateDate4Value := aValue.CreateDate;
  aValue.TargetDate := 1.5;
  var __TargetDate5Value := aValue.TargetDate;
  aValue.State := Default(TProjectState);
  var __State6Value := aValue.State;
  aValue.Loading := True;
  var __Loading7Value := aValue.Loading;
  aValue.Loaded := True;
  var __Loaded8Value := aValue.Loaded;
  aValue.PieceCount := 1;
  var __PieceCount9Value := aValue.PieceCount;
  aValue.PieceField2D := Default(TField);
  var __PieceField2D10Value := aValue.PieceField2D;
  aValue.PieceLength1D := Default(TField);
  var __PieceLength1D11Value := aValue.PieceLength1D;
  aValue.ProcessedCount := 1;
  var __ProcessedCount12Value := aValue.ProcessedCount;
  aValue.ProcessedField2D := Default(TField);
  var __ProcessedField2D13Value := aValue.ProcessedField2D;
  aValue.ProcessedLength1D := Default(TField);
  var __ProcessedLength1D14Value := aValue.ProcessedLength1D;
  aValue.MaterialGroupCount := 1;
  var __MaterialGroupCount15Value := aValue.MaterialGroupCount;
  var __OnChange16Value := aValue.OnChange;
  var __OnIdChange17Value := aValue.OnIdChange;
  var __Clone34Result := aValue.Clone();
  aValue.Assign(Default(IProject));
  aValue.UpdateStats(Default(IUnknown));
  aValue.FormatAdded(Default(IUnknown));
  aValue.FormatRemoved(Default(IUnknown));
  aValue.FormatChanged(Default(IUnknown));
  aValue.FormatIdChanged(Default(IUnknown), 1, 1);
  aValue.GetFormats(Default(IUnknown), Default(IUnknown), True);
  aValue.BeginUpdate();
  aValue.EndUpdate();
end;

procedure TouchIProjectChangeEvent(const aValue: IProjectChangeEvent);
begin
  if not Assigned(aValue) then Exit;
  aValue.Add(Default(IProjectChangeEventHandler));
  aValue.Remove(Default(IProjectChangeEventHandler));
  aValue.Invoke(Default(IUnknown), Default(IProject), 1);
end;

procedure TouchIProjectChangeEventHandler(const aValue: IProjectChangeEventHandler);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(IUnknown), Default(IProject), 1);
end;

procedure TouchIProjects(const aValue: IProjects);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
  var __OnAdd2Value := aValue.OnAdd;
  var __OnRemove3Value := aValue.OnRemove;
  var __OnChange4Value := aValue.OnChange;
  var __CreateProject0Result := aValue.CreateProject();
  aValue.Add(Default(IProject));
  aValue.DeleteByIndex(1);
  aValue.DeleteById(1);
  aValue.Remove(Default(IProject));
  var __IndexOf5Result := aValue.IndexOf(Default(IProject));
  var __IndexOf6Result := aValue.IndexOf(1);
  var __FindDuplicate7Result := aValue.FindDuplicate(Default(IProject), True);
  var __FindByTitle8Result := aValue.FindByTitle('aTitle1');
  var __FindUniqueName9Result := aValue.FindUniqueName('aBaseName1');
  var __CheckUniqueName10Result := aValue.CheckUniqueName('aTitle1', Default(IProject));
  var __CheckUniqueName11Result := aValue.CheckUniqueName(Default(IProject), True);
  var __GetById14Result := aValue.GetById(1);
  aValue.Load(1.5, True, True);
  aValue.Reload();
  aValue.BeginUpdate();
  aValue.EndUpdate();
  var __IsUpdating22Result := aValue.IsUpdating();
end;

procedure TouchIRectangle(const aValue: IRectangle);
begin
  if not Assigned(aValue) then Exit;
  aValue.North := 1;
  var __North0Value := aValue.North;
  aValue.South := 1;
  var __South1Value := aValue.South;
  aValue.West := 1;
  var __West2Value := aValue.West;
  aValue.East := 1;
  var __East3Value := aValue.East;
  aValue.Top := 1;
  var __Top4Value := aValue.Top;
  aValue.Bottom := 1;
  var __Bottom5Value := aValue.Bottom;
  aValue.Left := 1;
  var __Left6Value := aValue.Left;
  aValue.Right := 1;
  var __Right7Value := aValue.Right;
  var __OnChange8Value := aValue.OnChange;
  aValue.Assign(Default(IRectangle));
  aValue.BeginUpdate();
  aValue.EndUpdate();
end;

procedure TouchIResult(const aValue: IResult);
begin
  if not Assigned(aValue) then Exit;
  aValue.Id := 1;
  var __Id0Value := aValue.Id;
  aValue.Title := 'IResult.Title';
  var __Title1Value := aValue.Title;
  aValue.Date := 1.5;
  var __Date2Value := aValue.Date;
  aValue.WasUsedElementsMarked := True;
  var __WasUsedElementsMarked3Value := aValue.WasUsedElementsMarked;
  aValue.WasStockUpdated := True;
  var __WasStockUpdated4Value := aValue.WasStockUpdated;
  aValue.WasReusableWasteAddedToStocks := True;
  var __WasReusableWasteAddedToStocks5Value := aValue.WasReusableWasteAddedToStocks;
  aValue.Cancelled := True;
  var __Cancelled6Value := aValue.Cancelled;
  aValue.SheetCount := 1;
  var __SheetCount7Value := aValue.SheetCount;
  aValue.PieceCount := 1;
  var __PieceCount8Value := aValue.PieceCount;
  aValue.SheetField2d := 1;
  var __SheetField2d9Value := aValue.SheetField2d;
  aValue.PieceField2d := 1;
  var __PieceField2d10Value := aValue.PieceField2d;
  aValue.WasteField2d := 1;
  var __WasteField2d11Value := aValue.WasteField2d;
  aValue.RecycledField2d := 1;
  var __RecycledField2d12Value := aValue.RecycledField2d;
  aValue.CutCount2d := 1;
  var __CutCount2d13Value := aValue.CutCount2d;
  aValue.CutLength2d := 1.5;
  var __CutLength2d14Value := aValue.CutLength2d;
  aValue.SheetLength1d := 1;
  var __SheetLength1d15Value := aValue.SheetLength1d;
  aValue.PieceLength1d := 1;
  var __PieceLength1d16Value := aValue.PieceLength1d;
  aValue.WasteLength1d := 1;
  var __WasteLength1d17Value := aValue.WasteLength1d;
  aValue.RecycledLength1d := 1;
  var __RecycledLength1d18Value := aValue.RecycledLength1d;
  aValue.CutCount1d := 1;
  var __CutCount1d19Value := aValue.CutCount1d;
  var __OnChange20Value := aValue.OnChange;
  var __OnIdChange21Value := aValue.OnIdChange;
end;

procedure TouchIResultChangeEvent(const aValue: IResultChangeEvent);
begin
  if not Assigned(aValue) then Exit;
  aValue.Add(Default(IResultChangeEventHandler));
  aValue.Remove(Default(IResultChangeEventHandler));
  aValue.Invoke(Default(IUnknown), Default(IResult), 1);
end;

procedure TouchIResultChangeEventHandler(const aValue: IResultChangeEventHandler);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(IUnknown), Default(IResult), 1);
end;

procedure TouchIResults(const aValue: IResults);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
  var __OnAdd2Value := aValue.OnAdd;
  var __OnRemove3Value := aValue.OnRemove;
  var __CreateResult0Result := aValue.CreateResult();
  aValue.Add(Default(IResult));
  aValue.DeleteByIndex(1);
  aValue.DeleteById(1);
  aValue.Remove(Default(IResult));
  var __IndexOf5Result := aValue.IndexOf(Default(IResult));
  var __IndexOf6Result := aValue.IndexOf(1);
  var __GetById9Result := aValue.GetById(1);
  aValue.Reload();
end;

procedure TouchIShape(const aValue: IShape);
begin
  if not Assigned(aValue) then Exit;
  var __ShapeType0Value := aValue.ShapeType;
  var __EdgeCount1Value := aValue.EdgeCount;
  var __ParamCount2Value := aValue.ParamCount;
  var __OnChange3Value := aValue.OnChange;
  var __SaveToString1Result := aValue.SaveToString(Default(TLengthUnits), Default(TAngleUnits));
  var __LoadFromString2Result := aValue.LoadFromString('aString1', Default(TLengthUnits), Default(TAngleUnits));
  var __GetNetPath3Result := aValue.GetNetPath(1, 1, 1, 1);
  var __GetGrossPath4Result := aValue.GetGrossPath(1, 1, 1, 1);
  var __GetEdgeInfo6Arg1: WideString := 'aName2';
  var __GetEdgeInfo6Arg2: WideString := 'aTitle3';
  var __GetEdgeInfo6Result := aValue.GetEdgeInfo(1, __GetEdgeInfo6Arg1, __GetEdgeInfo6Arg2);
  var __GetEdgeBandByIndex7Result := aValue.GetEdgeBandByIndex(1);
  aValue.SetEdgeBandByIndex(1, Default(IBand));
  var __GetEdgeBandByName9Result := aValue.GetEdgeBandByName('aName1');
  aValue.SetEdgeBandByName('aName1', Default(IBand));
  var __GetParamInfo12Arg1: WideString := 'aName2';
  var __GetParamInfo12Arg2: WideString := 'aTitle3';
  var __GetParamInfo12Arg3: TShapeParamType := Default(TShapeParamType);
  var __GetParamInfo12Result := aValue.GetParamInfo(1, __GetParamInfo12Arg1, __GetParamInfo12Arg2, __GetParamInfo12Arg3);
  var __GetParamByIndex13Result := aValue.GetParamByIndex(1);
  aValue.SetParamByIndex(1, 1);
  var __GetParamByName15Result := aValue.GetParamByName('aName1');
  aValue.SetParamByName('aName1', 1);
  var __IsSame17Result := aValue.IsSame(Default(IShape));
end;

procedure TouchISheet(const aValue: ISheet);
begin
  if not Assigned(aValue) then Exit;
  aValue.Id := 1;
  var __Id0Value := aValue.Id;
  aValue.Width := 1;
  var __Width1Value := aValue.Width;
  aValue.Length := 1;
  var __Length2Value := aValue.Length;
  aValue.Quantity := 1;
  var __Quantity3Value := aValue.Quantity;
  aValue.StackSize := 1;
  var __StackSize4Value := aValue.StackSize;
  aValue.Ornament := Default(TOrnament);
  var __Ornament5Value := aValue.Ornament;
  aValue.Identifier := 'ISheet.Identifier';
  var __Identifier6Value := aValue.Identifier;
  aValue.Description := 'ISheet.Description';
  var __Description7Value := aValue.Description;
  aValue.Material := Default(IMaterial);
  var __Material8Value := aValue.Material;
  var __Edging9Value := aValue.Edging;
  aValue.Priority := Default(TStockPriority);
  var __Priority10Value := aValue.Priority;
  aValue.CutShiftHorzLimit := 1;
  var __CutShiftHorzLimit11Value := aValue.CutShiftHorzLimit;
  aValue.CutShiftVertLimit := 1;
  var __CutShiftVertLimit12Value := aValue.CutShiftVertLimit;
  var __EffectiveCutShiftHorzLimit13Value := aValue.EffectiveCutShiftHorzLimit;
  var __EffectiveCutShiftVertLimit14Value := aValue.EffectiveCutShiftVertLimit;
  aValue.ExtractionCost := 1.5;
  var __ExtractionCost15Value := aValue.ExtractionCost;
  aValue.CustomData := 'ISheet.CustomData';
  var __CustomData16Value := aValue.CustomData;
  var __Defects17Value := aValue.Defects;
  var __AvailableQuantity18Value := aValue.AvailableQuantity;
  var __Field19Value := aValue.Field;
  var __FieldOfAll20Value := aValue.FieldOfAll;
  var __OnChange21Value := aValue.OnChange;
  var __OnIdChange22Value := aValue.OnIdChange;
  var __OnDefectAdd23Value := aValue.OnDefectAdd;
  var __OnDefectRemove24Value := aValue.OnDefectRemove;
  var __OnDefectChange25Value := aValue.OnDefectChange;
  var __IsStandard35Result := aValue.IsStandard();
  aValue.Assign(Default(ISheet));
  aValue.BeginUpdate();
  aValue.EndUpdate();
end;

procedure TouchISheetChangeEvent(const aValue: ISheetChangeEvent);
begin
  if not Assigned(aValue) then Exit;
  aValue.Add(Default(ISheetChangeEventHandler));
  aValue.Remove(Default(ISheetChangeEventHandler));
  aValue.Invoke(Default(IUnknown), Default(ISheet), 1);
end;

procedure TouchISheetChangeEventHandler(const aValue: ISheetChangeEventHandler);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(IUnknown), Default(ISheet), 1);
end;

procedure TouchISheetDefect(const aValue: ISheetDefect);
begin
  if not Assigned(aValue) then Exit;
  aValue.PosX := 1;
  var __PosX0Value := aValue.PosX;
  aValue.PosY := 1;
  var __PosY1Value := aValue.PosY;
  aValue.Length := 1;
  var __Length2Value := aValue.Length;
  aValue.Width := 1;
  var __Width3Value := aValue.Width;
  var __OnChange4Value := aValue.OnChange;
  aValue.Assign(Default(ISheetDefect));
  aValue.BeginUpdate();
  aValue.EndUpdate();
end;

procedure TouchISheetDefectChangeEvent(const aValue: ISheetDefectChangeEvent);
begin
  if not Assigned(aValue) then Exit;
  aValue.Add(Default(ISheetDefectChangeEventHandler));
  aValue.Remove(Default(ISheetDefectChangeEventHandler));
  aValue.Invoke(Default(IUnknown), Default(ISheetDefect), 1);
end;

procedure TouchISheetDefectChangeEventHandler(const aValue: ISheetDefectChangeEventHandler);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(IUnknown), Default(ISheetDefect), 1);
end;

procedure TouchISheetDefects(const aValue: ISheetDefects);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
  var __OnAdd2Value := aValue.OnAdd;
  var __OnRemove3Value := aValue.OnRemove;
  aValue.Assign(Default(ISheetDefects));
  aValue.Clear();
  aValue.Add(Default(ISheetDefect));
  aValue.DeleteByIndex(1);
  aValue.Remove(Default(ISheetDefect));
  var __IndexOf5Result := aValue.IndexOf(Default(ISheetDefect));
  var __Find6Result := aValue.Find(1, 1, 1, 1);
end;

procedure TouchISheets(const aValue: ISheets);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
  var __Field2Value := aValue.Field;
  var __AvailableQuantity3Value := aValue.AvailableQuantity;
  var __OnAdd4Value := aValue.OnAdd;
  var __OnRemove5Value := aValue.OnRemove;
  var __OnChange6Value := aValue.OnChange;
  var __CreateSheet0Result := aValue.CreateSheet();
  aValue.Add(Default(ISheet));
  aValue.DeleteByIndex(1);
  aValue.DeleteById(1);
  aValue.Remove(Default(ISheet));
  var __IndexOf5Result := aValue.IndexOf(Default(ISheet));
  var __IndexOf6Result := aValue.IndexOf(1);
  var __IndexOf7Arg2: Boolean := True;
  var __IndexOf7Result := aValue.IndexOf(Default(ISheet), 1, __IndexOf7Arg2);
  var __CreateDefect8Result := aValue.CreateDefect();
  var __GetById11Result := aValue.GetById(1);
  var __CalcMaxLength12Result := aValue.CalcMaxLength();
  aValue.BeginUpdate();
  aValue.EndUpdate();
  var __IsUpdating20Result := aValue.IsUpdating();
  aValue.Reload();
end;

procedure TouchISolution(const aValue: ISolution);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
  var __CalcCutsInfoByMaterial2Arg1: Integer := 1;
  var __CalcCutsInfoByMaterial2Arg2: Double := 1.5;
  aValue.CalcCutsInfoByMaterial(Default(IMaterial), __CalcCutsInfoByMaterial2Arg1, __CalcCutsInfoByMaterial2Arg2);
end;

procedure TouchISolutionCut(const aValue: ISolutionCut);
begin
  if not Assigned(aValue) then Exit;
  var __Kind0Value := aValue.Kind;
  var __PosX1Value := aValue.PosX;
  var __PosY2Value := aValue.PosY;
  var __TarX3Value := aValue.TarX;
  var __TarY4Value := aValue.TarY;
  var __PosXp5Value := aValue.PosXp;
  var __PosYp6Value := aValue.PosYp;
  var __TarXp7Value := aValue.TarXp;
  var __TarYp8Value := aValue.TarYp;
  var __NeedShift9Value := aValue.NeedShift;
  var __CalcLength10Result := aValue.CalcLength();
end;

procedure TouchISolutionCuts(const aValue: ISolutionCuts);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
end;

procedure TouchISolutionFormat(const aValue: ISolutionFormat);
begin
  if not Assigned(aValue) then Exit;
  var __Format0Value := aValue.Format;
  var __X1Value := aValue.X;
  var __Y2Value := aValue.Y;
  var __Rotation3Value := aValue.Rotation;
  var __Mirrored4Value := aValue.Mirrored;
end;

procedure TouchISolutionFormats(const aValue: ISolutionFormats);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
end;

procedure TouchISolutionSheet(const aValue: ISolutionSheet);
begin
  if not Assigned(aValue) then Exit;
  var __Sheet0Value := aValue.Sheet;
  var __SolutionFormats1Value := aValue.SolutionFormats;
  var __SolutionWastes2Value := aValue.SolutionWastes;
  var __SolutionCuts3Value := aValue.SolutionCuts;
  var __Quantity4Value := aValue.Quantity;
  var __Index5Value := aValue.Index;
  var __Rotation6Value := aValue.Rotation;
  var __Mirror7Value := aValue.Mirror;
  aValue.IsSaved := True;
  var __IsSaved8Value := aValue.IsSaved;
  aValue.IsPlotted := True;
  var __IsPlotted9Value := aValue.IsPlotted;
  var __GetEffectiveModificator12Arg0: Integer := 1;
  var __GetEffectiveModificator12Arg1: TMirrors := Default(TMirrors);
  aValue.GetEffectiveModificator(__GetEffectiveModificator12Arg0, __GetEffectiveModificator12Arg1);
  var __GetOriginPoint13Arg0: Integer := 1;
  var __GetOriginPoint13Arg1: Integer := 1;
  aValue.GetOriginPoint(__GetOriginPoint13Arg0, __GetOriginPoint13Arg1);
  var __CalcPoint14Arg0: Integer := 1;
  var __CalcPoint14Arg1: Integer := 1;
  aValue.CalcPoint(__CalcPoint14Arg0, __CalcPoint14Arg1);
  var __UnCalcPoint15Arg0: Integer := 1;
  var __UnCalcPoint15Arg1: Integer := 1;
  aValue.UnCalcPoint(__UnCalcPoint15Arg0, __UnCalcPoint15Arg1);
  var __CalcPointF16Arg0: Double := 1.5;
  var __CalcPointF16Arg1: Double := 1.5;
  aValue.CalcPointF(__CalcPointF16Arg0, __CalcPointF16Arg1);
  var __UnCalcPointF17Arg0: Double := 1.5;
  var __UnCalcPointF17Arg1: Double := 1.5;
  aValue.UnCalcPointF(__UnCalcPointF17Arg0, __UnCalcPointF17Arg1);
  var __GetDirection18Arg0: Integer := 1;
  var __GetDirection18Arg1: Integer := 1;
  aValue.GetDirection(__GetDirection18Arg0, __GetDirection18Arg1);
  var __CalcEffectiveLayout19Arg0: Cardinal := 1;
  var __CalcEffectiveLayout19Arg1: Cardinal := 1;
  var __CalcEffectiveLayout19Arg2: Cardinal := 1;
  var __CalcEffectiveLayout19Arg3: Cardinal := 1;
  var __CalcEffectiveLayout19Arg4: Cardinal := 1;
  var __CalcEffectiveLayout19Arg5: Cardinal := 1;
  aValue.CalcEffectiveLayout(__CalcEffectiveLayout19Arg0, __CalcEffectiveLayout19Arg1, __CalcEffectiveLayout19Arg2, __CalcEffectiveLayout19Arg3, __CalcEffectiveLayout19Arg4, __CalcEffectiveLayout19Arg5);
  var __CalcRecycledField20Result := aValue.CalcRecycledField(1, 1);
  var __CalcCutsInfo21Arg0: Integer := 1;
  var __CalcCutsInfo21Arg1: Double := 1.5;
  aValue.CalcCutsInfo(__CalcCutsInfo21Arg0, __CalcCutsInfo21Arg1);
end;

procedure TouchISolutionWaste(const aValue: ISolutionWaste);
begin
  if not Assigned(aValue) then Exit;
  var __X0Value := aValue.X;
  var __Y1Value := aValue.Y;
  var __Length2Value := aValue.Length;
  var __Width3Value := aValue.Width;
  var __Shape4Value := aValue.Shape;
  var __Field5Value := aValue.Field;
  var __Identifier6Value := aValue.Identifier;
  var __GetShapePathAsString7Result := aValue.GetShapePathAsString();
end;

procedure TouchISolutionWastes(const aValue: ISolutionWastes);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
end;

procedure TouchIStandardSheet(const aValue: IStandardSheet);
begin
  if not Assigned(aValue) then Exit;
  aValue.Id := 1;
  var __Id0Value := aValue.Id;
  aValue.Title := 'IStandardSheet.Title';
  var __Title1Value := aValue.Title;
  aValue.Length := 1;
  var __Length2Value := aValue.Length;
  aValue.Width := 1;
  var __Width3Value := aValue.Width;
  aValue.Ornament := Default(TOrnament);
  var __Ornament4Value := aValue.Ornament;
  var __Edging5Value := aValue.Edging;
  var __OnChange6Value := aValue.OnChange;
  var __OnIdChange7Value := aValue.OnIdChange;
  aValue.Assign(Default(IStandardSheet));
  aValue.BeginUpdate();
  aValue.EndUpdate();
end;

procedure TouchIStandardSheetChangeEvent(const aValue: IStandardSheetChangeEvent);
begin
  if not Assigned(aValue) then Exit;
  aValue.Add(Default(IStandardSheetChangeEventHandler));
  aValue.Remove(Default(IStandardSheetChangeEventHandler));
  aValue.Invoke(Default(IUnknown), Default(IStandardSheet), 1);
end;

procedure TouchIStandardSheetChangeEventHandler(const aValue: IStandardSheetChangeEventHandler);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(IUnknown), Default(IStandardSheet), 1);
end;

procedure TouchIStandardSheets(const aValue: IStandardSheets);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
  var __OnAdd2Value := aValue.OnAdd;
  var __OnRemove3Value := aValue.OnRemove;
  aValue.Assign(Default(IStandardSheets));
  aValue.Clear();
  aValue.Add(Default(IStandardSheet));
  aValue.DeleteByIndex(1);
  aValue.Remove(Default(IStandardSheet));
  var __IndexOf5Result := aValue.IndexOf(Default(IStandardSheet));
  var __Find6Result := aValue.Find(1, 1, Default(TOrnament), 1, 1, 1, 1);
  var __Find7Result := aValue.Find(1, 1, 1, 1, 1, 1);
  var __CheckUniqueName8Result := aValue.CheckUniqueName('aTitle1', Default(IStandardSheet));
end;

procedure TouchITcEnumExtensionsCallback(const aValue: ITcEnumExtensionsCallback);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(TTcpExtensionType), 'aExtension2', 'aName3');
end;

procedure TouchITcPlotterInfo(const aValue: ITcPlotterInfo);
begin
  if not Assigned(aValue) then Exit;
  aValue.PlotterType := Default(TTcPlotterType);
  var __PlotterType0Value := aValue.PlotterType;
  aValue.MaterialKinds := Default(TMaterialKinds);
  var __MaterialKinds1Value := aValue.MaterialKinds;
  aValue.AxisX := Default(TTcAxisDirection);
  var __AxisX2Value := aValue.AxisX;
  aValue.AxisY := Default(TTcAxisDirection);
  var __AxisY3Value := aValue.AxisY;
  aValue.SizeX := 1;
  var __SizeX4Value := aValue.SizeX;
  aValue.SizeY := 1;
  var __SizeY5Value := aValue.SizeY;
  aValue.CanCrossCuts := True;
  var __CanCrossCuts6Value := aValue.CanCrossCuts;
  aValue.FullCutsOnly := True;
  var __FullCutsOnly7Value := aValue.FullCutsOnly;
  aValue.CanCutAnyShapes := True;
  var __CanCutAnyShapes8Value := aValue.CanCutAnyShapes;
  aValue.StripCuts := Default(TStripCutting);
  var __StripCuts9Value := aValue.StripCuts;
  aValue.MaxStripeWidth := 1;
  var __MaxStripeWidth10Value := aValue.MaxStripeWidth;
  aValue.CutsDepthOn := True;
  var __CutsDepthOn11Value := aValue.CutsDepthOn;
  aValue.CutsDepth := 1;
  var __CutsDepth12Value := aValue.CutsDepth;
  aValue.CutsDepthIncMargins := True;
  var __CutsDepthIncMargins13Value := aValue.CutsDepthIncMargins;
  aValue.TwoDimensionMoves := True;
  var __TwoDimensionMoves14Value := aValue.TwoDimensionMoves;
  aValue.PrefferedDirection := Default(TTcMoveDirection);
  var __PrefferedDirection15Value := aValue.PrefferedDirection;
  aValue.MarginWest := 1;
  var __MarginWest16Value := aValue.MarginWest;
  aValue.MarginNorth := 1;
  var __MarginNorth17Value := aValue.MarginNorth;
  aValue.MarginEast := 1;
  var __MarginEast18Value := aValue.MarginEast;
  aValue.MarginSouth := 1;
  var __MarginSouth19Value := aValue.MarginSouth;
  aValue.BridgeMoveDirection := Default(TTcMoveDirection);
  var __BridgeMoveDirection20Value := aValue.BridgeMoveDirection;
  aValue.BridgeSize := 1;
  var __BridgeSize21Value := aValue.BridgeSize;
  aValue.HeadSize := 1;
  var __HeadSize22Value := aValue.HeadSize;
  aValue.HeadKnifeSpace := 1;
  var __HeadKnifeSpace23Value := aValue.HeadKnifeSpace;
  aValue.DefaultRotation := 1;
  var __DefaultRotation24Value := aValue.DefaultRotation;
  aValue.DefaultMirror := Default(TMirrors);
  var __DefaultMirror25Value := aValue.DefaultMirror;
  aValue.Assign(Default(ITcPlotterInfo));
end;

procedure TouchITcPlugin(const aValue: ITcPlugin);
begin
  if not Assigned(aValue) then Exit;
  var __EngineVersion0Value := aValue.EngineVersion;
  var __Name1Value := aValue.Name;
  var __Version2Value := aValue.Version;
  var __Title3Value := aValue.Title;
  var __RegRoot4Value := aValue.RegRoot;
  aValue.LanguageId := 1;
  var __LanguageId5Value := aValue.LanguageId;
  var __Professional6Value := aValue.Professional;
  aValue.UiScale := 1.5;
  var __UiScale7Value := aValue.UiScale;
  var __TonCut8Value := aValue.TonCut;
  var __Features9Value := aValue.Features;
  var __PlotterInfo10Value := aValue.PlotterInfo;
  var __Initialize13Result := aValue.Initialize('aRegRoot1', 1, Default(ITonCut));
  var __Finalize14Result := aValue.Finalize();
  var __Configure15Result := aValue.Configure(0);
  var __About16Result := aValue.About(0);
  var __LoadConfig17Result := aValue.LoadConfig('aKey1', 'aVersion2');
  var __SaveConfig18Result := aValue.SaveConfig('aKey1');
  var __BackupConfig19Arg0: WideString := 'aBackup1';
  var __BackupConfig19Result := aValue.BackupConfig(__BackupConfig19Arg0);
  var __RestoreConfig20Result := aValue.RestoreConfig('aBackup1', Default(TConfigurationParts));
  var __EnumExtensions21Result := aValue.EnumExtensions(Default(TTcpExtensionType), Default(ITcEnumExtensionsCallback));
  var __IsMyFile22Result := aValue.IsMyFile('aFileName1');
  var __LoadFile23Result := aValue.LoadFile(0, 'aFileName2', Default(IDevices), Default(IMaterials), Default(IBands), Default(IProjects), Default(IFormats), Default(ISheets));
  var __SaveFile24Result := aValue.SaveFile(0, 'aFileName2', Default(IFormats), Default(ISheets));
  var __SaveResult25Result := aValue.SaveResult(0, 'aFileName2', Default(ISolutionSheet));
  var __BatchSaveResult26Result := aValue.BatchSaveResult(0, Default(TTcpSaveTarget), 'aPath3', Default(ISolution));
  var __Plot27Result := aValue.Plot(0, Default(ISolutionSheet));
  var __BatchPlot28Result := aValue.BatchPlot(0, Default(ISolution));
  var __SavePlot29Result := aValue.SavePlot(0, 'aFileName2', Default(ISolutionSheet));
  var __BatchSavePlot30Result := aValue.BatchSavePlot(0, Default(TTcpSaveTarget), 'aPath3', Default(ISolution));
end;

procedure TouchITemplate(const aValue: ITemplate);
begin
  if not Assigned(aValue) then Exit;
  aValue.Id := 1;
  var __Id0Value := aValue.Id;
  aValue.Title := 'ITemplate.Title';
  var __Title1Value := aValue.Title;
  aValue.Description := 'ITemplate.Description';
  var __Description2Value := aValue.Description;
  var __Formats3Value := aValue.Formats;
  var __OnChange4Value := aValue.OnChange;
  var __OnIdChange5Value := aValue.OnIdChange;
  var __OnFormatAdd6Value := aValue.OnFormatAdd;
  var __OnFormatRemove7Value := aValue.OnFormatRemove;
  var __OnFormatChange8Value := aValue.OnFormatChange;
  aValue.Assign(Default(ITemplate));
  aValue.BeginUpdate();
  aValue.EndUpdate();
end;

procedure TouchITemplateChangeEvent(const aValue: ITemplateChangeEvent);
begin
  if not Assigned(aValue) then Exit;
  aValue.Add(Default(ITemplateChangeEventHandler));
  aValue.Remove(Default(ITemplateChangeEventHandler));
  aValue.Invoke(Default(IUnknown), Default(ITemplate), 1);
end;

procedure TouchITemplateChangeEventHandler(const aValue: ITemplateChangeEventHandler);
begin
  if not Assigned(aValue) then Exit;
  aValue.Invoke(Default(IUnknown), Default(ITemplate), 1);
end;

procedure TouchITemplates(const aValue: ITemplates);
begin
  if not Assigned(aValue) then Exit;
  var __Count0Value := aValue.Count;
  var __Items1Value := aValue.Items[1];
  var __OnAdd2Value := aValue.OnAdd;
  var __OnRemove3Value := aValue.OnRemove;
  var __CreateTemplate0Result := aValue.CreateTemplate();
  var __CreateFormat1Result := aValue.CreateFormat();
  aValue.Add(Default(ITemplate));
  aValue.DeleteByIndex(1);
  aValue.DeleteById(1);
  aValue.Remove(Default(ITemplate));
  var __IndexOf6Result := aValue.IndexOf(Default(ITemplate));
  var __IndexOf7Result := aValue.IndexOf(1);
  var __CheckUniqueName8Result := aValue.CheckUniqueName('aTitle1', Default(ITemplate));
  var __CheckUniqueName9Result := aValue.CheckUniqueName(Default(ITemplate));
  var __GetById12Result := aValue.GetById(1);
  aValue.Reload();
end;

procedure TouchITonCut(const aValue: ITonCut);
begin
  if not Assigned(aValue) then Exit;
  var __Units0Value := aValue.Units;
  var __Precision1Value := aValue.Precision;
  var __PieceIdentification2Value := aValue.PieceIdentification;
  var __UsingProjects3Value := aValue.UsingProjects;
  var __SelectedProject4Value := aValue.SelectedProject;
  var __Devices5Value := aValue.Devices;
  var __Materials6Value := aValue.Materials;
  var __Bands7Value := aValue.Bands;
  var __Sheets8Value := aValue.Sheets;
  var __Templates9Value := aValue.Templates;
  var __Projects10Value := aValue.Projects;
  var __Formats11Value := aValue.Formats;
  var __Results12Value := aValue.Results;
  var __Solution13Value := aValue.Solution;
  aValue.CreateSolution();
  aValue.ReleaseSolution();
  var __CreateMaterial16Result := aValue.CreateMaterial('aTitle1', Default(TMaterialKind), 1, 1);
  var __CreateBand17Result := aValue.CreateBand('aTitle1', 1, 1, 1, 1);
  var __CreateProject18Result := aValue.CreateProject('aTitle1');
  var __CanCutAnyShapes19Result := aValue.CanCutAnyShapes(Default(IDevice));
  var __FormatLength20Result := aValue.FormatLength(1, True);
  var __FormatLength21Result := aValue.FormatLength(1.5, True);
  var __HumanReadableLength22Result := aValue.HumanReadableLength(1.5, True);
  var __FormatField23Result := aValue.FormatField(Default(TField), True);
  var __HumanReadableField24Result := aValue.HumanReadableField(Default(TField), True);
  var __HumanReadableField25Result := aValue.HumanReadableField(1.5, True);
  var __FormatDegrees26Result := aValue.FormatDegrees(1.5, True);
  var __FormatRadians27Result := aValue.FormatRadians(1.5, True);
end;

procedure TouchAllSupportedInterfaces(const aTonCut: ITonCut);
begin
  if Assigned(aTonCut) then
  begin
    TouchITonCut(aTonCut);
    TouchIProject(aTonCut.SelectedProject);
    TouchIDevices(aTonCut.Devices);
    TouchIMaterials(aTonCut.Materials);
    TouchIBands(aTonCut.Bands);
    TouchISheets(aTonCut.Sheets);
    TouchITemplates(aTonCut.Templates);
    TouchIProjects(aTonCut.Projects);
    TouchIFormats(aTonCut.Formats);
    TouchIResults(aTonCut.Results);
    TouchISolution(aTonCut.Solution);
    TouchIMaterial(aTonCut.CreateMaterial('aTitle1', Default(TMaterialKind), 1, 1));
    TouchIBand(aTonCut.CreateBand('aTitle1', 1, 1, 1, 1));
    TouchIProject(aTonCut.CreateProject('aTitle1'));
  end;
end;

end.
