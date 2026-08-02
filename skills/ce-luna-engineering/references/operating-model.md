<!-- BEGIN CANONICAL README -->
# CE + Sol/Luna Engineering

CE + Sol/Luna is a practical operating model for software work that needs both
fast implementation and accountable engineering judgment. It combines the
Compound Engineering (CE) lifecycle with a clear separation between a lead
(Sol), an implementation maker (Luna), and an independent reviewer (Luna).

The model is intentionally tool- and vendor-neutral. Adapt the names to your
team if needed; preserve proportional routing, role boundaries, evidence, and
authorization requirements. Observe and Small work may be handled directly by
Sol; makers and reviewers are selected by lane or named risk rather than made
universal.

## Canonical cross-surface source

The portable authority is [`policy/engineering-lifecycle.md`](policy/engineering-lifecycle.md).
[`AGENTS.md`](AGENTS.md) is the complete portable Codex policy; the decision
record, operating guide, and native adapters live under `docs/` and `surfaces/`.
Git is canonical; installed Codex files are deployments.
Use [`manifest/codex-files.tsv`](manifest/codex-files.tsv) and
[`manifest/ce-luna-skill-files.tsv`](manifest/ce-luna-skill-files.tsv) with the
read-only drift checker, and opt into installation only with
`scripts/install-codex.sh --apply`. The canonical CE skill defaults to
`~/.agents/skills/ce-luna-engineering`; `CE_SKILL_ROOT` is only an installer and
drift-checker target override for testing, never a runtime discovery selector.
`CODEX_ROOT` remains the separate Codex-home destination for
agent role TOMLs and the assessment runtime.
Surface copies under `surfaces/codex/` are adapters kept in exact parity by
review and validation. Merge the
tracked `AGENTS.md` and `config.toml` fragments manually so unrelated policy
and machine settings are preserved. Backups are made when an existing manifest
target differs. Credentials, MCP details, machine paths, trust settings,
caches, histories, databases, and unrelated personal configuration are
deliberately excluded.

## Install with Codex

Cloning this repository, installing the Codex skill, and adopting the lifecycle
as a global default are separate actions:

| Desired result | Required action |
| --- | --- |
| Invoke `$ce-luna-engineering` when needed | Install the skill package |
| Use CE + Sol/Luna as the default engineering lifecycle | Install the skill, then safely update the applicable global `AGENTS.md` |
| Read or contribute to the operating model | Clone the repository; cloning alone does not install the skill |

To install the skill from GitHub, give Codex this exact prompt:

> Use `$skill-installer` to install `skills/ce-luna-engineering` from
> `ceej23/ce-luna-engineering` into the destination parent `~/.agents/skills`,
> verify the resulting path is `~/.agents/skills/ce-luna-engineering`, and do
> not use `$CODEX_HOME/skills` because that creates a legacy duplicate.

The canonical installer places the package under `~/.agents/skills`, shared by
Codex Desktop and CLI. Start a fresh Codex task after installation so its skill
catalog is reloaded and the skill can be discovered.

Agents that already have `~/.codex/skills/ce-luna-engineering` should inventory
both copies, keep a timestamped backup, install the canonical path, and start
a fresh task. Verify drift before retiring the legacy copy; leaving both copies
active risks duplicate discovery and stale instructions. Roll back by backing
up/restoring the legacy copy, moving the canonical `~/.agents/skills/ce-luna-engineering`
aside, and starting a fresh task; `CE_SKILL_ROOT` only selects an installer or
drift-check target and does not activate runtime discovery.

Installing the skill makes explicit invocation available; it does not modify
your global instructions. To adopt the lifecycle as the default, use this
follow-up prompt:

> Use `$ce-luna-engineering` to adopt CE + Sol/Luna as my global engineering
> lifecycle. Inventory every applicable `AGENTS.md` first, preserve unrelated
> instructions and stricter security or repository rules, replace only
> conflicting lifecycle defaults, and verify the effective context in a fresh
> Codex task. Do not overwrite an `AGENTS.md` wholesale.

This separation is intentional. Updating instructions without installing the
skill does not make `$ce-luna-engineering` discoverable, while installing the
skill alone does not make it the default lifecycle.

### Verify the result

- Confirm `ce-luna-engineering` appears in the available skills in a fresh
  Codex task.
- Invoke `$ce-luna-engineering` on a planning-only example and confirm Sol owns
  framing and planning, any maker receives a bounded packet, and review is
  independent and read-only.
- For default-lifecycle adoption, inspect the effective instructions and
  confirm unrelated rules remain active and CE + Sol/Luna is the only default
  engineering lifecycle.
- If the runtime cannot inspect effective instruction precedence, record that
  limitation and leave conflicting parent or global policy explicitly
  unresolved.

The manifest also installs a self-contained, report-only assessment runtime
under `skills/ce-assess-engineering/runtime`. It partitions disposable UTC
weekly records by explicit agent and repository identity. Run its setup,
readiness, validation/ingest, and idempotent `if-due` commands only after Sol
accepts substantive instrumented work; missing or drifted assessment state is
`UNVERIFIED` setup drift and cannot change acceptance or delivery.

### Validate repository changes

Run the validator from the repository root:

```text
python scripts/validate_skill.py
```

## Classify before the lifecycle

Sol classifies the work before choosing the active lifecycle phases. Use the
smallest lane that contains the risk:

| Lane | Qualifies when | Default execution | Default budget |
| --- | --- | --- | --- |
| **Tier 0: Observe** | No target mutation: diagnosis, status, evidence inspection, or reporting | Sol only; focused evidence; no maker or reviewer | 15 minutes; 1 total agent |
| **Tier 1: Small** | Localized, reversible, known solution; no cross-cutting or control-bearing decision; an explicitly requested browser-local or single-user artifact replacement may qualify when bounded and unrelated state is preserved | Sol or one bounded maker; focused verification; review only on a named trigger | 30 minutes; 2 total agents |
| **Tier 2: Standard** | Ordinary mutation that does not qualify as Small or High-risk | One or more bounded makers, at least one independent integrated reviewer, one remediation/re-review maximum, one broad Sol check | 60 minutes; three agents is the default starting topology, not a ceiling |
| **Tier 3: High-risk** | Architecture, public API or schema, migration, dependency, security, credentials, privacy-sensitive data, production, external writes, or irreversible effects | Full Sol/maker/reviewer boundaries; one or more bounded makers and at least one independent integrated reviewer; focused specialists only for a named risk | Explicit task budget; three agents is the default starting topology, not a ceiling |

Tier selection is conservative: a Tier 3 trigger always wins. A Tier 1 review
trigger includes a user request, unexpected ambiguity or scope, a
security/privacy-sensitive path, public interface/schema/dependency
implications, inadequate test evidence, or a risk Sol explicitly promotes.
Promote the work before continuing when the trigger cannot fit safely inside
the selected lane.

For Showcase visual work, use a separate direction-selection lane only when no
Tier 3 trigger applies: create at most three small and genuinely different
directions, obtain a human selection, record a visual-fidelity contract, then
harden the selected direction. Renderer-only variants are not different
directions. The default target is 45 minutes and two total agents; three
directions do not require three agents.

This classification deliberately revises the earlier universal contract:
Tier 0 and Tier 1 may be Sol-only. Whenever a Luna maker or reviewer is used,
all role, scope, control, independence, evidence, and delivery boundaries below
still apply.

An explicitly requested browser-local or single-user artifact replacement is
Tier 1 only when the target is bounded, reversible, and unrelated state is
preserved. A one-file local artifact must not fan out specialist review; use
one focused validation and stop. Promote the lane if the artifact crosses
users, systems, security boundaries, or external state.

Tier 0 and Sol-only Tier 1 work may classify inline without a formal routing
declaration. Before delegation or any Tier 2 or Tier 3 mutation, publish one
compact routing declaration:

`Lane: [selected lane] | Budget: [time/cost limit] | Agents: [topology]`

For Tier 2 and Tier 3, the declared topology is a fail-closed precondition to
the first write: it must include Sol, at least one bounded maker, and at least
one independent reviewer of the integrated stable target. Lane-selected roles
are optional only before lane selection; once Tier 2 or Tier 3 is selected,
silence about delegation does not downgrade the topology. The implementation
request permits this required internal delegation, while delivery actions stay
separately authorized.

The one-maker/one-reviewer/three-agent shape is a default starting topology,
not a ceiling. Sol may dispatch multiple independently bounded makers only
when the routing declaration records the decomposition rationale, exclusive
and non-overlapping write ownership, dependencies, integration order, and
sufficient budget. Sol integrates every completed unit before review, and at
least one integrated reviewer must have authored none of the target. Additional
focused reviewers are allowed only for named risks; avoid default panels. If
required roles, capacity, or budget are unavailable, stop before mutation and
report rather than falling back to Tier 2/3 Sol-only execution.

When a declaration is required, do not begin mutating work until it contains
an explicit budget.

## Direct and mediated engagements

Codex Desktop and Codex CLI use the direct topology by default:

```text
User -> engineering Sol -> optional lane-selected Luna maker/reviewer
```

Some infrastructure operations use a mediated topology:

```text
User
  -> operational controller
  -> one repository-engineering Sol
       -> optional lane-selected Luna maker/reviewer
  -> operational controller for deployment, rollback and live acceptance
```

This is a composition of operational and repository-engineering authority, not
one CE lifecycle wrapped around another. The controller must not create a
duplicate maker/reviewer panel for the same repository outcome.

The operational controller owns current-state inspection, live-risk
classification, approval capture, production controls and credentials, service
lifecycle actions, deployment, rollback, live health verification, and
operational acceptance. Engineering Sol owns repository framing within the
bounded packet, repository lane selection, technical design and architecture,
internal routing, integration, engineering verification, engineering
acceptance, and an operator-ready return.

The outer operational lane and inner repository lane may differ. A production
deployment remains operational Tier 3 even when its isolated repository change
is Tier 1. Repository architecture, security, migration, schema, dependency,
credential, and other Tier 3 triggers still promote the inner lane.

Nested engineering agents must not SSH back into the operator host, deploy,
control services, access production credentials or state, or perform live
verification. Tool access, including `--yolo`, provides capability rather than
authority.

## The lifecycle

```text
Frame → Plan → Make → Integrate → Review → Synthesize → Compound
 Sol    Sol+CE   Luna     Sol        Luna       Sol          CE
```

This is the complete path for work whose selected lane requires every phase.
Tier 0 and Tier 1 collapse phases that add no proportionate evidence. Tier 2
uses the complete path with the limits above. Tier 3 may add a focused
specialist only for a named risk and within its explicit budget.

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

## Workflow assessment

[`policy/engineering-assessment.md`](policy/engineering-assessment.md) defines
the portable assessment contract. Substantive instrumented runs may emit a
sealed, redacted bundle of lifecycle facts and receive a deterministic
conformance result. `PASS`, `FAIL`, `UNVERIFIED`, and `EXCEPTION` are evidence
states only: Sol still owns acceptance and external-write authorization.

The capability matrix names the controls each surface can enforce, observe,
attest, or cannot support. Never infer a host guarantee from adapter text. The
assessment skill consumes only validated summaries and is report-only; policy
or adapter changes remain separately authorized engineering work.

## Risk gates and verification

The lead owns the gates; a maker or reviewer supplies evidence for them.

- **Scope gate:** every worker has an allowed read scope and exact write scope.
  Unexpected files or requirements stop the unit.
- **Control gate:** architecture, security, policy, credentials, external
  writes, and other control-bearing decisions stay with the lead.
- **Independence gate:** when the selected lane requires review, it starts only
  from a stable baseline and is read-only; a changed target invalidates that
  review lane.
- **Evidence gate:** acceptance requires the requested checks to pass (or a
  clearly recorded, lead-owned exception). Prefer focused tests and linting,
  then run the broader verification appropriate to the change.
- **Budget gate:** stop when the selected time, cost, retry, agent, or
  verification budget is exhausted. Report progress, evidence, and remaining
  risk instead of silently escalating.
- **Delivery gate:** commits, pushes, releases, deployments, and production
  actions require explicit authorization and are not implied by implementation
  or review.

Track inspect, design, implementation, review, commit, push or pull request,
release, deployment or rollback, credentials, and production authority as
separate states. Authority for one state never implies another.

Assessment exceptions retain their underlying failed or unverified control,
are scoped to one run and policy version, and expire. They never turn a result
into an acceptance decision.

## Getting started

1. Define the outcome, mutation, risks, and acceptance evidence in plain
   language.
2. Select the lane using the conservative precedence above and record its
   budget.
3. For delegated work, capture the worktree state and send one compact packet
   per bounded unit. Keep unrelated user changes intact.
4. Run focused checks during implementation. Run at most one broad,
   parent-owned verification after integration by default.
5. Review only when the selected lane requires it. Resolve blocking findings
   within the lane's remediation budget.
6. Accept and stop when the selected checks pass and no blocker remains.
   Capture a short learning only when it will help future work.

## Operating limits and stopping rules

- Use no history or minimal recent context for workers by default. Send the
  compact packet, not the conversation or unrelated architecture rationale.
  Full-history delegation requires written justification.
- Keep one accepted outcome or immutable target per root. When material scope
  expansion arrives after acceptance, stop. Do not implement it in the current
  root. Return a compact handoff and require a fresh task for the new outcome.
- For mediated continuation, send `immutable target + brief reference +
  authority delta + remaining budget` instead of restating the operating
  contract.
- Treat specialist practices as optional lenses or checklists inside the
  selected lane, never as nested mandatory lifecycles. Do not create review
  panels by default.
- P0 and P1 findings block by default. Any finding that violates an explicit
  acceptance criterion, safety or security policy, authorization boundary, or
  rollout prerequisite blocks regardless of numeric severity. Other P2 and P3
  findings may be deliberately deferred.
- Allow one reviewer attempt and one retry only for a confirmed transient
  infrastructure failure against the same unchanged target. When remediation
  changes the target, allow one focused independent re-review of affected axes;
  this is not an infrastructure retry.
- If a maker or reviewer produces no material file, test, finding, or blocker
  after roughly 10 minutes, return a progress checkpoint to Sol. Tier 2 should
  checkpoint around 30 minutes and stop for reassessment at its 60-minute
  budget rather than silently looping. A review is normally bounded to 15–20
  minutes and returns partial findings or a blocker if it cannot finish.
- For frontend or browser verification, use one canonical local HTTP preview
  rooted at the resolved target. After two failed attempts with that preview or
  tool path, switch approach or report the verification gap and stop.
- After checks pass and no blocker remains, stop. Suggestions do not reopen the
  lifecycle.
- After acceptance, allow at most three minutes to reassess a newly discovered
  issue. If it is a new outcome or material scope expansion, stop, preserve the
  accepted target, and start a fresh task rather than churning in the old root.
- Use deterministic telemetry off the critical path. Keep the default
  post-execution assessment under one minute and use no subagent. Deepen it
  only after a budget breach, repeated failure, discarded work, user rejection,
  or a quality or safety regression.

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
decisions, and subagent spawning. P0 and P1 findings block by default. A
finding that violates acceptance, safety, security, policy, authorization, or
rollout requirements blocks regardless of severity; other P2 and P3 findings
may be deferred.

## Adapting the model

This is an operating contract, not a prescription for a particular agent
runtime. Teams can change tools, names, or automation while retaining:

- one accountable lead for judgment and acceptance;
- bounded implementation ownership;
- an independent read-only review when the selected lane requires it;
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
| Implementation and execution | **Make (Luna) → Integrate (Sol):** bounded delegated units for Tier 2 and Tier 3; Sol may execute Tier 1 directly. |
| Debugging and diagnosis | **Frame/Plan → Make → Verify:** reproduce the behavior, make the smallest scoped change, and attach evidence to the decision. |
| Review and QA | **Review (independent Luna) → Synthesize (Sol):** read-only findings followed by lead-owned remediation and acceptance. |
| Handoff and delivery | **Compound + delivery gate (Sol):** capture learning and perform separately authorized commits, releases, or deployments. |

Specialist practices such as TDD, codebase design, and domain modeling remain
useful optional quality lenses. Apply them inside the CE lifecycle when the
work benefits from them; they complement the lifecycle rather than becoming a
second competing default.

A safe incremental adoption sequence is:

1. Keep the existing skills available while documenting CE + Sol/Luna as the
   default proportional workflow for software-repository work.
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
Sol classifies work before execution. Observe and Small work may be Sol-only;
Standard work uses one bounded Luna maker and one independent read-only Luna
reviewer; High-risk work uses the full boundaries plus only focused,
risk-justified specialists. Sol owns framing, planning, architecture, security,
integration, synthesis, verification, and acceptance. Specialist practices
such as TDD, domain modeling, or codebase design are optional lenses inside the
selected lane, not competing default workflows. Stop when the lane's checks
pass or its budget is exhausted; delivery actions always require separate
explicit authorization.
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

### Migrating duplicated workflow blocks

For agents that already carry a copied CE workflow block in one or more
`AGENTS.md` files, use this bounded migration:

1. Inventory every effective `AGENTS.md` (global, parent, repository, and
   nested) and record the runtime's precedence order.
2. Install or update the `ce-luna-engineering` skill from this repository, then
   start a fresh task so the skill catalog reloads.
3. Replace only the duplicated CE lifecycle/default-routing block with a thin
   stanza that routes to `$ce-luna-engineering`; preserve RTK, Tokensave,
   safety, security, testing, and domain rules, including any stricter rules.
4. Inspect the diff, verify effective context in a fresh task, and confirm CE
   is the only default lifecycle while unrelated instructions remain active.
5. If precedence cannot be inspected deterministically, leave the conflict
   explicit and report it rather than overwriting a file wholesale.

Keep a rollback copy or versioned diff of each edited block. Re-run the
inventory after upgrades to detect drift; restore only the prior CE block if a
rollback is needed, and never restore unrelated instructions or personal
settings.

## License

This guide is available under the [MIT License](LICENSE).
