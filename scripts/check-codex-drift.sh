#!/usr/bin/env bash
set -euo pipefail
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
codex_root=${CODEX_ROOT:-"${HOME:?HOME is required}/.codex"}
manifest="$repo_root/manifest/codex-files.tsv"
die() { echo "error: $*" >&2; exit 2; }
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

sources=()
targets=()
while IFS= read -r line || [[ -n "$line" ]]; do
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
done < "$manifest"

status=0
for index in "${!sources[@]}"; do
  source=${sources[$index]}
  target=${targets[$index]}
  expected="$repo_root/$source"; actual="$codex_root/$target"
  if [[ ! -f "$actual" ]]; then echo "missing: $target" >&2; status=1
  elif ! cmp -s "$expected" "$actual"; then echo "changed: $target" >&2; status=1
  fi
done
if (( status == 0 )); then echo "Codex files match manifest ($codex_root)"; fi
exit "$status"
