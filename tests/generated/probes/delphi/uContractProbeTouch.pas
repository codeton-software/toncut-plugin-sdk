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
  uITcAlgorithmData,
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
  aValue.PreviewColor := Default(TTcColor);
  var __PreviewColor6Value := aValue.PreviewColor;
  var __OnChange7Value := aValue.OnChange;
  var __OnIdChange8Value := aValue.OnIdChange;
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
  aValue.DefaultRotation := 1;
  var __DefaultRotation0Value := aValue.DefaultRotation;
  aValue.DefaultMirror := Default(TMirrors);
  var __DefaultMirror1Value := aValue.DefaultMirror;
  aValue.Id := 1;
  var __Id2Value := aValue.Id;
  aValue.Title := 'IDevice.Title';
  var __Title3Value := aValue.Title;
  aValue.Driver := 'IDevice.Driver';
  var __Driver4Value := aValue.Driver;
  aValue.CanCutAnyShapes := True;
  var __CanCutAnyShapes5Value := aValue.CanCutAnyShapes;
  aValue.CanCrossCuts := True;
  var __CanCrossCuts6Value := aValue.CanCrossCuts;
  aValue.FullCutsOnly := True;
  var __FullCutsOnly7Value := aValue.FullCutsOnly;
  aValue.StripCuts := Default(TStripCutting);
  var __StripCuts8Value := aValue.StripCuts;
  aValue.MaxStripeWidth := 1;
  var __MaxStripeWidth9Value := aValue.MaxStripeWidth;
  aValue.MinCutSize := 1;
  var __MinCutSize10Value := aValue.MinCutSize;
  aValue.MinCutDistance := 1;
  var __MinCutDistance11Value := aValue.MinCutDistance;
  var __MinEdgeDistance12Value := aValue.MinEdgeDistance;
  aValue.EdgingCuts := Default(TEdgingCuts);
  var __EdgingCuts13Value := aValue.EdgingCuts;
  aValue.OriginEdgingCuts := Default(TOriginEdgingCuts);
  var __OriginEdgingCuts14Value := aValue.OriginEdgingCuts;
  aValue.MaxCutDepthOn := True;
  var __MaxCutDepthOn15Value := aValue.MaxCutDepthOn;
  aValue.MaxCutDepth := 1;
  var __MaxCutDepth16Value := aValue.MaxCutDepth;
  aValue.FirstCutDirection := Default(TCutDirections);
  var __FirstCutDirection17Value := aValue.FirstCutDirection;
  aValue.MaxCutDepthIncludeSheetEdging := True;
  var __MaxCutDepthIncludeSheetEdging18Value := aValue.MaxCutDepthIncludeSheetEdging;
  aValue.MaxCutLengthByLengthOn := True;
  var __MaxCutLengthByLengthOn19Value := aValue.MaxCutLengthByLengthOn;
  aValue.MaxCutLengthByLength := 1;
  var __MaxCutLengthByLength20Value := aValue.MaxCutLengthByLength;
  aValue.MaxCutLengthByWidthOn := True;
  var __MaxCutLengthByWidthOn21Value := aValue.MaxCutLengthByWidthOn;
  aValue.MaxCutLengthByWidth := 1;
  var __MaxCutLengthByWidth22Value := aValue.MaxCutLengthByWidth;
  aValue.MaterialKind := Default(TMaterialKind);
  var __MaterialKind23Value := aValue.MaterialKind;
  aValue.CanCutSlants := True;
  var __CanCutSlants24Value := aValue.CanCutSlants;
  aValue.LeftSlantMeasurement := Default(TSlantMeasurement);
  var __LeftSlantMeasurement25Value := aValue.LeftSlantMeasurement;
  aValue.RightSlantMeasurement := Default(TSlantMeasurement);
  var __RightSlantMeasurement26Value := aValue.RightSlantMeasurement;
  aValue.CutCostPerMeter := 1.5;
  var __CutCostPerMeter27Value := aValue.CutCostPerMeter;
  aValue.ReuseCost := 1.5;
  var __ReuseCost28Value := aValue.ReuseCost;
  aValue.UtilizationCost := 1.5;
  var __UtilizationCost29Value := aValue.UtilizationCost;
  aValue.SegmentShiftCost := 1.5;
  var __SegmentShiftCost30Value := aValue.SegmentShiftCost;
  aValue.SegmentRotationCost := 1.5;
  var __SegmentRotationCost31Value := aValue.SegmentRotationCost;
  aValue.CustomData := 'IDevice.CustomData';
  var __CustomData32Value := aValue.CustomData;
  var __AlgorithmData33Value := aValue.AlgorithmData;
  var __OnChange34Value := aValue.OnChange;
  var __OnIdChange35Value := aValue.OnIdChange;
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
  aValue.PreviewColor := Default(TTcColor);
  var __PreviewColor26Value := aValue.PreviewColor;
  aValue.CustomData := 'IFormat.CustomData';
  var __CustomData27Value := aValue.CustomData;
  var __AlgorithmData28Value := aValue.AlgorithmData;
  var __EffectivePriority29Value := aValue.EffectivePriority;
  var __LeftQuantity30Value := aValue.LeftQuantity;
  var __TotalSurplus31Value := aValue.TotalSurplus;
  var __TotalMargin32Value := aValue.TotalMargin;
  var __TotalLength33Value := aValue.TotalLength;
  var __TotalWidth34Value := aValue.TotalWidth;
  var __TotalField35Value := aValue.TotalField;
  var __GrossLength36Value := aValue.GrossLength;
  var __GrossWidth37Value := aValue.GrossWidth;
  var __OnChange38Value := aValue.OnChange;
  var __OnIdChange39Value := aValue.OnIdChange;
  var __GetShapePathAsString62Result := aValue.GetShapePathAsString(1.5, True, True, True);
  var __GetShapeOffsetInsideBoundingBox63Arg2: Double := 1.5;
  var __GetShapeOffsetInsideBoundingBox63Arg3: Double := 1.5;
  aValue.GetShapeOffsetInsideBoundingBox(1.5, True, __GetShapeOffsetInsideBoundingBox63Arg2, __GetShapeOffsetInsideBoundingBox63Arg3);
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
  aValue.LoadByProject(Default(IProject), Default(IFormats));
  aValue.LoadByProject(Default(IProject));
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
  aValue.MaxShorterRecycleSize := 1;
  var __MaxShorterRecycleSize23Value := aValue.MaxShorterRecycleSize;
  aValue.MaxLongerRecycleSize := 1;
  var __MaxLongerRecycleSize24Value := aValue.MaxLongerRecycleSize;
  aValue.PrefShorterRecycleSize := 1;
  var __PrefShorterRecycleSize25Value := aValue.PrefShorterRecycleSize;
  aValue.PrefLongerRecycleSize := 1;
  var __PrefLongerRecycleSize26Value := aValue.PrefLongerRecycleSize;
  var __EffectiveMinShorterRecycleSize27Value := aValue.EffectiveMinShorterRecycleSize;
  var __EffectiveMinLongerRecycleSize28Value := aValue.EffectiveMinLongerRecycleSize;
  var __EffectiveMaxShorterRecycleSize29Value := aValue.EffectiveMaxShorterRecycleSize;
  var __EffectiveMaxLongerRecycleSize30Value := aValue.EffectiveMaxLongerRecycleSize;
  var __EffectivePrefShorterRecycleSize31Value := aValue.EffectivePrefShorterRecycleSize;
  var __EffectivePrefLongerRecycleSize32Value := aValue.EffectivePrefLongerRecycleSize;
  aValue.Kerf := 1;
  var __Kerf33Value := aValue.Kerf;
  var __MinEdgeDistance34Value := aValue.MinEdgeDistance;
  aValue.AllowEdgeCuts := True;
  var __AllowEdgeCuts35Value := aValue.AllowEdgeCuts;
  aValue.RecycleEdgingOn := True;
  var __RecycleEdgingOn36Value := aValue.RecycleEdgingOn;
  aValue.RecycleEdging := 1;
  var __RecycleEdging37Value := aValue.RecycleEdging;
  aValue.StackCutting := True;
  var __StackCutting38Value := aValue.StackCutting;
  aValue.StackSize := 1;
  var __StackSize39Value := aValue.StackSize;
  aValue.AllowPartialStack := True;
  var __AllowPartialStack40Value := aValue.AllowPartialStack;
  aValue.MinStackSize := 1;
  var __MinStackSize41Value := aValue.MinStackSize;
  aValue.PricePerSqM := 1.5;
  var __PricePerSqM42Value := aValue.PricePerSqM;
  aValue.WeightOfSqM := 1.5;
  var __WeightOfSqM43Value := aValue.WeightOfSqM;
  aValue.PricePerMeter := 1.5;
  var __PricePerMeter44Value := aValue.PricePerMeter;
  aValue.WeightOfMeter := 1.5;
  var __WeightOfMeter45Value := aValue.WeightOfMeter;
  aValue.CutCostPerMeter := 1.5;
  var __CutCostPerMeter46Value := aValue.CutCostPerMeter;
  aValue.ReuseCost := 1.5;
  var __ReuseCost47Value := aValue.ReuseCost;
  aValue.UtilizationCostPerKg := 1.5;
  var __UtilizationCostPerKg48Value := aValue.UtilizationCostPerKg;
  aValue.SegmentShiftCost := 1.5;
  var __SegmentShiftCost49Value := aValue.SegmentShiftCost;
  aValue.SegmentRotationCost := 1.5;
  var __SegmentRotationCost50Value := aValue.SegmentRotationCost;
  aValue.PriceToCostMultiplier := 1.5;
  var __PriceToCostMultiplier51Value := aValue.PriceToCostMultiplier;
  aValue.ReusableWasteExpectedUsage := 1.5;
  var __ReusableWasteExpectedUsage52Value := aValue.ReusableWasteExpectedUsage;
  aValue.CutExcess := 1;
  var __CutExcess53Value := aValue.CutExcess;
  aValue.CutShiftTotalLimit := 1;
  var __CutShiftTotalLimit54Value := aValue.CutShiftTotalLimit;
  aValue.CutShiftHorzLimit := 1;
  var __CutShiftHorzLimit55Value := aValue.CutShiftHorzLimit;
  aValue.CutShiftVertLimit := 1;
  var __CutShiftVertLimit56Value := aValue.CutShiftVertLimit;
  aValue.CustomData := 'IMaterial.CustomData';
  var __CustomData57Value := aValue.CustomData;
  var __AlgorithmData58Value := aValue.AlgorithmData;
  var __StandardSheets59Value := aValue.StandardSheets;
  var __OnChange60Value := aValue.OnChange;
  var __OnIdChange61Value := aValue.OnIdChange;
  var __OnStandardSheetAdd62Value := aValue.OnStandardSheetAdd;
  var __OnStandardSheetRemove63Value := aValue.OnStandardSheetRemove;
  var __OnStandardSheetChange64Value := aValue.OnStandardSheetChange;
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
  var __MinEdgeDistance10Value := aValue.MinEdgeDistance;
  aValue.Priority := 1;
  var __Priority11Value := aValue.Priority;
  aValue.CutShiftHorzLimit := 1;
  var __CutShiftHorzLimit12Value := aValue.CutShiftHorzLimit;
  aValue.CutShiftVertLimit := 1;
  var __CutShiftVertLimit13Value := aValue.CutShiftVertLimit;
  var __EffectiveCutShiftHorzLimit14Value := aValue.EffectiveCutShiftHorzLimit;
  var __EffectiveCutShiftVertLimit15Value := aValue.EffectiveCutShiftVertLimit;
  aValue.ExtractionCost := 1.5;
  var __ExtractionCost16Value := aValue.ExtractionCost;
  aValue.PricePerSqM := 1.5;
  var __PricePerSqM17Value := aValue.PricePerSqM;
  aValue.CustomData := 'ISheet.CustomData';
  var __CustomData18Value := aValue.CustomData;
  var __AlgorithmData19Value := aValue.AlgorithmData;
  var __Defects20Value := aValue.Defects;
  var __Holes21Value := aValue.Holes;
  var __AvailableQuantity22Value := aValue.AvailableQuantity;
  var __Field23Value := aValue.Field;
  var __FieldOfAll24Value := aValue.FieldOfAll;
  var __OnChange25Value := aValue.OnChange;
  var __OnIdChange26Value := aValue.OnIdChange;
  var __OnDefectAdd27Value := aValue.OnDefectAdd;
  var __OnDefectRemove28Value := aValue.OnDefectRemove;
  var __OnDefectChange29Value := aValue.OnDefectChange;
  var __IsStandard38Result := aValue.IsStandard();
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
  var __TechnologicalWasteField2Value := aValue.TechnologicalWasteField;
  var __EdgingWasteField3Value := aValue.EdgingWasteField;
  var __KerfWasteField4Value := aValue.KerfWasteField;
  var __CalcCutsInfoByMaterial5Arg1: Integer := 1;
  var __CalcCutsInfoByMaterial5Arg2: Double := 1.5;
  aValue.CalcCutsInfoByMaterial(Default(IMaterial), __CalcCutsInfoByMaterial5Arg1, __CalcCutsInfoByMaterial5Arg2);
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
  var __ShiftDistance10Value := aValue.ShiftDistance;
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
  var __TechnologicalWasteField5Value := aValue.TechnologicalWasteField;
  var __EdgingWasteField6Value := aValue.EdgingWasteField;
  var __KerfWasteField7Value := aValue.KerfWasteField;
  var __Index8Value := aValue.Index;
  var __Rotation9Value := aValue.Rotation;
  var __Mirror10Value := aValue.Mirror;
  aValue.IsSaved := True;
  var __IsSaved11Value := aValue.IsSaved;
  aValue.IsPlotted := True;
  var __IsPlotted12Value := aValue.IsPlotted;
  var __GetEffectiveModificator15Arg0: Integer := 1;
  var __GetEffectiveModificator15Arg1: TMirrors := Default(TMirrors);
  aValue.GetEffectiveModificator(__GetEffectiveModificator15Arg0, __GetEffectiveModificator15Arg1);
  var __GetOriginPoint16Arg0: Integer := 1;
  var __GetOriginPoint16Arg1: Integer := 1;
  aValue.GetOriginPoint(__GetOriginPoint16Arg0, __GetOriginPoint16Arg1);
  var __CalcPoint17Arg0: Integer := 1;
  var __CalcPoint17Arg1: Integer := 1;
  aValue.CalcPoint(__CalcPoint17Arg0, __CalcPoint17Arg1);
  var __UnCalcPoint18Arg0: Integer := 1;
  var __UnCalcPoint18Arg1: Integer := 1;
  aValue.UnCalcPoint(__UnCalcPoint18Arg0, __UnCalcPoint18Arg1);
  var __CalcPointF19Arg0: Double := 1.5;
  var __CalcPointF19Arg1: Double := 1.5;
  aValue.CalcPointF(__CalcPointF19Arg0, __CalcPointF19Arg1);
  var __UnCalcPointF20Arg0: Double := 1.5;
  var __UnCalcPointF20Arg1: Double := 1.5;
  aValue.UnCalcPointF(__UnCalcPointF20Arg0, __UnCalcPointF20Arg1);
  var __GetDirection21Arg0: Integer := 1;
  var __GetDirection21Arg1: Integer := 1;
  aValue.GetDirection(__GetDirection21Arg0, __GetDirection21Arg1);
  var __CalcEffectiveLayout22Arg0: Cardinal := 1;
  var __CalcEffectiveLayout22Arg1: Cardinal := 1;
  var __CalcEffectiveLayout22Arg2: Cardinal := 1;
  var __CalcEffectiveLayout22Arg3: Cardinal := 1;
  var __CalcEffectiveLayout22Arg4: Cardinal := 1;
  var __CalcEffectiveLayout22Arg5: Cardinal := 1;
  aValue.CalcEffectiveLayout(__CalcEffectiveLayout22Arg0, __CalcEffectiveLayout22Arg1, __CalcEffectiveLayout22Arg2, __CalcEffectiveLayout22Arg3, __CalcEffectiveLayout22Arg4, __CalcEffectiveLayout22Arg5);
  var __CalcRecycledField23Result := aValue.CalcRecycledField(1, 1);
  var __CalcCutsInfo24Arg0: Integer := 1;
  var __CalcCutsInfo24Arg1: Double := 1.5;
  aValue.CalcCutsInfo(__CalcCutsInfo24Arg0, __CalcCutsInfo24Arg1);
end;

procedure TouchISolutionWaste(const aValue: ISolutionWaste);
begin
  if not Assigned(aValue) then Exit;
  var __X0Value := aValue.X;
  var __Y1Value := aValue.Y;
  var __Length2Value := aValue.Length;
  var __Width3Value := aValue.Width;
  var __Shape4Value := aValue.Shape;
  var __Holes5Value := aValue.Holes;
  var __Field6Value := aValue.Field;
  var __Identifier7Value := aValue.Identifier;
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

procedure TouchITcAlgorithmData(const aValue: ITcAlgorithmData);
begin
  if not Assigned(aValue) then Exit;
  aValue.Data := 'ITcAlgorithmData.Data';
  var __Data0Value := aValue.Data;
  aValue.Units := Default(TDefaultUnits);
  var __Units1Value := aValue.Units;
  var __OnChange2Value := aValue.OnChange;
  var __GetState4Arg0: WideString;
  var __GetState4Arg1: TDefaultUnits;
  aValue.GetState(__GetState4Arg0, __GetState4Arg1);
  aValue.SetState('aData1', Default(TDefaultUnits));
  var __GetLength6Result := aValue.GetLength('aPath1', 1);
  var __GetTime7Result := aValue.GetTime('aPath1', 1.5);
  var __GetPercent8Result := aValue.GetPercent('aPath1', 1);
  var __GetAngle9Result := aValue.GetAngle('aPath1', 1.5);
  var __GetPrice10Result := aValue.GetPrice('aPath1', 1.5);
  var __GetWeight11Result := aValue.GetWeight('aPath1', 1.5);
  var __GetValue12Result := aValue.GetValue('aPath1', 1.5);
  var __GetValue13Result := aValue.GetValue('aPath1', 'aDefault2');
  var __GetValue14Result := aValue.GetValue('aPath1', True);
  var __SameAs15Result := aValue.SameAs(Default(ITcAlgorithmData));
  var __Serialize16Result := aValue.Serialize();
  aValue.Deserialize('aBlob1');
  var __GetInteger19Result := aValue.GetInteger('aPath1', 1);
  var __GetCount20Result := aValue.GetCount('aJsonPointer1');
  var __GetLengthByPointer21Result := aValue.GetLengthByPointer('aJsonPointer1', 1);
  var __GetTimeByPointer22Result := aValue.GetTimeByPointer('aJsonPointer1', 1.5);
  var __GetPercentByPointer23Result := aValue.GetPercentByPointer('aJsonPointer1', 1);
  var __GetAngleByPointer24Result := aValue.GetAngleByPointer('aJsonPointer1', 1.5);
  var __GetPriceByPointer25Result := aValue.GetPriceByPointer('aJsonPointer1', 1.5);
  var __GetWeightByPointer26Result := aValue.GetWeightByPointer('aJsonPointer1', 1.5);
  var __GetIntegerByPointer27Result := aValue.GetIntegerByPointer('aJsonPointer1', 1);
  var __GetValueByPointer28Result := aValue.GetValueByPointer('aJsonPointer1', 1.5);
  var __GetValueByPointer29Result := aValue.GetValueByPointer('aJsonPointer1', 'aDefault2');
  var __GetValueByPointer30Result := aValue.GetValueByPointer('aJsonPointer1', True);
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
