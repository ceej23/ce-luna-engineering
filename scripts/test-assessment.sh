#!/usr/bin/env bash
set -u
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd); v="$root/scripts/validate-assessment.sh"; failures=0
run() { label=$1; expected=$2; dir=$3; out=$(bash "$v" "$dir" 2>/dev/null); rc=$?; [[ "$out" == *"RESULT $expected"* && ( "$expected" == PASS && $rc -eq 0 || "$expected" != PASS && $rc -ne 0 ) ]] || { echo "FAIL $label"; failures=$((failures+1)); return; }; echo "ok $label"; }
run valid PASS "$root/assessment/fixtures/valid-codex-run"
run cursor UNVERIFIED "$root/assessment/fixtures/unsupported-cursor-control"
run sensitive UNVERIFIED "$root/assessment/fixtures/invalid-sensitive-field"
run integrity UNVERIFIED "$root/assessment/fixtures/invalid-integrity"
run exception EXCEPTION "$root/assessment/fixtures/approved-exception"
run unknown-adapter UNVERIFIED "$root/assessment/fixtures/unknown-codex-adapter"
run maker-as-reviewer UNVERIFIED "$root/assessment/fixtures/maker-as-reviewer"
tmp=$(mktemp -d "$root/.assessment-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
cp -R "$root/assessment/fixtures/approved-exception" "$tmp/malformed-expiry"
sed 's/2099-12-31/2024-02-30/' "$tmp/malformed-expiry/exception.tsv" > "$tmp/malformed-expiry/exception.new"
mv "$tmp/malformed-expiry/exception.new" "$tmp/malformed-expiry/exception.tsv"
run malformed-expiry UNVERIFIED "$tmp/malformed-expiry"
cp -R "$root/assessment/fixtures/approved-exception" "$tmp/exception-extra-column"
sed '2s/$/\textra/' "$tmp/exception-extra-column/exception.tsv" > "$tmp/exception-extra-column/exception.new"
mv "$tmp/exception-extra-column/exception.new" "$tmp/exception-extra-column/exception.tsv"
run exception-extra-column UNVERIFIED "$tmp/exception-extra-column"
cp -R "$root/assessment/fixtures/approved-exception" "$tmp/exception-plus-failure"
sed $'3s/\tpass\t/\tfail\t/' "$tmp/exception-plus-failure/events.tsv" > "$tmp/exception-plus-failure/events.new"
mv "$tmp/exception-plus-failure/events.new" "$tmp/exception-plus-failure/events.tsv"
run exception-plus-failure FAIL "$tmp/exception-plus-failure"
cp -R "$root/assessment/fixtures/approved-exception" "$tmp/exception-sensitive-field"
sed 's/bounded-test-waiver/prompt-redaction/' "$tmp/exception-sensitive-field/exception.tsv" > "$tmp/exception-sensitive-field/exception.new"
mv "$tmp/exception-sensitive-field/exception.new" "$tmp/exception-sensitive-field/exception.tsv"
run exception-sensitive-field UNVERIFIED "$tmp/exception-sensitive-field"
cp -R "$root/assessment/fixtures/unsupported-cursor-control" "$tmp/fail-before-unsupported"
sed $'3s/\tpass\t/\tfail\t/' "$tmp/fail-before-unsupported/events.tsv" > "$tmp/fail-before-unsupported/events.new"
mv "$tmp/fail-before-unsupported/events.new" "$tmp/fail-before-unsupported/events.tsv"
run fail-before-unsupported FAIL "$tmp/fail-before-unsupported"
cp -R "$root/assessment/fixtures/valid-codex-run" "$tmp/partial-reviewer"
sed $'5s/\tluna-reviewer\tluna-reviewer\tluna-reviewer\t/\tluna-reviewer\trogue-reviewer\tluna-reviewer\t/' "$tmp/partial-reviewer/events.tsv" > "$tmp/partial-reviewer/events.new"
mv "$tmp/partial-reviewer/events.new" "$tmp/partial-reviewer/events.tsv"
run partial-reviewer UNVERIFIED "$tmp/partial-reviewer"
mkdir "$tmp/real"
ln -s "$tmp/real" "$tmp/link"
cp -R "$root/assessment/fixtures/valid-codex-run" "$tmp/real/valid"
run symlink-parent UNVERIFIED "$tmp/link/valid"
summary_check() {
  label=$1; expected=$2; expected_reason=$3; expected_severity=$4; fixture=$5; target=$6
  out=$(bash "$v" "$fixture" --summary "$target" 2>/dev/null); rc=$?
  [[ "$out" == *"RESULT $expected"* && -f "$target" ]] || { echo "FAIL summary-$label"; failures=$((failures+1)); return; }
  summary_result=$(printf '%s' "$expected" | tr '[:upper:]' '[:lower:]')
  fields=$(awk -F '\t' -v r="$summary_result" -v reason="$expected_reason" -v severity="$expected_severity" 'NR == 1 { print NF; ok=($1=="validated-summary/v1" && $9==r && $10==reason && $11==severity) } END { exit !ok }' "$target")
  [[ "$fields" == 12 ]] || { echo "FAIL summary-$label-fields"; failures=$((failures+1)); return; }
  echo "ok summary-$label"
}
mkdir "$tmp/summary"
summary_check pass PASS conformant info "$root/assessment/fixtures/valid-codex-run" "$tmp/summary/pass.tsv"
summary_check unverified UNVERIFIED control-unverified warning "$root/assessment/fixtures/maker-as-reviewer" "$tmp/summary/unverified.tsv"
summary_check exception EXCEPTION approved-exception warning "$root/assessment/fixtures/approved-exception" "$tmp/summary/exception.tsv"
summary_check fail FAIL control-failure info "$tmp/exception-plus-failure" "$tmp/summary/fail.tsv"
cp -R "$root/assessment/fixtures/valid-codex-run" "$tmp/unauthorized-delivery"
sed $'6s/\tpass\t/\tfail\t/' "$tmp/unauthorized-delivery/events.tsv" > "$tmp/unauthorized-delivery/events.new"
mv "$tmp/unauthorized-delivery/events.new" "$tmp/unauthorized-delivery/events.tsv"
summary_check severe-fail FAIL 'control-failure;unauthorized-delivery' severe "$tmp/unauthorized-delivery" "$tmp/summary/severe-fail.tsv"
summary_check pass-second PASS conformant info "$root/assessment/fixtures/valid-codex-run" "$tmp/summary/pass-second.tsv"
id_one=$(awk -F '\t' 'NR == 1 { print $2 }' "$tmp/summary/pass.tsv")
id_two=$(awk -F '\t' 'NR == 1 { print $2 }' "$tmp/summary/pass-second.tsv")
[[ "$id_one" == "$id_two" ]] || { echo "FAIL summary-stable-id"; failures=$((failures+1)); }
[[ "$id_one" =~ ^sha256:[a-f0-9]{64}$ ]] || { echo "FAIL summary-id-format"; failures=$((failures+1)); }
before=$(cksum "$tmp/summary/pass.tsv")
bash "$v" "$root/assessment/fixtures/valid-codex-run" --summary "$tmp/summary/pass.tsv" >/dev/null 2>&1; rc=$?
[[ $rc -ne 0 && "$(cksum "$tmp/summary/pass.tsv")" == "$before" ]] || { echo "FAIL summary-collision"; failures=$((failures+1)); }
[[ ! -e "$tmp/summary/missing.tsv" ]] || { echo "FAIL summary-malformed-preexisting"; failures=$((failures+1)); }
bash "$v" "$root/assessment/fixtures/invalid-sensitive-field" --summary "$tmp/summary/missing.tsv" >/dev/null 2>&1; rc=$?
[[ $rc -ne 0 && ! -e "$tmp/summary/missing.tsv" ]] || { echo "FAIL summary-malformed"; failures=$((failures+1)); }
mkdir "$tmp/summary-real"
ln -s "$tmp/summary-real" "$tmp/summary-link"
bash "$v" "$root/assessment/fixtures/valid-codex-run" --summary "$tmp/summary-link/rejected.tsv" >/dev/null 2>&1; rc=$?
[[ $rc -ne 0 && ! -e "$tmp/summary-real/rejected.tsv" ]] || { echo "FAIL summary-symlink-parent"; failures=$((failures+1)); }
ln -s "$tmp/summary/pass.tsv" "$tmp/summary/symlink-target.tsv"
bash "$v" "$root/assessment/fixtures/valid-codex-run" --summary "$tmp/summary/symlink-target.tsv" >/dev/null 2>&1; rc=$?
[[ $rc -ne 0 ]] || { echo "FAIL summary-symlink-target"; failures=$((failures+1)); }
[[ -z "$(find "$tmp/summary" -name '.validated-summary.*' -print -quit)" ]] || { echo "FAIL summary-temp-cleanup"; failures=$((failures+1)); }
(( failures == 0 ))
