using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;

namespace TonCutCsv.Managed;

public static class CsvCodec
{
    public static bool HasRequiredHeader(IReadOnlyList<string> header)
    {
        if (header.Count < CsvSchema.Headers.Count)
        {
            return false;
        }

        for (var i = 0; i < CsvSchema.Headers.Count; i++)
        {
            if (!string.Equals(header[i].Trim(), CsvSchema.Headers[i], StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }
        }

        return true;
    }

    public static IReadOnlyList<IReadOnlyList<string>> Parse(string text)
    {
        var rows = new List<IReadOnlyList<string>>();
        var row = new List<string>();
        var field = new StringBuilder();
        var inQuotes = false;

        void FlushField()
        {
            row.Add(field.ToString());
            field.Clear();
        }

        void FlushRow()
        {
            if (!(row.Count == 1 && row[0].Length == 0))
            {
                rows.Add(row.ToArray());
            }
            row.Clear();
        }

        for (var i = 0; i < text.Length; i++)
        {
            var ch = text[i];
            if (ch == '"')
            {
                if (inQuotes && i + 1 < text.Length && text[i + 1] == '"')
                {
                    field.Append('"');
                    i++;
                }
                else
                {
                    inQuotes = !inQuotes;
                }
            }
            else if (ch == ',' && !inQuotes)
            {
                FlushField();
            }
            else if ((ch == '\r' || ch == '\n') && !inQuotes)
            {
                FlushField();
                FlushRow();
                if (ch == '\r' && i + 1 < text.Length && text[i + 1] == '\n')
                {
                    i++;
                }
            }
            else
            {
                field.Append(ch);
            }
        }

        if (inQuotes)
        {
            throw new InvalidOperationException("CSV parser error: unmatched quote.");
        }

        if (field.Length > 0 || row.Count > 0)
        {
            FlushField();
            FlushRow();
        }

        return rows;
    }

    public static IReadOnlyList<CsvRowRecord> Decode(IReadOnlyList<IReadOnlyList<string>> rows)
    {
        if (rows.Count == 0 || !HasRequiredHeader(rows[0]))
        {
            throw new InvalidOperationException("CSV header does not match the starter schema.");
        }

        var records = new List<CsvRowRecord>();
        for (var i = 1; i < rows.Count; i++)
        {
            var row = rows[i];
            var recordType = GetCell(rows[0], row, "RecordType");
            if (string.IsNullOrWhiteSpace(recordType))
            {
                continue;
            }

            var normalizedRecordType = recordType.Trim();
            if (!string.Equals(normalizedRecordType, "FORMAT", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(normalizedRecordType, "SHEET", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException($"Unknown RecordType at row {i + 1}: {recordType}");
            }

            records.Add(new CsvRowRecord
            {
                RecordType = normalizedRecordType,
                ProjectTitle = GetCell(rows[0], row, "ProjectTitle"),
                MaterialTitle = GetCell(rows[0], row, "MaterialTitle"),
                MaterialKind = ParseMaterialKind(GetCell(rows[0], row, "MaterialKind")),
                MaterialWidth = ParseUInt(GetCell(rows[0], row, "MaterialWidth")),
                MaterialThickness = ParseUInt(GetCell(rows[0], row, "MaterialThickness")),
                Length = ParseUInt(GetCell(rows[0], row, "Length")),
                Width = ParseUInt(GetCell(rows[0], row, "Width")),
                Quantity = ParseOptionalPositiveUInt(GetCell(rows[0], row, "Quantity"), 1),
                Identifier = GetCell(rows[0], row, "Identifier"),
                Description = GetCell(rows[0], row, "Description"),
            });
        }

        return records;
    }

    public static string Encode(IEnumerable<CsvRowRecord> records)
    {
        var builder = new StringBuilder();
        builder.AppendLine(string.Join(",", CsvSchema.Headers));
        foreach (var record in records)
        {
            builder.AppendLine(string.Join(",",
                Escape(record.RecordType),
                Escape(record.ProjectTitle),
                Escape(record.MaterialTitle),
                Escape(record.MaterialKind),
                Escape(record.MaterialWidth.ToString(CultureInfo.InvariantCulture)),
                Escape(record.MaterialThickness.ToString(CultureInfo.InvariantCulture)),
                Escape(record.Length.ToString(CultureInfo.InvariantCulture)),
                Escape(record.Width.ToString(CultureInfo.InvariantCulture)),
                Escape(record.Quantity.ToString(CultureInfo.InvariantCulture)),
                Escape(record.Identifier),
                Escape(record.Description)));
        }

        return builder.ToString();
    }

    private static string GetCell(IReadOnlyList<string> header, IReadOnlyList<string> row, string name)
    {
        for (var i = 0; i < header.Count; i++)
        {
            if (string.Equals(header[i].Trim(), name, StringComparison.OrdinalIgnoreCase))
            {
                return i < row.Count ? row[i].Trim() : string.Empty;
            }
        }

        return string.Empty;
    }

    private static uint ParseUInt(string value)
    {
        if (!uint.TryParse(value, NumberStyles.None, CultureInfo.InvariantCulture, out var result))
        {
            throw new InvalidOperationException($"Invalid unsigned integer value: {value}");
        }

        return result;
    }

    private static uint ParseOptionalPositiveUInt(string value, uint fallback)
    {
        if (!uint.TryParse(value, NumberStyles.None, CultureInfo.InvariantCulture, out var result) || result == 0)
        {
            return fallback;
        }

        return result;
    }

    private static string ParseMaterialKind(string value)
    {
        if (string.Equals(value, "mk1D", StringComparison.OrdinalIgnoreCase))
        {
            return "mk1D";
        }

        if (string.Equals(value, "mk2D", StringComparison.OrdinalIgnoreCase))
        {
            return "mk2D";
        }

        if (string.Equals(value, "mkUnknown", StringComparison.OrdinalIgnoreCase))
        {
            return "mkUnknown";
        }

        throw new InvalidOperationException($"Unknown MaterialKind: {value}");
    }

    private static string Escape(string value)
    {
        value ??= string.Empty;
        if (value.IndexOfAny(new[] { ',', '"', '\r', '\n' }) >= 0)
        {
            return "\"" + value.Replace("\"", "\"\"") + "\"";
        }

        return value;
    }
}
