import sys
import unittest
import importlib.util
import re
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch


sys.path.insert(0, str(Path(__file__).resolve().parent))

from sdk_test_lib import (  # noqa: E402
    GENERATED_ROOT,
    build_manifest,
    build_support,
    contract_generation_fingerprint,
    fingerprint_input_bytes,
    diff_cpp_interface_against_pascal,
    generate_artifacts,
    load_config,
    parse_cpp_header,
    parse_cpp_enums,
    parse_pascal_enum_ordinals,
    parse_pascal_units,
    validate_cpp_data_types,
    validate_cpp_projections,
)
from run_sdk_tests import (  # noqa: E402
    cmd_build,
    ensure_build_target,
    manual_runtime_report_compatibility_error,
    missing_command_tools,
    prepare_command,
)


EXAMPLES_BUILD_PATH = Path(__file__).resolve().parents[2] / "examples" / "build_examples.py"
EXAMPLES_BUILD_SPEC = importlib.util.spec_from_file_location(
    "sdk_build_examples", EXAMPLES_BUILD_PATH
)
assert EXAMPLES_BUILD_SPEC is not None and EXAMPLES_BUILD_SPEC.loader is not None
sdk_build_examples = importlib.util.module_from_spec(EXAMPLES_BUILD_SPEC)
EXAMPLES_BUILD_SPEC.loader.exec_module(sdk_build_examples)


def make_interface(name: str, method_names: list[str]) -> dict:
    return {
        "name": name,
        "file": "test-contract",
        "methods": [
            {"name": method_name, "parameters": [], "returnType": None}
            for method_name in method_names
        ],
        "properties": [],
    }


class CppProjectionValidationTests(unittest.TestCase):
    def test_public_narrative_keeps_algorithm_payloads_and_internals_opaque(
        self,
    ) -> None:
        sdk_root = Path(__file__).resolve().parents[2]
        public_narrative_files = [
            sdk_root / "README.md",
            *sorted((sdk_root / "manuals").rglob("*.md")),
            *sorted((sdk_root / "examples").rglob("*.md")),
            *sorted((sdk_root / "examples").rglob("*.pas")),
            *sorted((sdk_root / "examples").rglob("*.cpp")),
            *sorted((sdk_root / "examples").rglob("*.hpp")),
            *sorted((sdk_root / "examples").rglob("*.cs")),
            *sorted((sdk_root / "tests" / "generated" / "reports").rglob("*.md")),
        ]
        algorithm_data_mentions: list[str] = []
        internals_mentions: list[str] = []
        for path in public_narrative_files:
            text = path.read_text(encoding="utf-8")
            relative_path = path.relative_to(sdk_root).as_posix()
            if re.search(r"(?i)ITcAlgorithmData|algorithm[- ]data", text):
                algorithm_data_mentions.append(relative_path)
            if re.search(r"(?i)\binternals\b", text):
                internals_mentions.append(relative_path)

        policy_path = "manuals/public-contract-units.md"
        self.assertEqual(algorithm_data_mentions, [policy_path])
        self.assertEqual(internals_mentions, [policy_path])

        policy_text = (sdk_root / policy_path).read_text(encoding="utf-8")
        self.assertIn(
            "This SDK documents only its public interface signatures: it does not\n"
            "publish or prescribe any algorithm-specific payload, schema, member paths,\n"
            "keys, values, defaults, or examples, and it does not publish an internals\n"
            "configuration tree.",
            policy_text,
        )

    def test_contract_fingerprint_ignores_crlf_checkout_line_endings(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as directory:
            lf_path = Path(directory) / "lf.pas"
            crlf_path = Path(directory) / "crlf.pas"
            lf_path.write_bytes(b"unit uX;\ninterface\nend.\n")
            crlf_path.write_bytes(b"unit uX;\r\ninterface\r\nend.\r\n")
            self.assertEqual(
                fingerprint_input_bytes(lf_path), fingerprint_input_bytes(crlf_path)
            )
            # Any other byte difference still changes the hashed input.
            crlf_path.write_bytes(b"unit uY;\r\ninterface\r\nend.\r\n")
            self.assertNotEqual(
                fingerprint_input_bytes(lf_path), fingerprint_input_bytes(crlf_path)
            )
        self.assertRegex(contract_generation_fingerprint(), r"^[0-9a-f]{64}$")

    def test_contract_generation_is_byte_idempotent(self) -> None:
        generate_artifacts()
        first = {
            path.relative_to(GENERATED_ROOT).as_posix(): path.read_bytes()
            for path in GENERATED_ROOT.rglob("*")
            if path.is_file()
        }
        generate_artifacts()
        second = {
            path.relative_to(GENERATED_ROOT).as_posix(): path.read_bytes()
            for path in GENERATED_ROOT.rglob("*")
            if path.is_file()
        }
        self.assertEqual(second, first)

    def test_build_driver_forces_fresh_rebuilds(self) -> None:
        self.assertEqual(
            ensure_build_target("msbuild ContractProbe.sln"),
            "msbuild ContractProbe.sln /t:Rebuild",
        )
        self.assertEqual(
            ensure_build_target("msbuild ContractProbe.sln /t:Custom"),
            "msbuild ContractProbe.sln /t:Custom",
        )
        with patch("run_sdk_tests.resolve_command", side_effect=lambda command: command):
            self.assertEqual(
                prepare_command("msbuild ContractProbe.sln /p:Configuration=Release"),
                "msbuild ContractProbe.sln /p:Configuration=Release /t:Rebuild",
            )
        with patch.object(
            sdk_build_examples,
            "resolve_command",
            side_effect=lambda command: command,
        ):
            self.assertEqual(
                sdk_build_examples.prepare_command(
                    "msbuild CsvImportExport.sln /p:Configuration=Release"
                ),
                "msbuild CsvImportExport.sln /p:Configuration=Release /t:Rebuild",
            )

    def test_lane_skip_does_not_rewrite_canonical_artifacts(self) -> None:
        generate_artifacts()
        before = {
            path.relative_to(GENERATED_ROOT).as_posix(): path.read_bytes()
            for path in GENERATED_ROOT.rglob("*")
            if path.is_file()
        }
        args = SimpleNamespace(dry_run=True, execute=False)
        with patch("builtins.print"):
            cmd_build(args, {"cppbuilder"})
        after = {
            path.relative_to(GENERATED_ROOT).as_posix(): path.read_bytes()
            for path in GENERATED_ROOT.rglob("*")
            if path.is_file()
        }
        self.assertEqual(after, before)

    def test_example_build_driver_rejects_non_win32_platforms(self) -> None:
        parser = sdk_build_examples.build_parser()
        platform_action = next(
            action for action in parser._actions if action.dest == "platform"
        )
        self.assertEqual(platform_action.choices, ["Win32"])

    def test_build_drivers_detect_missing_cppbuilder_compiler(self) -> None:
        commands = [{"command": "msbuild ContractProbe.groupproj"}]
        with (
            patch("run_sdk_tests.discover_rsvars_path", return_value="rsvars.bat"),
            patch("run_sdk_tests.discover_cppbuilder_rsvars_path", return_value=None),
        ):
            self.assertEqual(missing_command_tools(commands), ["bcc32.exe"])

        with (
            patch.object(
                sdk_build_examples,
                "discover_rsvars_path",
                return_value="rsvars.bat",
            ),
            patch.object(
                sdk_build_examples,
                "discover_cppbuilder_rsvars_path",
                return_value=None,
            ),
        ):
            self.assertEqual(
                sdk_build_examples.missing_command_tools(commands),
                ["bcc32.exe"],
            )

    def test_cpp_enums_sets_aliases_constants_and_packing_match_pascal(self) -> None:
        validate_cpp_data_types()
        self.assertEqual(
            parse_cpp_enums()["TTcpResult"]["ordinals"],
            parse_pascal_enum_ordinals()["TTcpResult"],
        )

    def test_generated_support_reports_unsupported_interfaces_and_members(self) -> None:
        manifest = build_manifest(parse_pascal_units(), parse_cpp_header())
        support = build_support(manifest, load_config())
        zero_method_cpp_interfaces = {
            item["name"]
            for item in manifest["cppInterfaces"]
            if not item["methods"]
        }

        for lane_name in ("cppbuilder", "msvc"):
            lane = support["lanes"][lane_name]
            self.assertTrue(
                all(item["methodCount"] > 0 for item in lane["supportedInterfaces"])
            )
            ownership_only_names = {
                item["name"] for item in lane["ownershipOnlyInterfaces"]
            }
            self.assertEqual(ownership_only_names, zero_method_cpp_interfaces)
            self.assertLessEqual(
                ownership_only_names,
                set(lane["unsupportedInterfaces"]),
            )
            self.assertEqual(
                ownership_only_names,
                set(lane["opaquePointerTypes"]),
            )

        msvc = support["lanes"]["msvc"]

        self.assertIn("ITcAlgorithmData", msvc["unsupportedInterfaces"])
        projected = {item["name"]: item for item in msvc["supportedInterfaces"]}
        for owner_name in ("IFormat", "IMaterial", "ISheet"):
            algorithm_data = next(
                item
                for item in projected[owner_name]["unsupportedProperties"]
                if item["name"] == "AlgorithmData"
            )
            self.assertEqual(
                algorithm_data["missingAccessors"],
                ["GetAlgorithmData"],
            )
            self.assertIn(
                "GetAlgorithmData",
                [item["name"] for item in projected[owner_name]["unsupportedMethods"]],
            )

        self.assertNotIn("ITcPlotterInfo", projected)
        self.assertEqual(len(msvc["supportedInterfaces"]), 15)
        self.assertEqual(len(msvc["ownershipOnlyInterfaces"]), 15)
        self.assertEqual(len(msvc["unsupportedInterfaces"]), 50)
        ownership_only = {
            item["name"] for item in msvc["ownershipOnlyInterfaces"]
        }
        self.assertIn("IDevices", ownership_only)
        self.assertIn("IDevices", msvc["unsupportedInterfaces"])
        plotter_info = next(
            item
            for item in msvc["ownershipOnlyInterfaces"]
            if item["name"] == "ITcPlotterInfo"
        )
        self.assertEqual(plotter_info["diff"]["projection"], "documented-opaque")
        self.assertEqual(len(plotter_info["unsupportedMethods"]), 53)
        self.assertIn("ITcPlotterInfo", msvc["unsupportedInterfaces"])
        self.assertEqual(set(msvc["opaquePointerTypes"]), ownership_only)

        csharp = support["lanes"]["csharp"]
        self.assertEqual(csharp["interfaceSupportSurface"], "native-shim-only")
        self.assertEqual(csharp["supportedInterfaces"], [])
        self.assertEqual(csharp["directManagedSupportedInterfaces"], [])
        self.assertEqual(
            len(csharp["nativeShimSupportedInterfaces"]),
            15,
        )
        self.assertEqual(len(csharp["nativeShimOwnershipOnlyInterfaces"]), 15)
        self.assertEqual(len(csharp["nativeShimUnsupportedInterfaces"]), 50)
        self.assertEqual(csharp["ownershipOnlyInterfaces"], [])
        self.assertTrue(
            all(
                item["methodCount"] > 0
                for item in csharp["nativeShimSupportedInterfaces"]
            )
        )
        csharp_ownership_only_names = {
            item["name"] for item in csharp["nativeShimOwnershipOnlyInterfaces"]
        }
        self.assertEqual(csharp_ownership_only_names, zero_method_cpp_interfaces)
        self.assertLessEqual(
            csharp_ownership_only_names,
            set(csharp["nativeShimUnsupportedInterfaces"]),
        )
        self.assertEqual(
            csharp_ownership_only_names,
            set(csharp["nativeShimOpaquePointerTypes"]),
        )

    def test_every_exact_cpp_interface_type_has_an_iunknown_prefix(self) -> None:
        cpp_interfaces = parse_cpp_header()
        defined_names = {item["name"] for item in cpp_interfaces}
        for interface in cpp_interfaces:
            for method in interface["methods"]:
                for parameter in method["parameters"]:
                    base_type = parameter["type"].removeprefix("const ").rstrip("*")
                    if base_type.startswith("I") and len(base_type) > 1:
                        self.assertIn(base_type, defined_names)

    def test_pascal_overload_directives_do_not_leak_into_return_types(self) -> None:
        interfaces = {item["name"]: item for item in parse_pascal_units()}

        format_index_overloads = interfaces["IFormats"]["methods"][8:12]
        self.assertEqual(
            [method["returnType"] for method in format_index_overloads],
            ["Integer"] * 4,
        )
        toncut_overloads = interfaces["ITonCut"]["methods"][20:26]
        self.assertEqual(
            [method["returnType"] for method in toncut_overloads],
            ["WideString"] * 6,
        )

    def test_multiline_pascal_parameter_separators_do_not_end_declarations(self) -> None:
        interfaces = {item["name"]: item for item in parse_pascal_units()}
        methods = {
            method["name"]: method
            for method in interfaces["ITcAlgorithmData"]["methods"]
        }

        get_state = methods["GetState"]
        self.assertEqual(
            [parameter["modifier"] for parameter in get_state["parameters"]],
            ["out", "out"],
        )
        self.assertEqual(
            [parameter["type"] for parameter in get_state["parameters"]],
            ["WideString", "TDefaultUnits"],
        )

        set_state = methods["SetState"]
        self.assertEqual(
            [parameter["modifier"] for parameter in set_state["parameters"]],
            ["const", "const"],
        )
        self.assertEqual(
            [parameter["type"] for parameter in set_state["parameters"]],
            ["WideString", "TDefaultUnits"],
        )

    def test_every_pascal_method_has_a_strict_parsed_identifier_and_types(self) -> None:
        for interface in parse_pascal_units():
            for method in interface["methods"]:
                self.assertRegex(method["name"], r"^[A-Za-z_][A-Za-z0-9_]*$")
                self.assertNotEqual(method.get("returnType"), "Variant")
                for parameter in method["parameters"]:
                    self.assertNotEqual(parameter["type"], "Variant")

    def test_native_initialize_retains_same_host_before_releasing_it(self) -> None:
        generate_artifacts()
        sdk_root = Path(__file__).resolve().parents[2]
        source_paths = [
            sdk_root / "examples" / "shared" / "cpp" / "CsvImportExportPluginBase.cpp",
            sdk_root
            / "tests"
            / "generated"
            / "probes"
            / "msvc"
            / "ContractProbePlugin.cpp",
        ]
        for source_path in source_paths:
            source = source_path.read_text(encoding="utf-8")
            initialize_start = source.index("::Initialize(")
            initialize = source[initialize_start : initialize_start + 1600]
            retain = initialize.index("aTonCut->AddRef()")
            release = initialize.index("tonCut_->Release()")
            assign = initialize.index("tonCut_ = aTonCut")
            self.assertLess(retain, release, source_path.name)
            self.assertLess(release, assign, source_path.name)

    def test_generated_probe_initialize_never_executes_compile_touch_code(self) -> None:
        generate_artifacts()
        sdk_root = Path(__file__).resolve().parents[2]
        native_root = sdk_root / "tests" / "generated" / "probes"
        for lane in ("cppbuilder", "msvc", "csharp"):
            plugin_source = (
                native_root / lane / "ContractProbePlugin.cpp"
            ).read_text(encoding="utf-8")
            initialize_start = plugin_source.index("::Initialize(")
            initialize_end = plugin_source.index("::Finalize(", initialize_start)
            self.assertNotIn(
                "TouchAllSupportedInterfaces",
                plugin_source[initialize_start:initialize_end],
                lane,
            )
            touch_source = (
                native_root / lane / "ContractProbeTouch.cpp"
            ).read_text(encoding="utf-8")
            self.assertIn("void TouchAllSupportedInterfaces(", touch_source, lane)
            module_definition = (
                native_root / lane / "ContractProbe.def"
            ).read_text(encoding="utf-8")
            self.assertIn('LIBRARY "ContractProbe.plg"', module_definition, lane)

        delphi_source = (
            native_root / "delphi" / "uContractProbePlugin.pas"
        ).read_text(encoding="utf-8")
        initialize_start = delphi_source.index("TContractProbePlugin.Initialize(")
        initialize_end = delphi_source.index(
            "TContractProbePlugin.Finalize(", initialize_start
        )
        self.assertNotIn(
            "TouchAllSupportedInterfaces",
            delphi_source[initialize_start:initialize_end],
        )
        delphi_touch = (
            native_root / "delphi" / "uContractProbeTouch.pas"
        ).read_text(encoding="utf-8")
        self.assertIn("procedure TouchAllSupportedInterfaces(", delphi_touch)

    def test_generated_harness_leaves_protected_lifecycle_normally(self) -> None:
        generate_artifacts()
        harness = (
            Path(__file__).resolve().parents[2]
            / "tests"
            / "generated"
            / "harness"
            / "delphi"
            / "ContractHostHarness.dpr"
        ).read_text(encoding="utf-8")
        self.assertNotIn("Halt(", harness)
        self.assertIn("System.ExitCode := 0;", harness)
        self.assertIn("System.ExitCode := 2;", harness)
        self.assertIn("Harness exception: Unknown exception", harness)
        self.assertIn("procedure InitializePluginFromExport;", harness)
        initialize_scope = harness[
            harness.index("procedure InitializePluginFromExport;") : harness.index(
                "function ResultAllowed(",
                harness.index("procedure InitializePluginFromExport;"),
            )
        ]
        self.assertIn("InitializedPlugin := InitFn(", initialize_scope)
        self.assertIn("Plugin := InitializedPlugin;", initialize_scope)
        self.assertIn("InitializedPlugin := nil;", initialize_scope)
        main_start = harness.rindex("begin\n  System.ExitCode := 0;")
        self.assertNotIn("Plugin := InitFn(", harness[main_start:])
        finally_start = harness.index("finally")
        release_plugin = harness.index("Plugin := nil;", finally_start)
        free_library = harness.index("FreeLibrary(LibraryHandle);", release_plugin)
        self.assertLess(release_plugin, free_library)

    def test_native_backup_config_replaces_inout_bstr_without_leaking_it(self) -> None:
        generate_artifacts()
        sdk_root = Path(__file__).resolve().parents[2]
        source_paths = [
            sdk_root / "examples" / "shared" / "cpp" / "CsvImportExportPluginBase.cpp",
            sdk_root
            / "tests"
            / "generated"
            / "probes"
            / "msvc"
            / "ContractProbePlugin.cpp",
        ]
        for source_path in source_paths:
            source = source_path.read_text(encoding="utf-8")
            helper_start = source.index("HRESULT ReplaceBstr(")
            helper = source[helper_start : helper_start + 600]
            allocate = helper.index("BstrValue replacement(value)")
            oom = helper.index("if (!replacement)")
            preserve = helper.index("BSTR previous = *target")
            assign = helper.index("*target = replacement.release()")
            release = helper.index("SysFreeString(previous)")
            self.assertLess(allocate, oom, source_path.name)
            self.assertLess(oom, preserve, source_path.name)
            self.assertLess(preserve, assign, source_path.name)
            self.assertLess(assign, release, source_path.name)

            backup_start = source.index("::BackupConfig(")
            backup = source[backup_start : backup_start + 500]
            self.assertIn("ReplaceBstr(", backup, source_path.name)
            self.assertNotIn("PutBstr(", backup, source_path.name)
            self.assertIn("SUCCEEDED(hr)", backup, source_path.name)

        harness = (
            sdk_root
            / "tests"
            / "generated"
            / "harness"
            / "delphi"
            / "ContractHostHarness.dpr"
        ).read_text(encoding="utf-8")
        self.assertIn("Backup := 'caller-owned-preexisting-backup';", harness)
        self.assertEqual(harness.count("aPlugin.BackupConfig(Backup)"), 2)

    def test_native_save_result_propagates_set_is_saved_failure(self) -> None:
        source_path = (
            Path(__file__).resolve().parents[2]
            / "examples"
            / "shared"
            / "cpp"
            / "CsvImportExportPluginBase.cpp"
        )
        source = source_path.read_text(encoding="utf-8")
        save_result_start = source.index("::SaveResult(")
        save_result = source[save_result_start : save_result_start + 1800]
        call = save_result.index("const HRESULT hr = aSolutionSheet->SetIsSaved(1)")
        check = save_result.index("if (FAILED(hr))", call)
        failure_result = save_result.index("*result = cprException", check)
        failure_return = save_result.index("return hr", failure_result)
        success_result = save_result.index("*result = cprOK", failure_return)
        self.assertLess(call, check)
        self.assertLess(check, failure_result)
        self.assertLess(failure_result, failure_return)
        self.assertLess(failure_return, success_result)

    def test_native_unsigned_csv_parser_matches_delphi_cardinal_range(self) -> None:
        sdk_root = Path(__file__).resolve().parents[2]
        cpp_source = (
            sdk_root / "examples" / "shared" / "cpp" / "CsvCodec.cpp"
        ).read_text(encoding="utf-8")
        parser_start = cpp_source.index("bool TryParseUnsigned(")
        parser_end = cpp_source.index("bool ReadAll(", parser_start)
        parser = cpp_source[parser_start:parser_end]
        self.assertIn("result = 0;", parser)
        self.assertIn("trimmed.front() == L'-'", parser)
        self.assertIn("errno = 0;", parser)
        self.assertIn("end == trimmed.c_str()", parser)
        self.assertIn("errno == ERANGE", parser)
        self.assertIn("parsed > UINT_MAX", parser)

        delphi_source = (
            sdk_root
            / "examples"
            / "delphi"
            / "CsvImportExport"
            / "uCsvCommon.pas"
        ).read_text(encoding="utf-8")
        self.assertIn("TryStrToUInt64(Trim(AValue), parsed)", delphi_source)
        self.assertIn("parsed <= High(Cardinal)", delphi_source)

    def test_csv_millimeter_rounding_widens_before_adding_bias(self) -> None:
        sdk_root = Path(__file__).resolve().parents[2]
        cpp_source = (
            sdk_root
            / "examples"
            / "shared"
            / "cpp"
            / "CsvImportExportPluginBase.cpp"
        ).read_text(encoding="utf-8")
        cpp_start = cpp_source.index("unsigned ToCsvMillimeters(")
        cpp_end = cpp_source.index("void AppendMoveCommand(", cpp_start)
        self.assertIn(
            "static_cast<std::uint64_t>(value) + (cLengthMultiplier / 2u)",
            cpp_source[cpp_start:cpp_end],
        )

        delphi_source = (
            sdk_root
            / "examples"
            / "delphi"
            / "CsvImportExport"
            / "uCsvImportExportPlugin.pas"
        ).read_text(encoding="utf-8")
        delphi_start = delphi_source.index("function ToCsvMillimeters(")
        delphi_end = delphi_source.index(
            "function TCsvImportExportPlugin.FindMaterialByTitle(", delphi_start
        )
        self.assertIn(
            "UInt64(AValue) + UInt64(cLengthMultiplier div 2)",
            delphi_source[delphi_start:delphi_end],
        )
        self.assertEqual(((2**32 - 1) + 50) // 100, 42_949_673)

    def test_native_csv_io_rejects_truncation_and_conversion_failures(self) -> None:
        source = (
            Path(__file__).resolve().parents[2]
            / "examples"
            / "shared"
            / "cpp"
            / "CsvCodec.cpp"
        ).read_text(encoding="utf-8")
        self.assertIn("bool ReadAll(HANDLE file", source)
        self.assertIn("bool WriteAll(HANDLE file", source)
        self.assertIn("read == 0 || read > requested", source)
        self.assertIn("written == 0 || written > requested", source)
        self.assertIn("size.QuadPart < 0 || size.QuadPart > INT_MAX", source)
        self.assertIn("MB_ERR_INVALID_CHARS", source)
        self.assertIn("class ScopedHandle final", source)

        reader_start = source.index("bool ReadFileBytes(")
        reader_end = source.index("std::wstring EncodeField(", reader_start)
        reader = source[reader_start:reader_end]
        self.assertIn("const ScopedHandle file(::CreateFileW(", reader)
        self.assertIn("ReadAll(file.Get()", reader)
        self.assertNotIn("::CloseHandle(file)", reader)

        writer_start = source.index("bool WriteUtf8CsvFile(")
        writer = source[writer_start:]
        self.assertIn("if (!ToUtf8(content, utf8))", writer)
        self.assertIn("WriteAll(file, bom, sizeof(bom))", writer)
        self.assertIn("WriteAll(file, utf8.data(), utf8.size())", writer)
        self.assertIn("FlushFileBuffers(file)", writer)
        self.assertNotIn("static_cast<DWORD>(utf8.size())", writer)

        plugin_source = (
            Path(__file__).resolve().parents[2]
            / "examples"
            / "shared"
            / "cpp"
            / "CsvImportExportPluginBase.cpp"
        ).read_text(encoding="utf-8")
        ascii_start = plugin_source.index("bool WriteAsciiLines(")
        ascii_end = plugin_source.index("}  // namespace", ascii_start)
        ascii_writer = plugin_source[ascii_start:ascii_end]
        content = ascii_writer.index("std::string content;")
        create = ascii_writer.index("HANDLE handle = ::CreateFileW(")
        self.assertLess(content, create)

    def test_csv_header_validation_and_lookup_use_the_same_normalization(self) -> None:
        sdk_root = Path(__file__).resolve().parents[2]
        cpp_source = (
            sdk_root / "examples" / "shared" / "cpp" / "CsvCodec.cpp"
        ).read_text(encoding="utf-8")
        cell_start = cpp_source.index("std::wstring CellByName(")
        cell_end = cpp_source.index("}  // namespace", cell_start)
        self.assertIn("_wcsicmp(Trim(header[i]).c_str()", cpp_source[cell_start:cell_end])

        delphi_source = (
            sdk_root
            / "examples"
            / "delphi"
            / "CsvImportExport"
            / "uCsvCommon.pas"
        ).read_text(encoding="utf-8")
        cell_start = delphi_source.rindex("function CellByName(")
        cell_end = delphi_source.index("function TryParseCardinalField(", cell_start)
        self.assertIn("SameText(Trim(AHeader[i]), AName)", delphi_source[cell_start:cell_end])

        csharp_source = (
            sdk_root
            / "examples"
            / "csharp"
            / "managed-core"
            / "CsvCodec.cs"
        ).read_text(encoding="utf-8")
        self.assertIn("header[i].Trim()", csharp_source)

    def test_cross_language_import_rejects_null_material_and_unknown_rows(self) -> None:
        sdk_root = Path(__file__).resolve().parents[2]
        cpp_source = (
            sdk_root / "examples" / "shared" / "cpp" / "CsvImportExportPluginBase.cpp"
        ).read_text(encoding="utf-8")
        ensure_start = cpp_source.index("CsvImportExportPluginBase::EnsureMaterial(")
        ensure_end = cpp_source.index("CsvImportExportPluginBase::LoadFile(", ensure_start)
        self.assertIn(
            "return HRESULT_FROM_WIN32(ERROR_ALREADY_EXISTS);",
            cpp_source[ensure_start:ensure_end],
        )
        load_start = ensure_end
        load_end = cpp_source.index("CsvImportExportPluginBase::SaveFile(", load_start)
        self.assertEqual(
            cpp_source[load_start:load_end].count("if (FAILED(hr) || !material)"),
            2,
        )

        csharp_source = (
            sdk_root
            / "examples"
            / "csharp"
            / "managed-core"
            / "CsvCodec.cs"
        ).read_text(encoding="utf-8")
        self.assertIn("Unknown RecordType at row", csharp_source)
        self.assertIn("ParseOptionalPositiveUInt", csharp_source)
        self.assertIn("|| result == 0", csharp_source)

        generate_artifacts()
        managed_probe = (
            sdk_root
            / "tests"
            / "generated"
            / "probes"
            / "csharp-managed"
            / "Program.cs"
        ).read_text(encoding="utf-8")
        self.assertIn("Zero quantity", managed_probe)
        self.assertIn("Invalid quantity", managed_probe)
        self.assertIn("accepted an unknown RecordType", managed_probe)
        self.assertIn('spacedHeader + "\\r\\n" +', managed_probe)
        self.assertNotIn('spacedHeader + "\n\n" +', managed_probe)

    def test_generated_runtime_and_probe_lifecycle_are_bounded(self) -> None:
        generate_artifacts()
        sdk_root = Path(__file__).resolve().parents[2]
        runner = (
            sdk_root / "tests" / "generated" / "runtime" / "run_manual_checks.py"
        ).read_text(encoding="utf-8")
        self.assertIn('parser.add_argument("--skip-cppbuilder", action="store_true")', runner)
        self.assertIn('parser.add_argument(\n        "--timeout-seconds"', runner)
        self.assertIn("process.communicate(timeout=timeout_seconds)", runner)
        self.assertIn("except subprocess.TimeoutExpired", runner)
        self.assertIn("not math.isfinite(parsed)", runner)
        self.assertIn('"generationFingerprint": DEFAULTS["generationFingerprint"]', runner)

        delphi_probe = (
            sdk_root
            / "tests"
            / "generated"
            / "probes"
            / "delphi"
            / "uContractProbePlugin.pas"
        ).read_text(encoding="utf-8")
        self.assertIn(
            "function TContractProbePlugin.Finalize(): TTcpResult; begin FTonCut := nil;",
            delphi_probe,
        )
        for lane in ("cppbuilder", "msvc", "csharp"):
            cpp_probe = (
                sdk_root
                / "tests"
                / "generated"
                / "probes"
                / lane
                / "ContractProbePlugin.cpp"
            ).read_text(encoding="utf-8")
            finalize_start = cpp_probe.index("ContractProbePlugin::Finalize(")
            finalize_end = cpp_probe.index(
                "ContractProbePlugin::Configure(", finalize_start
            )
            self.assertIn("tonCut_->Release()", cpp_probe[finalize_start:finalize_end])
            self.assertIn("tonCut_ = nullptr", cpp_probe[finalize_start:finalize_end])

    def test_runtime_report_rejects_stale_or_mismatched_provenance(self) -> None:
        current = {
            "generationFingerprint": "current",
            "skippedLanes": ["cppbuilder"],
        }
        self.assertIsNone(
            manual_runtime_report_compatibility_error(
                current, "current", {"cppbuilder"}
            )
        )
        self.assertIn(
            "no generated-contract fingerprint",
            manual_runtime_report_compatibility_error({}, "current", set()) or "",
        )
        self.assertIn(
            "not current",
            manual_runtime_report_compatibility_error(
                {"generationFingerprint": "old", "skippedLanes": []},
                "current",
                set(),
            )
            or "",
        )
        self.assertIn(
            "this report expects none",
            manual_runtime_report_compatibility_error(current, "current", set()) or "",
        )

    def test_sheet_quantity_is_checked_before_signed_assignment(self) -> None:
        sdk_root = Path(__file__).resolve().parents[2]
        cpp_source = (
            sdk_root
            / "examples"
            / "shared"
            / "cpp"
            / "CsvImportExportPluginBase.cpp"
        ).read_text(encoding="utf-8")
        load_start = cpp_source.index("CsvImportExportPluginBase::LoadFile(")
        load_end = cpp_source.index("CsvImportExportPluginBase::SaveFile(", load_start)
        load = cpp_source[load_start:load_end]
        guard = load.index("record.quantity > static_cast<unsigned>((std::numeric_limits<int>::max)())")
        create_sheet = load.index("aSheets->CreateSheet(")
        self.assertLess(guard, create_sheet)

        delphi_source = (
            sdk_root
            / "examples"
            / "delphi"
            / "CsvImportExport"
            / "uCsvImportExportPlugin.pas"
        ).read_text(encoding="utf-8")
        guard = delphi_source.index(
            "(recordType = 'SHEET') and (quantity > Cardinal(MaxInt))"
        )
        create_sheet = delphi_source.index("sheet := aSheets.CreateSheet();", guard)
        self.assertLess(guard, create_sheet)
        self.assertEqual(2**31 - 1, 2_147_483_647)

    def test_delphi_update_scopes_unwind_each_started_collection(self) -> None:
        source = (
            Path(__file__).resolve().parents[2]
            / "examples"
            / "delphi"
            / "CsvImportExport"
            / "uCsvImportExportPlugin.pas"
        ).read_text(encoding="utf-8")
        self.assertIn(
            "aProjects.BeginUpdate();\n        try\n          aFormats.BeginUpdate();"
            "\n          try\n            aSheets.BeginUpdate();\n            try",
            source,
        )
        sheets_end = source.index("aSheets.EndUpdate();")
        formats_end = source.index("aFormats.EndUpdate();", sheets_end)
        projects_end = source.index("aProjects.EndUpdate();", formats_end)
        self.assertLess(sheets_end, formats_end)
        self.assertLess(formats_end, projects_end)

    def test_delphi_starter_preserves_validation_and_allocation_lifetimes(self) -> None:
        sdk_root = Path(__file__).resolve().parents[2]
        plugin_source = (
            sdk_root
            / "examples"
            / "delphi"
            / "CsvImportExport"
            / "uCsvImportExportPlugin.pas"
        ).read_text(encoding="utf-8")
        load_start = plugin_source.index("function TCsvImportExportPlugin.LoadFile(")
        load_end = plugin_source.index("function TCsvImportExportPlugin.SaveFile(", load_start)
        load = plugin_source[load_start:load_end]
        validate = load.index("headerResult := ValidateHeader(aFileName);")
        preserve = load.index("Exit(headerResult);", validate)
        parse = load.index("table := ParseCsvText(text);", preserve)
        revalidate = load.index("not HasRequiredHeader(table[0])", parse)
        project_create = load.index("projectCache := TDictionary<string, IProject>.Create;", revalidate)
        project_try = load.index("\n    try\n", project_create)
        material_create = load.index("materialCache := TDictionary<string, IMaterial>.Create;", project_try)
        material_try = load.index("\n      try\n", material_create)
        material_free = load.index("materialCache.Free;", material_try)
        project_free = load.index("projectCache.Free;", material_free)
        self.assertLess(validate, preserve)
        self.assertLess(parse, revalidate)
        self.assertLess(project_create, project_try)
        self.assertLess(project_try, material_create)
        self.assertLess(material_create, material_try)
        self.assertLess(material_try, material_free)
        self.assertLess(material_free, project_free)

        save_result_start = plugin_source.index(
            "function TCsvImportExportPlugin.SaveResult("
        )
        save_result_end = plugin_source.index(
            "function TCsvImportExportPlugin.BatchSaveResult(", save_result_start
        )
        save_result = plugin_source[save_result_start:save_result_end]
        self.assertNotIn("Exit(", save_result)
        self.assertIn("finally\n    commands.Free;", save_result)

        common_source = (
            sdk_root
            / "examples"
            / "delphi"
            / "CsvImportExport"
            / "uCsvCommon.pas"
        ).read_text(encoding="utf-8")
        parse_start = common_source.rindex("function ParseCsvText(")
        parse_end = common_source.index("function HasRequiredHeader(", parse_start)
        parse_scope = common_source[parse_start:parse_end]
        rows_create = parse_scope.index("rows := TList<TCsvRow>.Create;")
        rows_try = parse_scope.index("\n  try\n", rows_create)
        row_create = parse_scope.index("currentRow := TList<string>.Create;", rows_try)
        row_try = parse_scope.index("\n    try\n", row_create)
        row_free = parse_scope.index("currentRow.Free;", row_try)
        rows_free = parse_scope.index("rows.Free;", row_free)
        self.assertLess(rows_create, rows_try)
        self.assertLess(rows_try, row_create)
        self.assertLess(row_create, row_try)
        self.assertLess(row_try, row_free)
        self.assertLess(row_free, rows_free)

    def test_current_solution_sheet_is_an_exact_pascal_prefix(self) -> None:
        manifest = build_manifest(parse_pascal_units(), parse_cpp_header())
        config = load_config()

        validate_cpp_projections(manifest, config)

        pascal = next(
            item for item in manifest["interfaces"] if item["name"] == "ISolutionSheet"
        )
        cpp = next(
            item
            for item in manifest["cppInterfaces"]
            if item["name"] == "ISolutionSheet"
        )
        self.assertEqual(
            [method["name"] for method in cpp["methods"]],
            [method["name"] for method in pascal["methods"][:23]],
        )
        diff = diff_cpp_interface_against_pascal(
            cpp, pascal, config["cppProjection"]
        )
        self.assertTrue(diff["safe"])
        self.assertEqual(diff["projection"], "prefix")

    def test_solution_cut_is_a_complete_pascal_projection_with_shift_metadata(self) -> None:
        manifest = build_manifest(parse_pascal_units(), parse_cpp_header())
        config = load_config()

        validate_cpp_projections(manifest, config)

        pascal = next(
            item for item in manifest["interfaces"] if item["name"] == "ISolutionCut"
        )
        cpp = next(
            item
            for item in manifest["cppInterfaces"]
            if item["name"] == "ISolutionCut"
        )
        expected_method_names = [
            "GetKind",
            "GetPosX",
            "GetPosY",
            "GetTarX",
            "GetTarY",
            "GetPosXp",
            "GetPosYp",
            "GetTarXp",
            "GetTarYp",
            "GetNeedShift",
            "CalcLength",
            "GetShiftDistance",
        ]
        self.assertEqual(
            [method["name"] for method in pascal["methods"]],
            expected_method_names,
        )
        self.assertEqual(
            [method["name"] for method in cpp["methods"]],
            expected_method_names,
        )
        self.assertEqual(
            [
                [parameter["type"] for parameter in method["parameters"]]
                for method in cpp["methods"]
            ],
            [
                ["TCutKind*"],
                ["int*"],
                ["int*"],
                ["int*"],
                ["int*"],
                ["int*"],
                ["int*"],
                ["int*"],
                ["int*"],
                ["DelphiBool*"],
                ["double*"],
                ["int*"],
            ],
        )
        diff = diff_cpp_interface_against_pascal(
            cpp, pascal, config["cppProjection"]
        )
        self.assertTrue(diff["safe"])
        self.assertEqual(diff["projection"], "full")

    def test_solution_sheet_prefix_has_the_required_abi_types(self) -> None:
        cpp = next(
            item for item in parse_cpp_header() if item["name"] == "ISolutionSheet"
        )
        expected_parameter_types = [
            ["ISheet**"],
            ["ISolutionFormats**"],
            ["ISolutionWastes**"],
            ["ISolutionCuts**"],
            ["int*"],
            ["std::int64_t*"],
            ["std::int64_t*"],
            ["std::int64_t*"],
            ["int*"],
            ["int*"],
            ["TMirrors*"],
            ["DelphiBool*"],
            ["DelphiBool"],
            ["DelphiBool*"],
            ["DelphiBool"],
            ["int*", "TMirrors*"],
            ["int*", "int*"],
            ["int*", "int*"],
            ["int*", "int*"],
            ["double*", "double*"],
            ["double*", "double*"],
            ["int*", "int*"],
            ["unsigned*", "unsigned*", "unsigned*", "unsigned*", "unsigned*", "unsigned*"],
        ]

        self.assertEqual(
            [
                [parameter["type"] for parameter in method["parameters"]]
                for method in cpp["methods"]
            ],
            expected_parameter_types,
        )

    def test_set_and_open_array_translations_preserve_storage_and_hidden_bound(self) -> None:
        interfaces = {item["name"]: item for item in parse_cpp_header()}
        format_methods = {
            method["name"]: method for method in interfaces["IFormat"]["methods"]
        }
        formats_methods = {
            method["name"]: method for method in interfaces["IFormats"]["methods"]
        }

        self.assertEqual(
            [
                parameter["type"]
                for parameter in format_methods["GetOrnament"]["parameters"]
            ],
            ["TOrnaments*"],
        )
        self.assertEqual(
            [
                parameter["type"]
                for parameter in format_methods["SetOrnament"]["parameters"]
            ],
            ["TOrnaments"],
        )
        self.assertEqual(
            [
                parameter["type"]
                for parameter in formats_methods["IndexOfByList"]["parameters"][:3]
            ],
            ["std::int64_t*", "int", "IMaterial*"],
        )

    def test_missing_open_array_high_bound_is_rejected(self) -> None:
        pascal = {
            "name": "ITest",
            "methods": [
                {
                    "name": "Find",
                    "parameters": [
                        {"name": "values", "modifier": None, "type": "array of Int64"}
                    ],
                    "returnType": "Integer",
                }
            ],
            "properties": [],
        }
        cpp = {
            "name": "ITest",
            "methods": [
                {
                    "name": "Find",
                    "parameters": [
                        {"name": "values", "type": "std::int64_t*"},
                        {"name": "result", "type": "int*"},
                    ],
                    "returnType": "HRESULT",
                }
            ],
        }

        diff = diff_cpp_interface_against_pascal(cpp, pascal)

        self.assertFalse(diff["safe"])
        self.assertEqual(diff["projection"], "abi-mismatch")
        self.assertEqual(diff["methodDiffs"][0]["status"], "abi-parameter-count")

    def test_widestring_and_interface_result_indirection_are_enforced(self) -> None:
        pascal = {
            "name": "ITest",
            "methods": [
                {
                    "name": "Load",
                    "parameters": [
                        {"name": "name", "modifier": "const", "type": "WideString"}
                    ],
                    "returnType": "IResult",
                }
            ],
            "properties": [],
        }
        cpp = {
            "name": "ITest",
            "methods": [
                {
                    "name": "Load",
                    "parameters": [
                        {"name": "name", "type": "wchar_t*"},
                        {"name": "result", "type": "IResult*"},
                    ],
                    "returnType": "HRESULT",
                }
            ],
        }

        diff = diff_cpp_interface_against_pascal(cpp, pascal)

        self.assertFalse(diff["safe"])
        self.assertEqual(diff["projection"], "abi-mismatch")
        self.assertEqual(
            [item["status"] for item in diff["methodDiffs"]],
            ["abi-type-mismatch", "abi-type-mismatch"],
        )

    def test_prior_solution_sheet_selection_is_rejected(self) -> None:
        pascal = next(
            item for item in parse_pascal_units() if item["name"] == "ISolutionSheet"
        )
        previous_projection = make_interface(
            "ISolutionSheet",
            [
                "GetSolutionCuts",
                "SetIsSaved",
                "CalcPointF",
                "CalcEffectiveLayout",
            ],
        )

        diff = diff_cpp_interface_against_pascal(previous_projection, pascal)

        self.assertFalse(diff["safe"])
        self.assertEqual(diff["projection"], "non-prefix")
        self.assertEqual(
            [item["status"] for item in diff["methodDiffs"]],
            ["non-prefix-method"] * 4,
        )
        with self.assertRaisesRegex(ValueError, "ISolutionSheet"):
            validate_cpp_projections(
                {
                    "interfaces": [pascal],
                    "cppInterfaces": [previous_projection],
                },
                {},
            )

    def test_reordered_methods_are_rejected(self) -> None:
        pascal = make_interface("ITest", ["First", "Second", "Third"])
        reordered = make_interface("ITest", ["Second", "First"])

        diff = diff_cpp_interface_against_pascal(reordered, pascal)

        self.assertFalse(diff["safe"])
        with self.assertRaisesRegex(ValueError, "not a safe Pascal vtable prefix"):
            validate_cpp_projections(
                {"interfaces": [pascal], "cppInterfaces": [reordered]}, {}
            )

    def test_documented_overload_alias_preserves_prefix(self) -> None:
        pascal = make_interface("ITest", ["Find", "Find"])
        cpp = make_interface("ITest", ["FindById", "FindByTitle"])
        config = {
            "cppProjection": {
                "methodAliases": {
                    "ITest": {
                        "0": {"pascal": "Find", "cpp": "FindById"},
                        "1": {"pascal": "Find", "cpp": "FindByTitle"},
                    }
                }
            }
        }

        validate_cpp_projections(
            {"interfaces": [pascal], "cppInterfaces": [cpp]}, config
        )
        diff = diff_cpp_interface_against_pascal(
            cpp, pascal, config["cppProjection"]
        )
        self.assertTrue(diff["safe"])
        self.assertEqual(diff["projection"], "full")
        self.assertEqual(len(diff["acceptedAliases"]), 2)

    def test_zero_method_cpp_interfaces_require_documented_ownership_only_status(self) -> None:
        pascal = make_interface("ITest", ["First"])
        opaque = make_interface("ITest", [])
        manifest = {"interfaces": [pascal], "cppInterfaces": [opaque]}

        with self.assertRaisesRegex(ValueError, "undocumented-opaque"):
            validate_cpp_projections(manifest, {})

        with self.assertRaisesRegex(ValueError, "missing from ownership-only support"):
            validate_cpp_projections(
                manifest, {"cppProjection": {"opaqueInterfaces": ["ITest"]}}
            )

        validate_cpp_projections(
            manifest,
            {
                "cppProjection": {
                    "opaqueInterfaces": ["ITest"],
                    "ownershipOnlyInterfaces": ["ITest"],
                }
            },
        )


if __name__ == "__main__":
    unittest.main()
