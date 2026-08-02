---
name: ce-luna-engineering
description: Run proportional Compound Engineering with accountable Sol/Luna boundaries across direct Codex and mediated operator engagements.
---

# CE + Sol/Luna Engineering

Classify work before selecting lifecycle phases. Use the smallest lane that
contains the risk; do not make every quality practice mandatory.

## Select the lane

| Lane | Qualifies when | Default execution | Budget |
| --- | --- | --- | --- |
| **Tier 0: Observe** | No target mutation | Sol only; focused evidence; no maker or reviewer | 15 minutes; 1 total agent |
| **Tier 1: Small** | Localized, reversible, known solution; no cross-cutting or control-bearing decision; explicitly requested browser-local or single-user artifact replacements qualify when bounded and unrelated state is preserved | Sol or one bounded maker; focused verification; triggered review only | 30 minutes; 2 total agents |
| **Tier 2: Standard** | Ordinary mutation that is neither Small nor High-risk | One or more bounded makers, at least one independent integrated reviewer, one remediation/re-review allowance, one broad Sol check | 60 minutes; three agents is the default starting topology, not a ceiling |
| **Tier 3: High-risk** | Architecture, public API/schema, migration, dependency, security, credentials, privacy-sensitive data, production, external writes, or irreversible effects | Full boundaries; one or more bounded makers and at least one independent integrated reviewer; focused specialists only for a named risk | Explicit task budget; three agents is the default starting topology, not a ceiling |

Tier 3 always wins. A Tier 1 review trigger includes a user request, unexpected
scope or ambiguity, a security/privacy-sensitive path, public interface,
schema, migration or dependency implications, inadequate test evidence, or a
risk Sol promotes. Promote the lane before continuing when needed.

Tier 0 and Tier 1 may be Sol-only. Whenever Luna is used, all role, scope,
control, independence, evidence, and delivery boundaries below apply.

Tier 0 and Sol-only Tier 1 work may classify inline without a formal routing
declaration. Before delegation or any Tier 2 or Tier 3 mutation, publish:

`Lane: [selected lane] | Budget: [time/cost limit] | Agents: [topology]`

For Tier 2 and Tier 3, this declared topology is a fail-closed precondition to
the first write: include Sol, at least one bounded maker, and at least one
independent reviewer of the integrated stable target. Roles are optional only
before lane selection; user silence cannot downgrade the mandatory topology.
The implementation request permits required internal delegation, while
delivery actions remain separately authorized.

The one-maker/one-reviewer/three-agent shape is a default starting topology,
not a ceiling. Multiple makers require recorded decomposition rationale,
exclusive non-overlapping ownership, dependencies, integration order, and
sufficient budget. Sol integrates all completed units before review, and at
least one integrated reviewer must have authored none of the target. Additional
reviewers are only for named risks; avoid default panels. If roles, capacity,
or budget are unavailable, stop before mutation and report rather than falling
back to Tier 2/3 Sol-only execution.

For an explicitly requested, bounded, reversible browser-local or single-user
artifact replacement that preserves unrelated state, a one-file local artifact
must not fan out specialist review: run one focused validation and stop. This
never suppresses a named Tier 1 review trigger or Tier 2/3 promotion; promote
when any trigger applies or the artifact crosses users, systems, security
boundaries, or external state.

## Run the selected lifecycle

The complete path is:

`Frame -> Plan -> Make -> Integrate -> Review -> Synthesize -> Compound`

- **Sol** owns intent, classification, framing, plan decisions, architecture,
  security, integration, synthesis, final verification, and engineering
  acceptance.
- **Luna maker** implements one bounded unit only.
- **Luna reviewer** independently reviews a stable target in read-only mode.
- **CE** supplies planning and quality practices. Architecture review, TDD,
  domain modelling, UX review, simplification, code review, and other
  specialist skills are selected-lane or named-risk lenses, never mandatory
  nested workflows.

Tier 0 and Tier 1 collapse phases that add no proportionate evidence. Tier 2
uses the complete path within its limits. Tier 3 may add a focused specialist
only for a named risk and within its explicit budget.

## Dispatch only selected roles

Read [references/worker-packets.md](references/worker-packets.md) before the
first maker or reviewer dispatch.

When the selected lane uses a maker, invoke the named `luna_maker` custom agent
with no or minimal history and a complete bounded packet. When it uses a
reviewer, invoke the named `luna_reviewer` against the stable target in
read-only or isolated mode. Do not pass model or effort overrides as a
substitute for a named role, and do not claim the observed model or effort
without host evidence.

If a selected role is unavailable, stop that required lane and report the
limitation. Do not stop Tier 0 or Sol-only Tier 1 merely because an unselected
role is unavailable.

A maker packet includes:

- working directory and plan/unit;
- allowed read scope and exact write scope;
- observable acceptance criteria;
- exact verification commands;
- prohibited operations and stop conditions; and
- a return contract for files, checks, blockers, and residual risks.

A reviewer packet includes the stable base and target, plan/unit, acceptance
criteria, relevant axes, read-only requirement, prohibited operations, and the
findings contract. Findings include severity, location, direct evidence,
violated criterion, impact, and bounded remediation direction. Require
`no findings` when appropriate.

Makers and reviewers do not own architecture, public interfaces or schema,
migration, dependencies, security, credentials, policy, product direction,
Git, release, deployment, production, or acceptance. They do not spawn
subagents or broaden scope.

## Bound review and verification

- A transient reviewer infrastructure failure permits one retry against the
  same unchanged target.
- When confirmed remediation changes the target, perform one focused
  independent re-review of affected axes. This is not an infrastructure retry.
- P0 and P1 findings block by default.
- Any acceptance-criterion, safety, security, policy, authorization, or rollout
  violation blocks regardless of numeric severity.
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
- Stop when checks pass and no blocker remains. Suggestions do not reopen the
  lifecycle.
- Stop on budget breach and report progress, evidence, and remaining risk
  rather than silently escalating.
- After acceptance, allow at most three minutes to reassess a newly discovered
  issue. A new outcome or material scope expansion stops this task; preserve
  the accepted target and start a fresh task.

## Preserve authority boundaries

Track inspect, design, implement, review, commit, push or pull request, release,
deploy or rollback, credentials, and production authority separately. Tool
access, including `--yolo`, grants capability rather than authority.

Commits, pushes, pull requests, releases, deployments, credentials, service
lifecycle actions, production actions, and other external writes require
separate explicit authorization. Implementation and review do not authorize
delivery.

## Use the direct topology by default

Codex Desktop and Codex CLI normally use:

`user -> engineering Sol -> optional lane-selected Luna maker/reviewer`

For a mediated infrastructure engagement, use:

```text
user
  -> operational controller
  -> one repository-engineering Sol
       -> optional lane-selected Luna maker/reviewer
  -> operational controller for deployment, rollback and live acceptance
```

This is one repository-engineering lifecycle inside Codex, not a duplicate
operator-side maker/reviewer lifecycle. The outer operational lane and inner
repository lane are classified independently.

The operational controller retains current-state inspection, live-risk
classification, approvals, credentials, service control, deployment, rollback,
live verification, and operational acceptance. Engineering Sol retains
repository framing within the packet, repository lane selection, technical
design, internal routing, integration, engineering verification, engineering
acceptance, and the operator-ready return.

Nested engineering agents must not SSH back into the operator host, deploy,
control services, access production credentials or state, or perform live
verification. Stop rather than reinterpret ambiguous operational intent.

## Keep execution bounded

- Send workers no history or minimal recent context plus one compact packet.
- Keep one accepted outcome or immutable target per root.
- On material scope expansion after acceptance, stop and require a fresh task.
- For mediated continuation, send `immutable target + brief reference +
  authority delta + remaining budget`.
- Do not create review panels by default.
- Keep deterministic telemetry off the critical path and report-only.

## Close out

Sol reports the selected lane and budget, files changed, scope result, checks,
review and remediation result when selected, residual risk, and each delivery
authority state without implying actions that did not occur. Assessment
evidence remains report-only and never replaces engineering or operational
acceptance.

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
