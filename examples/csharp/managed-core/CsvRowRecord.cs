namespace TonCutCsv.Managed;

public sealed class CsvRowRecord
{
    public string RecordType { get; set; } = string.Empty;
    public string ProjectTitle { get; set; } = string.Empty;
    public string MaterialTitle { get; set; } = string.Empty;
    public string MaterialKind { get; set; } = "mkUnknown";
    public uint MaterialWidth { get; set; }
    public uint MaterialThickness { get; set; }
    public uint Length { get; set; }
    public uint Width { get; set; }
    public uint Quantity { get; set; } = 1;
    public string Identifier { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
}
