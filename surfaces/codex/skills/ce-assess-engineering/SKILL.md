---
name: ce-assess-engineering
description: Report-only assessment of sealed CE + Sol/Luna lifecycle evidence.
---

# CE Engineering Assessment

This skill is self-contained after installation. Let `SKILL_ROOT` be the
selected absolute directory containing this file; all runtime paths below are
relative to it. Records and analysis are disposable local state isolated by
the explicit agent and repository identities. Never share or read state across
identities, and never use a source checkout or personal configuration.

## Setup and readiness

```sh
SKILL_ROOT=/absolute/CODEX_ROOT/skills/ce-assess-engineering
RUNTIME="$SKILL_ROOT/runtime"
CODEX_ROOT=/absolute/CODEX_ROOT
AGENT=agent-slug
REPOSITORY=repository-slug
python3 "$RUNTIME/scripts/assessment_window.py" --codex-root "$CODEX_ROOT" --agent "$AGENT" --repository "$REPOSITORY" setup
python3 "$RUNTIME/scripts/assessment_window.py" --codex-root "$CODEX_ROOT" --agent "$AGENT" --repository "$REPOSITORY" readiness
```

Use lowercase hyphenated bounded identifiers. Setup is idempotent and creates
only the local `$CODEX_ROOT/assessment/$AGENT/$REPOSITORY` state.

## Validate and ingest

Validate a sealed bundle and emit a redacted summary into an ephemeral path:

```sh
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
SUMMARY="$TMP_DIR/summary.tsv"
bash "$RUNTIME/scripts/validate-assessment.sh" /absolute/sealed/bundle --summary "$SUMMARY"
python3 "$RUNTIME/scripts/assessment_window.py" --codex-root "$CODEX_ROOT" --agent "$AGENT" --repository "$REPOSITORY" ingest "$SUMMARY"
```

The validator must return `PASS`, `FAIL`, `UNVERIFIED`, or `EXCEPTION`; none is
an acceptance or delivery decision. Partial reporting is on-demand and never
persisted:

```sh
python3 "$RUNTIME/scripts/assessment_window.py" --codex-root "$CODEX_ROOT" --agent "$AGENT" --repository "$REPOSITORY" report --partial
```

## Weekly cadence

Use UTC ISO weeks. The report-only due check is safe to repeat and never edits
policy, proposals, approvals, or delivery state:

```sh
python3 "$RUNTIME/scripts/assessment_window.py" --codex-root "$CODEX_ROOT" --agent "$AGENT" --repository "$REPOSITORY" if-due
```

Completed windows require coverage of at least 20 summaries, retain at most 13
closed windows, and route late summaries to the current open ingestion week.
Routine candidates require two consecutive covered windows; severe validated
`FAIL` candidates are immediate. Approximately 30 runs per week is expected
volume, not a threshold. There is no cross-agent aggregation, scheduler
registration, automatic policy proposal, or state mutation beyond the local
window store.

## Boundaries

Consume only validator-approved summaries. Never read prompts, transcripts,
diffs, source, absolute paths, environment values, credentials, personal
configuration, caches, histories, databases, or connector data. Never modify
bundles, validator results, policy, adapters, manifests, Git state, approvals,
releases, deployments, or production systems. Sol retains acceptance,
exception approval, and all policy decisions.
