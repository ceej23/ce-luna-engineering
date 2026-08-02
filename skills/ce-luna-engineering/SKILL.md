---
name: ce-luna-engineering
description: Run a proportional Compound Engineering lifecycle with accountable Sol/Luna boundaries across direct and mediated engagements. Use when adopting CE + Sol/Luna or when engineering work benefits from bounded makers and independent review.
---

# CE + Sol/Luna Engineering

Classify work before selecting lifecycle phases. Use the smallest lane that
contains the risk; do not make every quality practice mandatory.

## Select the lane

| Lane | Qualifies when | Default execution | Budget |
| --- | --- | --- | --- |
| **Tier 0: Observe** | No target mutation | Sol only; focused evidence; no maker or reviewer | 15 minutes; 1 total agent |
| **Tier 1: Small** | Localized, reversible, known solution; no cross-cutting or control-bearing decision; explicitly requested browser-local or single-user artifact replacements qualify when bounded and unrelated state is preserved | Sol or one bounded maker; focused verification; triggered review only | 30 minutes; 2 total agents |
| **Tier 2: Standard** | Ordinary mutation that is neither Small nor High-risk | One or more bounded makers, at least one independent integrated reviewer, one remediation/re-review maximum, one broad Sol check | 60 minutes; scale with independently bounded units and budget |
| **Tier 3: High-risk** | Architecture, public API/schema, migration, dependency, security, credentials, privacy-sensitive data, production, external writes, or irreversible effects | Full boundaries; one or more bounded makers and at least one independent integrated reviewer; focused specialists only for a named risk | Explicit task budget; scale only when independently bounded units justify it |

Tier 3 always wins. A Tier 1 review trigger includes a user request, unexpected
scope or ambiguity, a security/privacy-sensitive path, public
interface/schema/dependency implications, inadequate test evidence, or a risk
Sol promotes. Promote the lane before continuing when needed.

For Showcase visual direction work without a Tier 3 trigger, create at most
three small and genuinely different directions, obtain a human selection,
record a visual-fidelity contract, then harden. Renderer-only variants do not
count. Default to 45 minutes and two total agents.

Tier 0 and Tier 1 may be Sol-only. This deliberately replaces the earlier
universal maker/reviewer requirement. Whenever Luna is used, every role,
scope, control, independence, evidence, and delivery boundary below applies.

Tier 0 and Sol-only Tier 1 work may classify inline without a formal routing
declaration. Before delegation or any Tier 2 or Tier 3 mutation, publish:

`Lane: [selected lane] | Budget: [limit] | Agents: [Sol + makers + reviewer] | Units: [IDs]`

For Tier 2/3 this is fail-closed before the first write: include Sol, one or
more bounded makers, and one independent reviewer of the integrated target.
Select multiple makers for two or more genuinely independent, non-overlapping
units that fit the budget; otherwise use one. Record unit IDs and exclusive
paths, adding dependency/order only when they exist. Explain only a one-maker
choice despite independent units or any extra reviewer/specialist. Sol
integrates all units before review; avoid default panels. If mandatory capacity
is unavailable, stop unless facts justify reclassification. Keep ceremony to
named risks and add fields, roles, or checks only when simpler controls are
insufficient.

When a declaration is required, do not begin mutating work without an explicit
budget in it.

For an explicitly requested, bounded, reversible browser-local or single-user
artifact replacement that preserves unrelated state, a one-file local artifact
must not fan out specialist review: run one focused validation and stop. This
never suppresses a named Tier 1 review trigger or Tier 2/3 promotion; promote
when any trigger applies or the artifact crosses users, systems, security
boundaries, or external state.

## Run the selected lifecycle

The complete path is:

`Frame → Plan → Make → Integrate → Review → Synthesize → Compound`

- **Sol** owns intent, classification, framing, plan decisions, architecture,
  security, integration, synthesis, final verification, and acceptance.
- **Luna maker** implements one bounded unit only.
- **Luna reviewer** independently reviews a stable target in read-only mode.
- **CE** supplies planning and quality practices; specialist skills are lenses
  or checklists inside the selected lane, never nested mandatory lifecycles.

Tier 0 and Tier 1 collapse phases that add no proportionate evidence. Tier 2
uses the complete path with the limits above. Tier 3 may add a focused
specialist only for a named risk and within its explicit budget.

## Keep execution bounded

- Send workers no history or minimal recent context plus one compact packet.
  Full-history delegation requires written justification.
- Keep one accepted outcome or immutable target per root. When material scope
  expansion arrives after acceptance, stop. Do not implement it in the current
  root. Return a compact handoff and require a fresh task for the new outcome.
- For mediated continuation, send `immutable target + brief reference +
  authority delta + remaining budget`.
- Do not create panels by default.
- P0 and P1 findings block by default. Any finding that violates an explicit
  acceptance criterion, safety or security policy, authorization boundary, or
  rollout prerequisite blocks regardless of numeric severity. Other P2 and P3
  findings may be deliberately deferred.
- Allow one reviewer attempt and one retry only for confirmed transient
  infrastructure failure against the same unchanged target. When remediation
  changes the target, allow one focused independent re-review of affected axes;
  this is not an infrastructure retry.
- Run focused implementation checks and at most one broad Sol-owned check
  after integration by default.
- If a maker or reviewer produces no material file, test, finding, or blocker
  after roughly 10 minutes, return a progress checkpoint to Sol. Tier 2 should
  checkpoint around 30 minutes and stop for reassessment at its 60-minute
  budget rather than silently looping. A review is normally bounded to 15–20
  minutes and returns partial findings or a blocker if it cannot finish.
- For frontend or browser verification, use one canonical local HTTP preview
  rooted at the resolved target. After two failed attempts with that preview or
  tool path, switch approach or report the verification gap and stop.
- Stop when checks pass and no blocker remains. Suggestions do not reopen the
  lifecycle.
- After acceptance, allow at most three minutes to reassess a newly discovered
  issue. A new outcome or material scope expansion stops this task; preserve
  the accepted target and start a fresh task.
- On budget breach, stop and report progress, evidence, and remaining risk.
  Do not silently escalate.
- Keep deterministic telemetry off the critical path. Default post-execution
  assessment stays under one minute and uses no subagent.

## Dispatch a maker

Every maker packet includes:

- working directory;
- objective and plan unit;
- allowed read scope;
- exact write scope;
- observable acceptance criteria;
- exact verification commands;
- prohibited operations;
- stop conditions; and
- return contract covering files changed, verification, blockers, and risks.

Do not give a maker architecture, public API or schema, dependency, security,
credential, Git, release, deployment, production, policy, product, or
acceptance ownership. A maker does not spawn subagents or broaden scope.

## Dispatch a reviewer

Provide the stable base and target, plan/unit, acceptance criteria, and
relevant axes. Findings include severity, location, direct evidence, violated
criterion, impact, and bounded remediation direction. Require `no findings`
when appropriate.

Review is read-only. A reviewer does not edit, accept, own architecture or
policy, or spawn subagents.

## Enforce gates

- Accept only with requested evidence or a recorded Sol-owned exception.
- Keep architecture, security, policy, credentials, and external writes with
  Sol.
- Commits, pushes, pull requests, releases, deployments, production actions,
  and other external writes require separate explicit user authorization.
- Implementation and review authorization do not authorize delivery.

Track inspect, design, implementation, review, commit, push or pull request,
release, deployment or rollback, credentials, and production authority as
separate states. Tool access, including `--yolo`, grants capability rather than
authority.

## Compose direct and mediated engagements

Codex Desktop and Codex CLI use the direct topology by default:

`user -> engineering Sol -> optional lane-selected Luna maker/reviewer`

For a mediated infrastructure engagement, use exactly one repository-
engineering root:

```text
user
  -> operational controller
  -> repository-engineering Sol
       -> optional lane-selected Luna maker/reviewer
  -> operational controller for deployment, rollback and live acceptance
```

The controller owns current-state inspection, live-risk classification,
approval capture, production controls and credentials, service lifecycle
actions, deployment, rollback, live verification, and operational acceptance.
Engineering Sol owns repository framing within the packet, repository lane
selection, technical design, internal routing, integration, engineering
verification, engineering acceptance, and an operator-ready return.

The outer operational lane and inner repository lane may differ. Do not create
a duplicate controller-side maker/reviewer lifecycle. Nested engineering agents
must not SSH back into the operator host, deploy, control services, access
production credentials or state, or perform live verification. Sol may refine
technical criteria but stops rather than reinterpreting ambiguous product or
operational intent.

## Read the full operating model

Read [references/operating-model.md](references/operating-model.md) before
adapting this lifecycle to `AGENTS.md`, migrating another lifecycle, resolving
role or gate ambiguity, or designing non-trivial worker packets.

## Migrate duplicated AGENTS.md workflow blocks

Inventory every applicable global, parent, repository, and nested `AGENTS.md`
and determine effective precedence. Install or update this skill, start a fresh
task, and replace only the duplicated CE lifecycle/default-routing block with a
thin `$ce-luna-engineering` routing stanza. Preserve RTK, Tokensave, safety,
security, testing, domain, and stricter repository rules. Inspect the diff and
verify effective context in a fresh task; if precedence cannot be inspected,
leave the conflict explicit rather than overwriting an `AGENTS.md` wholesale.
Keep a rollback diff for the replaced block and re-run the inventory after
skill updates to detect drift; restore only that block if needed.
