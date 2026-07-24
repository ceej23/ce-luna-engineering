#!/usr/bin/env python3
"""Validate the bundled CE + Sol/Luna Codex skill."""

from __future__ import annotations

import json
import os
import re
import stat
import sys
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
SKILL_NAME = "ce-luna-engineering"
SKILL_DIRECTORY = REPOSITORY_ROOT / "skills" / SKILL_NAME
SKILL_FILE = SKILL_DIRECTORY / "SKILL.md"
OPENAI_FILE = SKILL_DIRECTORY / "agents" / "openai.yaml"
REFERENCE_FILE = SKILL_DIRECTORY / "references" / "operating-model.md"
BUNDLED_LICENSE_FILE = SKILL_DIRECTORY / "references" / "LICENSE"
README_FILE = REPOSITORY_ROOT / "README.md"
LICENSE_FILE = REPOSITORY_ROOT / "LICENSE"
CANONICAL_SEPARATOR = "<!-- BEGIN CANONICAL README -->"
ALLOWED_PACKAGE_FILES = frozenset(
    {
        Path("SKILL.md"),
        Path("agents/openai.yaml"),
        Path("references/operating-model.md"),
        Path("references/LICENSE"),
    }
)
ALLOWED_PACKAGE_DIRECTORIES = frozenset(
    {Path("."), Path("agents"), Path("references")}
)
PLACEHOLDER_PATTERN = re.compile(r"\b(?:TODO|TBD|FIXME|XXX)\b", re.IGNORECASE)
SKILL_NAME_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
FIELD_NAME_PATTERN = re.compile(r"^[a-z_][a-z0-9_]*$")
AMBIGUOUS_PLAIN_SCALAR_PATTERN = re.compile(
    r"^(?:null|true|false|yes|no|on|off|~|[-+]?(?:\d[\d_.]*|\.inf)|\.nan)$",
    re.IGNORECASE,
)
YAML_CONTROL_TOKEN_PATTERN = re.compile(r"(?:^|\s)[!&*][^\s]*")
LINE_BOUNDARY_CHARACTERS = frozenset(
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


def display_path(path: Path) -> str:
    """Return a stable repository-relative path for diagnostics."""
    try:
        return path.relative_to(REPOSITORY_ROOT).as_posix()
    except ValueError:
        return str(path)


def normalize_newlines(text: str) -> str:
    """Normalize platform line endings without changing other content."""
    return text.replace("\r\n", "\n").replace("\r", "\n")


def read_utf8(path: Path, failures: list[str]) -> str | None:
    """Read a regular file as strict UTF-8."""
    try:
        return normalize_newlines(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        failures.append(f"missing required file: {display_path(path)}")
    except UnicodeDecodeError as error:
        failures.append(
            f"{display_path(path)} is not valid UTF-8: byte {error.start}"
        )
    except OSError as error:
        failures.append(f"could not read {display_path(path)}: {error}")
    return None


def parse_quoted_string(raw_value: str) -> str | None:
    """Parse exactly one JSON-compatible, double-quoted string token."""
    if raw_value != raw_value.strip():
        return None
    if len(raw_value) < 2 or raw_value[0] != '"' or raw_value[-1] != '"':
        return None
    try:
        parsed = json.loads(raw_value)
    except (json.JSONDecodeError, UnicodeDecodeError):
        return None
    if not isinstance(parsed, str) or not parsed:
        return None
    if any(character in parsed for character in LINE_BOUNDARY_CHARACTERS):
        return None
    return parsed


def parse_frontmatter_string(raw_value: str) -> str | None:
    """Parse a non-empty string scalar from the SKILL frontmatter subset."""
    if not raw_value or raw_value != raw_value.strip():
        return None
    if raw_value[0] == '"':
        return parse_quoted_string(raw_value)
    if not raw_value[0].isalnum():
        return None
    if not re.search(r"[A-Za-z]", raw_value):
        return None
    if AMBIGUOUS_PLAIN_SCALAR_PATTERN.fullmatch(raw_value):
        return None
    if any(token in raw_value for token in ("[", "]", "{", "}", ": ", " #")):
        return None
    if YAML_CONTROL_TOKEN_PATTERN.search(raw_value):
        return None
    return raw_value


def parse_skill_frontmatter(
    text: str, failures: list[str], source: str = "SKILL.md"
) -> dict[str, str] | None:
    """Parse exact name/description frontmatter from a constrained YAML subset."""
    lines = normalize_newlines(text).splitlines()
    if not lines or lines[0] != "---":
        failures.append(f"{source} must start with '---'")
        return None

    try:
        closing_index = lines.index("---", 1)
    except ValueError:
        failures.append(f"{source} has no closing '---'")
        return None

    local_failure_count = len(failures)
    fields: dict[str, str] = {}
    for line_number, line in enumerate(lines[1:closing_index], start=2):
        if not line:
            failures.append(
                f"{source}:{line_number} blank frontmatter lines are not allowed"
            )
            continue
        if "\t" in line:
            failures.append(f"{source}:{line_number} tabs are not allowed")
            continue
        if line != line.lstrip():
            failures.append(
                f"{source}:{line_number} frontmatter fields must be unindented"
            )
            continue
        if ": " not in line:
            failures.append(
                f"{source}:{line_number} must be a 'key: string' field"
            )
            continue

        key, raw_value = line.split(": ", 1)
        if not FIELD_NAME_PATTERN.fullmatch(key):
            failures.append(f"{source}:{line_number} has malformed field '{key}'")
            continue
        if key in fields:
            failures.append(f"{source}:{line_number} duplicates '{key}'")
            continue
        if key not in {"name", "description"}:
            failures.append(f"{source}:{line_number} has unexpected field '{key}'")
            continue

        value = parse_frontmatter_string(raw_value)
        if value is None:
            failures.append(
                f"{source}:{line_number} '{key}' must be a non-empty, "
                "single-line string scalar"
            )
            continue
        fields[key] = value

    missing = sorted({"name", "description"} - fields.keys())
    for key in missing:
        failures.append(f"{source} is missing required field '{key}'")

    if len(failures) != local_failure_count:
        return None
    return fields


def parse_openai_metadata(
    text: str, failures: list[str], source: str = "agents/openai.yaml"
) -> dict[str, str] | None:
    """Parse the exact interface-only OpenAI metadata document."""
    lines = normalize_newlines(text).splitlines()
    local_failure_count = len(failures)
    required_fields = {"display_name", "short_description", "default_prompt"}

    if any("\t" in line for line in lines):
        for line_number, line in enumerate(lines, start=1):
            if "\t" in line:
                failures.append(f"{source}:{line_number} tabs are not allowed")

    nonempty_indexes = [index for index, line in enumerate(lines) if line]
    if not nonempty_indexes:
        failures.append(f"{source} must contain one top-level interface mapping")
        return None
    first_index = nonempty_indexes[0]
    if first_index != 0 or lines[0] != "interface:":
        failures.append(f"{source}:1 must be exactly 'interface:'")

    fields: dict[str, str] = {}
    for line_number, line in enumerate(lines[1:], start=2):
        if not line:
            continue
        if not line.startswith("  ") or line.startswith("   "):
            failures.append(
                f"{source}:{line_number} fields must use exactly two spaces"
            )
            continue
        field_line = line[2:]
        if ":" not in field_line:
            failures.append(
                f"{source}:{line_number} must be a quoted 'key: value' field"
            )
            continue

        key, separator, raw_value = field_line.partition(":")
        if not FIELD_NAME_PATTERN.fullmatch(key):
            failures.append(f"{source}:{line_number} has malformed field '{key}'")
            continue
        if key in fields:
            failures.append(f"{source}:{line_number} duplicates '{key}'")
            continue
        if key not in required_fields:
            failures.append(f"{source}:{line_number} has unexpected field '{key}'")
            continue
        if separator != ":" or not raw_value.startswith(" "):
            failures.append(
                f"{source}:{line_number} must be a quoted 'key: value' field"
            )
            continue

        value = parse_quoted_string(raw_value[1:])
        if value is None:
            failures.append(
                f"{source}:{line_number} '{key}' must be a non-empty, "
                "single-line quoted string"
            )
            continue
        fields[key] = value

    missing = sorted(required_fields - fields.keys())
    for key in missing:
        failures.append(f"{source} is missing required interface field '{key}'")

    short_description = fields.get("short_description", "")
    if short_description and not 25 <= len(short_description) <= 64:
        failures.append(
            "interface.short_description must be 25-64 characters; "
            f"found {len(short_description)}"
        )

    default_prompt = fields.get("default_prompt", "")
    if default_prompt and "$ce-luna-engineering" not in default_prompt:
        failures.append(
            "interface.default_prompt must contain '$ce-luna-engineering'"
        )

    if len(failures) != local_failure_count:
        return None
    return fields


def validate_package_manifest(
    package_directory: Path, failures: list[str]
) -> set[Path]:
    """Validate the exact package tree without following filesystem links."""
    safe_files: set[Path] = set()
    seen_entries: set[Path] = set()
    seen_directories: set[Path] = set()

    try:
        root_mode = package_directory.lstat().st_mode
    except FileNotFoundError:
        failures.append(f"missing package directory: {package_directory}")
        return safe_files
    except OSError as error:
        failures.append(f"could not inspect package directory: {error}")
        return safe_files

    if stat.S_ISLNK(root_mode):
        failures.append(f"package directory must not be a symlink: {package_directory}")
        return safe_files
    if not stat.S_ISDIR(root_mode):
        failures.append(f"package path is not a directory: {package_directory}")
        return safe_files

    seen_directories.add(Path("."))
    pending: list[tuple[Path, Path]] = [(package_directory, Path("."))]
    while pending:
        absolute_directory, relative_directory = pending.pop()
        try:
            entries = sorted(os.scandir(absolute_directory), key=lambda item: item.name)
        except OSError as error:
            failures.append(f"could not enumerate {absolute_directory}: {error}")
            continue

        for entry in entries:
            relative_path = (
                Path(entry.name)
                if relative_directory == Path(".")
                else relative_directory / entry.name
            )
            seen_entries.add(relative_path)
            absolute_path = Path(entry.path)
            try:
                mode = entry.stat(follow_symlinks=False).st_mode
            except OSError as error:
                failures.append(f"could not inspect {absolute_path}: {error}")
                continue

            if stat.S_ISLNK(mode):
                failures.append(f"package entry must not be a symlink: {relative_path}")
                continue
            if stat.S_ISDIR(mode):
                if relative_path not in ALLOWED_PACKAGE_DIRECTORIES:
                    failures.append(f"unexpected package directory: {relative_path}")
                    continue
                seen_directories.add(relative_path)
                pending.append((absolute_path, relative_path))
                continue
            if stat.S_ISREG(mode):
                if relative_path not in ALLOWED_PACKAGE_FILES:
                    failures.append(f"unexpected package file: {relative_path}")
                    continue
                safe_files.add(relative_path)
                continue
            failures.append(f"package entry is not a regular file: {relative_path}")

    for relative_directory in sorted(
        ALLOWED_PACKAGE_DIRECTORIES - seen_directories, key=str
    ):
        failures.append(f"missing package directory: {relative_directory}")
    for relative_file in sorted(ALLOWED_PACKAGE_FILES - seen_entries, key=str):
        failures.append(f"missing required package file: {relative_file}")

    return safe_files


def validate_placeholders(
    package_directory: Path,
    safe_files: set[Path],
    texts: dict[Path, str],
    failures: list[str],
) -> None:
    """Scan every allowed regular text file for placeholder tokens."""
    for relative_file in sorted(safe_files, key=str):
        absolute_file = package_directory / relative_file
        package_text = texts.get(absolute_file)
        if package_text is None:
            continue
        for match in PLACEHOLDER_PATTERN.finditer(package_text):
            line_number = package_text[: match.start()].count("\n") + 1
            failures.append(
                f"{relative_file.as_posix()}:{line_number} contains "
                f"placeholder '{match.group(0)}'"
            )


def validate_reference(
    reference_text: str, readme_text: str, failures: list[str]
) -> None:
    """Ensure the bundled canonical reference contains the exact README."""
    reference_lines = reference_text.splitlines(keepends=True)
    separator_indexes = [
        index
        for index, line in enumerate(reference_lines)
        if line.rstrip("\n") == CANONICAL_SEPARATOR
    ]
    if len(separator_indexes) != 1:
        failures.append(
            "skills/ce-luna-engineering/references/operating-model.md must "
            f"contain exactly one '{CANONICAL_SEPARATOR}' separator line"
        )
        return

    bundled_readme = "".join(reference_lines[separator_indexes[0] + 1 :])
    if bundled_readme != readme_text:
        failures.append(
            "bundled operating-model reference is out of sync: content after "
            f"'{CANONICAL_SEPARATOR}' must exactly match README.md"
        )


def validate_license(
    bundled_license_text: str, license_text: str, failures: list[str]
) -> None:
    """Ensure the skill bundles the exact repository license."""
    if bundled_license_text != license_text:
        failures.append(
            "bundled license is out of sync: "
            "skills/ce-luna-engineering/references/LICENSE must exactly match "
            "LICENSE after newline normalization"
        )


def validate_repository(
    repository_root: Path = REPOSITORY_ROOT,
) -> list[str]:
    """Validate a repository tree and return all discovered failures."""
    failures: list[str] = []
    package_directory = repository_root / "skills" / SKILL_NAME
    safe_relative_files = validate_package_manifest(package_directory, failures)

    texts: dict[Path, str] = {}
    for relative_file in sorted(safe_relative_files, key=str):
        absolute_file = package_directory / relative_file
        text = read_utf8(absolute_file, failures)
        if text is not None:
            texts[absolute_file] = text

    readme_file = repository_root / "README.md"
    license_file = repository_root / "LICENSE"
    for repository_file in (readme_file, license_file):
        text = read_utf8(repository_file, failures)
        if text is not None:
            texts[repository_file] = text

    skill_file = package_directory / "SKILL.md"
    skill_text = texts.get(skill_file)
    if skill_text is not None:
        fields = parse_skill_frontmatter(
            skill_text, failures, display_path(skill_file)
        )
        if fields is not None:
            skill_name = fields["name"]
            if not SKILL_NAME_PATTERN.fullmatch(skill_name):
                failures.append(
                    "SKILL.md name must use lowercase letters, digits, and "
                    "single hyphens"
                )
            if skill_name != package_directory.name:
                failures.append(
                    f"SKILL.md name '{skill_name}' does not match folder "
                    f"'{package_directory.name}'"
                )

        line_count = len(skill_text.splitlines())
        if line_count >= 500:
            failures.append(
                f"SKILL.md must be under 500 lines; found {line_count}"
            )

    openai_file = package_directory / "agents" / "openai.yaml"
    openai_text = texts.get(openai_file)
    if openai_text is not None:
        parse_openai_metadata(openai_text, failures, display_path(openai_file))

    validate_placeholders(
        package_directory, safe_relative_files, texts, failures
    )

    reference_text = texts.get(
        package_directory / "references" / "operating-model.md"
    )
    readme_text = texts.get(readme_file)
    if reference_text is not None and readme_text is not None:
        validate_reference(reference_text, readme_text, failures)

    bundled_license_text = texts.get(package_directory / "references" / "LICENSE")
    license_text = texts.get(license_file)
    if bundled_license_text is not None and license_text is not None:
        validate_license(bundled_license_text, license_text, failures)

    return failures


def main() -> int:
    failures = validate_repository()
    if failures:
        print("Skill validation failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(
        "Skill validation passed: ce-luna-engineering "
        "(exact 4-file package; README and LICENSE synchronized)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
