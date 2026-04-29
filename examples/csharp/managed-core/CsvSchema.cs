using System.Collections.Generic;

namespace TonCutCsv.Managed;

public static class CsvSchema
{
    public static readonly IReadOnlyList<string> Headers = new[]
    {
        "RecordType",
        "ProjectTitle",
        "MaterialTitle",
        "MaterialKind",
        "MaterialWidth",
        "MaterialThickness",
        "Length",
        "Width",
        "Quantity",
        "Identifier",
        "Description",
    };
}
