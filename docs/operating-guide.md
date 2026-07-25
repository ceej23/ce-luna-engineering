# Operating guide

## What is canonical

Start with [`policy/engineering-lifecycle.md`](../policy/engineering-lifecycle.md) for lifecycle meaning, then consult the relevant adapter under `surfaces/`. The decision record explains why this split exists. The Codex manifest is the complete allowlist for drift and installation.

[`policy/engineering-assessment.md`](../policy/engineering-assessment.md) owns
assessment semantics. Its capability matrix distinguishes enforced, observed,
attested, and unsupported controls per surface. A bundle or report is never a
replacement for Sol acceptance, external-write authorization, or human approval
of a policy change.

## Adopt and update

Review the adapter and copy it into the native project or user configuration using your organization's approved process. For Codex, [`AGENTS.md`](../AGENTS.md) is the complete portable policy source; merge it or the focused `AGENTS.fragment.md` and `config.fragment.toml` deliberately. The installer never replaces complete personal policy or configuration files. Run `scripts/check-codex-drift.sh` for read-only evidence on the complete agent and skill files listed in the manifest. Installation requires an explicit `--apply` and an alternate `CODEX_ROOT` may be used for testing: `CODEX_ROOT=/tmp/codex-test scripts/install-codex.sh --apply`.

When policy changes, update the policy, affected adapters, manifest or scripts, README, and CONTRIBUTING together. Never add credentials, complete personal configuration, machine paths, trust settings, MCP/connectors, caches, histories, or databases. Do not mutate an active home configuration as part of review or CI.

Use `scripts/validate-assessment.sh` on an explicit local bundle path and retain
only its redacted result. `UNVERIFIED` means the deployment cannot establish a
required control; do not convert it into compliance. Exceptions require a
lead-owned, expiring record and retain the underlying result. Periodic
assessment is report-only and any adopted recommendation follows the same
policy-first, cross-surface review path as other lifecycle changes.

The installed assessment skill keeps disposable records under the selected
absolute `CODEX_ROOT`, partitioned by explicit agent and repository identity.
Use its UTC ISO weekly `if-due` check only after Sol accepts substantive
instrumented work. Completed windows need 20 summaries, retain at most 13
closed windows, and routine signals need two consecutive covered windows;
severe validated failures are immediate candidates. Late summaries go to the
current open week and partial reports are ephemeral. The check is idempotent,
report-only, and never schedules jobs, aggregates identities, edits policy, or
mutates delivery.

Validation has one minimal runtime prerequisite: Python 3 and its standard
library. The validator uses a descriptor-relative, no-follow helper to acquire
the permitted records safely on supported macOS/Linux platforms. If Python 3,
descriptor-relative opens, or the required no-follow primitive is unavailable,
it fails closed as `UNVERIFIED` without reading the bundle; no third-party
package or Bash-only guarantee is assumed.

## Drift semantics

The checker compares only complete manifest targets and exits non-zero for missing or different files. Fragments are reviewed manually because replacing a full `AGENTS.md` or `config.toml` would discard unrelated policy and machine settings. The installer is inert without `--apply`, writes only manifest targets, rejects unsafe target roots and paths, and backs up differing existing files before overwriting them.
