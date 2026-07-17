# CE + Sol/Luna Engineering

CE + Sol/Luna is a practical operating model for software work that needs both
fast implementation and accountable engineering judgment. It combines the
Compound Engineering (CE) lifecycle with a clear separation between a lead
(Sol), an implementation maker (Luna), and an independent reviewer (Luna).

The model is intentionally tool- and vendor-neutral. Adapt the names to your
team if needed; preserve the boundaries and evidence requirements.

## The lifecycle

```text
Frame → Plan → Make → Integrate → Review → Synthesize → Compound
 Sol    Sol+CE   Luna     Sol        Luna       Sol          CE
```

1. **Frame (Sol):** clarify intent, risks, constraints, architecture questions,
   and observable acceptance criteria.
2. **Plan (Sol, using CE):** Sol chooses the smallest coherent plan and owns
   planning decisions. CE supplies planning practices and process; explore
   ambiguity before committing to implementation and keep the plan explicit for
   non-trivial work.
3. **Make (Luna):** implement one bounded unit with exact file ownership and a
   verification command. The maker does not expand the task while implementing.
4. **Integrate (Sol):** inspect scope, reconcile units, and establish a stable
   baseline before review.
5. **Review (Luna):** independently inspect the stable diff in read-only mode.
   Report evidence-backed findings, including severity and remediation
   direction. Do not edit or accept the work.
6. **Synthesize (Sol):** confirm findings, decide what to remediate, run the
   parent-owned verification, and make the acceptance decision.
7. **Compound (CE):** simplify where useful, perform the relevant quality or
   code-review tail, capture durable learning, and carry out separately
   authorized delivery actions.

## Role boundaries

| Role | Owns | Must not own |
| --- | --- | --- |
| **Sol (lead)** | Intent, plan decisions, architecture, security, integration, synthesis, final verification, and acceptance | Delegating ambiguous or control-bearing judgment without resolving it |
| **Luna maker** | A clearly bounded implementation unit, within explicit scope and criteria | Architecture, public API or schema decisions, security, dependencies, credentials, Git, release, deployment, production, or product decisions |
| **Luna reviewer** | Independent read-only review for correctness, regressions, tests, accessibility, UX, performance, and maintainability | Edits, commits, acceptance, release, policy, architecture, or product direction |
| **CE** | Planning practices and process, plus quality practices such as discovery, simplification, review, and learning capture | Making plan decisions for Sol, overriding the Sol/Luna contract, or silently broadening authorization |

The reviewer should not be the author of the change under review. A reviewer
returns **no findings** explicitly when the evidence supports that conclusion.

## Risk gates and verification

The lead owns the gates; a maker or reviewer supplies evidence for them.

- **Scope gate:** every worker has an allowed read scope and exact write scope.
  Unexpected files or requirements stop the unit.
- **Control gate:** architecture, security, policy, credentials, external
  writes, and other control-bearing decisions stay with the lead.
- **Independence gate:** review starts only from a stable baseline and is
  read-only; a changed worktree invalidates the review lane.
- **Evidence gate:** acceptance requires the requested checks to pass (or a
  clearly recorded, lead-owned exception). Prefer focused tests and linting,
  then run the broader verification appropriate to the change.
- **Delivery gate:** commits, pushes, releases, deployments, and production
  actions require explicit authorization and are not implied by implementation
  or review.

## Getting started

1. Define the desired behavior and risks in plain language.
2. Decide whether the work is ambiguous enough to need exploration, or whether
   a short plan is sufficient.
3. Split implementation into independent, bounded units. Give each unit a
   worker packet (template below).
4. Capture the worktree status before dispatching makers. Keep unrelated user
   changes intact.
5. Integrate all maker work and run a stable-baseline verification.
6. Dispatch an independent, read-only reviewer with the diff and criteria.
7. Resolve findings, rerun parent-owned checks, and record the acceptance
   decision. Capture a short learning when it will help future work.

For a tiny change, the lead may use a compact packet instead of a large plan;
the scope, independence, verification, and authorization gates still apply.

## Reusable Luna maker packet

Use this as a checklist and adapt it to the repository. Do not include
conversation history or architecture rationale that the maker does not need.

```markdown
# Luna maker packet

Working directory: /absolute/path/to/worktree
Objective: [observable outcome]
CE plan/unit: [plan reference and unit ID]

Allowed read scope:
- [files or directories]

Exact write scope:
- [files or directories]

Acceptance criteria:
- [observable behavior]
- [observable behavior]

Verification commands:
- [exact command]

Prohibited operations:
- reads or access outside the allowed read scope, and writes outside the exact
  write scope;
- architecture, API, schema, migration, dependency, security, sandbox,
  credential, Git, release, deployment, production, or destructive changes;
- spawning subagents.

Stop conditions:
- ambiguity, unexpected changes, missing tools, failing assumptions, or any
  request to expand scope. Return the decision to Sol.

Return contract:
- files changed;
- verification commands and results;
- blockers;
- residual risks.
```

## Review packet essentials

Give the reviewer a stable review base, target diff, plan/unit identifiers,
acceptance criteria, and the review axes that matter for the change. Require
findings to include severity, file and line or symbol, direct evidence, the
violated criterion, impact, and bounded remediation direction. Explicitly
exclude edits, commits, pushes, acceptance, architecture or security-policy
decisions, and subagent spawning.

## Adapting the model

This is an operating contract, not a prescription for a particular agent
runtime. Teams can change tools, names, or automation while retaining:

- one accountable lead for judgment and acceptance;
- bounded implementation ownership;
- an independent read-only review;
- explicit risk and authorization gates; and
- verification evidence attached to the decision.

## Migrating from a Matt Pocock skills suite

Teams moving from the Matt Pocock skills suite can adopt this model as a
workflow change, not a judgement about any product. Retire the old lifecycle
defaults as defaults, then use the CE lifecycle with Sol accountable for
decisions and Luna makers and reviewers operating within explicit packets.
The capability mapping is intentionally at the practice level:

| Retiring lifecycle/default skill role | CE + Sol/Luna capability |
| --- | --- |
| Planning and task shaping | **Frame → Plan (Sol):** clarify intent, risks, constraints, and acceptance criteria before dispatching work. |
| Implementation and execution | **Make (Luna) → Integrate (Sol):** bounded implementation units, explicit ownership, and a stable baseline. |
| Debugging and diagnosis | **Frame/Plan → Make → Verify:** reproduce the behavior, make the smallest scoped change, and attach evidence to the decision. |
| Review and QA | **Review (independent Luna) → Synthesize (Sol):** read-only findings followed by lead-owned remediation and acceptance. |
| Handoff and delivery | **Compound + delivery gate (Sol):** capture learning and perform separately authorized commits, releases, or deployments. |

Specialist practices such as TDD, codebase design, and domain modeling remain
useful optional quality lenses. Apply them inside the CE lifecycle when the
work benefits from them; they complement the lifecycle rather than becoming a
second competing default.

A safe incremental adoption sequence is:

1. Keep the existing skills available while documenting CE + Sol/Luna as the
   single default workflow for new work.
2. Pilot one bounded change with explicit packets, stable-baseline review, and
   parent-owned verification.
3. Move recurring work to the CE lifecycle, retaining specialist practices as
   opt-in lenses where they add value.
4. Retire the former defaults only after the team has one agreed workflow and
   evidence that the gates and role boundaries are understood.

Avoid enabling two competing default workflows at once: choose CE + Sol/Luna
as the default during the transition, and invoke any legacy or specialist
practice explicitly for a particular unit.

## Adopting the model in AGENTS.md

If you maintain an AGENTS.md file that shapes an active Codex context, add a
small policy such as this one (adapt the wording to your team; it is
tool-agnostic):

```markdown
## Engineering lifecycle

Use Compound Engineering with Sol/Luna as the single default lifecycle:
Sol owns framing, planning, architecture, security, integration, synthesis,
verification, and acceptance; Luna makers implement bounded units; an
independent Luna reviewer performs read-only review. Specialist practices such
as TDD, domain modeling, or codebase design are optional lenses within that
lifecycle, not competing default workflows.
```

Before editing policy, inventory every applicable AGENTS.md in the active
context, from parent/global locations through the repository-local file. Read
the effective instructions and classify each apparent disagreement as either:

- a lifecycle/default-routing conflict (for example, another mandatory
  lifecycle, assigning lead-only decisions to workers, or agent/worker
  directives that autonomously perform external commit/push/deploy writes or
  bypass lead or explicit authorization); lead- or CI-controlled delivery
  rules are compatible and should be preserved; or
- a compatible domain or repository rule (for example, testing and linting
  conventions, domain requirements, or security controls).

Remove or replace only directives in the first category. Preserve unrelated
domain, security, and repository-specific instructions, and never bulk-delete
an entire AGENTS.md. Parent/global guidance and repository-local guidance may
have different precedence in a given tool or runtime; do not assume universal
AGENTS.md semantics. Consult and document the target runtime's precedence rules
and use its effective-context inspection when available. A repository-local
policy may add stricter rules only where that runtime permits it, and never
weakens safety controls or Sol/Luna role boundaries. If the runtime cannot
deterministically inspect precedence and effective instructions, leave any
parent/global conflict explicitly unresolved rather than assuming it was
removed.

After making the edit, inspect the diff and have it reviewed for scope,
precedence, and preserved instructions. Start a fresh Codex session so the
effective context is reloaded. Where the runtime supports effective-context
inspection, verify that the intended lifecycle is the only default and that
unrelated rules remain active; otherwise, record that this verification is
conditional and retain unresolved precedence conflicts.

## License

This guide is available under the [MIT License](LICENSE).
