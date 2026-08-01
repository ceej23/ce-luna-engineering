# Canonical engineering lifecycle

This repository is the canonical, reviewable source for the CE + Sol/Luna
workflow. This vendor-neutral policy owns lifecycle semantics. Codex Desktop,
Codex CLI, Claude Code, Cursor, and mediated operator integrations are adapters
that must preserve this policy without inventing stronger or weaker universal
gates.

The normal engagement is direct:

```text
User -> engineering Sol -> optional lane-selected Luna maker/reviewer
```

Codex Desktop and Codex CLI use this direct topology. A mediated infrastructure
operator is a distinct composition described under **Mediated authority**; it
does not replace the direct default.

## Proportional routing

Sol classifies work before execution and selects the smallest lane that contains
the risk:

| Lane | Qualifies when | Default execution | Default budget |
| --- | --- | --- | --- |
| **Tier 0: Observe** | No target mutation | Sol only; focused evidence; no maker or reviewer | 15 minutes; 1 total agent |
| **Tier 1: Small** | Localized, reversible, known solution with no cross-cutting or control-bearing decision; an explicitly requested browser-local or single-user artifact replacement may qualify when bounded and unrelated state is preserved | Sol or one bounded maker; focused verification; review only on a named trigger | 30 minutes; 2 total agents |
| **Tier 2: Standard** | Ordinary mutation that is neither Small nor High-risk | One maker, one independent reviewer, one remediation/re-review allowance, and one broad Sol check | 60 minutes; 3 total agents |
| **Tier 3: High-risk** | Architecture, public API or schema, migration, dependency, security, credentials, privacy-sensitive data, production, external writes, or irreversible effects | Full role boundaries; focused specialists only for a named risk | Explicit task budget; 3 total agents before justified escalation |

Tier 3 always wins. A Tier 1 review trigger includes a user request, unexpected
scope or ambiguity, a security or privacy-sensitive path, public interface,
schema, migration or dependency implications, inadequate test evidence, or a
risk Sol promotes. Promote the lane before continuing when necessary.

Tier 0 and Sol-only Tier 1 work may classify inline without a formal routing
declaration. Before delegation or any Tier 2 or Tier 3 mutation, publish:

`Lane: [selected lane] | Budget: [time/cost limit] | Agents: [topology]`

Tier 0 and Tier 1 may be Sol-only. The complete lifecycle remains:

`Frame -> Plan -> Make -> Integrate -> Review -> Synthesize -> Compound`

An explicitly requested browser-local or single-user artifact replacement is
still Tier 1 only when the target is bounded, reversible, and unrelated state
is preserved. For a one-file local artifact, do not fan out specialist review:
use one focused validation and stop. Promote the lane if the artifact crosses
users, systems, security boundaries, or external state.

Collapse phases that do not add proportionate evidence. Tier 2 uses the complete
path within its limits. Tier 3 adds only risk-justified specialists within its
explicit budget. Architecture review, UX review, TDD, domain modelling, Matt
Pocock practices, simplification, code review, and other specialist practices
are selected-lane or named-risk lenses, never mandatory nested workflows.

## Role invariants

- **Sol** owns intent, classification, planning decisions, architecture,
  security, integration, synthesis, verification, and engineering acceptance.
- **Luna maker** implements one bounded unit with exact file ownership,
  observable criteria, exact checks, prohibited operations, and stop
  conditions.
- **Luna reviewer** independently inspects a stable target read-only when the
  selected lane requires it. The reviewer must not author, edit, or accept the
  work and returns either evidence-backed findings or `no findings`.
- **Compound Engineering** supplies planning and quality practices. It does not
  override Sol, silently broaden authorization, or create another lifecycle.

Unexpected scope, an unresolved requirement, or a control-bearing decision
stops a worker and returns the decision to Sol. A maker or reviewer must not own
architecture, public API or schema, migration, dependencies, security,
credentials, Git, release, deployment, production, product decisions, policy,
or final acceptance.

## Review and stopping rules

- Review only when the selected lane or a named trigger requires it.
- Review begins from a stable target. A changed target invalidates the completed
  review evidence for affected axes.
- A transient reviewer infrastructure failure permits at most one retry against
  the same unchanged target. This is not a remediation re-review.
- When confirmed remediation changes the target, perform at most one focused
  independent re-review of the affected axes unless the lane is explicitly
  escalated.
- P0 and P1 findings block by default.
- Any finding that violates an explicit acceptance criterion, safety or
  security policy, authorization boundary, or rollout prerequisite blocks
  regardless of its numeric severity.
- Other P2 and P3 findings may be deliberately deferred.
- Run focused implementation checks and at most one broad Sol-owned check after
  integration by default.
- If a maker or reviewer produces no material file, test, finding, or blocker
  after roughly 10 minutes, return a progress checkpoint to Sol. Tier 2 should
  checkpoint around 30 minutes and stop for reassessment at its 60-minute
  budget rather than silently looping. A review is normally bounded to 15–20
  minutes and returns partial findings or a blocker if it cannot finish.
- For frontend or browser verification, use one canonical local HTTP preview
  rooted at the resolved target. After two failed attempts with that preview or
  tool path, switch approach or report the verification gap and stop.
- Stop when required checks pass and no blocker remains. Suggestions do not
  reopen the lifecycle.
- After acceptance, allow at most three minutes to reassess a newly discovered
  issue. If it is a new outcome or material scope expansion, stop, preserve the
  accepted target, and start a fresh task rather than churning in the old root.
- Stop at the declared time, cost, retry, agent, or verification budget and
  report progress, evidence, and remaining risk rather than silently escalating.

## Authority states

Tool access and execution modes provide capability, not authority. `--yolo`,
an unsandboxed process, or equivalent tool access does not authorize any
external action.

Track these authority states separately:

1. inspect;
2. design;
3. implement;
4. review;
5. commit;
6. push or open a pull request;
7. release;
8. deploy or roll back;
9. access credentials;
10. act on production or live services.

Authority for one state does not imply another. Commits, pushes, pull requests,
releases, deployments, production actions, service lifecycle changes,
credential access, and other external writes require explicit authorization
from the user or an authorized controller. Implementation or review
authorization never implies delivery authorization.

## Mediated authority

Some engagements place an operational controller between the user and the
repository engineering agent:

```text
User
  -> operational controller
  -> one repository-engineering Sol
       -> optional lane-selected Luna maker/reviewer
  -> operational controller for deployment, rollback and live acceptance
```

This is a composition of two authority domains, not one CE lifecycle wrapped
around another. The operational controller must not create a duplicate
maker/reviewer panel for the same repository outcome.

The operational controller owns the user's operational intent, current-state
inspection, live-risk classification, approval capture, production controls
and credentials, service lifecycle actions, deployment, rollback, live health
verification, and operational acceptance.

The engineering Sol owns repository framing within the bounded request,
repository lane selection, technical design and architecture, optional internal
maker/reviewer routing, integration, engineering verification, engineering
acceptance, and an operator-ready return contract. Sol may refine technical
criteria but must stop rather than reinterpret ambiguous product or operational
intent.

The outer operational lane and inner repository lane are classified
independently. A production deployment can remain operational Tier 3 while an
isolated repository edit is Tier 1. A repository security, architecture,
migration, schema, dependency, credential, or other Tier 3 trigger still makes
the inner engineering work Tier 3.

The controller's packet to engineering Sol records:

- the immutable repository outcome and available evidence;
- repository, worktree, allowed reads, and exact write scope;
- prohibited production, credential, network, SSH, deployment, and service
  operations;
- each authority state that is granted or withheld;
- observable engineering acceptance criteria and verification expectations;
- stop conditions, remaining budget, and the return contract.

Nested engineering agents must not SSH back into the operator's host, deploy,
control services, access production credentials or state, or perform live
verification. Engineering returns changed files or diff scope, checks, review
result, residual risks, rollback-relevant notes, delivery state, and explicit
operator steps. The operational controller then performs only separately
authorized deployment-specific and live verification and makes operational
acceptance.

## Canonical state and adapters

Git-tracked policy and adapter files are canonical. Installed files under a
user's home directory are deployments and may be checked for drift. Local
settings, credentials, caches, histories, databases, trust settings,
connectors, and personal preferences are not canonical and must never be copied
by this project.

Surface adapters may express native syntax and capabilities, but may not claim
unsupported routing, sandbox, model, approval, or authorization guarantees.
Change lifecycle meaning here first, then update every affected adapter,
distributable skill, manifest-managed skill, guide, and contract test.

Assessment semantics, evidence privacy, capability declarations, and
conformance outcomes are owned by
[`engineering-assessment.md`](engineering-assessment.md). Assessment results
are evidence for Sol; they do not grant acceptance, authorization, release,
deployment, or policy-change authority.
