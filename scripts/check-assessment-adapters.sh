#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
die() { echo "error: $*" >&2; exit 1; }
require_text() {
  local file=$1 text=$2
  grep -Fq -- "$text" "$repo_root/$file" || die "missing '$text' in $file"
}
reject_text() {
  local file=$1 text=$2
  if grep -Fq -- "$text" "$repo_root/$file"; then
    die "unsupported claim '$text' in $file"
  fi
}

for path in \
  policy/engineering-lifecycle.md \
  policy/engineering-assessment.md \
  assessment/schema/run-events-v1.tsv \
  assessment/schema/capability-matrix-v1.tsv \
  surfaces/codex/skills/ce-assess-engineering/SKILL.md; do
  [[ -f "$repo_root/$path" ]] || die "missing required assessment artifact: $path"
done

while IFS=$'\t' read -r source target; do
  [[ -n "$source" && "${source:0:1}" != "#" ]] || continue
  [[ -f "$repo_root/$source" && ! -L "$repo_root/$source" ]] || die "manifest source missing: $source"
  [[ -n "$target" && "$target" != /* && "$target" != *'..'* ]] || die "invalid manifest target: $target"
done < "$repo_root/manifest/codex-files.tsv"
for shell_file in scripts/check-assessment-adapters.sh scripts/test-assessment-window.sh scripts/test-assessment-install.sh scripts/validate-assessment.sh; do
  bash -n "$repo_root/$shell_file" || die "shell syntax failed: $shell_file"
done

require_text policy/engineering-lifecycle.md "engineering-assessment.md"
require_text policy/engineering-assessment.md "UNVERIFIED"
require_text policy/engineering-assessment.md "Sol owns acceptance"
require_text surfaces/codex/AGENTS.fragment.md "assessment"
require_text surfaces/claude-code/CLAUDE.fragment.md "unverified"
require_text surfaces/cursor/engineering-workflow.mdc "alwaysApply: true"
require_text surfaces/cursor/engineering-workflow.mdc "unverified"
reject_text surfaces/claude-code/CLAUDE.fragment.md "../../policy/"
require_text manifest/codex-files.tsv "surfaces/codex/skills/ce-assess-engineering/SKILL.md"
require_text manifest/codex-files.tsv "surfaces/codex/skills/ce-assess-engineering/agents/openai.yaml"

for surface in codex claude-code cursor ci; do
  grep -q "^$surface" "$repo_root/assessment/schema/capability-matrix-v1.tsv" || die "missing capability rows for $surface"
done

echo "Assessment policy and adapters are conformant"
