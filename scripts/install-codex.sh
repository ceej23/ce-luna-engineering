#!/usr/bin/env bash
set -euo pipefail
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
codex_root=${CODEX_ROOT:-"${HOME:?HOME is required}/.codex"}
manifest="$repo_root/manifest/codex-files.tsv"
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

sources=()
targets=()
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -n "$line" && "${line:0:1}" != "#" ]] || continue
  tabs=${line//[!$'\t']/}
  [[ ${#tabs} -eq 1 ]] || die "manifest row must contain exactly two fields: $line"
  IFS=$'\t' read -r source target <<< "$line"
  is_normalized_relative "$source" && is_normalized_relative "$target" || die "invalid manifest entry: $source -> $target"
  expected="$repo_root/$source"; actual="$codex_root/$target"
  [[ -f "$expected" && ! -L "$expected" ]] || die "missing or symlinked source: $source"
  assert_no_symlink_components "$expected"
  assert_no_symlink_components "$actual"
  sources[${#sources[@]}]=$source
  targets[${#targets[@]}]=$target
done < "$manifest"

if [[ ${1:-} != "--apply" ]]; then
  echo "dry run: no files changed (pass --apply to install into $codex_root)"
  for target in "${targets[@]}"; do echo "would install: $target"; done
  exit 0
fi

for index in "${!sources[@]}"; do
  source=${sources[$index]}
  target=${targets[$index]}
  expected="$repo_root/$source"; actual="$codex_root/$target"
  assert_no_symlink_components "$actual"
  mkdir -p -- "${actual%/*}"
  if [[ -f "$actual" ]] && ! files_match "$expected" "$actual"; then
    backup_base="$actual.backup.$(date -u +%Y%m%dT%H%M%SZ).$$"
    backup=$backup_base
    suffix=0
    while [[ -e "$backup" || -L "$backup" ]]; do
      suffix=$((suffix + 1))
      backup="$backup_base.$suffix"
    done
    cp -p -- "$actual" "$backup"
    echo "backup: $backup"
  fi
  if [[ ! -f "$actual" ]] || ! files_match "$expected" "$actual"; then
    cp -p -- "$expected" "$actual"
    echo "installed: $target"
  else
    echo "unchanged: $target"
  fi
done
