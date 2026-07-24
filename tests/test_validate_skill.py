from __future__ import annotations

import importlib.util
import os
import tempfile
import unittest
from pathlib import Path


VALIDATOR_PATH = Path(__file__).resolve().parents[1] / "scripts" / "validate_skill.py"
SPEC = importlib.util.spec_from_file_location("validate_skill", VALIDATOR_PATH)
assert SPEC is not None and SPEC.loader is not None
validate_skill = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(validate_skill)


VALID_FRONTMATTER = """\
---
name: ce-luna-engineering
description: Run accountable engineering work safely.
---

# Skill
"""

VALID_OPENAI_METADATA = """\
interface:
  display_name: "CE + Sol/Luna Engineering"
  short_description: "Run accountable CE + Sol/Luna engineering"
  default_prompt: "Use $ce-luna-engineering for this engineering task."
"""


class QuotedStringTests(unittest.TestCase):
    def test_accepts_valid_json_string_tokens(self) -> None:
        cases = (
            ('"plain"', "plain"),
            ('"café"', "café"),
            (r'"escaped quote: \"ok\""', 'escaped quote: "ok"'),
            (r'"tab\tvalue"', "tab\tvalue"),
            (r'"snowman: \u2603"', "snowman: \u2603"),
        )
        for raw_value, expected in cases:
            with self.subTest(raw_value=raw_value):
                self.assertEqual(
                    validate_skill.parse_quoted_string(raw_value), expected
                )

    def test_rejects_invalid_or_non_string_tokens(self) -> None:
        cases = (
            ("empty", '""'),
            ("single quoted", "'value'"),
            ("adjacent literal", '"one" "two"'),
            ("trailing token", '"value" token'),
            ("trailing comment", '"value" # comment'),
            ("list", '["value"]'),
            ("map", '{"key": "value"}'),
            ("malformed escape", r'"bad\q"'),
        )
        for category, raw_value in cases:
            with self.subTest(category=category):
                self.assertIsNone(
                    validate_skill.parse_quoted_string(raw_value)
                )

    def test_rejects_every_python_line_boundary_after_decoding(self) -> None:
        expected_boundaries = frozenset(
            {
                "\n",
                "\r",
                "\v",
                "\f",
                "\x1c",
                "\x1d",
                "\x1e",
                "\x85",
                "\u2028",
                "\u2029",
            }
        )
        self.assertEqual(
            validate_skill.LINE_BOUNDARY_CHARACTERS, expected_boundaries
        )
        cases = (
            ("LF", r'"before\nthen"'),
            ("CR", r'"before\rthen"'),
            ("VT", r'"before\u000bthen"'),
            ("FF", r'"before\u000cthen"'),
            ("file separator", r'"before\u001cthen"'),
            ("group separator", r'"before\u001dthen"'),
            ("record separator", r'"before\u001ethen"'),
            ("NEL", r'"before\u0085then"'),
            ("line separator", r'"before\u2028then"'),
            ("paragraph separator", r'"before\u2029then"'),
        )
        for category, raw_value in cases:
            with self.subTest(category=category):
                self.assertIsNone(
                    validate_skill.parse_quoted_string(raw_value)
                )


class SkillFrontmatterTests(unittest.TestCase):
    def test_accepts_valid_frontmatter(self) -> None:
        failures: list[str] = []
        fields = validate_skill.parse_skill_frontmatter(
            VALID_FRONTMATTER, failures
        )
        self.assertEqual(
            fields,
            {
                "name": "ce-luna-engineering",
                "description": "Run accountable engineering work safely.",
            },
        )
        self.assertEqual(failures, [])

    def test_rejects_collection_values(self) -> None:
        for value in ("[ce-luna-engineering]", "{value: unsafe}"):
            with self.subTest(value=value):
                text = VALID_FRONTMATTER.replace(
                    "ce-luna-engineering", value, 1
                )
                failures: list[str] = []
                fields = validate_skill.parse_skill_frontmatter(text, failures)
                self.assertIsNone(fields)
                self.assertTrue(
                    any("string scalar" in failure for failure in failures)
                )

    def test_rejects_adjacent_and_single_quoted_literals(self) -> None:
        for value in (
            '"ce-luna" "engineering"',
            "'ce-luna-engineering'",
        ):
            with self.subTest(value=value):
                text = VALID_FRONTMATTER.replace(
                    "ce-luna-engineering", value, 1
                )
                failures: list[str] = []
                fields = validate_skill.parse_skill_frontmatter(text, failures)
                self.assertIsNone(fields)
                self.assertTrue(
                    any("string scalar" in failure for failure in failures)
                )

    def test_rejects_duplicate_field(self) -> None:
        text = VALID_FRONTMATTER.replace(
            "description:", "name: duplicate\ndescription:"
        )
        failures: list[str] = []
        fields = validate_skill.parse_skill_frontmatter(text, failures)
        self.assertIsNone(fields)
        self.assertTrue(any("duplicates 'name'" in failure for failure in failures))

    def test_rejects_unexpected_field(self) -> None:
        text = VALID_FRONTMATTER.replace(
            "description:", "version: one\ndescription:"
        )
        failures: list[str] = []
        fields = validate_skill.parse_skill_frontmatter(text, failures)
        self.assertIsNone(fields)
        self.assertTrue(
            any("unexpected field 'version'" in failure for failure in failures)
        )

    def test_rejects_malformed_or_indented_field(self) -> None:
        for original, replacement, diagnostic in (
            (
                "name: ce-luna-engineering",
                " name: ce-luna-engineering",
                "must be unindented",
            ),
            (
                "name: ce-luna-engineering",
                "name ce-luna-engineering",
                "must be a 'key: string' field",
            ),
        ):
            with self.subTest(replacement=replacement):
                text = VALID_FRONTMATTER.replace(original, replacement)
                failures: list[str] = []
                fields = validate_skill.parse_skill_frontmatter(text, failures)
                self.assertIsNone(fields)
                self.assertTrue(
                    any(diagnostic in failure for failure in failures)
                )


class OpenAIMetadataTests(unittest.TestCase):
    def test_accepts_valid_metadata(self) -> None:
        failures: list[str] = []
        fields = validate_skill.parse_openai_metadata(
            VALID_OPENAI_METADATA, failures
        )
        self.assertEqual(
            fields,
            {
                "display_name": "CE + Sol/Luna Engineering",
                "short_description": "Run accountable CE + Sol/Luna engineering",
                "default_prompt": (
                    "Use $ce-luna-engineering for this engineering task."
                ),
            },
        )
        self.assertEqual(failures, [])

    def test_rejects_nested_and_misindented_fields(self) -> None:
        text = """\
interface:
  labels:
    display_name: "CE + Sol/Luna Engineering"
  short_description: "Run accountable CE + Sol/Luna engineering"
  default_prompt: "Use $ce-luna-engineering for this engineering task."
"""
        failures: list[str] = []
        fields = validate_skill.parse_openai_metadata(text, failures)
        self.assertIsNone(fields)
        self.assertTrue(any("unexpected field 'labels'" in item for item in failures))
        self.assertTrue(any("exactly two spaces" in item for item in failures))
        self.assertTrue(
            any("missing required interface field 'display_name'" in item for item in failures)
        )

    def test_rejects_duplicate_field(self) -> None:
        text = VALID_OPENAI_METADATA.replace(
            '  display_name: "CE + Sol/Luna Engineering"\n',
            '  display_name: "CE + Sol/Luna Engineering"\n'
            '  display_name: "Duplicate"\n',
        )
        failures: list[str] = []
        fields = validate_skill.parse_openai_metadata(text, failures)
        self.assertIsNone(fields)
        self.assertTrue(
            any("duplicates 'display_name'" in failure for failure in failures)
        )

    def test_rejects_unquoted_and_collection_values(self) -> None:
        original = '  display_name: "CE + Sol/Luna Engineering"'
        for replacement in (
            "  display_name: CE + Sol/Luna Engineering",
            '  display_name: ["CE + Sol/Luna Engineering"]',
        ):
            with self.subTest(replacement=replacement):
                text = VALID_OPENAI_METADATA.replace(original, replacement)
                failures: list[str] = []
                fields = validate_skill.parse_openai_metadata(text, failures)
                self.assertIsNone(fields)
                self.assertTrue(
                    any("quoted string" in failure for failure in failures)
                )

    def test_rejects_adjacent_and_single_quoted_literals(self) -> None:
        original = '  display_name: "CE + Sol/Luna Engineering"'
        for replacement in (
            '  display_name: "CE + Sol" "/Luna Engineering"',
            "  display_name: 'CE + Sol/Luna Engineering'",
        ):
            with self.subTest(replacement=replacement):
                text = VALID_OPENAI_METADATA.replace(original, replacement)
                failures: list[str] = []
                fields = validate_skill.parse_openai_metadata(text, failures)
                self.assertIsNone(fields)
                self.assertTrue(
                    any("quoted string" in failure for failure in failures)
                )


class PackageManifestTests(unittest.TestCase):
    def create_valid_package(self, root: Path) -> Path:
        package = root / "ce-luna-engineering"
        (package / "agents").mkdir(parents=True)
        (package / "references").mkdir()
        for relative_file in validate_skill.ALLOWED_PACKAGE_FILES:
            path = package / relative_file
            path.write_text("valid\n", encoding="utf-8")
        return package

    def test_accepts_exact_manifest(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            package = self.create_valid_package(Path(temporary_directory))
            failures: list[str] = []
            safe_files = validate_skill.validate_package_manifest(
                package, failures
            )
            self.assertEqual(
                safe_files, set(validate_skill.ALLOWED_PACKAGE_FILES)
            )
            self.assertEqual(failures, [])

    def test_rejects_unexpected_package_file(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            package = self.create_valid_package(Path(temporary_directory))
            (package / "private.txt").write_text("secret\n", encoding="utf-8")
            failures: list[str] = []
            validate_skill.validate_package_manifest(package, failures)
            self.assertTrue(
                any(
                    "unexpected package file: private.txt" in failure
                    for failure in failures
                )
            )

    def test_rejects_missing_required_package_file(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            package = self.create_valid_package(Path(temporary_directory))
            missing_file = Path("references/LICENSE")
            (package / missing_file).unlink()
            failures: list[str] = []
            validate_skill.validate_package_manifest(package, failures)
            self.assertTrue(
                any(
                    f"missing required package file: {missing_file}" in failure
                    for failure in failures
                )
            )

    def test_rejects_unexpected_package_directory(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            package = self.create_valid_package(Path(temporary_directory))
            (package / "private").mkdir()
            failures: list[str] = []
            validate_skill.validate_package_manifest(package, failures)
            self.assertTrue(
                any(
                    "unexpected package directory: private" in failure
                    for failure in failures
                )
            )

    def test_rejects_non_regular_entry_when_supported(self) -> None:
        if not hasattr(os, "mkfifo"):
            self.skipTest("FIFO creation is unavailable")
        with tempfile.TemporaryDirectory() as temporary_directory:
            package = self.create_valid_package(Path(temporary_directory))
            fifo = package / "SKILL.md"
            fifo.unlink()
            try:
                os.mkfifo(fifo)
            except OSError:
                self.skipTest("FIFO creation is unavailable")
            failures: list[str] = []
            validate_skill.validate_package_manifest(package, failures)
            self.assertTrue(
                any(
                    "package entry is not a regular file: SKILL.md" in failure
                    for failure in failures
                )
            )

    def test_scans_every_allowed_file_for_placeholders(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            package = self.create_valid_package(Path(temporary_directory))
            safe_files = set(validate_skill.ALLOWED_PACKAGE_FILES)
            for target_file in safe_files:
                with self.subTest(target_file=target_file):
                    texts = {
                        package / relative_file: (
                            "TODO\n" if relative_file == target_file else "complete\n"
                        )
                        for relative_file in safe_files
                    }
                    failures: list[str] = []
                    validate_skill.validate_placeholders(
                        package, safe_files, texts, failures
                    )
                    self.assertEqual(len(failures), 1)
                    self.assertTrue(
                        failures[0].startswith(
                            f"{target_file.as_posix()}:1 contains placeholder"
                        )
                    )

    def test_rejects_symlink_when_supported(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            package = self.create_valid_package(root)
            target = root / "target.txt"
            target.write_text("target\n", encoding="utf-8")
            link = package / "link.txt"
            try:
                os.symlink(target, link)
            except (NotImplementedError, OSError):
                self.skipTest("symlink creation is unavailable")
            failures: list[str] = []
            validate_skill.validate_package_manifest(package, failures)
            self.assertTrue(
                any("must not be a symlink: link.txt" in item for item in failures)
            )


if __name__ == "__main__":
    unittest.main()
