#!/usr/bin/env python3
"""Isolated, deterministic UTC ISO-week assessment windows."""

from __future__ import annotations

import argparse
import fcntl
import hashlib
import json
import os
import re
import stat
from contextlib import contextmanager
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Iterator

STATE_VERSION = "assessment-state/v1"
REPORT_VERSION = "assessment-window/v1"
COVERAGE_GATE = 20
RETENTION_WINDOWS = 13
IDENTIFIER = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
SUMMARY_DIGEST = re.compile(r"^sha256:[0-9a-f]{64}$")
REFERENCE_DIGEST = re.compile(r"^[0-9a-f]{64}$")
WEEK = re.compile(r"^\d{4}-W\d{2}$")
CONTROL_NAMES = {"scope", "control", "evidence", "independence", "delivery"}
CONTROL_RESULTS = {"pass", "fail", "unverified"}
SURFACES = {"codex", "claude-code", "cursor", "ci"}
RESULTS = {"pass", "fail", "unverified", "exception"}
SEVERITIES = {"info", "warning", "severe"}
SEVERE_REASONS = {"reviewer-write", "integrity-mismatch", "unauthorized-delivery"}
SUMMARY_FIELDS = 12


class AssessmentError(Exception):
    """A safe, user-reportable assessment failure."""


def _utc(value: str | None) -> datetime:
    if value is None:
        return datetime.now(timezone.utc)
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as error:
        raise AssessmentError("invalid --now timestamp") from error
    if parsed.tzinfo is None or parsed.utcoffset() != timedelta(0):
        raise AssessmentError("--now must include UTC offset Z or +00:00")
    return parsed.astimezone(timezone.utc)


def _week(value: datetime) -> str:
    return value.strftime("%G-W%V")


def _previous_week(week: str) -> str:
    _validate_week(week)
    year, number = int(week[:4]), int(week[6:])
    monday = datetime.fromisocalendar(year, number, 1)
    return (monday - timedelta(days=7)).strftime("%G-W%V")


def _validate_week(week: str) -> None:
    if not WEEK.fullmatch(week):
        raise AssessmentError("invalid ISO week")
    try:
        datetime.fromisocalendar(int(week[:4]), int(week[6:]), 1)
    except ValueError as error:
        raise AssessmentError("invalid ISO week") from error


def _check_existing_components(path: Path) -> None:
    current = Path(path.anchor)
    for part in path.parts[1:]:
        current /= part
        try:
            mode = os.lstat(current).st_mode
        except FileNotFoundError:
            return
        if stat.S_ISLNK(mode):
            raise AssessmentError("symlink path component")


def _root_path(value: str, create: bool) -> Path:
    root = Path(value)
    if not root.is_absolute() or root == Path("/"):
        raise AssessmentError("unsafe CODEX root")
    _check_existing_components(root)
    if create:
        root.mkdir(parents=True, exist_ok=True)
    if not root.is_dir():
        raise AssessmentError("CODEX root is not ready")
    return root


def _state_path(root_value: str, agent: str, repository: str, create: bool) -> Path:
    if not IDENTIFIER.fullmatch(agent) or not IDENTIFIER.fullmatch(repository):
        raise AssessmentError("invalid agent or repository identity")
    root = _root_path(root_value, create=create)
    state = root / "assessment" / agent / repository
    _check_existing_components(state)
    if create:
        state.mkdir(parents=True, exist_ok=True)
    if not state.is_dir():
        raise AssessmentError("assessment state is not set up")
    return state


def _write_exclusive(path: Path, data: bytes) -> None:
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    descriptor = os.open(path, flags, 0o600)
    try:
        with os.fdopen(descriptor, "wb", closefd=False) as output:
            output.write(data)
            output.flush()
            os.fsync(output.fileno())
    finally:
        os.close(descriptor)


@contextmanager
def _locked(state: Path) -> Iterator[None]:
    lock_path = state / ".lock"
    if lock_path.is_symlink():
        raise AssessmentError("unsafe state lock")
    flags = os.O_RDWR | os.O_CREAT
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    descriptor = os.open(lock_path, flags, 0o600)
    try:
        fcntl.flock(descriptor, fcntl.LOCK_EX)
        yield
    finally:
        fcntl.flock(descriptor, fcntl.LOCK_UN)
        os.close(descriptor)


def _setup(state: Path) -> None:
    marker = state / "state.json"
    expected = json.dumps({"schema_version": STATE_VERSION}, sort_keys=True).encode() + b"\n"
    with _locked(state):
        if marker.exists():
            if marker.is_symlink() or marker.read_bytes() != expected:
                raise AssessmentError("assessment setup drift")
            return
        _write_exclusive(marker, expected)


def _ready(state: Path) -> None:
    marker = state / "state.json"
    expected = json.dumps({"schema_version": STATE_VERSION}, sort_keys=True).encode() + b"\n"
    if marker.is_symlink() or not marker.is_file() or marker.read_bytes() != expected:
        raise AssessmentError("assessment state is not ready")


def _parse_control_facts(value: str) -> None:
    facts = value.split(";")
    if len(facts) != 6:
        raise AssessmentError("invalid control facts")
    for fact in facts:
        try:
            control, result = fact.split(":")
        except ValueError as error:
            raise AssessmentError("invalid control facts") from error
        if control not in CONTROL_NAMES or result not in CONTROL_RESULTS:
            raise AssessmentError("invalid control facts")


def _parse_route_facts(value: str) -> None:
    facts = value.split(";")
    if len(facts) != 6:
        raise AssessmentError("invalid route facts")
    for fact in facts:
        parts = fact.split(":")
        if len(parts) != 3 or any(
            route != "unknown" and not IDENTIFIER.fullmatch(route) for route in parts
        ):
            raise AssessmentError("invalid route facts")


def _read_summary(path_value: str | Path) -> tuple[list[str], bytes]:
    path = Path(path_value)
    _check_existing_components(path)
    flags = os.O_RDONLY
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    try:
        descriptor = os.open(path, flags)
    except OSError as error:
        raise AssessmentError("unsafe summary input") from error
    try:
        if not stat.S_ISREG(os.fstat(descriptor).st_mode):
            raise AssessmentError("unsafe summary input")
        with os.fdopen(descriptor, "rb", closefd=False) as source:
            raw = source.read()
    finally:
        os.close(descriptor)
    if not raw.endswith(b"\n") or raw.count(b"\n") != 1 or b"\r" in raw:
        raise AssessmentError("summary must contain exactly one LF-terminated record")
    try:
        fields = raw[:-1].decode("utf-8").split("\t")
    except UnicodeDecodeError as error:
        raise AssessmentError("summary is not UTF-8") from error
    if len(fields) != SUMMARY_FIELDS or fields[0] != "validated-summary/v1":
        raise AssessmentError("invalid summary contract")

    (
        _schema,
        summary_id,
        run_id,
        policy_ref,
        adapter_ref,
        surface,
        controls,
        routes,
        result,
        reason_text,
        severity,
        validated_at,
    ) = fields
    if not SUMMARY_DIGEST.fullmatch(summary_id) or not REFERENCE_DIGEST.fullmatch(
        policy_ref
    ):
        raise AssessmentError("invalid summary digest")
    if adapter_ref != "unknown" and not REFERENCE_DIGEST.fullmatch(adapter_ref):
        raise AssessmentError("invalid adapter digest")
    if not IDENTIFIER.fullmatch(run_id) or surface not in SURFACES:
        raise AssessmentError("invalid summary identity")
    if result not in RESULTS or severity not in SEVERITIES:
        raise AssessmentError("invalid result or severity")
    _parse_control_facts(controls)
    _parse_route_facts(routes)
    reasons = reason_text.split(";")
    if any(not IDENTIFIER.fullmatch(reason) for reason in reasons):
        raise AssessmentError("invalid reason codes")
    if "conformant" in reasons and (len(reasons) != 1 or result != "pass" or severity != "info"):
        raise AssessmentError("incompatible conformant summary")
    if severity == "severe" and (
        result != "fail" or not SEVERE_REASONS.intersection(reasons)
    ):
        raise AssessmentError("unsupported severe summary")
    try:
        parsed_at = datetime.strptime(validated_at, "%Y-%m-%dT%H:%M:%SZ")
    except ValueError as error:
        raise AssessmentError("invalid validation timestamp") from error
    if parsed_at.strftime("%Y-%m-%dT%H:%M:%SZ") != validated_at:
        raise AssessmentError("invalid validation timestamp")

    digest_fields = fields[:1] + fields[2:11]
    expected_id = "sha256:" + hashlib.sha256("\t".join(digest_fields).encode()).hexdigest()
    if summary_id != expected_id:
        raise AssessmentError("summary digest mismatch")
    return fields, raw


def _window_dir(state: Path, week: str) -> Path:
    return state / "windows" / week


def _ingest(state: Path, sources: list[str], now: datetime) -> int:
    week = _week(now)
    with _locked(state):
        window = _window_dir(state, week)
        if (window / "report.json").exists():
            raise AssessmentError("current ingestion window is closed")
        summaries_dir = window / "summaries"
        _check_existing_components(summaries_dir)
        summaries_dir.mkdir(parents=True, exist_ok=True)
        ingested = 0
        for source in sources:
            fields, raw = _read_summary(source)
            target = summaries_dir / f"{fields[1]}.tsv"
            if target.exists():
                if target.is_symlink() or target.read_bytes() != raw:
                    raise AssessmentError("conflicting summary identifier")
                continue
            _write_exclusive(target, raw)
            ingested += 1
        return ingested


def _summaries(state: Path, week: str) -> list[list[str]]:
    summaries_dir = _window_dir(state, week) / "summaries"
    if not summaries_dir.exists():
        return []
    _check_existing_components(summaries_dir)
    values: list[list[str]] = []
    for path in sorted(summaries_dir.iterdir()):
        if not re.fullmatch(r"sha256-[0-9a-f]{64}\.tsv", path.name.replace(":", "-")):
            raise AssessmentError("unexpected summary artifact")
        fields, _raw = _read_summary(path)
        values.append(fields)
    return values


def _signal_key(fields: list[str], reason: str) -> str:
    return "|".join((fields[3], fields[4], fields[5], fields[6], reason))


def _load_closed_report(state: Path, week: str) -> dict[str, Any] | None:
    path = _window_dir(state, week) / "report.json"
    if not path.exists():
        return None
    if path.is_symlink():
        raise AssessmentError("unsafe closed report")
    try:
        report = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise AssessmentError("invalid closed report") from error
    if report.get("schema_version") != REPORT_VERSION or report.get("window") != week:
        raise AssessmentError("invalid closed report")
    return report


def _build_report(state: Path, week: str, partial: bool) -> dict[str, Any]:
    values = _summaries(state, week)
    covered = not partial and len(values) >= COVERAGE_GATE
    signal_counts: dict[str, int] = {}
    severe_candidates: list[dict[str, str]] = []
    for fields in values:
        reasons = fields[9].split(";")
        for reason in reasons:
            if reason != "conformant":
                key = _signal_key(fields, reason)
                signal_counts[key] = signal_counts.get(key, 0) + 1
        direct_severe = sorted(SEVERE_REASONS.intersection(reasons))
        if fields[8] == "fail" and fields[10] == "severe" and direct_severe:
            severe_candidates.append(
                {
                    "type": "severe-failure",
                    "summary_id": fields[1],
                    "signal": _signal_key(fields, direct_severe[0]),
                }
            )

    candidates = list(severe_candidates)
    if covered:
        prior = _load_closed_report(state, _previous_week(week))
        if prior is not None and prior.get("covered") is True:
            prior_counts = prior.get("signal_counts", {})
            for key in sorted(signal_counts):
                if isinstance(prior_counts, dict) and prior_counts.get(key, 0) > 0:
                    candidates.append({"type": "routine-signal", "signal": key})

    return {
        "schema_version": REPORT_VERSION,
        "window": week,
        "summary_count": len(values),
        "coverage_gate": COVERAGE_GATE,
        "covered": covered,
        "partial": partial,
        "signal_counts": dict(sorted(signal_counts.items())),
        "proposal_candidates": candidates,
        "report_only": True,
        "changes_policy": False,
        "changes_delivery": False,
    }


def _remove_generated_window(path: Path) -> None:
    _check_existing_components(path)
    allowed_files = {"report.json"}
    for child in path.rglob("*"):
        if child.is_symlink():
            raise AssessmentError("unsafe retention artifact")
        if child.is_file() and child.parent.name != "summaries" and child.name not in allowed_files:
            raise AssessmentError("unexpected retention artifact")
    summaries = path / "summaries"
    if summaries.exists():
        for child in summaries.iterdir():
            if not child.is_file() or child.is_symlink():
                raise AssessmentError("unsafe retention artifact")
            child.unlink()
        summaries.rmdir()
    report = path / "report.json"
    if report.exists():
        report.unlink()
    path.rmdir()


def _prune(state: Path) -> None:
    windows_dir = state / "windows"
    if not windows_dir.exists():
        return
    closed: list[Path] = []
    for child in windows_dir.iterdir():
        if child.is_symlink():
            raise AssessmentError("unsafe window path")
        if child.is_dir() and WEEK.fullmatch(child.name) and (child / "report.json").is_file():
            closed.append(child)
    for expired in sorted(closed, key=lambda item: item.name)[:-RETENTION_WINDOWS]:
        _remove_generated_window(expired)


def _close(state: Path, week: str, now: datetime) -> bool:
    _validate_week(week)
    if week >= _week(now):
        raise AssessmentError("only completed ISO weeks may close")
    with _locked(state):
        path = _window_dir(state, week) / "report.json"
        _check_existing_components(path.parent)
        existing = _load_closed_report(state, week)
        if existing is not None:
            return False
        path.parent.mkdir(parents=True, exist_ok=True)
        _check_existing_components(path.parent)
        report = _build_report(state, week, partial=False)
        _write_exclusive(
            path,
            (json.dumps(report, sort_keys=True, separators=(",", ":")) + "\n").encode(),
        )
        _prune(state)
        return True


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--codex-root", required=True)
    parser.add_argument("--agent", required=True)
    parser.add_argument("--repository", required=True)
    parser.add_argument("--now", help="UTC RFC3339 test clock")
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("setup")
    commands.add_parser("readiness")
    ingest = commands.add_parser("ingest")
    ingest.add_argument("summary", nargs="+")
    report = commands.add_parser("report")
    report.add_argument("--week")
    report.add_argument("--partial", action="store_true")
    close = commands.add_parser("close")
    close.add_argument("--week", required=True)
    commands.add_parser("if-due")
    return parser


def main() -> int:
    arguments = _parser().parse_args()
    try:
        now = _utc(arguments.now)
        if arguments.command == "setup":
            state = _state_path(
                arguments.codex_root, arguments.agent, arguments.repository, create=True
            )
            _setup(state)
            print(json.dumps({"ready": True, "state": "isolated"}, sort_keys=True))
            return 0

        state = _state_path(
            arguments.codex_root, arguments.agent, arguments.repository, create=False
        )
        _ready(state)
        if arguments.command == "readiness":
            print(json.dumps({"ready": True, "state": "isolated"}, sort_keys=True))
        elif arguments.command == "ingest":
            count = _ingest(state, arguments.summary, now)
            print(json.dumps({"ingested": count}, sort_keys=True))
        elif arguments.command == "report":
            week = arguments.week or _week(now)
            _validate_week(week)
            with _locked(state):
                if arguments.partial:
                    if week != _week(now):
                        raise AssessmentError("partial report must use the current open week")
                    report = _build_report(state, week, partial=True)
                else:
                    report = _load_closed_report(state, week)
                    if report is None:
                        raise AssessmentError("completed report is not closed")
            print(json.dumps(report, sort_keys=True))
        elif arguments.command == "close":
            created = _close(state, arguments.week, now)
            print(json.dumps({"closed": arguments.week, "created": created}, sort_keys=True))
        elif arguments.command == "if-due":
            week = _previous_week(_week(now))
            created = _close(state, week, now)
            print(json.dumps({"due": created, "window": week}, sort_keys=True))
        return 0
    except (AssessmentError, OSError) as error:
        print(json.dumps({"error": str(error), "ready": False}, sort_keys=True))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
