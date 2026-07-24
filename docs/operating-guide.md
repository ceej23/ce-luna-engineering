# Operating guide

## What is canonical

Start with [`policy/engineering-lifecycle.md`](../policy/engineering-lifecycle.md) for lifecycle meaning, then consult the relevant adapter under `surfaces/`. The decision record explains why this split exists. The Codex manifest is the complete allowlist for drift and installation.

## Adopt and update

Review the adapter and copy it into the native project or user configuration using your organization's approved process. For Codex, [`AGENTS.md`](../AGENTS.md) is the complete portable policy source; merge it or the focused `AGENTS.fragment.md` and `config.fragment.toml` deliberately. The installer never replaces complete personal policy or configuration files. Run `scripts/check-codex-drift.sh` for read-only evidence on the complete agent and skill files listed in the manifest. Installation requires an explicit `--apply` and an alternate `CODEX_ROOT` may be used for testing: `CODEX_ROOT=/tmp/codex-test scripts/install-codex.sh --apply`.

When policy changes, update the policy, affected adapters, manifest or scripts, README, and CONTRIBUTING together. Never add credentials, complete personal configuration, machine paths, trust settings, MCP/connectors, caches, histories, or databases. Do not mutate an active home configuration as part of review or CI.

## Drift semantics

The checker compares only complete manifest targets and exits non-zero for missing or different files. Fragments are reviewed manually because replacing a full `AGENTS.md` or `config.toml` would discard unrelated policy and machine settings. The installer is inert without `--apply`, writes only manifest targets, rejects unsafe target roots and paths, and backs up differing existing files before overwriting them.
