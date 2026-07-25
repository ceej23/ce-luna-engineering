#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/assessment-window.XXXXXX")
tmp=$(CDPATH= cd -- "$tmp" && pwd -P)
trap 'rm -rf "$tmp"' EXIT
window="$repo_root/scripts/assessment_window.py"
codex_root="$tmp/codex"

run_window() {
  python3 "$window" --codex-root "$codex_root" --agent "$1" --repository "$2" --now "$3" "${@:4}"
}

expect_failure() {
  if "$@" >/dev/null 2>&1; then
    echo "expected failure: $*" >&2
    exit 1
  fi
}

json_assert() {
  python3 -c 'import json,sys; data=json.load(sys.stdin); assert eval(sys.argv[1], {"data": data})' "$1"
}

make_summary() {
  target=$1
  run_id=$2
  result=$3
  reason=$4
  severity=$5
  policy=${6:-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa}
  adapter=${7:-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb}
  controls=${8:-scope:pass;control:pass;evidence:pass;independence:pass;delivery:pass;evidence:pass}
  python3 - "$target" "$run_id" "$result" "$reason" "$severity" "$policy" "$adapter" "$controls" <<'PY'
import hashlib
import pathlib
import sys

target, run_id, result, reason, severity, policy, adapter, controls = sys.argv[1:]
routes = ";".join(["unknown:unknown:unknown"] * 6)
facts = [
    "validated-summary/v1", run_id, policy, adapter, "codex", controls, routes,
    result, reason, severity,
]
summary_id = "sha256:" + hashlib.sha256("\t".join(facts).encode()).hexdigest()
record = [facts[0], summary_id, *facts[1:], "2020-01-01T00:00:00Z"]
pathlib.Path(target).write_text("\t".join(record) + "\n", encoding="utf-8")
PY
}

ingest_many() {
  agent=$1
  repository=$2
  now=$3
  count=$4
  reason=$5
  policy=${6:-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa}
  adapter=${7:-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb}
  controls=${8:-scope:pass;control:pass;evidence:pass;independence:pass;delivery:pass;evidence:pass}
  files=()
  for index in $(seq 1 "$count"); do
    summary="$tmp/${agent}-${repository}-${now%%T*}-${index}.tsv"
    make_summary "$summary" "${agent}-${repository}-${now%%T*}-$index" unverified "$reason" warning "$policy" "$adapter" "$controls"
    files+=("$summary")
  done
  run_window "$agent" "$repository" "$now" ingest "${files[@]}" >/dev/null
}

# A: setup/readiness, bounded identities, and no-follow roots.
run_window alpha repo-one 2026-01-05T12:00:00Z setup | json_assert 'data["ready"] is True'
run_window alpha repo-one 2026-01-05T12:00:00Z setup | json_assert 'data["ready"] is True'
run_window alpha repo-one 2026-01-05T12:00:00Z readiness | json_assert 'data["state"] == "isolated"'
expect_failure python3 "$window" --codex-root relative --agent alpha --repository repo setup
expect_failure python3 "$window" --codex-root / --agent alpha --repository repo setup
expect_failure python3 "$window" --codex-root "$codex_root" --agent ../alpha --repository repo setup
mkdir "$tmp/real-root"
ln -s "$tmp/real-root" "$tmp/link-root"
expect_failure python3 "$window" --codex-root "$tmp/link-root" --agent alpha --repository repo setup
run_window symlink-close repo 2026-01-12T12:00:00Z setup >/dev/null
mkdir "$tmp/outside"
ln -s "$tmp/outside" "$codex_root/assessment/symlink-close/repo/windows"
expect_failure run_window symlink-close repo 2026-01-12T12:00:00Z close --week 2026-W01
test ! -e "$tmp/outside/2026-W01/report.json"

# B/C: strict parsing, immutable/idempotent ingestion, and concurrency.
make_summary "$tmp/valid.tsv" valid-run pass conformant info
run_window alpha repo-one 2026-01-05T12:00:00Z ingest "$tmp/valid.tsv" | json_assert 'data["ingested"] == 1'
run_window alpha repo-one 2026-01-05T12:00:00Z ingest "$tmp/valid.tsv" | json_assert 'data["ingested"] == 0'
cp "$tmp/valid.tsv" "$tmp/conflict.tsv"
sed 's/2020-01-01/2020-01-02/' "$tmp/conflict.tsv" > "$tmp/conflict-new.tsv"
expect_failure run_window alpha repo-one 2026-01-05T12:00:00Z ingest "$tmp/conflict-new.tsv"
cp "$tmp/valid.tsv" "$tmp/tampered.tsv"
sed 's/conformant/other-signal/' "$tmp/tampered.tsv" > "$tmp/tampered-new.tsv"
expect_failure run_window alpha repo-one 2026-01-05T12:00:00Z ingest "$tmp/tampered-new.tsv"
printf '\n' >> "$tmp/tampered.tsv"
expect_failure run_window alpha repo-one 2026-01-05T12:00:00Z ingest "$tmp/tampered.tsv"
ln -s "$tmp/valid.tsv" "$tmp/summary-link.tsv"
expect_failure run_window alpha repo-one 2026-01-05T12:00:00Z ingest "$tmp/summary-link.tsv"
for index in 1 2 3 4 5; do
  make_summary "$tmp/concurrent-$index.tsv" "concurrent-$index" pass conformant info
  run_window alpha repo-one 2026-01-05T12:00:00Z ingest "$tmp/concurrent-$index.tsv" >/dev/null &
done
wait
test "$(find "$codex_root/assessment/alpha/repo-one/windows/2026-W02/summaries" -name '*.tsv' | wc -l | tr -d ' ')" -eq 6
test -z "$(find "$codex_root" -name '.assessment-*' -print -quit)"

# D: agent and repository isolation.
run_window beta repo-one 2026-01-05T12:00:00Z setup >/dev/null
run_window alpha repo-two 2026-01-05T12:00:00Z setup >/dev/null
run_window beta repo-one 2026-01-05T12:00:00Z report --partial | json_assert 'data["summary_count"] == 0'
run_window alpha repo-two 2026-01-05T12:00:00Z report --partial | json_assert 'data["summary_count"] == 0'

# E/F/G/H: late arrival, coverage boundary, partial ephemerality, immutable close, recurrence.
run_window cadence repo 2026-01-12T12:00:00Z setup >/dev/null
ingest_many cadence repo 2026-01-12T12:00:00Z 19 routine-friction
run_window cadence repo 2026-01-12T12:00:00Z report --partial | json_assert 'data["summary_count"] == 19 and data["covered"] is False and data["partial"] is True'
test ! -e "$codex_root/assessment/cadence/repo/windows/2026-W03/report.json"
run_window cadence repo 2026-01-19T12:00:00Z close --week 2026-W03 >/dev/null
run_window cadence repo 2026-01-19T12:00:00Z report --week 2026-W03 | json_assert 'data["summary_count"] == 19 and data["covered"] is False and data["proposal_candidates"] == []'

ingest_many cadence repo 2026-01-19T12:00:00Z 20 routine-friction
run_window cadence repo 2026-01-26T12:00:00Z close --week 2026-W04 >/dev/null
run_window cadence repo 2026-01-26T12:00:00Z report --week 2026-W04 | json_assert 'data["covered"] is True and data["proposal_candidates"] == []'
ingest_many cadence repo 2026-01-26T12:00:00Z 20 routine-friction
run_window cadence repo 2026-02-02T12:00:00Z close --week 2026-W05 >/dev/null
run_window cadence repo 2026-02-02T12:00:00Z report --week 2026-W05 | json_assert 'len(data["proposal_candidates"]) == 1 and data["proposal_candidates"][0]["type"] == "routine-signal"'

closed="$codex_root/assessment/cadence/repo/windows/2026-W05/report.json"
closed_before=$(cksum "$closed")
run_window cadence repo 2026-02-02T12:00:00Z close --week 2026-W05 | json_assert 'data["created"] is False'
test "$(cksum "$closed")" = "$closed_before"
make_summary "$tmp/late.tsv" late-run unverified routine-friction warning
run_window cadence repo 2026-02-02T12:00:00Z ingest "$tmp/late.tsv" >/dev/null
test "$(cksum "$closed")" = "$closed_before"
test -f "$codex_root/assessment/cadence/repo/windows/2026-W06/summaries/"*.tsv
expect_failure run_window cadence repo 2026-02-02T12:00:00Z close --week 2026-W06
expect_failure run_window cadence repo 2026-02-02T12:00:00Z close --week 2099-W99

# Different version and an uncovered intervening week both break recurrence.
different_policy=cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
run_window breaks repo 2026-02-02T12:00:00Z setup >/dev/null
ingest_many breaks repo 2026-02-02T12:00:00Z 20 routine-friction
run_window breaks repo 2026-02-09T12:00:00Z close --week 2026-W06 >/dev/null
ingest_many breaks repo 2026-02-09T12:00:00Z 20 routine-friction "$different_policy"
run_window breaks repo 2026-02-16T12:00:00Z close --week 2026-W07 >/dev/null
run_window breaks repo 2026-02-16T12:00:00Z report --week 2026-W07 | json_assert 'data["proposal_candidates"] == []'
ingest_many breaks repo 2026-02-16T12:00:00Z 19 routine-friction "$different_policy"
run_window breaks repo 2026-02-23T12:00:00Z close --week 2026-W08 >/dev/null
ingest_many breaks repo 2026-02-23T12:00:00Z 20 routine-friction "$different_policy"
run_window breaks repo 2026-03-02T12:00:00Z close --week 2026-W09 >/dev/null
run_window breaks repo 2026-03-02T12:00:00Z report --week 2026-W09 | json_assert 'data["proposal_candidates"] == []'

# Identical reasons on different control-result profiles are not recurrence.
alternate_controls='scope:pass;control:unverified;evidence:pass;independence:pass;delivery:pass;evidence:pass'
run_window control-break repo 2026-03-02T12:00:00Z setup >/dev/null
ingest_many control-break repo 2026-03-02T12:00:00Z 20 routine-friction
run_window control-break repo 2026-03-09T12:00:00Z close --week 2026-W10 >/dev/null
ingest_many control-break repo 2026-03-09T12:00:00Z 20 routine-friction \
  aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
  bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb \
  "$alternate_controls"
run_window control-break repo 2026-03-16T12:00:00Z close --week 2026-W11 >/dev/null
run_window control-break repo 2026-03-16T12:00:00Z report --week 2026-W11 | json_assert 'data["proposal_candidates"] == []'

# I: severe validated failure bypasses coverage; non-FAIL severe input is rejected.
run_window severe repo 2026-03-02T12:00:00Z setup >/dev/null
make_summary "$tmp/severe.tsv" severe-run fail reviewer-write severe
run_window severe repo 2026-03-02T12:00:00Z ingest "$tmp/severe.tsv" >/dev/null
run_window severe repo 2026-03-09T12:00:00Z close --week 2026-W10 >/dev/null
run_window severe repo 2026-03-09T12:00:00Z report --week 2026-W10 | json_assert 'data["covered"] is False and len(data["proposal_candidates"]) == 1 and data["changes_policy"] is False and data["changes_delivery"] is False'
make_summary "$tmp/fake-severe.tsv" fake-severe unverified reviewer-write severe
expect_failure run_window severe repo 2026-03-09T12:00:00Z ingest "$tmp/fake-severe.tsv"

# J: retain only 13 closed windows without touching the open week or outside sentinel.
run_window retention repo 2025-01-06T12:00:00Z setup >/dev/null
touch "$codex_root/assessment/retention/outside-sentinel"
for week_number in $(seq -w 2 15); do
  now_week=$((10#$week_number + 1))
  now=$(python3 - "$now_week" <<'PY'
from datetime import datetime
import sys
print(datetime.fromisocalendar(2025, int(sys.argv[1]), 1).strftime("%Y-%m-%dT12:00:00Z"))
PY
)
  run_window retention repo "$now" close --week "2025-W$week_number" >/dev/null
done
test "$(find "$codex_root/assessment/retention/repo/windows" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" -eq 13
test -f "$codex_root/assessment/retention/outside-sentinel"

# K: immediately previous completed week closes once, even empty.
run_window due repo 2026-07-25T12:00:00Z setup >/dev/null
run_window due repo 2026-07-25T12:00:00Z if-due | json_assert 'data["due"] is True and data["window"] == "2026-W29"'
due_report="$codex_root/assessment/due/repo/windows/2026-W29/report.json"
due_before=$(cksum "$due_report")
run_window due repo 2026-07-25T12:00:00Z if-due | json_assert 'data["due"] is False'
test "$(cksum "$due_report")" = "$due_before"

echo "assessment window tests passed"
