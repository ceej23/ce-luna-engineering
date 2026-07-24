---
name: ce-luna-engineering
description: Run the Compound Engineering lifecycle with accountable Sol/Luna role boundaries. Use when the user explicitly requests CE, Compound Engineering, Sol, or Luna; when adopting CE + Sol/Luna as an engineering lifecycle; or when running a non-trivial engineering change through bounded makers and independent review.
---

# CE + Sol/Luna Engineering

Use this lifecycle as one operating contract:

`Frame → Plan → Make → Integrate → Review → Synthesize → Compound`

Keep Sol accountable for intent, framing, plan decisions, architecture,
security, integration, synthesis, final verification, and acceptance. Use a
Luna maker only for one bounded implementation unit. Use a different Luna as
an independent, read-only reviewer. Apply specialist practices such as TDD,
diagnosis, domain modeling, codebase design, or UX review inside this
lifecycle; do not turn them into competing default workflows.

## Run the lifecycle

1. **Frame as Sol.** Clarify requested behavior, constraints, risks,
   architecture questions, and observable acceptance criteria. Resolve
   ambiguous or control-bearing decisions before delegating.
2. **Plan as Sol, using CE.** Choose the smallest coherent plan. Keep the plan
   explicit for non-trivial work and explore material ambiguity before
   implementation.
3. **Make with bounded Luna makers.** Record the worktree state and preserve
   unrelated user changes before dispatch. Give each maker an explicit packet.
   Require the maker to stop on ambiguity, unexpected files or requirements,
   missing tools, failing assumptions, or scope expansion.
4. **Integrate as Sol.** Inspect maker output and scope, reconcile the units,
   and run parent-owned checks to establish a stable baseline.
5. **Review with an independent Luna.** Give a reviewer who did not make the
   change a stable diff and a read-only review packet. Invalidate the review
   and repeat it if the worktree changes.
6. **Synthesize as Sol.** Confirm findings, decide remediation, rerun final
   verification, and make the acceptance decision.
7. **Compound with CE.** Simplify where useful, apply the relevant quality
   tail, and capture durable learning when it will help future work.

Use a compact plan and packet for tiny changes, but preserve scope,
independence, evidence, and authorization gates.

## Dispatch a maker

Include all of the following in every maker packet:

- working directory;
- objective and plan unit;
- allowed read scope;
- exact write scope;
- observable acceptance criteria;
- exact verification commands;
- prohibited operations;
- stop conditions; and
- return contract covering files changed, verification results, blockers, and
  residual risks.

Do not let a maker own architecture, public API or schema decisions,
dependencies, security, credentials, Git, release, deployment, production, or
product decisions. Do not let a maker spawn subagents or silently broaden
scope.

## Dispatch a reviewer

Provide the stable base and target diff, plan or unit identifiers, acceptance
criteria, and relevant review axes. Require each finding to contain severity,
location, direct evidence, the violated criterion, impact, and bounded
remediation direction. Require the reviewer to return `no findings` explicitly
when the evidence supports it.

Keep review read-only. Do not let the reviewer edit, accept the work, own
architecture or policy decisions, or spawn subagents.

## Enforce gates

- Accept work only with requested verification evidence or a clearly recorded,
  Sol-owned exception.
- Keep architecture, security, policy, credentials, and external writes under
  Sol's control.
- Require explicit user authorization for commits, pushes, pull requests,
  releases, deployments, production actions, and other external writes.
- Treat implementation and review authorization as distinct from delivery
  authorization.

## Read the full operating model

Read [references/operating-model.md](references/operating-model.md) before
adapting this lifecycle to an `AGENTS.md`, migrating from another lifecycle,
resolving role or gate ambiguity, or designing maker/reviewer packets beyond
the concise requirements above. Preserve its boundaries and evidence
requirements when adapting names, tools, or automation.
