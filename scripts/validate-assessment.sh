#!/usr/bin/env bash
set -u

bad() { printf 'RESULT %s\n' "$1"; exit 1; }
bundle=${1:-}
summary_path=''
if [[ "${2:-}" == --summary && -n "${3:-}" && -z "${4:-}" ]]; then summary_path=$3; elif [[ -n "${2:-}" ]]; then bad UNVERIFIED; fi
[[ -n "$bundle" && "$bundle" != / && "$bundle" != */ && "$bundle" != *//* && "$bundle" != *'/./'* && "$bundle" != *'/../'* ]] || bad UNVERIFIED
helper=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/assessment_safe_open.py
command -v python3 >/dev/null 2>&1 || bad UNVERIFIED
events_data=$(python3 "$helper" "$bundle" events) || bad UNVERIFIED
exception_data=$(python3 "$helper" "$bundle" exception 2>/dev/null)
exception_rc=$?
if [[ $exception_rc -eq 0 ]]; then exception_file=present
elif [[ $exception_rc -eq 2 ]]; then exception_file=''
else bad UNVERIFIED
fi
while IFS= read -r bundle_item; do
  [[ ! -L "$bundle_item" ]] || bad UNVERIFIED
  case "$bundle_item" in "$bundle/events.tsv"|"$bundle/exception.tsv") ;; *) bad UNVERIFIED ;; esac
done < <(find "$bundle" -mindepth 1 -print)
repo_root=$(cd -- "$(dirname -- "$0")/.." && pwd)
schema="$repo_root/assessment/schema/run-events-v1.tsv"
matrix="$repo_root/assessment/schema/capability-matrix-v1.tsv"
policy="$repo_root/policy/engineering-assessment.md"
expected_header=$(awk -F '\t' 'NR>1 { printf "%s%s", (NR==2?"":"\t"), $1 }' "$schema")
header=$(printf '%s\n' "$events_data" | head -n1); [[ "$header" == "$expected_header" || "$header" == "$(awk -F '\t' 'NR>1 { printf "%s%s", (NR==2?"":"\t"), $1 }' "$repo_root/assessment/schema/run-events-v2.tsv")" ]] || bad UNVERIFIED
v2_schema="$repo_root/assessment/schema/run-events-v2.tsv"
v2_header=$(awk -F '\t' 'NR>1 { printf "%s%s", (NR==2?"":"\t"), $1 }' "$v2_schema")
v2_reason=''
if [[ "$header" == "$v2_header" ]]; then
  v2_result=$(python3 - "$bundle" "$events_data" "$policy" "$matrix" "$repo_root" <<'PY'
import csv, hashlib, io, os, re, sys
bundle, raw, policy, matrix_path, repo_root = sys.argv[1:]
def unverified(): print("UNVERIFIED\ttopology-evidence-missing"); raise SystemExit(0)
SENSITIVE = re.compile(r"prompt|transcript|diff|source|credential|password|environment", re.I)
def identifier(v): return bool(re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", v))
def bounded(v): return v == "unknown" or identifier(v)
def private(v): return ".." not in v and not SENSITIVE.search(v)
def path(v):
    if v == "unknown" or not v or v.startswith("/") or v.startswith("~") or ".." in v or "*" in v or "?" in v or "//" in v: return False
    return bool(re.fullmatch(r"[A-Za-z0-9._-]+(?:/[A-Za-z0-9._-]+)*", v))
try: rows = list(csv.DictReader(io.StringIO(raw), delimiter="\t"))
except Exception: unverified()
if not rows: unverified()
required = set("schema_version run_id event_sequence event_type policy_ref adapter_ref surface control_id capability lane mutation topology unit_id actor_id route_requested route_configured route_observed owned_path decomposition_ref integration_ref reviewer_actor_id artifact_ref result".split())
if set(rows[0]) != required: unverified()
try: policy_digest = hashlib.sha256(open(policy, "rb").read()).hexdigest()
except OSError: unverified()
try:
    with open(matrix_path, encoding="utf-8", newline="") as handle:
        matrix_reader = csv.reader(handle, delimiter="\t")
        matrix_header = next(matrix_reader)
        matrix_header[0] = matrix_header[0].removeprefix("# ")
        matrix_rows = [dict(zip(matrix_header, values)) for values in matrix_reader]
except OSError: unverified()
matrix = {(row["surface"], row["control_id"], row["capability"]) for row in matrix_rows}
adapter_paths = {
    "codex": "surfaces/codex/AGENTS.fragment.md",
    "claude-code": "surfaces/claude-code/CLAUDE.fragment.md",
    "cursor": "surfaces/cursor/engineering-workflow.mdc",
    "ci": ".github/workflows/assessment-conformance.yml",
}
run = rows[0]["run_id"]; prev = 0
lane = rows[0]["lane"]; mutation = rows[0]["mutation"]; topology = rows[0]["topology"]
if not identifier(run) or run == "unknown" or lane not in {"tier-1","tier-2","tier-3"} or mutation not in {"none","target-mutated"} or topology not in {"sol-only","bounded-makers"}: unverified()
units = {}; integrations = {}; reviewers = []; review_seq = None
explicit_fail = False; unsupported = False; phase = "frame"
for row in rows:
    if row["schema_version"] != "assessment-run-events/v2" or row["run_id"] != run or row["policy_ref"] != policy_digest: unverified()
    if any(not private(value) for value in row.values() if value): unverified()
    try: seq = int(row["event_sequence"])
    except ValueError: unverified()
    if seq <= prev or row["lane"] != lane or row["mutation"] != mutation or row["topology"] != topology: unverified()
    prev = seq
    event_type = row["event_type"]
    if event_type not in {"frame","make","integrate","review","synthesize","seal"}: unverified()
    if row["surface"] not in {"codex","claude-code","cursor","ci"} or row["control_id"] not in {"scope","control","independence","evidence","delivery"} or row["capability"] not in {"enforced","observed","attested","unsupported"}: unverified()
    if (row["surface"], row["control_id"], row["capability"]) not in matrix: unverified()
    unsupported = unsupported or row["capability"] == "unsupported"
    try: expected_adapter = hashlib.sha256(open(os.path.join(repo_root, adapter_paths[row["surface"]]), "rb").read()).hexdigest()
    except OSError: unverified()
    if row["adapter_ref"] == "unknown": unverified()
    if row["adapter_ref"] != expected_adapter: unverified()
    for key in ("unit_id","actor_id","route_requested","route_configured","route_observed","decomposition_ref","integration_ref","reviewer_actor_id"):
        if not bounded(row[key]): unverified()
    if row["artifact_ref"] != "unknown" and not bounded(row["artifact_ref"]) and not re.fullmatch(r"sha256:[a-f0-9]{64}", row["artifact_ref"]): unverified()
    if row["owned_path"] != "unknown" and not path(row["owned_path"]): unverified()
    if event_type == "frame":
        if seq != 1 or phase != "frame": unverified()
        if row["actor_id"] != "sol": unverified()
        phase = "make"
    elif event_type == "make":
        if phase != "make": unverified()
        uid, actor, owned = row["unit_id"], row["actor_id"], row["owned_path"]
        if uid == "unknown" or actor == "unknown" or owned == "unknown" or row["decomposition_ref"] == "unknown": unverified()
        if uid in units: unverified()
        units[uid] = (actor, owned, row["decomposition_ref"])
        if row["surface"] == "codex" and any(row[key] != "luna-maker" for key in ("route_requested","route_configured","route_observed")): unverified()
    elif event_type == "integrate":
        if phase not in {"make","integrate"}: unverified()
        phase = "integrate"
        uid, ref = row["unit_id"], row["integration_ref"]
        if uid == "unknown" or ref == "unknown": unverified()
        if ref != "int-" + uid.removeprefix("unit-"): unverified()
        if uid in integrations: unverified()
        integrations[uid] = ref
    elif event_type == "review":
        if phase not in {"integrate","review"}: unverified()
        phase = "review"
        review_seq = seq
        if row["reviewer_actor_id"] == "unknown": unverified()
        reviewers.append(row["reviewer_actor_id"])
        if row["surface"] == "codex" and any(row[key] != "luna-reviewer" for key in ("route_requested","route_configured","route_observed")): unverified()
    elif event_type == "synthesize":
        if phase != "review": unverified()
        if row["actor_id"] != "sol": unverified()
        phase = "synthesize"
    elif event_type == "seal":
        if phase != "synthesize": unverified()
        phase = "seal"
    if row["result"] == "fail": explicit_fail = True
    elif row["result"] not in {"pass","unverified"}: unverified()
if mutation == "none" and units: unverified()
if phase != "seal": unverified()
if lane in {"tier-2","tier-3"} and mutation == "target-mutated":
    if topology == "sol-only" or not units: print("FAIL\trequired-maker-missing"); raise SystemExit(0)
    if not reviewers: print("FAIL\trequired-reviewer-missing"); raise SystemExit(0)
    actors = [v[0] for v in units.values()]
    if "sol" in actors: print("FAIL\trequired-maker-missing"); raise SystemExit(0)
    if any(r in actors for r in reviewers): print("FAIL\treviewer-not-independent"); raise SystemExit(0)
    paths = [(uid, v[1]) for uid,v in units.items()]
    for i, (u1,p1) in enumerate(paths):
        a = p1.split('/')
        for u2,p2 in paths[i+1:]:
            b = p2.split('/')
            if a == b or a == b[:len(a)] or b == a[:len(b)]: print("FAIL\townership-overlap"); raise SystemExit(0)
    if set(units) != set(integrations) or (review_seq is not None and any(int(r["event_sequence"]) >= review_seq for r in rows if r["event_type"] == "integrate")): unverified()
if explicit_fail: print("FAIL\tcontrol-failure")
elif unsupported: print("UNVERIFIED\tcapability-unsupported")
else: print("PASS\tconformant")
PY
  ) || bad UNVERIFIED
  IFS=$'\t' read -r outcome v2_reason <<< "$v2_result"
  case "$outcome" in PASS|FAIL|UNVERIFIED) ;; *) bad UNVERIFIED;; esac
  [[ -z "$exception_file" ]] || bad UNVERIFIED
  run=$(printf '%s\n' "$events_data" | awk -F '\t' 'NR == 2 { print $2 }')
  pref=$(printf '%s\n' "$events_data" | awk -F '\t' 'NR == 2 { print $5 }')
  run_surface=$(printf '%s\n' "$events_data" | awk -F '\t' 'NR == 2 { print $7 }')
  review_obs=$(printf '%s\n' "$events_data" | awk -F '\t' '$4 == "review" { print $17; exit }')
  unauthorized_delivery=0
fi
if [[ "$header" != "$v2_header" ]]; then
if command -v shasum >/dev/null 2>&1; then
  policy_digest=$(shasum -a 256 "$policy" | awk '{print $1}')
elif command -v sha256sum >/dev/null 2>&1; then
  policy_digest=$(sha256sum "$policy" | awk '{print $1}')
else
  bad UNVERIFIED
fi
[[ ${#policy_digest} -eq 64 ]] || bad UNVERIFIED
adapter_digest() {
  local surface=$1 adapter_path
  case "$surface" in
    codex) adapter_path="$repo_root/surfaces/codex/AGENTS.fragment.md" ;;
    claude-code) adapter_path="$repo_root/surfaces/claude-code/CLAUDE.fragment.md" ;;
    cursor) adapter_path="$repo_root/surfaces/cursor/engineering-workflow.mdc" ;;
    ci) adapter_path="$repo_root/.github/workflows/assessment-conformance.yml" ;;
    *) return 1 ;;
  esac
  [[ -f "$adapter_path" && ! -L "$adapter_path" ]] || return 1
  if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$adapter_path" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then sha256sum "$adapter_path" | awk '{print $1}'
  else return 1; fi
}
private_field_valid() {
  local value=$1
  [[ "$value" != /* && "$value" != '~/'* && "$value" != *'..'* && "$value" != *$'\n'* ]] || return 1
  [[ ! "$value" =~ [Pp][Rr][Oo][Mm][Pp][Tt]|[Tt][Rr][Aa][Nn][Ss][Cc][Rr][Ii][Pp][Tt]|[Dd][Ii][Ff][Ff]|[Ss][Oo][Uu][Rr][Cc][Ee]|[Cc][Rr][Ee][Dd][Ee][Nn][Tt][Ii][Aa][Ll]|[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]|[Ee][Nn][Vv][Ii][Rr][Oo][Nn][Mm][Ee][Nn][Tt] ]]
}
seq_prev=0; event_count=0; run=''; pref=''; run_surface=''; outcome=PASS; exception_seen=0; exception_control=''; exception_result=''; unexcepted_failure=0; unauthorized_delivery=0
order=(frame make integrate review synthesize seal)
control_order=(scope control evidence independence delivery evidence)
maker_req=''; maker_cfg=''; maker_obs=''; review_req=''; review_cfg=''; review_obs=''
while IFS='|' read -r schema_v run_id seq type policy_ref adapter surface control capability route_req route_cfg route_obs artifact result exception sentinel; do
  ((event_count++)); [[ "$sentinel" == end ]] || bad UNVERIFIED
  [[ "$schema_v" == assessment-run-events/v1 && -n "$run_id" && "$run_id" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ && "$seq" =~ ^[1-9][0-9]*$ ]] || bad UNVERIFIED
  [[ "$policy_ref" == "$policy_digest" && ( "$adapter" == unknown || "$adapter" =~ ^[a-f0-9]{64}$ ) ]] || bad UNVERIFIED
  expected_adapter=$(adapter_digest "$surface") || bad UNVERIFIED
  [[ "$adapter" == "$expected_adapter" ]] || { [[ "$adapter" == unknown ]] || bad UNVERIFIED; outcome=UNVERIFIED; }
  [[ "$surface" =~ ^(codex|claude-code|cursor|ci)$ && "$control" =~ ^(scope|control|independence|evidence|delivery)$ && "$capability" =~ ^(enforced|observed|attested|unsupported)$ ]] || bad UNVERIFIED
  [[ "$type" =~ ^(frame|make|integrate|review|synthesize|seal)$ ]] || bad UNVERIFIED
  (( seq > seq_prev )) || bad UNVERIFIED; seq_prev=$seq
  if [[ -n "$run" && "$run" != "$run_id" ]]; then bad UNVERIFIED; fi
  if [[ -n "$pref" && "$pref" != "$policy_ref" ]]; then bad UNVERIFIED; fi
  run=$run_id; pref=$policy_ref
  run_surface=$surface
  expected_type=${order[$((event_count-1))]:-}; [[ "$type" == "$expected_type" ]] || bad UNVERIFIED
  expected_control=${control_order[$((event_count-1))]:-}; [[ "$control" == "$expected_control" ]] || bad UNVERIFIED
  [[ "$result" =~ ^(pass|fail|unverified)$ ]] || bad UNVERIFIED
  [[ "$exception" != none ]] || exception=''
  if [[ -n "$exception" ]]; then
    [[ "$exception" == exception && -f "$bundle/exception.tsv" && "$result" != pass && $exception_seen -eq 0 ]] || bad UNVERIFIED
    exception_seen=1; exception_control=$control; exception_result=$result
  fi
  for value in "$run_id" "$route_req" "$route_cfg" "$route_obs" "$artifact" "$result"; do
    private_field_valid "$value" || bad UNVERIFIED
  done
  for route in "$route_req" "$route_cfg" "$route_obs"; do [[ "$route" == unknown || "$route" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || bad UNVERIFIED; done
  [[ "$artifact" == unknown || "$artifact" =~ ^sha256:[a-f0-9]{64}$ || "$artifact" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || bad UNVERIFIED
  if [[ "$type" == make ]]; then maker_req=$route_req; maker_cfg=$route_cfg; maker_obs=$route_obs; fi
  if [[ "$type" == review ]]; then review_req=$route_req; review_cfg=$route_cfg; review_obs=$route_obs; fi
  matrix_match=$(awk -F '\t' -v s="$surface" -v c="$control" -v k="$capability" 'NR>1 && $1==s && $2==c && $3==k {print 1}' "$matrix")
  [[ "$matrix_match" == 1 ]] || bad UNVERIFIED
  [[ "$capability" != unsupported ]] || [[ "$outcome" == FAIL ]] || outcome=UNVERIFIED
  if [[ -z "$exception" ]]; then
    [[ "$result" != fail ]] || {
      outcome=FAIL
      unexcepted_failure=1
      [[ "$control" != delivery ]] || unauthorized_delivery=1
    }
    [[ "$result" != unverified ]] || [[ "$outcome" == FAIL ]] || outcome=UNVERIFIED
  fi
done < <(printf '%s\n' "$events_data" | tail -n +2 | tr '\t' '|' | sed 's/$/|end/')
(( event_count == 6 )) || bad UNVERIFIED
if [[ "$run_surface" == codex ]]; then
  [[ "$adapter" != unknown ]] || outcome=UNVERIFIED
  [[ "$maker_req" != unknown && "$maker_cfg" != unknown && "$maker_obs" != unknown ]] || outcome=UNVERIFIED
  [[ "$review_req" != unknown && "$review_cfg" != unknown && "$review_obs" != unknown ]] || outcome=UNVERIFIED
  [[ "$review_req" != "$maker_req" && "$review_cfg" != "$maker_cfg" && "$review_obs" != "$maker_obs" ]] || outcome=UNVERIFIED
  [[ "$review_req" == luna-reviewer && "$review_cfg" == luna-reviewer && "$review_obs" == luna-reviewer && "$review_req" != "$maker_req" && "$review_cfg" != "$maker_cfg" && "$review_obs" != "$maker_obs" ]] || outcome=UNVERIFIED
fi
if [[ -n "$exception_file" ]]; then
  [[ $exception_seen -eq 1 ]] || bad UNVERIFIED
  exhead=$(printf '%s\n' "$exception_data" | head -n1); [[ "$exhead" == $'run\tcontrol\tunderlying_result\tapprover\treason\texpiry\tpolicy_ref' ]] || bad UNVERIFIED
  printf '%s\n' "$exception_data" | awk -F '\t' 'NR == 1 { next } NR == 2 { valid = (NF == 7); next } { valid = 0 } END { exit !(valid && NR == 2) }' || bad UNVERIFIED
  IFS=$'\t' read -r erun econtrol underlying approver reason expiry epolicy < <(printf '%s\n' "$exception_data" | tail -n +2)
  [[ $(printf '%s\n' "$exception_data" | tail -n +2 | wc -l | tr -d ' ') -eq 1 ]] || bad UNVERIFIED
  for value in "$erun" "$econtrol" "$underlying" "$approver" "$reason" "$expiry" "$epolicy"; do
    private_field_valid "$value" || bad UNVERIFIED
  done
  [[ "$erun" == "$run" && "$econtrol" == "$exception_control" && "$econtrol" =~ ^(scope|control|independence|evidence|delivery)$ && "$underlying" == "$exception_result" && "$underlying" =~ ^(fail|unverified)$ && "$approver" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ && "$reason" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ && "$epolicy" == "$pref" && "$epolicy" =~ ^[a-f0-9]{64}$ && "$expiry" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || bad UNVERIFIED
  expiry_epoch=''; expiry_normalized=''
  if expiry_epoch=$(date -j -f %Y-%m-%d "$expiry" +%s 2>/dev/null); then
    expiry_normalized=$(date -j -f %Y-%m-%d "$expiry" +%Y-%m-%d 2>/dev/null) || bad UNVERIFIED
  elif expiry_epoch=$(date -d "$expiry" +%s 2>/dev/null); then
    expiry_normalized=$(date -d "$expiry" +%Y-%m-%d 2>/dev/null) || bad UNVERIFIED
  else
    bad UNVERIFIED
  fi
  [[ "$expiry_normalized" == "$expiry" && "$expiry_epoch" -ge $(date +%s) ]] || bad UNVERIFIED
  [[ $unexcepted_failure -eq 0 && "$outcome" == PASS ]] && outcome=EXCEPTION
fi
if printf '%s\n' "$events_data" | awk -F '\t' 'NR > 1 && $14 == "fail" && $15 != "exception" { found = 1 } END { exit !found }'; then
  outcome=FAIL
fi
fi
if [[ -n "$summary_path" ]]; then
  summary_dir=${summary_path%/*}; [[ "$summary_dir" != "$summary_path" && -n "$summary_dir" ]] || bad UNVERIFIED
  [[ "$summary_path" != *'..'* && "$summary_path" != *//* ]] || bad UNVERIFIED
  case "$summary_path" in *$'\n'*|*$'\t'*) bad UNVERIFIED;; esac
  python3 - "$summary_path" <<'PY' || bad UNVERIFIED
import os, stat, sys
p = sys.argv[1]
parts = p.split('/')
cur = '/' if p.startswith('/') else os.path.abspath('.')
for part in (parts[1:-1] if p.startswith('/') else parts[:-1]):
    if not part or part == '.': raise SystemExit(2)
    cur = os.path.join(cur, part)
    try: st = os.lstat(cur)
    except OSError: raise SystemExit(2)
    if stat.S_ISLNK(st.st_mode) or not stat.S_ISDIR(st.st_mode): raise SystemExit(2)
try: os.lstat(os.path.join(cur, parts[-1]))
except FileNotFoundError: raise SystemExit(0)
except OSError: raise SystemExit(2)
raise SystemExit(2)
PY
  summary_tmp=$(mktemp "$summary_dir/.validated-summary.XXXXXX") || bad UNVERIFIED
  chmod 600 "$summary_tmp" || { rm -f "$summary_tmp"; bad UNVERIFIED; }
  trap 'rm -f "$summary_tmp"' EXIT HUP INT TERM
  reasons=()
  [[ "$outcome" == PASS ]] && reasons+=(conformant)
  [[ "$outcome" == FAIL ]] && reasons+=(control-failure)
  [[ "$outcome" == UNVERIFIED ]] && reasons+=(control-unverified)
  [[ "$outcome" == EXCEPTION ]] && reasons+=(approved-exception)
  [[ -n "$v2_reason" ]] && reasons+=("$v2_reason")
  [[ $unauthorized_delivery -eq 1 ]] && reasons+=(unauthorized-delivery)
  [[ "$run_surface" == codex && "$outcome" == UNVERIFIED && "$review_obs" != luna-reviewer ]] && reasons+=(route-unverified)
  reason_codes=$(printf '%s\n' "${reasons[@]}" | awk 'NF && !seen[$0]++' | paste -sd ';' -)
  [[ -n "$reason_codes" ]] || reason_codes=conformant
  severity=info
  [[ "$outcome" == UNVERIFIED || "$outcome" == EXCEPTION ]] && severity=warning
  [[ $unauthorized_delivery -eq 1 ]] && severity=severe
  validated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ) || bad UNVERIFIED
  summary_adapter=$(printf '%s\n' "$events_data" | awk -F '\t' 'NR == 2 { print $6 }')
  [[ -n "$summary_adapter" ]] || bad UNVERIFIED
  if [[ "$header" == "$v2_header" ]]; then
    control_results=$(printf '%s\n' "$events_data" | awk -F '\t' 'NR > 1 { printf "%s%s:%s", (n++?";":""), $8, $23 }')
    route_facts=$(printf '%s\n' "$events_data" | awk -F '\t' 'NR > 1 { printf "%s%s:%s:%s", (n++?";":""), $15, $16, $17 }')
  else
    control_results=$(printf '%s\n' "$events_data" | awk -F '\t' 'NR > 1 { printf "%s%s:%s", (n++?";":""), $8, $14 }')
    route_facts=$(printf '%s\n' "$events_data" | awk -F '\t' 'NR > 1 { printf "%s%s:%s:%s", (n++?";":""), $10, $11, $12 }')
  fi
  case "$outcome" in
    PASS) summary_result=pass ;;
    FAIL) summary_result=fail ;;
    UNVERIFIED) summary_result=unverified ;;
    EXCEPTION) summary_result=exception ;;
    *) bad UNVERIFIED ;;
  esac
  digest_input=$(printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s' validated-summary/v1 "$run" "$pref" "$summary_adapter" "$run_surface" "$control_results" "$route_facts" "$summary_result" "$reason_codes" "$severity")
  if command -v shasum >/dev/null 2>&1; then summary_id=sha256:$(printf '%s' "$digest_input" | shasum -a 256 | awk '{print $1}'); else summary_id=sha256:$(printf '%s' "$digest_input" | sha256sum | awk '{print $1}'); fi
  printf 'validated-summary/v1\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$summary_id" "$run" "$pref" "$summary_adapter" "$run_surface" "$control_results" "$route_facts" "$summary_result" "$reason_codes" "$severity" "$validated_at" > "$summary_tmp" || bad UNVERIFIED
  python3 - "$summary_tmp" "$summary_path" <<'PY' || bad UNVERIFIED
import os
import sys

temporary, target = sys.argv[1:]
descriptor = os.open(temporary, os.O_RDONLY)
try:
    os.fsync(descriptor)
finally:
    os.close(descriptor)
os.link(temporary, target, follow_symlinks=False)
directory = os.open(os.path.dirname(target), os.O_RDONLY)
try:
    os.fsync(directory)
finally:
    os.close(directory)
PY
  rm -f "$summary_tmp"; trap - EXIT HUP INT TERM
fi
printf 'RESULT %s\n' "$outcome"; [[ "$outcome" == PASS ]] && exit 0 || exit 1
