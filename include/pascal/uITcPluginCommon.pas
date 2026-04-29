unit uITcPluginCommon;

interface

uses
  uITonCut;

const
  cEngineVersion = 23;

type
  TTcpResult  = (cprFailed, cprOK, cprNotImplemented, cprException, cprNothing, cprNotInitialized, cprMoreData, cprCancel, cprMaybe, cprNo);
  TTcpVersion = UInt64;

  // Files.
  TTcpExtensionType = (etImport, etExport, etExportResults);

  // Save targets.
  TTcpSaveTarget = (stFile, stFolder);

  // Features.
  TTcpFeature  =
    (
    feImport,
    feExport,
    feSaveResultToFile,
    feBatchSaveResultToFile,
    feBatchSaveResultToFolder,
    fePlot,
    feBatchPlot,
    feSavePlotToFile,
    feBatchSavePlotToFile,
    feBatchSavePlotToFolder,
    feConfigure,
    feAbout
    );
  TTcpFeatures = set of TTcpFeature;

implementation

end.
