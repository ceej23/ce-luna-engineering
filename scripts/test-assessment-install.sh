#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_parent=${TMPDIR:-/tmp}
[[ -d /private/tmp ]] && tmp_parent=/private/tmp
tmp=$(mktemp -d "$tmp_parent/assessment-install.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
codex_root="$tmp/codex"
skill_root="$tmp/ce-skill"

CODEX_ROOT="$codex_root" CE_SKILL_ROOT="$skill_root" bash "$repo_root/scripts/install-codex.sh" --apply >/dev/null
CODEX_ROOT="$codex_root" CE_SKILL_ROOT="$skill_root" bash "$repo_root/scripts/check-codex-drift.sh" >/dev/null

runtime="$codex_root/skills/ce-assess-engineering/runtime"
window=(python3 "$runtime/scripts/assessment_window.py" --codex-root "$codex_root")
"${window[@]}" --agent maker-a --repository repo-a setup >/dev/null
"${window[@]}" --agent reviewer-b --repository repo-b setup >/dev/null
"${window[@]}" --agent reviewer-b --repository repo-b readiness >/dev/null

[[ -d "$codex_root/assessment/maker-a/repo-a" && -d "$codex_root/assessment/reviewer-b/repo-b" ]]
[[ ! -e "$codex_root/assessment/maker-a/repo-b" && ! -e "$codex_root/assessment/reviewer-b/repo-a" ]]
for required in \
  "$runtime/scripts/validate-assessment.sh" \
  "$runtime/scripts/assessment_safe_open.py" \
  "$runtime/scripts/assessment_window.py" \
  "$runtime/assessment/schema/run-events-v1.tsv" \
  "$runtime/assessment/schema/run-events-v2.tsv" \
  "$runtime/assessment/schema/capability-matrix-v1.tsv" \
  "$runtime/assessment/schema/validated-summary-v1.tsv" \
  "$runtime/policy/engineering-assessment.md" \
  "$runtime/policy/engineering-lifecycle.md"; do
  [[ -f "$required" && ! -L "$required" ]] || exit 1
done
[[ -x "$runtime/scripts/validate-assessment.sh" && -r "$runtime/scripts/assessment_window.py" ]]
python3 "$runtime/scripts/assessment_window.py" --help >/dev/null

bundle="$tmp/bundle"
mkdir -p "$bundle"
cp -p "$runtime/test-fixtures/valid-codex-run/events.tsv" "$bundle/events.tsv"
summary="$tmp/summary.tsv"
bash "$runtime/scripts/validate-assessment.sh" "$bundle" --summary "$summary" >/dev/null
v2_bundle="$tmp/v2-bundle"
mkdir -p "$v2_bundle"
cp -p "$runtime/test-fixtures/v2-tier2-single/events.tsv" "$v2_bundle/events.tsv"
bash "$runtime/scripts/validate-assessment.sh" "$v2_bundle" >/dev/null
"${window[@]}" --agent maker-a --repository repo-a ingest "$summary" >/dev/null
"${window[@]}" --agent maker-a --repository repo-a report --partial >/dev/null
python3 "$runtime/scripts/assessment_window.py" --codex-root "$codex_root" --agent maker-a --repository repo-a --now 2026-07-25T12:00:00Z if-due >/dev/null

repeat_log="$tmp/repeat-install.log"
CODEX_ROOT="$codex_root" CE_SKILL_ROOT="$skill_root" bash "$repo_root/scripts/install-codex.sh" --apply >"$repeat_log"
! grep -q '^backup:' "$repeat_log"
CODEX_ROOT="$codex_root" CE_SKILL_ROOT="$skill_root" bash "$repo_root/scripts/check-codex-drift.sh" >/dev/null

chmod -x "$runtime/scripts/validate-assessment.sh"
if CODEX_ROOT="$codex_root" CE_SKILL_ROOT="$skill_root" bash "$repo_root/scripts/check-codex-drift.sh" >/dev/null 2>&1; then
  echo "mode drift was not detected" >&2
  exit 1
fi
CODEX_ROOT="$codex_root" CE_SKILL_ROOT="$skill_root" bash "$repo_root/scripts/install-codex.sh" --apply >/dev/null
[[ -x "$runtime/scripts/validate-assessment.sh" ]]

printf '# drift mutation\n' >> "$runtime/policy/engineering-assessment.md"
if CODEX_ROOT="$codex_root" CE_SKILL_ROOT="$skill_root" bash "$repo_root/scripts/check-codex-drift.sh" >/dev/null 2>&1; then
  echo "drift mutation was not detected" >&2
  exit 1
fi
echo "Assessment installation, isolation, runtime, idempotence, and drift checks passed"
