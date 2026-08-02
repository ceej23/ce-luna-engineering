# Repository instructions

This repository publishes the CE + Sol/Luna operating model and its installable
Codex skill.

- Treat `policy/engineering-lifecycle.md` as the canonical lifecycle authority
  and `README.md` as its human guide. Preserve proportional routing, Sol
  accountability, bounded Luna roles when selected, independent review when
  required, evidence, and authorization boundaries.
- Distribute the installable skill only from
  `skills/ce-luna-engineering/`.
- Keep the skill instructions, `agents/openai.yaml`, and
  `references/operating-model.md` synchronized with the README whenever
  lifecycle behavior, role ownership, gates, or packet requirements change.
- Preserve `<!-- BEGIN CANONICAL README -->` in the bundled reference and keep
  everything after it byte-equivalent to `README.md` after newline
  normalization.
- Run `python -m unittest discover -s tests -p "test_*.py"`,
  `python -m py_compile scripts/validate_skill.py tests/test_validate_skill.py tests/test_policy_contract.py`,
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

## Proportional engineering workflow

Use `ce-luna-engineering` as the governing framework for software-repository
work. Sol classifies the request before execution. Tier 0 and Sol-only Tier 1
may classify inline without a formal routing declaration; before delegation or
any Tier 2 or Tier 3 mutation, Sol publishes a lane, budget, and agent topology:

- **Tier 0: Observe:** no mutation; Sol only.
- **Tier 1: Small:** localized and reversible; explicitly requested
  browser-local or single-user artifact replacements qualify when bounded and
  unrelated state is preserved; Sol or one bounded maker;
  review only on a named trigger.
- **Tier 2: Standard:** one or more bounded makers, at least one independent
  integrated reviewer, one remediation/re-review allowance, and one broad Sol
  check.
- **Tier 3: High-risk:** architecture, public interface or schema, migration,
  dependency, security, credentials, privacy, production, external writes, or
  irreversible effects; use one or more bounded makers, at least one
  independent integrated reviewer, and only focused, risk-justified
  specialists.

Tier 3 always wins. Tier 0 and Tier 1 may be Sol-only. For Tier 2/3, publish
`Lane | Budget | Agents | Units` and include Sol, one or more bounded makers,
and one independent integrated reviewer before the first write. Use multiple
makers for genuinely independent, non-overlapping units; otherwise use one.
Record unit IDs and owned paths, adding dependency/order only when needed. Sol
integrates all units before review; unavailable mandatory capacity stops
mutation unless facts justify reclassification.

Sol owns intent, classification, planning, architecture, security, integration,
synthesis, verification, and engineering acceptance. Whenever Luna is used,
read the worker-packet reference and provide exact scope, observable acceptance
criteria, verification commands, prohibited operations, stop conditions, and a
return contract. Required review is independent, stable-target, and read-only.

Use CE skill names exactly as exposed by the installed plugin. Architecture
review, `tdd`, `codebase-design`, `domain-modeling`,
`improve-codebase-architecture`, simplification, code review, and other
specialist practices are selected-lane or named-risk lenses, not mandatory
nested workflows or universal quality tails.

One transient reviewer infrastructure failure may be retried once against the
same unchanged target. Remediation that changes the target instead permits one
focused independent re-review of affected axes. P0/P1 findings block by
default; any acceptance, safety, policy, authorization, or rollout violation
blocks regardless of numeric severity. Other P2/P3 findings may be deferred.

Workers return a progress checkpoint after roughly 10 minutes without a
material file, test, finding, or blocker. Tier 2 checkpoints around 30 minutes
and stops for reassessment at its 60-minute budget rather than silently
looping. Review is normally bounded to 15–20 minutes and returns partial
findings or a blocker if it cannot finish. Frontend/browser verification uses
one canonical local HTTP preview rooted at the resolved target; after two
failed attempts with that preview or tool path, switch approach or report the
verification gap and stop.

For a one-file browser-local or single-user artifact, do not fan out specialist
review; use one focused validation and stop. After acceptance, allow at most
three minutes to reassess a new issue. Material scope expansion is a fresh task;
preserve the accepted target instead of churning in the old root.

The direct user-to-Sol topology is the default for Codex Desktop and CLI.
Mediated infrastructure engagements use one operational controller and one
repository-engineering Sol, with optional Luna roles internal to the latter.
The controller retains live approval, credentials, service control, deployment,
rollback, live verification, and operational acceptance. Nested engineering
agents must not SSH, deploy, control services, access production credentials or
state, or live-verify through the operator environment.

Repository-specific instructions may add domain commands and stricter safety
rules. They must not weaken parent-owned final verification or external-write
authorization. Tool capability, including `--yolo`, is not authority. Track
inspect, design, implementation, review, commit, push or pull request, release,
deployment or rollback, credentials, and production authorization separately.
