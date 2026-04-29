#pragma once

#include "../../../include/cpp/TonCutPluginSdk.hpp"

#include <string>
#include <vector>

namespace toncut {

struct CsvRowRecord {
  std::wstring recordType;
  std::wstring projectTitle;
  std::wstring materialTitle;
  TMaterialKind materialKind = mkUnknown;
  unsigned materialWidth = 0;
  unsigned materialThickness = 0;
  unsigned length = 0;
  unsigned width = 0;
  unsigned quantity = 1;
  std::wstring identifier;
  std::wstring description;
};

std::vector<std::wstring> CsvHeaders();
bool ParseUtf8CsvFile(const std::wstring& path, std::vector<std::vector<std::wstring>>& rows, std::wstring& error);
bool HasRequiredHeader(const std::vector<std::wstring>& header);
bool DecodeCsvRows(const std::vector<std::vector<std::wstring>>& rows, std::vector<CsvRowRecord>& records, std::wstring& error);
std::wstring EncodeCsvRows(const std::vector<CsvRowRecord>& records);
bool TryParseMaterialKind(const std::wstring& text, TMaterialKind& kind);
std::wstring MaterialKindToText(TMaterialKind kind);
bool WriteUtf8CsvFile(const std::wstring& path, const std::wstring& content, std::wstring& error);

}  // namespace toncut
