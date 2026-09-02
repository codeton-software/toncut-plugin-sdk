using System;
using System.IO;
using System.Linq;
using TonCutCsv.Managed;

internal static class Program
{
    private static int Main()
    {
        var sdkRoot = Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "..", "..", "..", "..", "..", ".."));
        var csvPath = Path.Combine(sdkRoot, "examples", "shared", "csv", "example.csv");
        var text = File.ReadAllText(csvPath);
        var rows = CsvCodec.Parse(text);
        var records = CsvCodec.Decode(rows);
        var encoded = CsvCodec.Encode(records);
        var encodedRows = CsvCodec.Parse(encoded);
        if (!CsvCodec.HasRequiredHeader(encodedRows[0].Select(cell => cell.ToString()).ToArray()))
        {
            Console.Error.WriteLine("Encoded header mismatch.");
            return 1;
        }
        if (records.Count == 0)
        {
            Console.Error.WriteLine("Managed core probe decoded zero records.");
            return 1;
        }
        var spacedHeader = string.Join(",", CsvSchema.Headers.Select(header => $" {header} "));
        var normalizationText = spacedHeader + "\r\n" +
            "FORMAT,Project,Material,mk2D,0,18,100,50,0,ID-1,Zero quantity\r\n" +
            "SHEET,,Material,mk2D,0,18,200,100,not-a-number,ID-2,Invalid quantity\r\n";
        var normalizedRecords = CsvCodec.Decode(CsvCodec.Parse(normalizationText));
        if (normalizedRecords.Count != 2 || normalizedRecords.Any(record => record.Quantity != 1))
        {
            Console.Error.WriteLine("Managed header lookup or quantity normalization mismatch.");
            return 1;
        }

        var unknownTypeText = string.Join(",", CsvSchema.Headers) + "\r\n" +
            "UNKNOWN,Project,Material,mk2D,0,18,100,50,1,ID-3,Unknown record\r\n";
        try
        {
            CsvCodec.Decode(CsvCodec.Parse(unknownTypeText));
            Console.Error.WriteLine("Managed core accepted an unknown RecordType.");
            return 1;
        }
        catch (InvalidOperationException)
        {
        }
        Console.WriteLine($"Managed core probe passed with {records.Count} records.");
        return 0;
    }
}
