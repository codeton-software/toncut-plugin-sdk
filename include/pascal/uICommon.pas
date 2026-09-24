unit uICommon;

interface

type
  TField = Int64;
  TRotation = Word;

  TUnits = (uMillimeters, uCentimeters, uInches);
  TTimeUnits = (tuDefault, tuSeconds, tuMinutes, tuHours, tuDays);
  TPercentUnits = (puDefault, puPercent);
  TLengthUnits = (luDefault, luMillimeters, luCentimeters, luInches, luMicrometers);
  TFieldUnits = (fuDefault, fuSquareMillimeters, fuSquareCentimeters, fuSquareMeters, fuSquareInches, fuSquareFeet);
  TAngleUnits = (auDefault, auDegrees, auRadians);
  TPriceUnits = (pruDefault);
  TWeightUnits = (
    wuDefault,      // context-dependent
    wuMilligrams,   // mg
    wuGrams,        // g
    wuKilograms,    // kg
    wuTons,         // t (metric ton, 1000 kg)

    wuOunces,       // oz (avoirdupois)
    wuPounds,       // lb
    wuShortTons,    // US ton (2000 lb)
    wuStones,       // st (14 lb, UK)

    wuTroyOunces    // oz t (31.1035 g, precious metals)
  );


  TTcPrice = Double;
  TTcWeight = Double;

  TElementDimensions = (edGross, edNet, edCut);

  TPieceIdentification = (piDescriptionOnly, piIdentifierAndDescription, piBarcodeAndDescription);
  TStockIdentification = (siDescriptionOnly, siIdentifierAndDescription);

  TStatus = (sPlotted, sSaved);
  TStatuses = set of TStatus;

  TMirror = (mHorizontal, mVertical);
  TMirrors = set of TMirror;

  TTryDirection = (tdByLength, tdByWidth, tdAuto);
  TSheetOrder = (soFromLarge, soFromSmall, soRandom, soCustom);
  TEdgingCuts = (ecOptimal, ecHorizontalFirst, ecVerticalFirst);
  TCutDirections = (cdHorizontal, cdVertical, cdAny);
  TOriginEdgingCuts = (oecDefault, oecTwoFullCuts);

  TStripCutting = (scNone, scByLength, scByWidth);

  TOrnament = (oNone, oByWidth, oByLength);
  TOrnaments = set of TOrnament;

  TOldPiecePriority = (ppNormal, ppHigh, ppCritical, ppDefault);
  // Legacy stock priority labels. ISheet.Priority is an Integer now (see the
  // cStockPriority* constants); this enum survives only to parse the named
  // labels 'normal' / 'low' in JSON, SSI and SQLite data, exactly as
  // TOldPiecePriority does for pieces.
  TOldStockPriority = (spNormal, spLow);
  TProjectPriority = (prpDefault, prpNormal, prpHigh, prpCritical);

  TProjectState = (prsNew, prsReady, prsPending, prsDone, prsCanceled, prsDeleted);

  TMaterialKind = (mkUnknown, mk1D, mk2D);
  TMaterialKinds = set of TMaterialKind;

  TQualityLevel = (qlPrecission, qlCompromise, qlSpeed);

  TCutKind = (ckLine, ckCurve);

  TCuttingDimensions = (cdNet, cdGross);

  TShapeType = (stNone, stRectangle, stLinear, stAny, stSlantRectangle, stL, stRightTriangle, stSlopeRectangle, stTrapezoid, stOctagon, stEllipse, stCircle, stHoop);

  TSlantMeasurement = (smFromMiddleToLeft, smFromMiddleToRight, smFromLeft, smFromRight);

  TBestSolutionCriterion = (bscOptimal, bscSmallestSheetArea, bscSmallestWasteArea, bscCustom, bscProductionTime, bscCost);

  TConfigurationParts = set of (cpData, cpConfig, cpPaths, cpProfiles, cpInternals);

  TDefaultUnits = record
    Time: TTimeUnits;
    Percent: TPercentUnits;
    Length: TLengthUnits;
    Field: TFieldUnits;
    Angle: TAngleUnits;
    Price: TPriceUnits;
    Weight: TWeightUnits;
  end;

  // Plotter stuff.
  TTcPlotterType   = (ptUnknown, ptCNC);
  TTcAxisDirection = (adWest, adNorth, adEast, adSouth);
  TTcMoveDirection = (mdAlongX, mdAlongY, mdAny);

const
  cLengthMultiplier = 100;
  cRotationUnit = 0.1;
  cFieldMultiplier = cLengthMultiplier * cLengthMultiplier;

  cShapeScaleFactor = 10000 / cLengthMultiplier;

  cRotation90 = Round(90 / cRotationUnit);
  cRotation180 = Round(180 / cRotationUnit);
  cRotation270 = Round(270 / cRotationUnit);
  cRotation360 = Round(360 / cRotationUnit);

  cPiecePriorityDefault = 0;
  cPiecePriorityNormal = 1;
  cPiecePriorityHigh = 10;
  cPiecePriorityCritical = 100;

  // Stock priorities: HIGHER = consume EARLIER. Soft: the score decides;
  // ordering uses it only as the last tie-break. The labels 'low' and
  // 'normal' map to these values, and a value above normal (up to
  // cStockPriorityMax) means "use this first", for example remnants or old
  // stock.
  cStockPriorityMin = 0;
  cStockPriorityLow = 0;
  cStockPriorityNormal = 10;
  cStockPriorityMax = 100;

  cDefaultUnits: TDefaultUnits = (
    Time: tuDefault;
    Percent: puDefault;
    Length: luDefault;
    Field: fuDefault;
    Angle: auDefault;
  );

  cAlgorithmLinear = 'linear';
  cAlgorithmAnyShapes = 'any-shapes';
  cAlgorithmRectangles = 'rectangles';
  cAlgorithmStripes = 'stripes';

implementation

end.
