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

# CE + Sol/Luna Engineering Policy

This is the portable Codex `AGENTS.md` source for the CE + Sol/Luna lifecycle.
It implements the canonical policy in
[`policy/engineering-lifecycle.md`](policy/engineering-lifecycle.md). Merge
repository-specific domain, security, and command rules alongside it; they may
be stricter but must not weaken these lifecycle or safety requirements.

## Mandatory engineering workflow

All software-repository changes must use `ce-luna-engineering` as the governing
framework. This includes features, bug fixes, refactors, code and test changes,
UI engineering, build or configuration code, and small mechanical
behavior-changing edits. Do not substitute another implementation workflow.

Read-only inspection, explanation, planning, and documentation-only changes may
be handled directly by Sol with proportionate verification. This exception must
not be used for code, test, configuration, or other behavior-changing edits. If
CE or a required role is unavailable, stop before write work and report the
limitation; do not silently fall back to another workflow.

For implementation, Sol owns intent, planning, architecture, security,
integration, synthesis, final verification, and acceptance. Dispatch only the
named `luna_maker` for bounded implementation and `luna_reviewer` for
independent read-only review. Sol integrates a stable baseline before review,
verifies findings, performs the required CE quality tail, and decides
completion.

Before the first maker or reviewer dispatch, read the CE skill's worker-packet
reference and provide complete bounded packets with acceptance criteria, exact
scope, verification commands, prohibited operations, and stop conditions.
Closeout must distinguish requested, configured, and observed maker/reviewer
routes; never claim observed model or effort without host evidence.

Use CE skill names exactly as exposed by the installed plugin. `tdd`,
`codebase-design`, `domain-modeling`, and `improve-codebase-architecture` are
optional quality disciplines within the CE lifecycle, not competing workflows.

Repository-specific instructions may add domain commands and stricter safety
rules. They must not weaken sandbox requirements, parent-owned final
verification, or external-write authorization.
