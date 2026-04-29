#include "CsvCodec.hpp"

#include <algorithm>
#include <cwctype>

namespace toncut {

namespace {

std::wstring Trim(const std::wstring& value) {
  std::size_t start = 0;
  while (start < value.size() && std::iswspace(value[start]) != 0) {
    ++start;
  }

  std::size_t end = value.size();
  while (end > start && std::iswspace(value[end - 1]) != 0) {
    --end;
  }

  return value.substr(start, end - start);
}

bool TryParseUnsigned(const std::wstring& value, unsigned& result) {
  const std::wstring trimmed = Trim(value);
  if (trimmed.empty()) {
    return false;
  }

  wchar_t* end = nullptr;
  const unsigned long parsed = std::wcstoul(trimmed.c_str(), &end, 10);
  if (end == nullptr || *end != L'\0') {
    return false;
  }

  result = static_cast<unsigned>(parsed);
  return true;
}

std::wstring FromUtf8(const std::string& bytes) {
  if (bytes.empty()) {
    return L"";
  }

  const int size = ::MultiByteToWideChar(CP_UTF8, 0, bytes.data(), static_cast<int>(bytes.size()), nullptr, 0);
  std::wstring result(size, L'\0');
  ::MultiByteToWideChar(CP_UTF8, 0, bytes.data(), static_cast<int>(bytes.size()), result.data(), size);
  return result;
}

std::string ToUtf8(const std::wstring& value) {
  if (value.empty()) {
    return {};
  }

  const int size = ::WideCharToMultiByte(CP_UTF8, 0, value.data(), static_cast<int>(value.size()), nullptr, 0, nullptr, nullptr);
  std::string result(size, '\0');
  ::WideCharToMultiByte(CP_UTF8, 0, value.data(), static_cast<int>(value.size()), result.data(), size, nullptr, nullptr);
  return result;
}

bool ReadFileBytes(const std::wstring& path, std::string& bytes, std::wstring& error) {
  HANDLE file = ::CreateFileW(path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (file == INVALID_HANDLE_VALUE) {
    error = L"Failed to open CSV file.";
    return false;
  }

  LARGE_INTEGER size {};
  if (::GetFileSizeEx(file, &size) == 0) {
    error = L"Failed to read CSV file size.";
    ::CloseHandle(file);
    return false;
  }

  bytes.resize(static_cast<std::size_t>(size.QuadPart));
  DWORD read = 0;
  const BOOL ok = bytes.empty() ? TRUE : ::ReadFile(file, bytes.data(), static_cast<DWORD>(bytes.size()), &read, nullptr);
  ::CloseHandle(file);
  if (ok == 0) {
    error = L"Failed to read CSV file.";
    return false;
  }

  bytes.resize(read);
  return true;
}

std::wstring EncodeField(const std::wstring& value) {
  std::wstring escaped;
  escaped.reserve(value.size());
  bool needsQuotes = false;

  for (wchar_t ch : value) {
    if (ch == L'"') {
      escaped.push_back(L'"');
      escaped.push_back(L'"');
      needsQuotes = true;
    } else {
      if (ch == L',' || ch == L'\r' || ch == L'\n') {
        needsQuotes = true;
      }
      escaped.push_back(ch);
    }
  }

  if (needsQuotes) {
    return L"\"" + escaped + L"\"";
  }
  return escaped;
}

std::wstring BuildLine(const std::vector<std::wstring>& fields) {
  std::wstring line;
  for (std::size_t i = 0; i < fields.size(); ++i) {
    if (i != 0) {
      line.push_back(L',');
    }
    line += EncodeField(fields[i]);
  }
  return line;
}

const std::vector<std::wstring> kHeaders = {
  L"RecordType",
  L"ProjectTitle",
  L"MaterialTitle",
  L"MaterialKind",
  L"MaterialWidth",
  L"MaterialThickness",
  L"Length",
  L"Width",
  L"Quantity",
  L"Identifier",
  L"Description"
};

std::wstring CellByName(
  const std::vector<std::wstring>& header,
  const std::vector<std::wstring>& row,
  const std::wstring& name
) {
  for (std::size_t i = 0; i < header.size(); ++i) {
    if (_wcsicmp(header[i].c_str(), name.c_str()) == 0) {
      if (i < row.size()) {
        return Trim(row[i]);
      }
      return L"";
    }
  }
  return L"";
}

}  // namespace

std::vector<std::wstring> CsvHeaders() {
  return kHeaders;
}

bool ParseUtf8CsvFile(const std::wstring& path, std::vector<std::vector<std::wstring>>& rows, std::wstring& error) {
  rows.clear();
  std::string bytes;
  if (!ReadFileBytes(path, bytes, error)) {
    return false;
  }

  if (bytes.size() >= 3 &&
      static_cast<unsigned char>(bytes[0]) == 0xEF &&
      static_cast<unsigned char>(bytes[1]) == 0xBB &&
      static_cast<unsigned char>(bytes[2]) == 0xBF) {
    bytes.erase(0, 3);
  }

  const std::wstring text = FromUtf8(bytes);
  std::vector<std::wstring> row;
  std::wstring field;
  bool inQuotes = false;

  auto flushField = [&]() {
    row.push_back(field);
    field.clear();
  };

  auto flushRow = [&]() {
    if (!(row.size() == 1 && row[0].empty())) {
      rows.push_back(row);
    }
    row.clear();
  };

  for (std::size_t i = 0; i < text.size(); ++i) {
    const wchar_t ch = text[i];
    if (ch == L'"') {
      if (inQuotes && i + 1 < text.size() && text[i + 1] == L'"') {
        field.push_back(L'"');
        ++i;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (ch == L',' && !inQuotes) {
      flushField();
    } else if ((ch == L'\r' || ch == L'\n') && !inQuotes) {
      flushField();
      flushRow();
      if (ch == L'\r' && i + 1 < text.size() && text[i + 1] == L'\n') {
        ++i;
      }
    } else {
      field.push_back(ch);
    }
  }

  if (inQuotes) {
    error = L"CSV parser error: unmatched quote.";
    return false;
  }

  if (!field.empty() || !row.empty()) {
    flushField();
    flushRow();
  }

  return true;
}

bool HasRequiredHeader(const std::vector<std::wstring>& header) {
  if (header.size() < kHeaders.size()) {
    return false;
  }

  for (std::size_t i = 0; i < kHeaders.size(); ++i) {
    if (_wcsicmp(Trim(header[i]).c_str(), kHeaders[i].c_str()) != 0) {
      return false;
    }
  }

  return true;
}

bool TryParseMaterialKind(const std::wstring& text, TMaterialKind& kind) {
  const std::wstring trimmed = Trim(text);
  if (_wcsicmp(trimmed.c_str(), L"mk1D") == 0) {
    kind = mk1D;
    return true;
  }
  if (_wcsicmp(trimmed.c_str(), L"mk2D") == 0) {
    kind = mk2D;
    return true;
  }
  if (_wcsicmp(trimmed.c_str(), L"mkUnknown") == 0) {
    kind = mkUnknown;
    return true;
  }
  return false;
}

std::wstring MaterialKindToText(TMaterialKind kind) {
  switch (kind) {
    case mk1D:
      return L"mk1D";
    case mk2D:
      return L"mk2D";
    default:
      return L"mkUnknown";
  }
}

bool DecodeCsvRows(
  const std::vector<std::vector<std::wstring>>& rows,
  std::vector<CsvRowRecord>& records,
  std::wstring& error
) {
  records.clear();
  if (rows.empty() || !HasRequiredHeader(rows.front())) {
    error = L"CSV header does not match the starter schema.";
    return false;
  }

  for (std::size_t i = 1; i < rows.size(); ++i) {
    CsvRowRecord record;
    record.recordType = Trim(CellByName(rows[0], rows[i], L"RecordType"));
    if (record.recordType.empty()) {
      continue;
    }

    record.projectTitle = CellByName(rows[0], rows[i], L"ProjectTitle");
    record.materialTitle = CellByName(rows[0], rows[i], L"MaterialTitle");
    record.identifier = CellByName(rows[0], rows[i], L"Identifier");
    record.description = CellByName(rows[0], rows[i], L"Description");

    if (!TryParseMaterialKind(CellByName(rows[0], rows[i], L"MaterialKind"), record.materialKind)) {
      error = L"Unknown MaterialKind at row " + std::to_wstring(i + 1) + L".";
      return false;
    }
    if (!TryParseUnsigned(CellByName(rows[0], rows[i], L"MaterialWidth"), record.materialWidth)) {
      error = L"Invalid MaterialWidth at row " + std::to_wstring(i + 1) + L".";
      return false;
    }
    if (!TryParseUnsigned(CellByName(rows[0], rows[i], L"MaterialThickness"), record.materialThickness)) {
      error = L"Invalid MaterialThickness at row " + std::to_wstring(i + 1) + L".";
      return false;
    }
    if (!TryParseUnsigned(CellByName(rows[0], rows[i], L"Length"), record.length)) {
      error = L"Invalid Length at row " + std::to_wstring(i + 1) + L".";
      return false;
    }
    if (!TryParseUnsigned(CellByName(rows[0], rows[i], L"Width"), record.width)) {
      error = L"Invalid Width at row " + std::to_wstring(i + 1) + L".";
      return false;
    }
    if (!TryParseUnsigned(CellByName(rows[0], rows[i], L"Quantity"), record.quantity) || record.quantity == 0) {
      record.quantity = 1;
    }

    const std::wstring normalizedType = Trim(record.recordType);
    if (_wcsicmp(normalizedType.c_str(), L"FORMAT") != 0 &&
        _wcsicmp(normalizedType.c_str(), L"SHEET") != 0) {
      error = L"Unknown RecordType at row " + std::to_wstring(i + 1) + L".";
      return false;
    }

    records.push_back(record);
  }

  return true;
}

std::wstring EncodeCsvRows(const std::vector<CsvRowRecord>& records) {
  std::wstring output = BuildLine(kHeaders) + L"\r\n";
  for (const CsvRowRecord& record : records) {
    output += BuildLine({
      record.recordType,
      record.projectTitle,
      record.materialTitle,
      MaterialKindToText(record.materialKind),
      std::to_wstring(record.materialWidth),
      std::to_wstring(record.materialThickness),
      std::to_wstring(record.length),
      std::to_wstring(record.width),
      std::to_wstring(record.quantity),
      record.identifier,
      record.description
    });
    output += L"\r\n";
  }
  return output;
}

bool WriteUtf8CsvFile(const std::wstring& path, const std::wstring& content, std::wstring& error) {
  const std::string utf8 = ToUtf8(content);
  HANDLE file = ::CreateFileW(path.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (file == INVALID_HANDLE_VALUE) {
    error = L"Failed to open output CSV file.";
    return false;
  }

  const unsigned char bom[] = {0xEF, 0xBB, 0xBF};
  DWORD written = 0;
  BOOL ok = ::WriteFile(file, bom, sizeof(bom), &written, nullptr);
  if (ok != 0 && !utf8.empty()) {
    ok = ::WriteFile(file, utf8.data(), static_cast<DWORD>(utf8.size()), &written, nullptr);
  }
  ::CloseHandle(file);

  if (ok == 0) {
    error = L"Failed to write output CSV file.";
    return false;
  }

  return true;
}

}  // namespace toncut
