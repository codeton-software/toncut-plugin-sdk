from __future__ import annotations

import hashlib
import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parent.parent
SDK_ROOT = ROOT.parent
GENERATED_ROOT = ROOT / "generated"
PROBES_ROOT = GENERATED_ROOT / "probes"
HARNESS_ROOT = GENERATED_ROOT / "harness"
REPORTS_ROOT = GENERATED_ROOT / "reports"
RUNTIME_ROOT = GENERATED_ROOT / "runtime"
SUPPORT_CONFIG_PATH = ROOT / "support" / "language-support.config.json"
LANE_DISPLAY_NAMES = {
    "delphi": "Delphi",
    "cppbuilder": "C++Builder",
    "msvc": "MSVC",
    "csharp": "C#",
}


def ensure_dir(dir_path: Path) -> None:
    dir_path.mkdir(parents=True, exist_ok=True)


def read_text(file_path: Path, *, bom: bool = False) -> str:
    encoding = "utf-8-sig" if bom else "utf-8"
    return file_path.read_text(encoding=encoding)


def write_text(file_path: Path, content: str) -> None:
    ensure_dir(file_path.parent)
    file_path.write_text(content, encoding="utf-8")


def write_json(file_path: Path, value: Any) -> None:
    write_text(file_path, f"{json.dumps(value, indent=2)}\n")


def iso_timestamp() -> str:
    return (
        datetime.now(timezone.utc)
        .isoformat(timespec="milliseconds")
        .replace("+00:00", "Z")
    )


def to_windows_path(value: str) -> str:
    return value.replace("/", "\\")


def to_posix_path(value: str) -> str:
    return value.replace("\\", "/")


def relative_to_sdk_path(from_path: Path, *segments: str) -> str:
    return os.path.relpath(SDK_ROOT.joinpath(*segments), from_path)


def relative_to_tests_path(*segments: str) -> str:
    return os.path.relpath(SDK_ROOT.joinpath(*segments), ROOT)


def normalize_whitespace(value: str) -> str:
    return re.sub(r"\s+", " ", value).strip()


def hash_guid(seed: str) -> str:
    hex_value = hashlib.md5(seed.encode("utf-8")).hexdigest().upper()
    return "{{{}-{}-{}-{}-{}}}".format(
        hex_value[0:8],
        hex_value[8:12],
        hex_value[12:16],
        hex_value[16:20],
        hex_value[20:32],
    )


def split_top_level(value: str, delimiter: str) -> list[str]:
    parts: list[str] = []
    current: list[str] = []
    paren = 0
    angle = 0
    for ch in value:
        if ch == "(":
            paren += 1
        if ch == ")":
            paren = max(0, paren - 1)
        if ch == "<":
            angle += 1
        if ch == ">":
            angle = max(0, angle - 1)
        if ch == delimiter and paren == 0 and angle == 0:
            parts.append("".join(current))
            current = []
            continue
        current.append(ch)
    if current:
        parts.append("".join(current))
    return parts


def strip_inline_comment(line: str) -> str:
    return re.sub(r"\s*//.*$", "", line)


def strip_pascal_directives(signature: str) -> str:
    value = re.sub(
        r"\b(?:stdcall|safecall|cdecl|overload|reintroduce|virtual|override|dynamic|inline|deprecated)\b",
        "",
        signature,
        flags=re.IGNORECASE,
    )
    value = re.sub(r";\s*;", ";", value)
    value = re.sub(r";+$", "", value)
    return value.strip()


def parse_pascal_parameters(text: str | None) -> list[dict[str, Any]]:
    if not text or not text.strip():
        return []
    result: list[dict[str, Any]] = []
    for segment in split_top_level(text, ";"):
        trimmed = normalize_whitespace(segment)
        if not trimmed:
            continue
        match = re.match(r"^(?:(const|var|out)\s+)?(.+?)\s*:\s*(.+)$", trimmed, re.IGNORECASE)
        if not match:
            result.append({"name": trimmed, "modifier": None, "type": "Variant"})
            continue
        modifier = match.group(1).lower() if match.group(1) else None
        names = [item.strip() for item in match.group(2).split(",") if item.strip()]
        type_name = normalize_whitespace(re.sub(r"\s*=\s*.+$", "", match.group(3)))
        for name in names:
            result.append({"name": name, "modifier": modifier, "type": type_name})
    return result


def parse_pascal_method(signature: str) -> dict[str, Any]:
    clean = strip_pascal_directives(signature)
    match = re.match(
        r"^(function|procedure)\s+([A-Za-z0-9_]+)\s*(?:\((.*)\))?\s*(?::\s*(.+))?$",
        clean,
        re.IGNORECASE,
    )
    if not match:
        return {
            "kind": "method",
            "signature": clean,
            "name": clean,
            "procedureKind": "procedure",
            "returnType": None,
            "parameters": [],
        }
    procedure_kind = match.group(1).lower()
    return {
        "kind": "method",
        "signature": clean,
        "name": match.group(2),
        "procedureKind": procedure_kind,
        "returnType": None
        if procedure_kind == "procedure"
        else normalize_whitespace(match.group(4) or "Variant"),
        "parameters": parse_pascal_parameters(match.group(3)),
    }


def parse_pascal_property(signature: str) -> dict[str, Any]:
    clean = strip_pascal_directives(signature)
    value = re.sub(r"^property\s+", "", clean, flags=re.IGNORECASE)
    accessor_match = re.search(r"\s+(?:read|write)\b", value, flags=re.IGNORECASE)
    header = value[: accessor_match.start()].strip() if accessor_match else value
    match = re.match(r"^([A-Za-z0-9_]+)(?:\[(.*)\])?\s*:\s*(.+)$", header)
    read_accessor_match = re.search(r"\bread\s+([A-Za-z0-9_]+)", clean, re.IGNORECASE)
    write_accessor_match = re.search(r"\bwrite\s+([A-Za-z0-9_]+)", clean, re.IGNORECASE)
    return {
        "kind": "property",
        "signature": clean,
        "name": match.group(1) if match else value,
        "type": normalize_whitespace(match.group(3)) if match else "Variant",
        "parameters": parse_pascal_parameters(match.group(2) if match else None),
        "readAccessor": read_accessor_match.group(1) if read_accessor_match else None,
        "writeAccessor": write_accessor_match.group(1) if write_accessor_match else None,
        "writable": bool(re.search(r"\bwrite\b", clean, re.IGNORECASE)),
        "defaultProperty": bool(re.search(r"\bdefault$", clean, re.IGNORECASE)),
    }


def parse_pascal_units() -> list[dict[str, Any]]:
    pascal_dir = SDK_ROOT / "include" / "pascal"
    files = sorted(file for file in pascal_dir.iterdir() if file.suffix.lower() == ".pas")
    interfaces: list[dict[str, Any]] = []

    for file_path in files:
        lines = read_text(file_path).splitlines()
        current: dict[str, Any] | None = None
        buffer: list[str] = []

        def flush() -> None:
            nonlocal buffer
            if current is None or not buffer:
                buffer = []
                return
            declaration = normalize_whitespace(" ".join(buffer))
            buffer = []
            if re.match(r"^(function|procedure)\s+", declaration, re.IGNORECASE):
                current["methods"].append(parse_pascal_method(declaration))
            elif re.match(r"^property\s+", declaration, re.IGNORECASE):
                current["properties"].append(parse_pascal_property(declaration))

        for raw_line in lines:
            line = strip_inline_comment(raw_line).strip()
            if current is None:
                match = re.match(
                    r"^([A-Za-z0-9_]+)\s*=\s*interface(?:\(([A-Za-z0-9_,.\s]+)\))?",
                    line,
                    re.IGNORECASE,
                )
                if match:
                    current = {
                        "name": match.group(1),
                        "file": f"SDK/include/pascal/{file_path.name}",
                        "fileName": file_path.name,
                        "extends": [
                            item.strip()
                            for item in (match.group(2) or "").split(",")
                            if item.strip()
                        ],
                        "methods": [],
                        "properties": [],
                    }
                continue

            if not line:
                continue
            if re.match(r"^end;$", line, re.IGNORECASE):
                flush()
                accessor_map: dict[str, bool] = {}
                for prop in current["properties"]:
                    if prop["readAccessor"]:
                        accessor_map[prop["readAccessor"]] = True
                    if prop["writeAccessor"]:
                        accessor_map[prop["writeAccessor"]] = True
                current["methods"] = [
                    {**method, "order": index, "accessor": accessor_map.get(method["name"], False)}
                    for index, method in enumerate(current["methods"])
                ]
                current["properties"] = [
                    {**prop, "order": index}
                    for index, prop in enumerate(current["properties"])
                ]
                interfaces.append(current)
                current = None
                continue

            if re.match(r"^\[[0-9A-Fa-f-]{36}\]$", line):
                continue
            if re.match(r"^(function|procedure|property)\s+", line, re.IGNORECASE):
                flush()
            if buffer or re.match(r"^(function|procedure|property)\s+", line, re.IGNORECASE):
                buffer.append(line)
                if re.search(r";\s*$", line):
                    flush()

    interfaces.sort(key=lambda item: item["name"])
    return interfaces


def parse_cpp_parameters(text: str) -> list[dict[str, Any]]:
    clean = text.strip()
    if not clean or clean == "void":
        return []
    result: list[dict[str, Any]] = []
    for index, part in enumerate(split_top_level(clean, ",")):
        item = normalize_whitespace(part)
        if not item:
            continue
        match = re.match(r"^(.*\b)([A-Za-z_][A-Za-z0-9_]*)$", item)
        if match:
            result.append(
                {"name": match.group(2), "type": normalize_whitespace(match.group(1))}
            )
        else:
            result.append({"name": f"arg{index}", "type": item})
    return result


def parse_cpp_header() -> list[dict[str, Any]]:
    text = read_text(SDK_ROOT / "include" / "cpp" / "TonCutPluginSdk.hpp")
    interfaces: list[dict[str, Any]] = []
    interface_regex = re.compile(
        r"struct\s+(I[A-Za-z0-9_]+)\s*:\s*IUnknown\s*\{([\s\S]*?)\};",
        re.DOTALL,
    )
    method_regex = re.compile(
        r"virtual\s+HRESULT\s+STDMETHODCALLTYPE\s+([A-Za-z0-9_]+)\s*\(([\s\S]*?)\)\s*=\s*0;",
        re.DOTALL,
    )
    for match in interface_regex.finditer(text):
        methods = []
        for method_match in method_regex.finditer(match.group(2)):
            methods.append(
                {
                    "name": method_match.group(1),
                    "signature": normalize_whitespace(
                        f"HRESULT {method_match.group(1)}({method_match.group(2)})"
                    ),
                    "returnType": "HRESULT",
                    "parameters": parse_cpp_parameters(method_match.group(2)),
                }
            )
        interfaces.append(
            {
                "name": match.group(1),
                "file": "SDK/include/cpp/TonCutPluginSdk.hpp",
                "methods": methods,
            }
        )
    interfaces.sort(key=lambda item: item["name"])
    return interfaces


def build_manifest(
    pascal_interfaces: list[dict[str, Any]],
    cpp_interfaces: list[dict[str, Any]],
) -> dict[str, Any]:
    return {
        "generatedAt": iso_timestamp(),
        "sourceRoot": "SDK/include",
        "totals": {
            "interfaceCount": len(pascal_interfaces),
            "methodCount": sum(len(item["methods"]) for item in pascal_interfaces),
            "propertyCount": sum(len(item["properties"]) for item in pascal_interfaces),
            "cppInterfaceCount": len(cpp_interfaces),
            "cppMethodCount": sum(len(item["methods"]) for item in cpp_interfaces),
        },
        "interfaces": pascal_interfaces,
        "cppInterfaces": cpp_interfaces,
    }


def load_config() -> dict[str, Any]:
    return json.loads(read_text(SUPPORT_CONFIG_PATH))


def normalize_lane_ids(lanes: set[str] | None = None) -> set[str]:
    return {
        lane.strip().lower()
        for lane in (lanes or set())
        if isinstance(lane, str) and lane.strip()
    }


def describe_lane_ids(lanes: set[str] | None = None) -> str:
    return ", ".join(
        LANE_DISPLAY_NAMES.get(lane, lane) for lane in sorted(normalize_lane_ids(lanes))
    )


def diff_cpp_interface_against_pascal(
    cpp_interface: dict[str, Any],
    pascal_interface: dict[str, Any] | None,
) -> dict[str, Any]:
    if pascal_interface is None:
        return {"status": "missing", "methodDiffs": []}
    max_length = max(len(cpp_interface["methods"]), len(pascal_interface["methods"]))
    method_diffs: list[dict[str, Any]] = []
    for index in range(max_length):
        cpp_method = cpp_interface["methods"][index] if index < len(cpp_interface["methods"]) else None
        pascal_method = (
            pascal_interface["methods"][index]
            if index < len(pascal_interface["methods"])
            else None
        )
        if cpp_method is None or pascal_method is None:
            method_diffs.append(
                {
                    "index": index,
                    "status": "length-mismatch",
                    "cppMethod": cpp_method["name"] if cpp_method else None,
                    "pascalMethod": pascal_method["name"] if pascal_method else None,
                }
            )
            continue
        if cpp_method["name"] != pascal_method["name"]:
            method_diffs.append(
                {
                    "index": index,
                    "status": "name-mismatch",
                    "cppMethod": cpp_method["name"],
                    "pascalMethod": pascal_method["name"],
                }
            )
    return {
        "status": "ok" if not method_diffs else "warning",
        "cppMethodCount": len(cpp_interface["methods"]),
        "pascalMethodCount": len(pascal_interface["methods"]),
        "methodDiffs": method_diffs,
    }


def build_support(manifest: dict[str, Any], config: dict[str, Any]) -> dict[str, Any]:
    pascal_by_name = {item["name"]: item for item in manifest["interfaces"]}
    lanes: dict[str, Any] = {}
    for lane_id, lane in config["lanes"].items():
        if lane["kind"] == "pascal-full":
            lanes[lane_id] = {
                **lane,
                "supportedInterfaces": [
                    {
                        "name": item["name"],
                        "file": item["file"],
                        "methodCount": len(item["methods"]),
                        "propertyCount": len(item["properties"]),
                        "methods": [method["name"] for method in item["methods"]],
                        "properties": [prop["name"] for prop in item["properties"]],
                    }
                    for item in manifest["interfaces"]
                ],
                "unsupportedInterfaces": [],
            }
            continue
        supported_interfaces = [
            {
                "name": item["name"],
                "file": item["file"],
                "methodCount": len(item["methods"]),
                "propertyCount": 0,
                "methods": [method["name"] for method in item["methods"]],
                "properties": [],
                "diff": diff_cpp_interface_against_pascal(item, pascal_by_name.get(item["name"])),
            }
            for item in manifest["cppInterfaces"]
        ]
        supported_names = {item["name"] for item in supported_interfaces}
        lanes[lane_id] = {
            **lane,
            "supportedInterfaces": supported_interfaces,
            "unsupportedInterfaces": [
                item["name"]
                for item in manifest["interfaces"]
                if item["name"] not in supported_names
            ],
        }
    return {
        "generatedAt": manifest["generatedAt"],
        "totals": manifest["totals"],
        "lanes": lanes,
    }


def pascal_sample(type_name: str, seed: str) -> str:
    value = normalize_whitespace(type_name)
    array_match = re.fullmatch(r"array\s+of\s+(.+)", value, re.IGNORECASE)
    if array_match:
        return f"[{pascal_sample(array_match.group(1), seed)}]"
    if re.search(r"\b(?:procedure|function|reference to)\b", value, re.IGNORECASE):
        return "nil"
    if re.fullmatch(r"Boolean", value, re.IGNORECASE):
        return "True"
    if re.fullmatch(
        r"Integer|SmallInt|ShortInt|Byte|Word|Cardinal|LongInt|Int64|UInt64|NativeInt|NativeUInt",
        value,
        re.IGNORECASE,
    ):
        return "1"
    if re.fullmatch(
        r"Single|Double|Extended|Currency|Real|TDateTime|TTcPrice|TTcWeight",
        value,
        re.IGNORECASE,
    ):
        return "1.5"
    if re.fullmatch(
        r"WideString|String|UnicodeString|AnsiString|PChar", value, re.IGNORECASE
    ):
        return f"'{seed}'"
    if re.fullmatch(r"THandle", value, re.IGNORECASE):
        return "0"
    return f"Default({value})"


def is_pascal_identifier(value: str) -> bool:
    return bool(re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", value))


def build_pascal_argument(
    parameter: dict[str, Any], member_name: str, suffix: int, index: int
) -> tuple[list[str], str]:
    type_name = normalize_whitespace(parameter["type"])
    sample = pascal_sample(type_name, f"{parameter['name']}{index + 1}")
    modifier = parameter.get("modifier")
    if modifier in {"var", "out"}:
        var_name = f"__{member_name}{suffix}Arg{index}"
        if modifier == "out":
            return [f"  var {var_name}: {type_name};"], var_name
        return [f"  var {var_name}: {type_name} := {sample};"], var_name
    return [], sample


def build_pascal_touch_line(
    member: dict[str, Any], interface_name: str, suffix: int
) -> list[str]:
    if member["kind"] == "property":
        args = ", ".join(
            pascal_sample(parameter["type"], f"{parameter['name']}{index + 1}")
            for index, parameter in enumerate(member["parameters"])
        )
        selector = f"[{args}]" if member["parameters"] else ""
        lines: list[str] = []
        if member["writable"]:
            sample = pascal_sample(member["type"], f"{interface_name}.{member['name']}")
            lines.append(f"  aValue.{member['name']}{selector} := {sample};")
        lines.append(
            f"  var __{member['name']}{suffix}Value := aValue.{member['name']}{selector};"
        )
        return lines

    if not is_pascal_identifier(member["name"]):
        return []

    arg_setup: list[str] = []
    arg_values: list[str] = []
    for index, parameter in enumerate(member["parameters"]):
        setup_lines, arg_value = build_pascal_argument(
            parameter, member["name"], suffix, index
        )
        arg_setup.extend(setup_lines)
        arg_values.append(arg_value)
    args = ", ".join(arg_values)
    call = (
        f"aValue.{member['name']}()"
        if not member["parameters"]
        else f"aValue.{member['name']}({args})"
    )
    if member["returnType"]:
        return [*arg_setup, f"  var __{member['name']}{suffix}Result := {call};"]
    return [*arg_setup, f"  {call};"]


def generate_delphi_probe(
    manifest: dict[str, Any], lane: dict[str, Any]
) -> dict[str, str]:
    interface_map = {item["name"]: item for item in manifest["interfaces"]}
    interfaces = [
        interface_map[item["name"]]
        for item in lane["supportedInterfaces"]
        if item["name"] in interface_map
    ]
    used_units = list(
        dict.fromkeys(
            ["uICommon", "uITcPluginCommon"]
            + [Path(iface["fileName"]).stem for iface in interfaces]
        )
    )

    touch_procedures: list[str] = []
    for iface in interfaces:
        lines = [
            f"procedure Touch{iface['name']}(const aValue: {iface['name']});",
            "begin",
            "  if not Assigned(aValue) then Exit;",
        ]
        for prop in iface["properties"]:
            lines.extend(build_pascal_touch_line(prop, iface["name"], prop["order"]))
        for method in iface["methods"]:
            if not method["accessor"]:
                lines.extend(
                    build_pascal_touch_line(method, iface["name"], method["order"])
                )
        lines.append("end;")
        touch_procedures.append("\n".join(lines))

    toncut_interface = interface_map.get("ITonCut")
    nested_calls: list[str] = []
    if toncut_interface:
        for prop in toncut_interface["properties"]:
            if re.match(r"^I[A-Z]", prop["type"]) and prop["type"] != "ITonCut":
                nested_calls.append(f"    Touch{prop['type']}(aTonCut.{prop['name']});")
        for method in toncut_interface["methods"]:
            if method["accessor"] or not method["returnType"]:
                continue
            if not re.match(r"^I[A-Z]", method["returnType"]):
                continue
            args = ", ".join(
                pascal_sample(parameter["type"], f"{parameter['name']}{index + 1}")
                for index, parameter in enumerate(method["parameters"])
            )
            call = (
                f"aTonCut.{method['name']}()"
                if not method["parameters"]
                else f"aTonCut.{method['name']}({args})"
            )
            nested_calls.append(f"    Touch{method['returnType']}({call});")

    touch_unit = """unit uContractProbeTouch;

interface

uses
  System.SysUtils,
  __USED_UNITS__;

procedure TouchAllSupportedInterfaces(const aTonCut: ITonCut);

implementation

__TOUCH_PROCEDURES__

procedure TouchAllSupportedInterfaces(const aTonCut: ITonCut);
begin
  if Assigned(aTonCut) then
  begin
    TouchITonCut(aTonCut);
__NESTED_CALLS__
  end;
end;

end.
"""
    touch_unit = touch_unit.replace("__USED_UNITS__", ",\n  ".join(used_units))
    touch_unit = touch_unit.replace("__TOUCH_PROCEDURES__", "\n\n".join(touch_procedures))
    touch_unit = touch_unit.replace(
        "__NESTED_CALLS__", "\n".join(nested_calls) if nested_calls else ""
    )

    plugin_unit = """unit uContractProbePlugin;

interface

uses
  Winapi.Windows,
  uICommon,
  uITonCut,
  uITcPlugin,
  uITcPluginCommon,
  uITcPlotterInfo,
  uITcEnumExtensionsCallback,
  uIDevices,
  uIMaterials,
  uIBands,
  uIProjects,
  uIFormats,
  uISheets,
  uISolution,
  uISolutionSheet,
  uContractProbeTouch;

type
  TContractProbePlugin = class(TInterfacedObject, ITcPlugin)
  private
    FRegRoot: WideString;
    FLanguageId: Integer;
    FUiScale: Single;
    FTonCut: ITonCut;
  public
    function GetEngineVersion(): Integer; safecall;
    function GetName(): WideString; safecall;
    function GetVersion(): TTcpVersion; safecall;
    function GetTitle(): WideString; safecall;
    function GetProfessional(): Boolean; safecall;
    function GetRegRoot(): WideString; safecall;
    function GetLanguageId(): Integer; safecall;
    procedure SetLanguageId(aValue: Integer); safecall;
    function GetUiScale(): Single; safecall;
    procedure SetUiScale(aValue: Single); safecall;
    function GetTonCut(): ITonCut; safecall;
    function GetFeatures(): TTcpFeatures; safecall;
    function GetPlotterInfo(): ITcPlotterInfo; safecall;
    function Initialize(const aRegRoot: WideString; aLanguageId: Integer; aTonCut: ITonCut): TTcpResult; safecall;
    function Finalize(): TTcpResult; safecall;
    function Configure(aWindow: THandle): TTcpResult; safecall;
    function About(aWindow: THandle): TTcpResult; safecall;
    function LoadConfig(const aKey: WideString; const aVersion: WideString): TTcpResult; safecall;
    function SaveConfig(const aKey: WideString): TTcpResult; safecall;
    function BackupConfig(var aBackup: WideString): TTcpResult; safecall;
    function RestoreConfig(const aBackup: WideString; aScope: TConfigurationParts): TTcpResult; safecall;
    function EnumExtensions(aType: TTcpExtensionType; aEnumCb: ITcEnumExtensionsCallback): TTcpResult; safecall;
    function IsMyFile(const aFileName: WideString): TTcpResult; safecall;
    function LoadFile(aWindow: THandle; const aFileName: WideString; aDevices: IDevices; aMaterials: IMaterials; aBands: IBands; aProjects: IProjects; aFormats: IFormats; aSheets: ISheets): TTcpResult; safecall;
    function SaveFile(aWindow: THandle; const aFileName: WideString; const aFormats: IFormats; const aSheets: ISheets): TTcpResult; safecall;
    function SaveResult(aWindow: THandle; const aFileName: WideString; const aSolutionSheet: ISolutionSheet): TTcpResult; safecall;
    function BatchSaveResult(aWindow: THandle; aSaveTarget: TTcpSaveTarget; const aPath: WideString; const aSolution: ISolution): TTcpResult; safecall;
    function Plot(aWindow: THandle; const aSolutionSheet: ISolutionSheet): TTcpResult; safecall;
    function BatchPlot(aWindow: THandle; const aSolution: ISolution): TTcpResult; safecall;
    function SavePlot(aWindow: THandle; const aFileName: WideString; const aSolutionSheet: ISolutionSheet): TTcpResult; safecall;
    function BatchSavePlot(aWindow: THandle; aSaveTarget: TTcpSaveTarget; const aPath: WideString; const aSolution: ISolution): TTcpResult; safecall;
  end;

implementation

function TContractProbePlugin.GetEngineVersion(): Integer; begin Result := cEngineVersion; end;
function TContractProbePlugin.GetName(): WideString; begin Result := 'ContractProbe'; end;
function TContractProbePlugin.GetVersion(): TTcpVersion; begin Result := TTcpVersion(1) shl 48; end;
function TContractProbePlugin.GetTitle(): WideString; begin Result := 'Contract Probe'; end;
function TContractProbePlugin.GetProfessional(): Boolean; begin Result := False; end;
function TContractProbePlugin.GetRegRoot(): WideString; begin Result := FRegRoot; end;
function TContractProbePlugin.GetLanguageId(): Integer; begin Result := FLanguageId; end;
procedure TContractProbePlugin.SetLanguageId(aValue: Integer); begin FLanguageId := aValue; end;
function TContractProbePlugin.GetUiScale(): Single; begin Result := FUiScale; end;
procedure TContractProbePlugin.SetUiScale(aValue: Single); begin FUiScale := aValue; end;
function TContractProbePlugin.GetTonCut(): ITonCut; begin Result := FTonCut; end;
function TContractProbePlugin.GetFeatures(): TTcpFeatures; begin Result := [feImport, feExport, feSaveResultToFile]; end;
function TContractProbePlugin.GetPlotterInfo(): ITcPlotterInfo; begin Result := nil; end;
function TContractProbePlugin.Initialize(const aRegRoot: WideString; aLanguageId: Integer; aTonCut: ITonCut): TTcpResult; begin FRegRoot := aRegRoot; FLanguageId := aLanguageId; FTonCut := aTonCut; TouchAllSupportedInterfaces(aTonCut); Result := cprOK; end;
function TContractProbePlugin.Finalize(): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.Configure(aWindow: THandle): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.About(aWindow: THandle): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.LoadConfig(const aKey: WideString; const aVersion: WideString): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.SaveConfig(const aKey: WideString): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.BackupConfig(var aBackup: WideString): TTcpResult; begin aBackup := 'contract-probe-backup'; Result := cprOK; end;
function TContractProbePlugin.RestoreConfig(const aBackup: WideString; aScope: TConfigurationParts): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.EnumExtensions(aType: TTcpExtensionType; aEnumCb: ITcEnumExtensionsCallback): TTcpResult; begin if Assigned(aEnumCb) then aEnumCb.Invoke(aType, '.probe', 'Contract Probe'); Result := cprOK; end;
function TContractProbePlugin.IsMyFile(const aFileName: WideString): TTcpResult; begin Result := cprMaybe; end;
function TContractProbePlugin.LoadFile(aWindow: THandle; const aFileName: WideString; aDevices: IDevices; aMaterials: IMaterials; aBands: IBands; aProjects: IProjects; aFormats: IFormats; aSheets: ISheets): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.SaveFile(aWindow: THandle; const aFileName: WideString; const aFormats: IFormats; const aSheets: ISheets): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.SaveResult(aWindow: THandle; const aFileName: WideString; const aSolutionSheet: ISolutionSheet): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.BatchSaveResult(aWindow: THandle; aSaveTarget: TTcpSaveTarget; const aPath: WideString; const aSolution: ISolution): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.Plot(aWindow: THandle; const aSolutionSheet: ISolutionSheet): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.BatchPlot(aWindow: THandle; const aSolution: ISolution): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.SavePlot(aWindow: THandle; const aFileName: WideString; const aSolutionSheet: ISolutionSheet): TTcpResult; begin Result := cprOK; end;
function TContractProbePlugin.BatchSavePlot(aWindow: THandle; aSaveTarget: TTcpSaveTarget; const aPath: WideString; const aSolution: ISolution): TTcpResult; begin Result := cprOK; end;

end.
"""

    dpr = """library ContractProbe;

{$A8}

uses
  Winapi.Windows,
  uITonCut,
  uITcPlugin,
  uContractProbePlugin in 'uContractProbePlugin.pas',
  uContractProbeTouch in 'uContractProbeTouch.pas';

function TcpInitializeV2(const aRegRoot: PChar; aLanguageId: Integer; aTonCut: ITonCut): ITcPlugin; stdcall;
begin
  Result := TContractProbePlugin.Create;
  Result.Initialize(aRegRoot, aLanguageId, aTonCut);
end;

exports
  TcpInitializeV2;

begin
end.
"""

    return {"touchUnit": touch_unit, "pluginUnit": plugin_unit, "dpr": dpr}


def build_cpp_touch_line(method: dict[str, Any]) -> str:
    args: list[str] = []
    for parameter in method["parameters"]:
        if re.search(r"\*$", parameter["type"]):
            args.append("nullptr")
        elif re.fullmatch(
            r"int|unsigned|unsigned short|std::int64_t|std::uint64_t|DelphiBool",
            parameter["type"],
            re.IGNORECASE,
        ):
            args.append("1")
        elif re.fullmatch(r"float|double", parameter["type"], re.IGNORECASE):
            args.append("1.5")
        else:
            args.append("{}")
    if not method["parameters"]:
        return f"  aValue->{method['name']}();"
    return f"  aValue->{method['name']}({', '.join(args)});"


def generate_cpp_probe(manifest: dict[str, Any], lane: dict[str, Any]) -> dict[str, str]:
    cpp_by_name = {item["name"]: item for item in manifest["cppInterfaces"]}
    touch_functions: list[str] = []
    for item in lane["supportedInterfaces"]:
        iface = cpp_by_name.get(item["name"])
        if iface is None:
            continue
        lines = [
            f"void Touch{item['name']}(toncut::{item['name']}* aValue) {{",
            "  if (aValue == nullptr) return;",
        ]
        for method in iface["methods"]:
            lines.append(build_cpp_touch_line(method))
        lines.append("}")
        touch_functions.append("\n".join(lines))

    touch_header = """#pragma once

#include "../../../SDK/include/cpp/TonCutPluginSdk.hpp"

namespace contract_probe {

__DECLARATIONS__
void TouchAllSupportedInterfaces(toncut::ITonCut* aTonCut);

}  // namespace contract_probe
"""
    touch_header = touch_header.replace(
        "__DECLARATIONS__",
        "\n".join(
            f"void Touch{item['name']}(toncut::{item['name']}* aValue);"
            for item in lane["supportedInterfaces"]
        ),
    )

    direct_getters = [
        ("IProjects", "GetProjects"),
        ("IMaterials", "GetMaterials"),
        ("IFormats", "GetFormats"),
        ("ISheets", "GetSheets"),
        ("ISolution", "GetSolution"),
    ]
    nested_getters = "\n".join(
        f"  if (aTonCut != nullptr) {{ toncut::{interface_name}* value = nullptr; aTonCut->{getter_name}((IUnknown**)&value); Touch{interface_name}(value); if (value != nullptr) value->Release(); }}"
        for interface_name, getter_name in direct_getters
        if any(item["name"] == interface_name for item in lane["supportedInterfaces"])
    )

    touch_source = """#include "ContractProbeTouch.hpp"

namespace contract_probe {

__TOUCH_FUNCTIONS__

void TouchAllSupportedInterfaces(toncut::ITonCut* aTonCut) {
__ROOT_TOUCH__
__NESTED_GETTERS__
}

}  // namespace contract_probe
"""
    touch_source = touch_source.replace("__TOUCH_FUNCTIONS__", "\n\n".join(touch_functions))
    touch_source = touch_source.replace(
        "__ROOT_TOUCH__",
        "  TouchITonCut(aTonCut);"
        if any(item["name"] == "ITonCut" for item in lane["supportedInterfaces"])
        else "  (void)aTonCut;",
    )
    touch_source = touch_source.replace("__NESTED_GETTERS__", nested_getters)

    plugin_header = """#pragma once

#include "ContractProbeTouch.hpp"

#include <atomic>
#include <string>

namespace contract_probe {

class ContractProbePlugin : public toncut::ITcPlugin {
 public:
  ContractProbePlugin();
  ~ContractProbePlugin();
  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID riid, void** object) override;
  ULONG STDMETHODCALLTYPE AddRef() override;
  ULONG STDMETHODCALLTYPE Release() override;
  HRESULT STDMETHODCALLTYPE GetEngineVersion(int* result) override;
  HRESULT STDMETHODCALLTYPE GetName(BSTR* result) override;
  HRESULT STDMETHODCALLTYPE GetVersion(toncut::TTcpVersion* result) override;
  HRESULT STDMETHODCALLTYPE GetTitle(BSTR* result) override;
  HRESULT STDMETHODCALLTYPE GetProfessional(toncut::DelphiBool* result) override;
  HRESULT STDMETHODCALLTYPE GetRegRoot(BSTR* result) override;
  HRESULT STDMETHODCALLTYPE GetLanguageId(int* result) override;
  HRESULT STDMETHODCALLTYPE SetLanguageId(int value) override;
  HRESULT STDMETHODCALLTYPE GetUiScale(float* result) override;
  HRESULT STDMETHODCALLTYPE SetUiScale(float value) override;
  HRESULT STDMETHODCALLTYPE GetTonCut(toncut::ITonCut** result) override;
  HRESULT STDMETHODCALLTYPE GetFeatures(toncut::TTcpFeatures* result) override;
  HRESULT STDMETHODCALLTYPE GetPlotterInfo(toncut::ITcPlotterInfo** result) override;
  HRESULT STDMETHODCALLTYPE Initialize(BSTR aRegRoot, int aLanguageId, toncut::ITonCut* aTonCut, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE Finalize(toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE Configure(HWND aWindow, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE About(HWND aWindow, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE LoadConfig(BSTR aKey, BSTR aVersion, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE SaveConfig(BSTR aKey, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE BackupConfig(BSTR* aBackup, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE RestoreConfig(BSTR aBackup, toncut::TConfigurationParts aScope, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE EnumExtensions(toncut::TTcpExtensionType aType, toncut::ITcEnumExtensionsCallback* aEnumCb, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE IsMyFile(BSTR aFileName, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE LoadFile(HWND aWindow, BSTR aFileName, IUnknown* aDevices, toncut::IMaterials* aMaterials, IUnknown* aBands, toncut::IProjects* aProjects, toncut::IFormats* aFormats, toncut::ISheets* aSheets, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE SaveFile(HWND aWindow, BSTR aFileName, toncut::IFormats* aFormats, toncut::ISheets* aSheets, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE SaveResult(HWND aWindow, BSTR aFileName, toncut::ISolutionSheet* aSolutionSheet, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE BatchSaveResult(HWND aWindow, toncut::TTcpSaveTarget aSaveTarget, BSTR aPath, toncut::ISolution* aSolution, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE Plot(HWND aWindow, toncut::ISolutionSheet* aSolutionSheet, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE BatchPlot(HWND aWindow, toncut::ISolution* aSolution, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE SavePlot(HWND aWindow, BSTR aFileName, toncut::ISolutionSheet* aSolutionSheet, toncut::TTcpResult* result) override;
  HRESULT STDMETHODCALLTYPE BatchSavePlot(HWND aWindow, toncut::TTcpSaveTarget aSaveTarget, BSTR aPath, toncut::ISolution* aSolution, toncut::TTcpResult* result) override;
 private:
  std::atomic<ULONG> refCount_;
  std::wstring regRoot_;
  int languageId_;
  float uiScale_;
  toncut::ITonCut* tonCut_;
};

}  // namespace contract_probe
"""

    plugin_source = """#include "ContractProbePlugin.hpp"

namespace contract_probe {

namespace {
HRESULT PutBstr(const std::wstring& value, BSTR* result) {
  if (result == nullptr) return E_POINTER;
  *result = ::SysAllocStringLen(value.data(), static_cast<UINT>(value.size()));
  return *result == nullptr ? E_OUTOFMEMORY : S_OK;
}
}  // namespace

ContractProbePlugin::ContractProbePlugin() : refCount_(1), languageId_(0), uiScale_(1.0f), tonCut_(nullptr) {}
ContractProbePlugin::~ContractProbePlugin() { if (tonCut_ != nullptr) tonCut_->Release(); }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::QueryInterface(REFIID, void** object) { if (object == nullptr) return E_POINTER; *object = static_cast<toncut::ITcPlugin*>(this); AddRef(); return S_OK; }
ULONG STDMETHODCALLTYPE ContractProbePlugin::AddRef() { return ++refCount_; }
ULONG STDMETHODCALLTYPE ContractProbePlugin::Release() { const auto value = --refCount_; if (value == 0) delete this; return value; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetEngineVersion(int* result) { if (result == nullptr) return E_POINTER; *result = toncut::cEngineVersion; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetName(BSTR* result) { return PutBstr(L"ContractProbe", result); }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetVersion(toncut::TTcpVersion* result) { if (result == nullptr) return E_POINTER; *result = toncut::MakeTcpVersion(1, 0, 0, 0); return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetTitle(BSTR* result) { return PutBstr(L"Contract Probe", result); }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetProfessional(toncut::DelphiBool* result) { if (result == nullptr) return E_POINTER; *result = 0; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetRegRoot(BSTR* result) { return PutBstr(regRoot_, result); }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetLanguageId(int* result) { if (result == nullptr) return E_POINTER; *result = languageId_; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::SetLanguageId(int value) { languageId_ = value; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetUiScale(float* result) { if (result == nullptr) return E_POINTER; *result = uiScale_; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::SetUiScale(float value) { uiScale_ = value; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetTonCut(toncut::ITonCut** result) { if (result == nullptr) return E_POINTER; *result = tonCut_; if (*result != nullptr) (*result)->AddRef(); return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetFeatures(toncut::TTcpFeatures* result) { if (result == nullptr) return E_POINTER; *result = toncut::FeatureMask(toncut::feImport) | toncut::FeatureMask(toncut::feExport) | toncut::FeatureMask(toncut::feSaveResultToFile); return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::GetPlotterInfo(toncut::ITcPlotterInfo** result) { if (result == nullptr) return E_POINTER; *result = nullptr; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::Initialize(BSTR aRegRoot, int aLanguageId, toncut::ITonCut* aTonCut, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; regRoot_ = toncut::FromBstr(aRegRoot); languageId_ = aLanguageId; if (tonCut_ != nullptr) tonCut_->Release(); tonCut_ = aTonCut; if (tonCut_ != nullptr) tonCut_->AddRef(); TouchAllSupportedInterfaces(tonCut_); *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::Finalize(toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::Configure(HWND, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::About(HWND, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::LoadConfig(BSTR, BSTR, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::SaveConfig(BSTR, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::BackupConfig(BSTR* aBackup, toncut::TTcpResult* result) { if (result == nullptr || aBackup == nullptr) return E_POINTER; *result = toncut::cprOK; return PutBstr(L"contract-probe-backup", aBackup); }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::RestoreConfig(BSTR, toncut::TConfigurationParts, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::EnumExtensions(toncut::TTcpExtensionType aType, toncut::ITcEnumExtensionsCallback* aEnumCb, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; if (aEnumCb != nullptr) { BSTR ext = ::SysAllocString(L".probe"); BSTR title = ::SysAllocString(L"Contract Probe"); aEnumCb->Invoke(aType, ext, title); ::SysFreeString(ext); ::SysFreeString(title); } *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::IsMyFile(BSTR, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprMaybe; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::LoadFile(HWND, BSTR, IUnknown*, toncut::IMaterials*, IUnknown*, toncut::IProjects*, toncut::IFormats*, toncut::ISheets*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::SaveFile(HWND, BSTR, toncut::IFormats*, toncut::ISheets*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::SaveResult(HWND, BSTR, toncut::ISolutionSheet*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::BatchSaveResult(HWND, toncut::TTcpSaveTarget, BSTR, toncut::ISolution*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::Plot(HWND, toncut::ISolutionSheet*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::BatchPlot(HWND, toncut::ISolution*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::SavePlot(HWND, BSTR, toncut::ISolutionSheet*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }
HRESULT STDMETHODCALLTYPE ContractProbePlugin::BatchSavePlot(HWND, toncut::TTcpSaveTarget, BSTR, toncut::ISolution*, toncut::TTcpResult* result) { if (result == nullptr) return E_POINTER; *result = toncut::cprOK; return S_OK; }

}  // namespace contract_probe
"""

    entry_point = """#include "ContractProbePlugin.hpp"

extern "C" __declspec(dllexport) void __stdcall TcpInitializeV2(
  toncut::ITcPlugin** aResult,
  const wchar_t* aRegRoot,
  int aLanguageId,
  toncut::ITonCut* aTonCut
) {
  if (aResult == nullptr) return;
  auto* plugin = new contract_probe::ContractProbePlugin();
  toncut::TTcpResult initResult = toncut::cprOK;
  plugin->Initialize(::SysAllocString(aRegRoot == nullptr ? L"" : aRegRoot), aLanguageId, aTonCut, &initResult);
  *aResult = plugin;
}
"""

    return {
        "touchHeader": touch_header,
        "touchSource": touch_source,
        "pluginHeader": plugin_header,
        "pluginSource": plugin_source,
        "entryPoint": entry_point,
    }


def generate_vs_project(guid: str, project_name: str, project_dir: Path) -> str:
    include_dir = to_windows_path(relative_to_sdk_path(project_dir, "include", "cpp"))
    header_path = to_windows_path(
        relative_to_sdk_path(project_dir, "include", "cpp", "TonCutPluginSdk.hpp")
    )
    return f"""<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup Label="ProjectConfigurations">
    <ProjectConfiguration Include="Debug|Win32"><Configuration>Debug</Configuration><Platform>Win32</Platform></ProjectConfiguration>
    <ProjectConfiguration Include="Release|Win32"><Configuration>Release</Configuration><Platform>Win32</Platform></ProjectConfiguration>
  </ItemGroup>
  <PropertyGroup Label="Globals"><VCProjectVersion>16.0</VCProjectVersion><ProjectGuid>{guid}</ProjectGuid><Keyword>Win32Proj</Keyword><ProjectName>{project_name}</ProjectName><WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion></PropertyGroup>
  <Import Project="$(VCTargetsPath)\\Microsoft.Cpp.Default.props" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration"><ConfigurationType>DynamicLibrary</ConfigurationType><UseDebugLibraries>true</UseDebugLibraries><PlatformToolset>v142</PlatformToolset><CharacterSet>Unicode</CharacterSet></PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Configuration"><ConfigurationType>DynamicLibrary</ConfigurationType><UseDebugLibraries>false</UseDebugLibraries><PlatformToolset>v142</PlatformToolset><WholeProgramOptimization>true</WholeProgramOptimization><CharacterSet>Unicode</CharacterSet></PropertyGroup>
  <Import Project="$(VCTargetsPath)\\Microsoft.Cpp.props" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'"><OutDir>$(ProjectDir)bin\\$(Configuration)\\</OutDir><IntDir>$(ProjectDir)obj\\$(Configuration)\\</IntDir><TargetName>{project_name}</TargetName><TargetExt>.plg</TargetExt></PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'"><OutDir>$(ProjectDir)bin\\$(Configuration)\\</OutDir><IntDir>$(ProjectDir)obj\\$(Configuration)\\</IntDir><TargetName>{project_name}</TargetName><TargetExt>.plg</TargetExt></PropertyGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'"><ClCompile><WarningLevel>Level4</WarningLevel><SDLCheck>true</SDLCheck><LanguageStandard>stdcpp17</LanguageStandard><ConformanceMode>true</ConformanceMode><StructMemberAlignment>8Bytes</StructMemberAlignment><AdditionalIncludeDirectories>$(ProjectDir);{include_dir};%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories><PreprocessorDefinitions>WIN32;_WINDOWS;UNICODE;_UNICODE;%(PreprocessorDefinitions)</PreprocessorDefinitions></ClCompile><Link><SubSystem>Windows</SubSystem><ModuleDefinitionFile>ContractProbe.def</ModuleDefinitionFile><AdditionalDependencies>OleAut32.lib;%(AdditionalDependencies)</AdditionalDependencies></Link></ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'"><ClCompile><WarningLevel>Level4</WarningLevel><FunctionLevelLinking>true</FunctionLevelLinking><IntrinsicFunctions>true</IntrinsicFunctions><SDLCheck>true</SDLCheck><LanguageStandard>stdcpp17</LanguageStandard><ConformanceMode>true</ConformanceMode><StructMemberAlignment>8Bytes</StructMemberAlignment><AdditionalIncludeDirectories>$(ProjectDir);{include_dir};%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories><PreprocessorDefinitions>WIN32;_WINDOWS;UNICODE;_UNICODE;NDEBUG;%(PreprocessorDefinitions)</PreprocessorDefinitions></ClCompile><Link><SubSystem>Windows</SubSystem><EnableCOMDATFolding>true</EnableCOMDATFolding><OptimizeReferences>true</OptimizeReferences><ModuleDefinitionFile>ContractProbe.def</ModuleDefinitionFile><AdditionalDependencies>OleAut32.lib;%(AdditionalDependencies)</AdditionalDependencies></Link></ItemDefinitionGroup>
  <ItemGroup><ClCompile Include="ContractProbeEntryPoint.cpp" /><ClCompile Include="ContractProbePlugin.cpp" /><ClCompile Include="ContractProbeTouch.cpp" /></ItemGroup>
  <ItemGroup><ClInclude Include="ContractProbePlugin.hpp" /><ClInclude Include="ContractProbeTouch.hpp" /><ClInclude Include="{header_path}" /></ItemGroup>
  <ItemGroup><None Include="ContractProbe.def" /></ItemGroup>
  <Import Project="$(VCTargetsPath)\\Microsoft.Cpp.targets" />
</Project>
"""


def generate_msvc_solution(project_guid: str, project_name: str, project_file_name: str) -> str:
    return f"""Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 16
VisualStudioVersion = 16.0.33529.622
MinimumVisualStudioVersion = 10.0.40219.1
Project("{{BC8A1FFA-BEE3-4634-8014-F334798102B3}}") = "{project_name}", "{project_file_name}", "{project_guid}"
EndProject
Global
\tGlobalSection(SolutionConfigurationPlatforms) = preSolution
\t\tDebug|Win32 = Debug|Win32
\t\tRelease|Win32 = Release|Win32
\tEndGlobalSection
\tGlobalSection(ProjectConfigurationPlatforms) = postSolution
\t\t{project_guid}.Debug|Win32.ActiveCfg = Debug|Win32
\t\t{project_guid}.Debug|Win32.Build.0 = Debug|Win32
\t\t{project_guid}.Release|Win32.ActiveCfg = Release|Win32
\t\t{project_guid}.Release|Win32.Build.0 = Release|Win32
\tEndGlobalSection
\tGlobalSection(SolutionProperties) = preSolution
\t\tHideSolutionNode = FALSE
\tEndGlobalSection
EndGlobal
"""


def generate_csharp_solution(native_guid: str, managed_guid: str) -> str:
    return f"""Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 16
VisualStudioVersion = 16.0.33529.622
MinimumVisualStudioVersion = 10.0.40219.1
Project("{{9A19103F-16F7-4668-BE54-9A1E7A4F7556}}") = "ManagedCoreProbe", "..\\csharp-managed\\ManagedCoreProbe.csproj", "{managed_guid}"
EndProject
Project("{{BC8A1FFA-BEE3-4634-8014-F334798102B3}}") = "ContractProbe.Native", "ContractProbe.vcxproj", "{native_guid}"
\tProjectSection(ProjectDependencies) = postProject
\t\t{managed_guid} = {managed_guid}
\tEndProjectSection
EndProject
Global
\tGlobalSection(SolutionConfigurationPlatforms) = preSolution
\t\tDebug|Win32 = Debug|Win32
\t\tRelease|Win32 = Release|Win32
\tEndGlobalSection
\tGlobalSection(ProjectConfigurationPlatforms) = postSolution
\t\t{managed_guid}.Debug|Win32.ActiveCfg = Debug|x86
\t\t{managed_guid}.Debug|Win32.Build.0 = Debug|x86
\t\t{managed_guid}.Release|Win32.ActiveCfg = Release|x86
\t\t{managed_guid}.Release|Win32.Build.0 = Release|x86
\t\t{native_guid}.Debug|Win32.ActiveCfg = Debug|Win32
\t\t{native_guid}.Debug|Win32.Build.0 = Debug|Win32
\t\t{native_guid}.Release|Win32.ActiveCfg = Release|Win32
\t\t{native_guid}.Release|Win32.Build.0 = Release|Win32
\tEndGlobalSection
\tGlobalSection(SolutionProperties) = preSolution
\t\tHideSolutionNode = FALSE
\tEndGlobalSection
EndGlobal
"""


def generate_cppbuilder_group_project(project_file_name: str) -> str:
    return f"""<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup>
    <Projects Include="{project_file_name}" />
  </ItemGroup>
  <Target Name="Build">
    <MSBuild Projects="@(Projects)" Targets="Build" Properties="Config=$(Config);Platform=$(Platform)" />
  </Target>
  <Target Name="Make">
    <MSBuild Projects="@(Projects)" Targets="Make" Properties="Config=$(Config);Platform=$(Platform)" />
  </Target>
  <Target Name="Clean">
    <MSBuild Projects="@(Projects)" Targets="Clean" Properties="Config=$(Config);Platform=$(Platform)" />
  </Target>
</Project>
"""


def generate_delphi_project(
    project_name: str,
    main_source: str,
    references: list[str],
    *,
    project_file_path: Path,
    console_app: bool = False,
    unit_search_path: str | None = None,
) -> str:
    template_path = (
        SDK_ROOT
        / "examples"
        / "delphi"
        / "CsvImportExport"
        / "CsvImportExport.dproj"
    )
    search_path = to_windows_path(
        unit_search_path
        or relative_to_sdk_path(project_file_path.parent, "include", "pascal")
    )
    content = read_text(template_path)
    if "DefaultTargets=" not in content.partition(">")[0]:
        content = content.replace(
            "<Project xmlns=",
            '<Project DefaultTargets="Build" xmlns=',
            1,
        )
    content = content.replace(
        "{DBFA437D-5732-41BB-9585-E640505F6E29}", hash_guid(f"delphi-{project_name}")
    )
    content = content.replace("CsvImportExport", project_name)
    content = re.sub(
        r"<MainSource>[^<]+</MainSource>",
        lambda _: f"<MainSource>{main_source}</MainSource>",
        content,
        count=1,
    )
    content = re.sub(
        r'<Source Name="MainSource">[^<]+</Source>',
        lambda _: f'<Source Name="MainSource">{main_source}</Source>',
        content,
        count=1,
    )
    content = re.sub(
        r'<DCCReference Include="[^"]+"\/>\s*<DCCReference Include="[^"]+"\/>',
        lambda _: "\n        ".join(
            f'<DCCReference Include="{reference}"/>' for reference in references
        ),
        content,
        count=1,
    )
    content = re.sub(
        r"<DCC_UnitSearchPath>[^<]+</DCC_UnitSearchPath>",
        lambda _: f"<DCC_UnitSearchPath>{search_path};$(DCC_UnitSearchPath)</DCC_UnitSearchPath>",
        content,
        count=1,
    )

    if console_app:
        content = content.replace(
            "<AppType>Library</AppType>", "<AppType>Application</AppType>", 1
        )
        content = content.replace(
            "<GenDll>true</GenDll>",
            "<GenDll>false</GenDll>\n        <DCC_ConsoleTarget>true</DCC_ConsoleTarget>",
            1,
        )
        content = content.replace(
            "<OutputExt>plg</OutputExt>", "<OutputExt>exe</OutputExt>"
        )

    return content


def generate_cppbuilder_project(guid: str, project_dir: Path) -> str:
    include_dir = to_windows_path(relative_to_sdk_path(project_dir, "include", "cpp"))
    return f"""<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <ProjectGuid>{guid}</ProjectGuid>
    <MainSource>ContractProbeEntryPoint.cpp</MainSource>
    <ProjectVersion>23.0</ProjectVersion>
    <FrameworkType>None</FrameworkType>
    <Config Condition="'$(Config)'==''">Release</Config>
    <Platform Condition="'$(Platform)'==''">Win32</Platform>
    <AppType>Library</AppType>
    <TargetName>ContractProbe</TargetName>
    <TargetExt>.plg</TargetExt>
    <Base>true</Base>
    <IncludePath>$(MSBuildProjectDirectory);{include_dir};$(IncludePath)</IncludePath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Config)'=='Debug'"><CfgType>Debug</CfgType><FinalOutputDir>.\\bin\\$(Platform)\\$(Config)</FinalOutputDir><IntermediateOutputDir>.\\obj\\$(Platform)\\$(Config)</IntermediateOutputDir></PropertyGroup>
  <PropertyGroup Condition="'$(Config)'=='Release'"><CfgType>Release</CfgType><FinalOutputDir>.\\bin\\$(Platform)\\$(Config)</FinalOutputDir><IntermediateOutputDir>.\\obj\\$(Platform)\\$(Config)</IntermediateOutputDir></PropertyGroup>
  <ItemGroup><CppCompile Include="ContractProbeEntryPoint.cpp" /><CppCompile Include="ContractProbePlugin.cpp" /><CppCompile Include="ContractProbeTouch.cpp" /></ItemGroup>
  <ItemGroup><None Include="ContractProbePlugin.hpp" /><None Include="ContractProbeTouch.hpp" /><None Include="ContractProbe.def" /></ItemGroup>
  <Import Project="$(BDS)\\Bin\\CodeGear.Cpp.Targets" Condition="Exists('$(BDS)\\Bin\\CodeGear.Cpp.Targets')" />
  <Import Project="$(BDS)\\Bin\\Borland.Cpp.Targets" Condition="Exists('$(BDS)\\Bin\\Borland.Cpp.Targets')" />
</Project>
"""


def generate_managed_probe() -> dict[str, str]:
    managed_dir = PROBES_ROOT / "csharp-managed"
    project_reference = to_windows_path(
        relative_to_sdk_path(
            managed_dir,
            "examples",
            "csharp",
            "managed-core",
            "TonCutCsv.Managed.csproj",
        )
    )
    csproj = f"""<?xml version="1.0" encoding="utf-8"?>
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net48</TargetFramework>
    <Platforms>x86</Platforms>
    <PlatformTarget>x86</PlatformTarget>
    <LangVersion>latest</LangVersion>
    <Nullable>enable</Nullable>
    <AssemblyName>ManagedCoreProbe</AssemblyName>
    <RootNamespace>ManagedCoreProbe</RootNamespace>
    <AppendTargetFrameworkToOutputPath>false</AppendTargetFrameworkToOutputPath>
    <OutputPath>bin\\$(Configuration)\\</OutputPath>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include="{project_reference}" />
  </ItemGroup>
</Project>
"""
    program = """using System;
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
"""
    return {"csproj": csproj, "program": program}


def generate_harness() -> str:
    return """program ContractHostHarness;

{$APPTYPE CONSOLE}
{$A8}

uses
  System.SysUtils,
  Winapi.Windows,
  uICommon,
  uITcPluginCommon,
  uITcEnumExtensionsCallback,
  uITonCut,
  uITcPlugin;

type
  TTcPluginInitialize = function(const aRegRoot: PChar; aLanguageId: Integer; aTonCut: ITonCut): ITcPlugin; stdcall;

  TEnumExtensionsCollector = class(TInterfacedObject, ITcEnumExtensionsCallback)
  public
    procedure Invoke(aType: TTcpExtensionType; const aExtension: WideString; const aName: WideString); safecall;
  end;

var
  LibraryHandle: THandle;
  InitFn: TTcPluginInitialize;
  Plugin: ITcPlugin;
  Backup: WideString;
  EnumCollector: ITcEnumExtensionsCallback;
  SampleCsvPath: String;
  OutputDir: String;
  HadFailure: Boolean;

procedure TEnumExtensionsCollector.Invoke(aType: TTcpExtensionType; const aExtension: WideString; const aName: WideString);
begin
  Writeln('EnumExtension[', Ord(aType), ']: ', String(aExtension), ' => ', String(aName));
end;

function ResultAllowed(aResult: TTcpResult; const aAllowed: array of TTcpResult): Boolean;
var
  allowed: TTcpResult;
begin
  for allowed in aAllowed do
    if aResult = allowed then
      Exit(True);
  Result := False;
end;

procedure PrintResult(const aName: String; aResult: TTcpResult; const aAllowed: array of TTcpResult);
begin
  Writeln(aName, ': ', Ord(aResult));
  if not ResultAllowed(aResult, aAllowed) then
  begin
    HadFailure := True;
    Writeln('Unexpected result for ', aName);
  end;
end;

procedure PrintException(const aName: String; const E: Exception);
begin
  HadFailure := True;
  Writeln(aName, ' exception: ', E.Message);
end;

procedure RunPluginSmoke(const aPlugin: ITcPlugin; const aSampleCsvPath, aOutputDir: String);
var
  exportCsv: String;
  exportPlt: String;
begin
  Writeln('--- Plugin Smoke Start ---');
  Writeln('EngineVersion: ', aPlugin.EngineVersion);
  Writeln('Name: ', String(aPlugin.Name));
  Writeln('Title: ', String(aPlugin.Title));
  Writeln('LanguageId: ', aPlugin.LanguageId);
  Writeln('Professional: ', BoolToStr(aPlugin.Professional, True));
  Writeln('UiScale: ', aPlugin.UiScale:0:2);
  Writeln('RegRoot: ', String(aPlugin.RegRoot));
  Writeln('Features mask enum count check only');

  PrintResult('LoadConfig', aPlugin.LoadConfig('Software\\TonCut\\ContractHarness', 'manual'), [cprOK]);
  PrintResult('SaveConfig', aPlugin.SaveConfig('Software\\TonCut\\ContractHarness'), [cprOK]);
  Backup := '';
  PrintResult('BackupConfig', aPlugin.BackupConfig(Backup), [cprOK]);
  Writeln('BackupConfig value length: ', Length(Backup));
  PrintResult('RestoreConfig', aPlugin.RestoreConfig(Backup, []), [cprOK]);
  PrintResult('Configure', aPlugin.Configure(0), [cprOK, cprNotImplemented]);
  PrintResult('About', aPlugin.About(0), [cprOK]);

  EnumCollector := TEnumExtensionsCollector.Create;
  PrintResult('EnumExtensions.Import', aPlugin.EnumExtensions(etImport, EnumCollector), [cprOK]);
  PrintResult('EnumExtensions.Export', aPlugin.EnumExtensions(etExport, EnumCollector), [cprOK]);
  PrintResult('EnumExtensions.ExportResults', aPlugin.EnumExtensions(etExportResults, EnumCollector), [cprOK]);

  if aSampleCsvPath <> '' then
  begin
    Writeln('Sample CSV: ', aSampleCsvPath);
    PrintResult('IsMyFile', aPlugin.IsMyFile(aSampleCsvPath), [cprOK, cprMaybe, cprNo]);
    try
      PrintResult('LoadFile', aPlugin.LoadFile(0, aSampleCsvPath, nil, nil, nil, nil, nil, nil), [cprOK]);
    except
      on E: Exception do
        PrintException('LoadFile', E);
    end;
  end;

  if aOutputDir <> '' then
  begin
    ForceDirectories(aOutputDir);
    Writeln('OutputDir: ', aOutputDir);
    exportCsv := IncludeTrailingPathDelimiter(aOutputDir) + 'manual-export.csv';
    exportPlt := IncludeTrailingPathDelimiter(aOutputDir) + 'manual-result.plt';
    try
      PrintResult('SaveFile', aPlugin.SaveFile(0, exportCsv, nil, nil), [cprOK]);
    except
      on E: Exception do
        PrintException('SaveFile', E);
    end;
    try
      PrintResult('SaveResult', aPlugin.SaveResult(0, exportPlt, nil), [cprOK]);
    except
      on E: Exception do
        PrintException('SaveResult', E);
    end;
    try
      PrintResult('SavePlot', aPlugin.SavePlot(0, exportPlt, nil), [cprOK, cprNotImplemented]);
    except
      on E: Exception do
        PrintException('SavePlot', E);
    end;
  end;

  try
    PrintResult('BatchSaveResult.File', aPlugin.BatchSaveResult(0, stFile, aOutputDir, nil), [cprOK, cprNotImplemented]);
  except
    on E: Exception do
      PrintException('BatchSaveResult', E);
  end;
  try
    PrintResult('BatchPlot.File', aPlugin.BatchPlot(0, nil), [cprOK, cprNotImplemented]);
  except
    on E: Exception do
      PrintException('BatchPlot', E);
  end;
  try
    PrintResult('Plot', aPlugin.Plot(0, nil), [cprOK, cprNotImplemented]);
  except
    on E: Exception do
      PrintException('Plot', E);
  end;
  try
    PrintResult('BatchSavePlot.File', aPlugin.BatchSavePlot(0, stFile, aOutputDir, nil), [cprOK, cprNotImplemented]);
  except
      on E: Exception do
        PrintException('BatchSavePlot', E);
  end;
  Writeln('--- Plugin Smoke End ---');
end;

begin
  try
    HadFailure := False;
    if ParamCount = 0 then
    begin
      Writeln('Usage: ContractHostHarness <plugin-path> [sample-csv-path] [output-dir]');
      Halt(2);
    end;

    LibraryHandle := LoadLibrary(PChar(ParamStr(1)));
    if LibraryHandle = 0 then
      RaiseLastOSError;

    try
      @InitFn := GetProcAddress(LibraryHandle, 'TcpInitializeV2');
      if not Assigned(InitFn) then
        raise Exception.Create('TcpInitializeV2 not found.');

      Plugin := InitFn('Software\\TonCut\\ContractHarness', 1033, nil);
      if not Assigned(Plugin) then
        raise Exception.Create('Initialization returned nil.');

      Writeln('Loaded plugin: ', String(Plugin.Name));
      if ParamCount >= 2 then
        SampleCsvPath := ParamStr(2)
      else
        SampleCsvPath := '';
      if ParamCount >= 3 then
        OutputDir := ParamStr(3)
      else
        OutputDir := ExtractFilePath(ParamStr(1));
      RunPluginSmoke(Plugin, SampleCsvPath, OutputDir);
      PrintResult('Finalize', Plugin.Finalize, [cprOK]);
      if HadFailure then
        Halt(1);
      Halt(0);
    finally
      EnumCollector := nil;
      Plugin := nil;
      if LibraryHandle <> 0 then
        FreeLibrary(LibraryHandle);
      LibraryHandle := 0;
    end;
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, 'Harness exception: ', E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
"""


def render_summary(manifest: dict[str, Any], support: dict[str, Any]) -> str:
    lines = [
        "# Contract Summary",
        "",
        f"Generated: {manifest['generatedAt']}",
        "",
        f"- Pascal interfaces: {manifest['totals']['interfaceCount']}",
        f"- Pascal methods: {manifest['totals']['methodCount']}",
        f"- Pascal properties: {manifest['totals']['propertyCount']}",
        f"- C++ subset interfaces: {manifest['totals']['cppInterfaceCount']}",
        f"- C++ subset methods: {manifest['totals']['cppMethodCount']}",
        "",
    ]
    for lane in support["lanes"].values():
        lines.append(f"## {lane['displayName']}")
        lines.append("")
        lines.append(f"- Strategy: {lane['kind']}")
        lines.append(f"- Supported interfaces: {len(lane['supportedInterfaces'])}")
        lines.append(f"- Unsupported Pascal interfaces: {len(lane['unsupportedInterfaces'])}")
        if lane.get("managedCore"):
            lines.append(f"- Managed core checks: {len(lane['managedCore']['checks'])}")
        lines.append("")
    return "\n".join(lines) + "\n"


def build_runtime_manifest(skipped_lanes: set[str] | None = None) -> dict[str, Any]:
    skipped = normalize_lane_ids(skipped_lanes)
    sample_csv = to_posix_path(
        relative_to_tests_path("examples", "shared", "csv", "example.csv")
    )
    starter_delphi_project = to_windows_path(
        relative_to_tests_path(
            "examples", "delphi", "CsvImportExport", "CsvImportExport.dproj"
        )
    )
    starter_cppbuilder_project = to_windows_path(
        relative_to_tests_path(
            "examples", "cppbuilder", "CsvImportExport", "CsvImportExport.groupproj"
        )
    )
    starter_msvc_project = to_windows_path(
        relative_to_tests_path("examples", "msvc", "CsvImportExport", "CsvImportExport.sln")
    )
    starter_csharp_project = to_windows_path(
        relative_to_tests_path(
            "examples", "csharp", "CsvImportExport", "CsvImportExport.sln"
        )
    )

    artifacts = [
        {
            "id": "probe-delphi-debug",
            "category": "probe",
            "lane": "delphi",
            "label": "Delphi ContractProbe Debug plugin",
            "path": "generated/probes/delphi/Win32/Debug/ContractProbe.plg",
        },
        {
            "id": "probe-cppbuilder-debug",
            "category": "probe",
            "lane": "cppbuilder",
            "label": "C++Builder ContractProbe Debug plugin",
            "path": "generated/probes/cppbuilder/bin/Win32/Debug/ContractProbe.plg",
        },
        {
            "id": "probe-msvc-debug",
            "category": "probe",
            "lane": "msvc",
            "label": "MSVC ContractProbe Debug plugin",
            "path": "generated/probes/msvc/bin/Debug/ContractProbe.plg",
        },
        {
            "id": "probe-csharp-native-debug",
            "category": "probe",
            "lane": "csharp",
            "label": "C# native ContractProbe Debug plugin",
            "path": "generated/probes/csharp/bin/Debug/ContractProbe.plg",
        },
        {
            "id": "probe-csharp-managed-debug",
            "category": "managed-probe",
            "lane": "csharp",
            "label": "ManagedCoreProbe Debug executable",
            "path": "generated/probes/csharp-managed/bin/Debug/ManagedCoreProbe.exe",
        },
        {
            "id": "harness-delphi-debug",
            "category": "harness",
            "lane": "delphi",
            "label": "Delphi ContractHostHarness Debug executable",
            "path": "generated/harness/delphi/Win32/Debug/ContractHostHarness.exe",
        },
        {
            "id": "starter-delphi-debug",
            "category": "starter",
            "lane": "delphi",
            "label": "Delphi CsvImportExport Debug plugin",
            "path": to_posix_path(
                relative_to_tests_path(
                    "examples",
                    "delphi",
                    "CsvImportExport",
                    "Win32",
                    "Debug",
                    "CsvImportExportDelphi.plg",
                )
            ),
        },
        {
            "id": "starter-cppbuilder-debug",
            "category": "starter",
            "lane": "cppbuilder",
            "label": "C++Builder CsvImportExport Debug plugin",
            "path": to_posix_path(
                relative_to_tests_path(
                    "examples",
                    "cppbuilder",
                    "CsvImportExport",
                    "bin",
                    "Win32",
                    "Debug",
                    "CsvImportExportCppBuilder.plg",
                )
            ),
        },
        {
            "id": "starter-msvc-debug",
            "category": "starter",
            "lane": "msvc",
            "label": "MSVC CsvImportExport Debug plugin",
            "path": to_posix_path(
                relative_to_tests_path(
                    "examples", "msvc", "CsvImportExport", "bin", "Debug", "CsvImportExportMsvc.plg"
                )
            ),
        },
        {
            "id": "starter-csharp-native-debug",
            "category": "starter",
            "lane": "csharp",
            "label": "C# CsvImportExport Debug native plugin",
            "path": to_posix_path(
                relative_to_tests_path(
                    "examples", "csharp", "CsvImportExport", "bin", "Debug", "CsvImportExportCSharp.plg"
                )
            ),
        },
        {
            "id": "starter-csharp-managed-debug",
            "category": "starter-managed",
            "lane": "csharp",
            "label": "C# TonCutCsv.Managed Debug library",
            "path": to_posix_path(
                relative_to_tests_path(
                    "examples", "csharp", "CsvImportExport", "bin", "Debug", "TonCutCsv.Managed.dll"
                )
            ),
        },
    ]
    build_commands = [
        {
            "id": "build-probe-delphi",
            "lane": "delphi",
            "label": "Build Delphi ContractProbe",
            "command": "msbuild generated\\probes\\delphi\\ContractProbe.dproj /p:Config=Debug /p:Platform=Win32",
        },
        {
            "id": "build-harness-delphi",
            "lane": "delphi",
            "label": "Build Delphi ContractHostHarness",
            "command": "msbuild generated\\harness\\delphi\\ContractHostHarness.dproj /p:Config=Debug /p:Platform=Win32",
        },
        {
            "id": "build-probe-cppbuilder",
            "lane": "cppbuilder",
            "label": "Build C++Builder ContractProbe",
            "command": "msbuild generated\\probes\\cppbuilder\\ContractProbe.groupproj /p:Config=Debug /p:Platform=Win32",
        },
        {
            "id": "build-probe-msvc",
            "lane": "msvc",
            "label": "Build MSVC ContractProbe",
            "command": "msbuild generated\\probes\\msvc\\ContractProbe.sln /p:Configuration=Debug /p:Platform=Win32",
        },
        {
            "id": "build-probe-csharp",
            "lane": "csharp",
            "label": "Build C# ContractProbe solution",
            "command": "msbuild generated\\probes\\csharp\\ContractProbe.sln /restore /p:Configuration=Debug /p:Platform=Win32",
        },
        {
            "id": "build-starter-delphi",
            "lane": "delphi",
            "label": "Build Delphi starter example",
            "command": f"msbuild {starter_delphi_project} /p:Config=Debug /p:Platform=Win32",
        },
        {
            "id": "build-starter-cppbuilder",
            "lane": "cppbuilder",
            "label": "Build C++Builder starter example",
            "command": f"msbuild {starter_cppbuilder_project} /p:Config=Debug /p:Platform=Win32",
        },
        {
            "id": "build-starter-msvc",
            "lane": "msvc",
            "label": "Build MSVC starter example",
            "command": f"msbuild {starter_msvc_project} /p:Configuration=Debug /p:Platform=Win32",
        },
        {
            "id": "build-starter-csharp",
            "lane": "csharp",
            "label": "Build C# starter example",
            "command": f"msbuild {starter_csharp_project} /restore /p:Configuration=Debug /p:Platform=Win32",
        },
    ]

    return {
        "generatedAt": iso_timestamp(),
        "fixtures": {
            "sampleCsv": sample_csv,
            "manualOutputDir": "generated/runtime/manual-output",
            "expectedCsvExport": "generated/runtime/manual-output/manual-export.csv",
            "expectedPltExport": "generated/runtime/manual-output/manual-result.plt",
        },
        "artifacts": [item for item in artifacts if item["lane"] not in skipped],
        "buildCommands": [
            {
                "id": item["id"],
                "label": item["label"],
                "command": item["command"],
            }
            for item in build_commands
            if item["lane"] not in skipped
        ],
        "scripts": {
            "manualCheckScript": "generated/runtime/run_manual_checks.py",
            "manualResultsTemplate": "generated/runtime/manual-results.template.json",
            "manualResultsFile": "generated/runtime/manual-results.json",
            "manualGuide": "generated/runtime/manual-checklist.md",
            "artifactStatus": "generated/runtime/artifact-status.json",
            "manualRuntimeReport": "generated/runtime/manual-runtime-report.json",
            "manualLogsDir": "generated/runtime/logs",
        },
    }


def render_manual_guide(
    runtime_manifest: dict[str, Any], skipped_lanes: set[str] | None = None
) -> str:
    harness_command = next(
        (
            item["command"]
            for item in runtime_manifest["buildCommands"]
            if item["id"] == "build-harness-delphi"
        ),
        None,
    )
    skipped_summary = describe_lane_ids(skipped_lanes)
    lines = ["# Manual SDK Test Checklist"]
    if skipped_summary:
        lines.extend(["", f"Skipped lanes: {skipped_summary}."])
    lines.extend(["", "## Build", ""])
    for step in runtime_manifest["buildCommands"]:
        lines.append(f"- {step['label']}: `{step['command']}`")

    lines.extend(["", "## Runtime Smoke", ""])
    if harness_command:
        lines.append(f"- Build the Delphi harness: `{harness_command}`")
    lines.append(
        f"- Run the generated runner from the `SDK/tests` directory: `python {to_windows_path(runtime_manifest['scripts']['manualCheckScript'])}`"
    )
    lines.append(
        "- The generated runner is non-interactive: it executes the managed probe and the native ContractProbe plugins only."
    )
    lines.append(
        f"- Or invoke the harness manually per probe plugin: `generated\\harness\\delphi\\Win32\\Debug\\ContractHostHarness.exe <plugin.plg> {to_windows_path(runtime_manifest['fixtures']['sampleCsv'])} {to_windows_path(runtime_manifest['fixtures']['manualOutputDir'])}`"
    )
    lines.append(
        f"- Runtime report JSON: `{to_windows_path(runtime_manifest['scripts']['manualRuntimeReport'])}`"
    )
    lines.append(
        f"- Runtime logs directory: `{to_windows_path(runtime_manifest['scripts']['manualLogsDir'])}`"
    )
    lines.extend(["", "## Starter Behavior", ""])
    lines.append(
        "- Starter examples are built in the automated loop, but their import/export behavior still needs a richer TonCut host double than the current harness provides."
    )
    lines.append(
        f"- Sample CSV fixture: `{to_windows_path(runtime_manifest['fixtures']['sampleCsv'])}`"
    )
    lines.append(
        f"- Expected CSV export path: `{to_windows_path(runtime_manifest['fixtures']['expectedCsvExport'])}`"
    )
    lines.append(
        f"- Expected PLT export path: `{to_windows_path(runtime_manifest['fixtures']['expectedPltExport'])}`"
    )
    lines.extend(["", "## Record Results", ""])
    lines.append(
        f"- Copy `{to_windows_path(runtime_manifest['scripts']['manualResultsTemplate'])}` to `{to_windows_path(runtime_manifest['scripts']['manualResultsFile'])}` and set each status to `pass`, `fail`, `pending`, or `not-applicable`."
    )
    lines.append(
        "- Use `python tools/run_sdk_tests.py report` to review artifact status, runtime logs, and your saved results."
    )
    return "\n".join(lines) + "\n"


def build_manual_results_template() -> dict[str, Any]:
    return {
        "checkedAt": "",
        "notes": "",
        "starterExamples": {
            "csvImport": {"status": "pending", "notes": ""},
            "csvExportRoundTrip": {"status": "pending", "notes": ""},
            "pltSingleSheetExport": {"status": "pending", "notes": ""},
        },
        "runtimeSmoke": {
            "probePluginsLoaded": {"status": "pending", "notes": ""},
            "managedProbePassed": {"status": "pending", "notes": ""},
        },
    }


def generate_manual_check_script(runtime_manifest: dict[str, Any]) -> str:
    harness = next(
        item["path"]
        for item in runtime_manifest["artifacts"]
        if item["id"] == "harness-delphi-debug"
    )
    managed_probe = next(
        item["path"]
        for item in runtime_manifest["artifacts"]
        if item["id"] == "probe-csharp-managed-debug"
    )
    plugin_entries = [
        {
            "id": item["id"],
            "label": item["label"],
            "lane": item["lane"],
            "category": item["category"],
            "path": item["path"],
        }
        for item in runtime_manifest["artifacts"]
        if item["category"] == "probe"
    ]
    defaults = {
        "harnessPath": harness,
        "managedProbePath": managed_probe,
        "sampleCsvPath": runtime_manifest["fixtures"]["sampleCsv"],
        "outputDir": runtime_manifest["fixtures"]["manualOutputDir"],
        "reportPath": runtime_manifest["scripts"]["manualRuntimeReport"],
        "logDir": runtime_manifest["scripts"]["manualLogsDir"],
    }

    script = """from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

TESTS_ROOT = Path(__file__).resolve().parents[2]
PLUGIN_ENTRIES = json.loads(r'''__PLUGIN_ENTRIES__''')
DEFAULTS = json.loads(r'''__DEFAULTS__''')


def iso_timestamp() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")


def resolve_workspace_path(path_value: str) -> Path:
    candidate = Path(path_value)
    return candidate.resolve() if candidate.is_absolute() else (TESTS_ROOT / candidate).resolve()


def ensure_dir(dir_path: Path) -> None:
    dir_path.mkdir(parents=True, exist_ok=True)


def append_exception(log_path: Path, exc: Exception) -> None:
    ensure_dir(log_path.parent)
    message = f"{type(exc).__name__}: {exc}\\n"
    with log_path.open("a", encoding="utf-8") as stream:
        stream.write(message)
    sys.stderr.write(message)


def run_with_logging(command: list[str], log_path: Path) -> int:
    ensure_dir(log_path.parent)
    with log_path.open("w", encoding="utf-8", newline="") as stream:
        process = subprocess.Popen(
            command,
            cwd=TESTS_ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
        assert process.stdout is not None
        for line in process.stdout:
            sys.stdout.write(line)
            stream.write(line)
        process.stdout.close()
        return process.wait()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--harness-path", default=DEFAULTS["harnessPath"])
    parser.add_argument("--managed-probe-path", default=DEFAULTS["managedProbePath"])
    parser.add_argument("--sample-csv-path", default=DEFAULTS["sampleCsvPath"])
    parser.add_argument("--output-dir", default=DEFAULTS["outputDir"])
    parser.add_argument("--report-path", default=DEFAULTS["reportPath"])
    parser.add_argument("--log-dir", default=DEFAULTS["logDir"])
    args = parser.parse_args()

    harness_path = resolve_workspace_path(args.harness_path)
    managed_probe_path = resolve_workspace_path(args.managed_probe_path)
    sample_csv_path = resolve_workspace_path(args.sample_csv_path)
    output_dir = resolve_workspace_path(args.output_dir)
    report_path = resolve_workspace_path(args.report_path)
    log_dir = resolve_workspace_path(args.log_dir)
    ensure_dir(output_dir)
    ensure_dir(log_dir)
    ensure_dir(report_path.parent)

    report: dict[str, object] = {
        "checkedAt": iso_timestamp(),
        "testsRoot": str(TESTS_ROOT),
        "harnessPath": str(harness_path),
        "managedProbePath": str(managed_probe_path),
        "sampleCsvPath": str(sample_csv_path),
        "outputDir": str(output_dir),
        "logDir": str(log_dir),
        "harnessRuns": [],
        "managedProbe": None,
    }

    managed_log_path = log_dir / "managed-core-probe.log"
    if managed_probe_path.exists():
        try:
            exit_code = run_with_logging([str(managed_probe_path)], managed_log_path)
            report["managedProbe"] = {
                "path": str(managed_probe_path),
                "logPath": str(managed_log_path),
                "exitCode": exit_code,
                "status": "pass" if exit_code == 0 else "fail",
            }
        except Exception as exc:
            append_exception(managed_log_path, exc)
            report["managedProbe"] = {
                "path": str(managed_probe_path),
                "logPath": str(managed_log_path),
                "status": "execution-error",
                "error": str(exc),
            }
    else:
        report["managedProbe"] = {
            "path": str(managed_probe_path),
            "logPath": str(managed_log_path),
            "status": "missing",
        }

    harness_runs = report["harnessRuns"]
    assert isinstance(harness_runs, list)
    for plugin in PLUGIN_ENTRIES:
        plugin_path = resolve_workspace_path(plugin["path"])
        safe_id = re.sub(r"[^A-Za-z0-9._-]", "_", plugin["id"])
        log_path = log_dir / f"{safe_id}.log"
        entry = {
            "id": plugin["id"],
            "label": plugin["label"],
            "lane": plugin["lane"],
            "category": plugin["category"],
            "pluginPath": str(plugin_path),
            "logPath": str(log_path),
        }

        if not plugin_path.exists():
            entry["status"] = "missing-plugin"
            harness_runs.append(entry)
            continue

        if not harness_path.exists():
            entry["status"] = "missing-harness"
            harness_runs.append(entry)
            continue

        try:
            exit_code = run_with_logging(
                [str(harness_path), str(plugin_path), str(sample_csv_path), str(output_dir)],
                log_path,
            )
            entry["exitCode"] = exit_code
            entry["status"] = "pass" if exit_code == 0 else "fail"
        except Exception as exc:
            append_exception(log_path, exc)
            entry["status"] = "execution-error"
            entry["error"] = str(exc)
        harness_runs.append(entry)

    report_path.write_text(json.dumps(report, indent=2) + "\\n", encoding="utf-8")
    print(f"Manual runtime report: {report_path}")
    print(f"Runtime logs directory: {log_dir}")
    managed_probe = report.get("managedProbe")
    if not isinstance(managed_probe, dict) or managed_probe.get("status") != "pass":
        return 1
    for run in harness_runs:
        if run.get("status") != "pass":
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
"""
    script = script.replace("__PLUGIN_ENTRIES__", json.dumps(plugin_entries, indent=2))
    script = script.replace("__DEFAULTS__", json.dumps(defaults, indent=2))
    return script


def generate_artifacts(skipped_lanes: set[str] | None = None) -> dict[str, Any]:
    manifest = build_manifest(parse_pascal_units(), parse_cpp_header())
    support = build_support(manifest, load_config())
    runtime_manifest = build_runtime_manifest(skipped_lanes)

    ensure_dir(GENERATED_ROOT)
    ensure_dir(PROBES_ROOT)
    ensure_dir(HARNESS_ROOT)
    ensure_dir(REPORTS_ROOT)
    ensure_dir(RUNTIME_ROOT)

    write_json(GENERATED_ROOT / "contract-manifest.json", manifest)
    write_json(GENERATED_ROOT / "language-support.json", support)
    write_text(REPORTS_ROOT / "contract-summary.md", render_summary(manifest, support))
    write_json(RUNTIME_ROOT / "runtime-manifest.json", runtime_manifest)
    write_text(
        RUNTIME_ROOT / "manual-checklist.md",
        render_manual_guide(runtime_manifest, skipped_lanes),
    )
    write_json(
        RUNTIME_ROOT / "manual-results.template.json", build_manual_results_template()
    )
    write_text(
        RUNTIME_ROOT / "run_manual_checks.py",
        generate_manual_check_script(runtime_manifest),
    )
    for legacy_script in RUNTIME_ROOT.glob("*.ps1"):
        legacy_script.unlink()

    delphi = generate_delphi_probe(manifest, support["lanes"]["delphi"])
    delphi_dir = PROBES_ROOT / "delphi"
    ensure_dir(delphi_dir)
    write_text(delphi_dir / "ContractProbe.dpr", delphi["dpr"])
    write_text(
        delphi_dir / "ContractProbe.dproj",
        generate_delphi_project(
            "ContractProbe",
            "ContractProbe.dpr",
            ["uContractProbePlugin.pas", "uContractProbeTouch.pas"],
            project_file_path=delphi_dir / "ContractProbe.dproj",
        ),
    )
    write_text(delphi_dir / "uContractProbePlugin.pas", delphi["pluginUnit"])
    write_text(delphi_dir / "uContractProbeTouch.pas", delphi["touchUnit"])

    for lane_id in ["msvc", "cppbuilder", "csharp"]:
        cpp = generate_cpp_probe(manifest, support["lanes"][lane_id])
        lane_dir = PROBES_ROOT / lane_id
        ensure_dir(lane_dir)
        write_text(lane_dir / "ContractProbeTouch.hpp", cpp["touchHeader"])
        write_text(lane_dir / "ContractProbeTouch.cpp", cpp["touchSource"])
        write_text(lane_dir / "ContractProbePlugin.hpp", cpp["pluginHeader"])
        write_text(lane_dir / "ContractProbePlugin.cpp", cpp["pluginSource"])
        write_text(lane_dir / "ContractProbeEntryPoint.cpp", cpp["entryPoint"])
        write_text(
            lane_dir / "ContractProbe.def",
            'LIBRARY "ContractProbe"\nEXPORTS\n  TcpInitializeV2\n',
        )
        if lane_id == "cppbuilder":
            write_text(
                lane_dir / "ContractProbe.cbproj",
                generate_cppbuilder_project(hash_guid(lane_id), lane_dir),
            )
            write_text(
                lane_dir / "ContractProbe.groupproj",
                generate_cppbuilder_group_project("ContractProbe.cbproj"),
            )
        else:
            project_guid = hash_guid(lane_id)
            write_text(
                lane_dir / "ContractProbe.vcxproj",
                generate_vs_project(project_guid, "ContractProbe", lane_dir),
            )
            if lane_id == "msvc":
                write_text(
                    lane_dir / "ContractProbe.sln",
                    generate_msvc_solution(
                        project_guid, "ContractProbe", "ContractProbe.vcxproj"
                    ),
                )

    managed = generate_managed_probe()
    managed_dir = PROBES_ROOT / "csharp-managed"
    ensure_dir(managed_dir)
    write_text(managed_dir / "ManagedCoreProbe.csproj", managed["csproj"])
    write_text(managed_dir / "Program.cs", managed["program"])
    write_text(
        PROBES_ROOT / "csharp" / "ContractProbe.sln",
        generate_csharp_solution(hash_guid("csharp"), hash_guid("csharp-managed")),
    )

    harness_dir = HARNESS_ROOT / "delphi"
    ensure_dir(harness_dir)
    write_text(harness_dir / "ContractHostHarness.dpr", generate_harness())
    write_text(
        harness_dir / "ContractHostHarness.dproj",
        generate_delphi_project(
            "ContractHostHarness",
            "ContractHostHarness.dpr",
            [],
            project_file_path=harness_dir / "ContractHostHarness.dproj",
            console_app=True,
        ),
    )

    expectations = {
        "generatedAt": manifest["generatedAt"],
        "lanes": {
            lane_id: {
                "supportedInterfaces": [
                    item["name"] for item in lane["supportedInterfaces"]
                ],
                "expectedMethodCount": sum(
                    item["methodCount"] for item in lane["supportedInterfaces"]
                ),
                "expectedPropertyCount": sum(
                    item["propertyCount"] for item in lane["supportedInterfaces"]
                ),
            }
            for lane_id, lane in support["lanes"].items()
        },
    }
    write_json(RUNTIME_ROOT / "expectations.json", expectations)

    return {
        "manifest": manifest,
        "support": support,
        "expectations": expectations,
        "runtimeManifest": runtime_manifest,
    }


def build_commands(skipped_lanes: set[str] | None = None) -> list[dict[str, str]]:
    return [
        {"id": item["id"], "label": item["label"], "command": item["command"]}
        for item in build_runtime_manifest(skipped_lanes)["buildCommands"]
    ]
