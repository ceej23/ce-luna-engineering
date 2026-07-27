#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT

fixture_repo="$test_root/repository"
fixture_codex="$test_root/codex"
mkdir -p -- "$fixture_repo/scripts" "$fixture_repo/manifest"
cp -p -- "$repo_root/scripts/install-codex.sh" "$fixture_repo/scripts/"
cp -p -- "$repo_root/scripts/check-codex-drift.sh" "$fixture_repo/scripts/"

# Build a disposable repository fixture whose manifest deliberately uses CRLF.
# This catches carriage returns leaking into installed target names.
while IFS= read -r line || [[ -n "$line" ]]; do
  line=${line%$'\r'}
  printf '%s\r\n' "$line" >> "$fixture_repo/manifest/codex-files.tsv"
  [[ -n "$line" && "${line:0:1}" != "#" ]] || continue
  IFS=$'\t' read -r source _target <<< "$line"
  mkdir -p -- "$fixture_repo/${source%/*}"
  cp -p -- "$repo_root/$source" "$fixture_repo/$source"
done < "$repo_root/manifest/codex-files.tsv"

CODEX_ROOT="$fixture_codex" bash "$fixture_repo/scripts/install-codex.sh" --apply \
  >/dev/null
CODEX_ROOT="$fixture_codex" bash "$fixture_repo/scripts/check-codex-drift.sh" \
  >/dev/null

test -f "$fixture_codex/skills/ce-luna-engineering/SKILL.md"
if find "$fixture_codex" -name $'*\r*' -print -quit | grep -q .; then
  echo "error: CRLF manifest produced a target containing a carriage return" >&2
  exit 1
fi

echo "Codex installer CRLF smoke test passed"
