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
        Console.WriteLine($"Managed core probe passed with {records.Count} records.");
        return 0;
    }
}
