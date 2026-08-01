#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_parent=${TMPDIR:-/tmp}
[[ -d /private/tmp ]] && tmp_parent=/private/tmp
test_root=$(mktemp -d "$tmp_parent/ce-codex-install.XXXXXX")
trap 'rm -rf -- "$test_root"' EXIT

fixture_repo="$test_root/repository"
fixture_codex="$test_root/codex"
fixture_skill="$test_root/ce-skill"
mkdir -p -- "$fixture_repo/scripts" "$fixture_repo/manifest"
cp -p -- "$repo_root/scripts/install-codex.sh" "$fixture_repo/scripts/"
cp -p -- "$repo_root/scripts/check-codex-drift.sh" "$fixture_repo/scripts/"
cp -p -- "$repo_root/manifest/ce-luna-skill-files.tsv" "$fixture_repo/manifest/"

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

while IFS= read -r line || [[ -n "$line" ]]; do
  line=${line%$'\r'}; [[ -n "$line" && "${line:0:1}" != "#" ]] || continue
  IFS=$'\t' read -r source _target <<< "$line"
  mkdir -p -- "$fixture_repo/${source%/*}"
  cp -p -- "$repo_root/$source" "$fixture_repo/$source"
done < "$repo_root/manifest/ce-luna-skill-files.tsv"

mkdir -p -- "$fixture_codex/agents/luna-maker.toml"
if CODEX_ROOT="$fixture_codex" CE_SKILL_ROOT="$fixture_skill" bash "$fixture_repo/scripts/install-codex.sh" >/dev/null 2>&1; then
  echo "error: directory Codex target was accepted" >&2; exit 1
fi
rmdir -- "$fixture_codex/agents/luna-maker.toml"
mkdir -p -- "$fixture_skill/agents/openai.yaml"
if CODEX_ROOT="$fixture_codex" CE_SKILL_ROOT="$fixture_skill" bash "$fixture_repo/scripts/install-codex.sh" >/dev/null 2>&1; then
  echo "error: directory CE skill target was accepted" >&2; exit 1
fi
rmdir -- "$fixture_skill/agents/openai.yaml"

CODEX_ROOT="$fixture_codex" CE_SKILL_ROOT="$fixture_skill" bash "$fixture_repo/scripts/install-codex.sh" --apply \
  >/dev/null
CODEX_ROOT="$fixture_codex" CE_SKILL_ROOT="$fixture_skill" bash "$fixture_repo/scripts/check-codex-drift.sh" \
  >/dev/null

test -f "$fixture_skill/SKILL.md"
if find "$fixture_codex" -name $'*\r*' -print -quit | grep -q .; then
  echo "error: CRLF manifest produced a target containing a carriage return" >&2
  exit 1
fi

echo "Codex installer CRLF smoke test passed"
