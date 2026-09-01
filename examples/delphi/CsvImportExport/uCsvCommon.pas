unit uCsvCommon;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  uICommon,
  uITcPluginCommon;

type
  TCsvRow = TArray<string>;
  TCsvTable = TArray<TCsvRow>;

function MakeTcpVersion(
  AMajor: Word;
  AMinor: Word;
  ABuild: Word;
  ARevision: Word
): TTcpVersion;

function CsvRequiredHeaders(): TCsvRow;
function CsvHeaderLine(): string;
function ParseCsvText(const AText: string): TCsvTable;
function EncodeCsvField(const AValue: string): string;
function BuildCsvLine(const AFields: array of string): string;
function HasRequiredHeader(const AHeader: TCsvRow): Boolean;
function CellByName(const AHeader, ARow: TCsvRow; const AName: string): string;
function TryParseCardinalField(const AValue: string; out AResult: Cardinal): Boolean;
function MaterialKindToText(AKind: TMaterialKind): string;
function TryParseMaterialKind(const AText: string; out AKind: TMaterialKind): Boolean;

implementation

function MakeTcpVersion(
  AMajor: Word;
  AMinor: Word;
  ABuild: Word;
  ARevision: Word
): TTcpVersion;
begin
  Result :=
    (UInt64(AMajor) shl 48) or
    (UInt64(AMinor) shl 32) or
    (UInt64(ABuild) shl 16) or
    UInt64(ARevision);
end;

function CsvRequiredHeaders(): TCsvRow;
begin
  Result := [
    'RecordType',
    'ProjectTitle',
    'MaterialTitle',
    'MaterialKind',
    'MaterialWidth',
    'MaterialThickness',
    'Length',
    'Width',
    'Quantity',
    'Identifier',
    'Description'
  ];
end;

function EncodeCsvField(const AValue: string): string;
var
  escaped: string;
begin
  escaped := StringReplace(AValue, '"', '""', [rfReplaceAll]);
  if (Pos(',', escaped) > 0) or (Pos('"', escaped) > 0) or
     (Pos(#13, escaped) > 0) or (Pos(#10, escaped) > 0) then
    Result := '"' + escaped + '"'
  else
    Result := escaped;
end;

function BuildCsvLine(const AFields: array of string): string;
var
  i: Integer;
begin
  Result := '';
  for i := Low(AFields) to High(AFields) do
    begin
      if i > Low(AFields) then
        Result := Result + ',';
      Result := Result + EncodeCsvField(AFields[i]);
    end;
end;

function CsvHeaderLine(): string;
var
  headers: TCsvRow;
  i: Integer;
begin
  headers := CsvRequiredHeaders();
  Result := '';
  for i := 0 to Length(headers) - 1 do
    begin
      if i > 0 then
        Result := Result + ',';
      Result := Result + headers[i];
    end;
end;

function ParseCsvText(const AText: string): TCsvTable;
var
  rows: TList<TCsvRow>;
  currentRow: TList<string>;
  currentField: string;
  i: Integer;
  inQuotes: Boolean;

  procedure FlushField();
  begin
    currentRow.Add(currentField);
    currentField := '';
  end;

  procedure FlushRow();
  begin
    if (currentRow.Count = 1) and (currentRow[0] = '') then
      begin
        currentRow.Clear();
        Exit;
      end;

    rows.Add(currentRow.ToArray());
    currentRow.Clear();
  end;

begin
  rows := TList<TCsvRow>.Create;
  try
    currentRow := TList<string>.Create;
    try
      currentField := '';
      inQuotes := False;
      i := 1;
      while i <= Length(AText) do
        begin
          case AText[i] of
          '"':
            begin
              if inQuotes and (i < Length(AText)) and (AText[i + 1] = '"') then
                begin
                  currentField := currentField + '"';
                  Inc(i);
                end
              else
                inQuotes := not inQuotes;
            end;
          ',':
            begin
              if inQuotes then
                currentField := currentField + ','
              else
                FlushField();
            end;
          #13:
            begin
              if inQuotes then
                currentField := currentField + #13
              else
                begin
                  FlushField();
                  FlushRow();
                  if (i < Length(AText)) and (AText[i + 1] = #10) then
                    Inc(i);
                end;
            end;
          #10:
            begin
              if inQuotes then
                currentField := currentField + #10
              else
                begin
                  FlushField();
                  FlushRow();
                end;
            end;
          else
            currentField := currentField + AText[i];
          end;
          Inc(i);
        end;

      if inQuotes then
        raise Exception.Create('CSV parser error: unmatched quote.');

      if (currentField <> '') or (currentRow.Count > 0) then
        begin
          FlushField();
          FlushRow();
        end;

      Result := rows.ToArray();
    finally
      currentRow.Free;
    end;
  finally
    rows.Free;
  end;
end;

function HasRequiredHeader(const AHeader: TCsvRow): Boolean;
var
  required: TCsvRow;
  i: Integer;
begin
  required := CsvRequiredHeaders();
  if Length(AHeader) < Length(required) then
    Exit(False);

  for i := 0 to Length(required) - 1 do
    if not SameText(Trim(AHeader[i]), required[i]) then
      Exit(False);

  Result := True;
end;

function CellByName(const AHeader, ARow: TCsvRow; const AName: string): string;
var
  i: Integer;
begin
  for i := 0 to Length(AHeader) - 1 do
    if SameText(Trim(AHeader[i]), AName) then
      begin
        if i < Length(ARow) then
          Exit(Trim(ARow[i]));
        Exit('');
      end;

  Result := '';
end;

function TryParseCardinalField(const AValue: string; out AResult: Cardinal): Boolean;
var
  parsed: UInt64;
begin
  Result := TryStrToUInt64(Trim(AValue), parsed) and (parsed <= High(Cardinal));
  if Result then
    AResult := Cardinal(parsed)
  else
    AResult := 0;
end;

function MaterialKindToText(AKind: TMaterialKind): string;
begin
  case AKind of
    mk1D: Result := 'mk1D';
    mk2D: Result := 'mk2D';
  else
    Result := 'mkUnknown';
  end;
end;

function TryParseMaterialKind(const AText: string; out AKind: TMaterialKind): Boolean;
begin
  if SameText(Trim(AText), 'mk1D') then
    begin
      AKind := mk1D;
      Exit(True);
    end;

  if SameText(Trim(AText), 'mk2D') then
    begin
      AKind := mk2D;
      Exit(True);
    end;

  if SameText(Trim(AText), 'mkUnknown') then
    begin
      AKind := mkUnknown;
      Exit(True);
    end;

  AKind := mkUnknown;
  Result := False;
end;

end.
