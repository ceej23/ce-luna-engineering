# Contributing

Contributions to this guide should make the operating model clearer, safer, or
more reusable for engineering teams.

- Keep examples host-neutral and free of private paths, credentials, customer
  information, and unverified implementation claims.
- Preserve proportional lane selection, the Sol lead, bounded Luna maker, and
  independent reviewer boundaries when their lane selects them unless a change
  explicitly explains the new contract.
- Prefer concise Markdown, small focused edits, and observable guidance.
- Update the lifecycle, role table, or worker packet when changing a related
  rule so the guide remains internally consistent.
- Treat `README.md` as the canonical human guide. The bundled reference at
  `skills/ce-luna-engineering/references/operating-model.md` must contain the
  exact README body after its `<!-- BEGIN CANONICAL README -->` separator.
- Keep `skills/ce-luna-engineering/SKILL.md` and
  `skills/ce-luna-engineering/agents/openai.yaml` synchronized with changes to
  lifecycle behavior, role boundaries, gates, dispatch packets, or invocation
  guidance.
- Run `python -m unittest discover -s tests -p "test_*.py"`,
  `python -m py_compile scripts/validate_skill.py tests/test_validate_skill.py tests/test_policy_contract.py`,
  and `python scripts/validate_skill.py` before submitting a change. The
  validator is dependency-free and checks the exact package manifest, metadata
  schemas, placeholders, and canonical README and license copies.
- Explain the motivation and trade-offs in your pull request. Documentation
  changes should include the exact checks you ran and their results.

## Cross-surface workflow changes

Treat `policy/engineering-lifecycle.md` as the authority for shared behavior.
When changing it, update affected Codex, Claude Code, and Cursor adapters plus
the operating guide and README. Keep the Codex manifest explicit and fragments
safe: never add credentials, MCP/connectors, machine paths, trust settings,
caches, histories, databases, or complete personal configuration.

Changes to assessment policy also update the evidence schema, capability
matrix, fixtures, adapter checker, and CI guidance. Assessment bundles and
reports are generated artifacts: keep them out of Git and never add prompts,
transcripts, diffs, source, absolute paths, environment values, or personal
runtime data.

Before proposing a change, run `bash -n scripts/check-codex-drift.sh`,
`bash -n scripts/install-codex.sh`, `bash scripts/test-codex-install.sh`, and
temporary-root drift/install smoke tests.
The checker is read-only; installation requires `--apply` and should be tested
with `CODEX_ROOT` rather than an active home configuration. Drift or scope
changes should be explained in the contribution.

Run `bash scripts/test-assessment.sh` and
`bash scripts/check-assessment-adapters.sh` for assessment changes. CI validates
tracked fixtures and adapters only; it must not inspect active home configuration
or upload runtime evidence.

This repository is distributed under the MIT License; see [LICENSE](LICENSE)
for the applicable terms.
