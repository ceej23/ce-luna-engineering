# Contributing

Contributions to this guide should make the operating model clearer, safer, or
more reusable for engineering teams.

- Keep examples host-neutral and free of private paths, credentials, customer
  information, and unverified implementation claims.
- Preserve the Sol lead, Luna maker, and independent reviewer boundaries unless
  a change explicitly explains the new contract.
- Prefer concise Markdown, small focused edits, and observable guidance.
- Update the lifecycle, role table, or worker packet when changing a related
  rule so the guide remains internally consistent.
- Explain the motivation and trade-offs in your pull request. Documentation
  changes should include any checks you ran (for example, Markdown rendering or
  link checks).

## Cross-surface workflow changes

Treat `policy/engineering-lifecycle.md` as the authority for shared behavior.
When changing it, update affected Codex, Claude Code, and Cursor adapters plus
the operating guide and README. Keep the Codex manifest explicit and fragments
safe: never add credentials, MCP/connectors, machine paths, trust settings,
caches, histories, databases, or complete personal configuration.

Before proposing a change, run `bash -n scripts/check-codex-drift.sh`,
`bash -n scripts/install-codex.sh`, and temporary-root drift/install smoke tests.
The checker is read-only; installation requires `--apply` and should be tested
with `CODEX_ROOT` rather than an active home configuration. Drift or scope
changes should be explained in the contribution.

This repository is distributed under the MIT License; see [LICENSE](LICENSE)
for the applicable terms.
