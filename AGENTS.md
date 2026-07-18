# Repository instructions

This repository publishes the CE + Sol/Luna operating model and its installable
Codex skill.

- Treat `README.md` as the canonical human guide and preserve its Sol lead,
  bounded Luna maker, independent read-only Luna reviewer, evidence, and
  authorization boundaries.
- Distribute the installable skill only from
  `skills/ce-luna-engineering/`.
- Keep the skill instructions, `agents/openai.yaml`, and
  `references/operating-model.md` synchronized with the README whenever
  lifecycle behavior, role ownership, gates, or packet requirements change.
- Preserve `<!-- BEGIN CANONICAL README -->` in the bundled reference and keep
  everything after it byte-equivalent to `README.md` after newline
  normalization.
- Run `python -m unittest discover -s tests -p "test_*.py"`,
  `python -m py_compile scripts/validate_skill.py tests/test_validate_skill.py`,
  and `python scripts/validate_skill.py` for every repository change.
- Do not weaken Sol/Luna role boundaries or imply that implementation or review
  authorizes commits, pushes, pull requests, releases, deployments, production
  actions, or any other external write. Delivery requires separate explicit
  user authorization.

Keep changes focused, dependency-free where practical, and free of credentials,
private paths, customer data, and unverified claims.
