#!/usr/bin/env bash
set -euo pipefail
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
codex_root=${CODEX_ROOT:-"${HOME:?HOME is required}/.codex"}
manifest="$repo_root/manifest/codex-files.tsv"
skill_root=${CE_SKILL_ROOT:-"${HOME:?HOME is required}/.agents/skills/ce-luna-engineering"}
skill_manifest="$repo_root/manifest/ce-luna-skill-files.tsv"
die() { echo "error: $*" >&2; exit 2; }
file_mode() {
  if stat -f '%Lp' "$1" >/dev/null 2>&1; then stat -f '%Lp' "$1"
  else stat -c '%a' "$1"
  fi
}
files_match() {
  cmp -s "$1" "$2" && [[ "$(file_mode "$1")" == "$(file_mode "$2")" ]]
}
is_normalized_relative() {
  [[ -n "$1" && "$1" != /* && "$1" != */ && "$1" != *//* && "/$1/" != *"/./"* && "/$1/" != *"/../"* ]]
}
assert_no_symlink_components() {
  local path=$1 current=/ part
  local -a parts
  IFS=/ read -r -a parts <<< "${path#/}"
  for part in "${parts[@]}"; do
    [[ -n "$part" ]] || continue
    current="${current%/}/$part"
    [[ ! -L "$current" ]] || die "symlink path component: $current"
  done
}
if [[ "$codex_root" != /* || "$codex_root" == "/" || "$codex_root" == "$HOME" || "$codex_root" == */ || "$codex_root" == *//* || "/$codex_root/" == *"/./"* || "/$codex_root/" == *"/../"* ]]; then
  die "refusing unsafe CODEX_ROOT: $codex_root"
fi
assert_no_symlink_components "$codex_root"
if [[ "$skill_root" != /* || "$skill_root" == "/" || "$skill_root" == "$HOME" || "$skill_root" == */ || "$skill_root" == *//* || "/$skill_root/" == *"/./"* || "/$skill_root/" == *"/../"* ]]; then
  die "refusing unsafe CE_SKILL_ROOT: $skill_root"
fi
assert_no_symlink_components "$skill_root"

sources=()
targets=()
skill_flags=()
while IFS= read -r line || [[ -n "$line" ]]; do
  line=${line%$'\r'}
  [[ -n "$line" && "${line:0:1}" != "#" ]] || continue
  tabs=${line//[!$'\t']/}
  [[ ${#tabs} -eq 1 ]] || die "manifest row must contain exactly two fields: $line"
  IFS=$'\t' read -r source target <<< "$line"
  is_normalized_relative "$source" && is_normalized_relative "$target" || die "invalid manifest entry: $source -> $target"
  expected="$repo_root/$source"
  [[ -f "$expected" && ! -L "$expected" ]] || die "missing or symlinked source: $source"
  assert_no_symlink_components "$expected"
  actual="$codex_root/$target"
  assert_no_symlink_components "$actual"
  sources[${#sources[@]}]=$source
  targets[${#targets[@]}]=$target
  skill_flags[${#skill_flags[@]}]=0
done < "$manifest"

while IFS= read -r line || [[ -n "$line" ]]; do
  line=${line%$'\r'}; [[ -n "$line" && "${line:0:1}" != "#" ]] || continue
  tabs=${line//[!$'\t']/}; [[ ${#tabs} -eq 1 ]] || die "skill manifest row must contain exactly two fields: $line"
  IFS=$'\t' read -r source target <<< "$line"
  is_normalized_relative "$source" && is_normalized_relative "$target" || die "invalid skill manifest entry: $source -> $target"
  expected="$repo_root/$source"; actual="$skill_root/$target"
  [[ -f "$expected" && ! -L "$expected" ]] || die "missing or symlinked source: $source"
  assert_no_symlink_components "$expected"; assert_no_symlink_components "$actual"
  sources[${#sources[@]}]=$source; targets[${#targets[@]}]=$target
  skill_flags[${#skill_flags[@]}]=1
done < "$skill_manifest"

status=0
for index in "${!sources[@]}"; do
  source=${sources[$index]}
  target=${targets[$index]}
  if [[ ${skill_flags[$index]:-0} == 1 ]]; then actual="$skill_root/$target"; else actual="$codex_root/$target"; fi
  expected="$repo_root/$source"
  if [[ ! -f "$actual" ]]; then echo "missing: $target" >&2; status=1
  elif ! files_match "$expected" "$actual"; then echo "changed: $target" >&2; status=1
  fi
done
if (( status == 0 )); then echo "Codex files and CE skill match manifests ($codex_root; $skill_root)"; fi
exit "$status"
