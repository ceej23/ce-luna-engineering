---
name: ce-luna-engineering
description: Run a proportional Compound Engineering lifecycle with accountable Sol/Luna boundaries. Use when adopting CE + Sol/Luna, or when non-trivial engineering work benefits from bounded makers and independent review.
---

# CE + Sol/Luna Engineering

Classify work before selecting lifecycle phases. Use the smallest lane that
contains the risk; do not make every quality practice mandatory.

## Select the lane

| Lane | Qualifies when | Default execution | Budget |
| --- | --- | --- | --- |
| **Tier 0: Observe** | No target mutation | Sol only; focused evidence; no maker or reviewer | 15 minutes; 1 total agent |
| **Tier 1: Small** | Localized, reversible, known solution; no cross-cutting or control-bearing decision | Sol or one bounded maker; focused verification; triggered review only | 30 minutes; 2 total agents |
| **Tier 2: Standard** | Ordinary mutation that is neither Small nor High-risk | One maker, one reviewer, one remediation/re-review maximum, one broad Sol check | 60 minutes; 3 total agents |
| **Tier 3: High-risk** | Architecture, public API/schema, migration, dependency, security, credentials, privacy-sensitive data, production, external writes, or irreversible effects | Full boundaries; focused specialists only for a named risk | Explicit task budget; 3 total agents before justified escalation |

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

Before any mutating work, tool call, or delegation, publish:

`Lane: [selected lane] | Budget: [time/cost limit] | Agents: [topology]`

Do not begin mutating work without an explicit budget in that declaration.

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
- P0 and P1 findings block. P2 and P3 are backlog unless Sol promotes them.
- Allow one reviewer attempt and one retry only for confirmed transient
  infrastructure failure. Then record the exception, perform Sol review, and
  stop the review lane.
- Run focused implementation checks and at most one broad Sol-owned check
  after integration by default.
- Stop when checks pass and no blocker remains. Suggestions do not reopen the
  lifecycle.
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

## Read the full operating model

Read [references/operating-model.md](references/operating-model.md) before
adapting this lifecycle to `AGENTS.md`, migrating another lifecycle, resolving
role or gate ambiguity, or designing non-trivial worker packets.
