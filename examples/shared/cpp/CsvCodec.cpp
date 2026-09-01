#include "CsvCodec.hpp"

#include <algorithm>
#include <cerrno>
#include <climits>
#include <cstdlib>
#include <cwctype>
#include <limits>

namespace toncut {

namespace {

class ScopedHandle final {
public:
  explicit ScopedHandle(HANDLE value) noexcept : value_(value) {
  }

  ~ScopedHandle() {
    if (value_ != INVALID_HANDLE_VALUE) {
      ::CloseHandle(value_);
    }
  }

  ScopedHandle(const ScopedHandle&) = delete;
  ScopedHandle& operator=(const ScopedHandle&) = delete;

  HANDLE Get() const noexcept {
    return value_;
  }

  bool IsValid() const noexcept {
    return value_ != INVALID_HANDLE_VALUE;
  }

private:
  HANDLE value_;
};

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
  result = 0;
  const std::wstring trimmed = Trim(value);
  if (trimmed.empty() || trimmed.front() == L'-') {
    return false;
  }

  errno = 0;
  wchar_t* end = nullptr;
  const unsigned long parsed = std::wcstoul(trimmed.c_str(), &end, 10);
  if (
    end == trimmed.c_str() ||
    end == nullptr ||
    *end != L'\0' ||
    errno == ERANGE ||
    parsed > UINT_MAX
  ) {
    return false;
  }

  result = static_cast<unsigned>(parsed);
  return true;
}

bool ReadAll(HANDLE file, void* data, std::size_t size) {
  auto* next = static_cast<unsigned char*>(data);
  while (size > 0) {
    const DWORD requested = static_cast<DWORD>(
      (std::min)(size, static_cast<std::size_t>((std::numeric_limits<DWORD>::max)()))
    );
    DWORD read = 0;
    if (::ReadFile(file, next, requested, &read, nullptr) == 0 || read == 0 || read > requested) {
      return false;
    }
    next += read;
    size -= read;
  }
  return true;
}

bool WriteAll(HANDLE file, const void* data, std::size_t size) {
  const auto* next = static_cast<const unsigned char*>(data);
  while (size > 0) {
    const DWORD requested = static_cast<DWORD>(
      (std::min)(size, static_cast<std::size_t>((std::numeric_limits<DWORD>::max)()))
    );
    DWORD written = 0;
    if (::WriteFile(file, next, requested, &written, nullptr) == 0 || written == 0 || written > requested) {
      return false;
    }
    next += written;
    size -= written;
  }
  return true;
}

bool FromUtf8(const std::string& bytes, std::wstring& result) {
  result.clear();
  if (bytes.empty()) {
    return true;
  }
  if (bytes.size() > static_cast<std::size_t>(INT_MAX)) {
    return false;
  }

  const int inputSize = static_cast<int>(bytes.size());
  const int size = ::MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, bytes.data(), inputSize, nullptr, 0);
  if (size <= 0) {
    return false;
  }
  result.resize(static_cast<std::size_t>(size));
  return ::MultiByteToWideChar(
    CP_UTF8,
    MB_ERR_INVALID_CHARS,
    bytes.data(),
    inputSize,
    result.data(),
    size
  ) == size;
}

bool ToUtf8(const std::wstring& value, std::string& result) {
  result.clear();
  if (value.empty()) {
    return true;
  }
  if (value.size() > static_cast<std::size_t>(INT_MAX)) {
    return false;
  }

  const int inputSize = static_cast<int>(value.size());
  const int size = ::WideCharToMultiByte(CP_UTF8, 0, value.data(), inputSize, nullptr, 0, nullptr, nullptr);
  if (size <= 0) {
    return false;
  }
  result.resize(static_cast<std::size_t>(size));
  return ::WideCharToMultiByte(
    CP_UTF8,
    0,
    value.data(),
    inputSize,
    result.data(),
    size,
    nullptr,
    nullptr
  ) == size;
}

bool ReadFileBytes(const std::wstring& path, std::string& bytes, std::wstring& error) {
  const ScopedHandle file(::CreateFileW(
    path.c_str(),
    GENERIC_READ,
    FILE_SHARE_READ,
    nullptr,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,
    nullptr
  ));
  if (!file.IsValid()) {
    error = L"Failed to open CSV file.";
    return false;
  }

  LARGE_INTEGER size {};
  if (::GetFileSizeEx(file.Get(), &size) == 0) {
    error = L"Failed to read CSV file size.";
    return false;
  }
  if (size.QuadPart < 0 || size.QuadPart > INT_MAX) {
    error = L"CSV file is too large to decode safely.";
    return false;
  }

  bytes.resize(static_cast<std::size_t>(size.QuadPart));
  const bool ok = ReadAll(file.Get(), bytes.data(), bytes.size());
  if (!ok) {
    error = L"Failed to read CSV file.";
    return false;
  }
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
    if (_wcsicmp(Trim(header[i]).c_str(), name.c_str()) == 0) {
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

  std::wstring text;
  if (!FromUtf8(bytes, text)) {
    error = L"CSV file is too large or contains invalid UTF-8.";
    return false;
  }
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
  std::string utf8;
  if (!ToUtf8(content, utf8)) {
    error = L"CSV text is too large or cannot be encoded as UTF-8.";
    return false;
  }
  HANDLE file = ::CreateFileW(path.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (file == INVALID_HANDLE_VALUE) {
    error = L"Failed to open output CSV file.";
    return false;
  }

  const unsigned char bom[] = {0xEF, 0xBB, 0xBF};
  bool ok = WriteAll(file, bom, sizeof(bom)) && WriteAll(file, utf8.data(), utf8.size());
  if (ok && ::FlushFileBuffers(file) == 0) {
    ok = false;
  }
  const BOOL closed = ::CloseHandle(file);

  if (!ok || closed == 0) {
    error = L"Failed to write output CSV file.";
    return false;
  }

  return true;
}

}  // namespace toncut
