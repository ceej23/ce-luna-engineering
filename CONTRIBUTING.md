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
- Treat `README.md` as the canonical human guide. The bundled reference at
  `skills/ce-luna-engineering/references/operating-model.md` must contain the
  exact README body after its `<!-- BEGIN CANONICAL README -->` separator.
- Keep `skills/ce-luna-engineering/SKILL.md` and
  `skills/ce-luna-engineering/agents/openai.yaml` synchronized with changes to
  lifecycle behavior, role boundaries, gates, dispatch packets, or invocation
  guidance.
- Run `python -m unittest discover -s tests -p "test_*.py"`,
  `python -m py_compile scripts/validate_skill.py tests/test_validate_skill.py`,
  and `python scripts/validate_skill.py` before submitting a change. The
  validator is dependency-free and checks the exact package manifest, metadata
  schemas, placeholders, and canonical README and license copies.
- Explain the motivation and trade-offs in your pull request. Documentation
  changes should include the exact checks you ran and their results.

This repository is distributed under the MIT License; see [LICENSE](LICENSE)
for the applicable terms.
