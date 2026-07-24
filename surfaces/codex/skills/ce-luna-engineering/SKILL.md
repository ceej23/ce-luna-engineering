---
name: ce-luna-engineering
description: Run implementation engineering through Compound Engineering with a Sol leader, Luna-medium maker, Luna-high read-only reviewer, and Sol synthesis. Use for feature delivery, bug fixes, refactors, backlog execution, test changes, UI engineering, and other work that changes a software repository. Also use when the user asks for the standard engineering workflow, maker-reviewer execution, delegated implementation, or end-to-end delivery across any project.
---

# CE Luna Engineering

Use Compound Engineering (CE) as the lifecycle and artifact system. Preserve a
separate leader–maker–reviewer execution loop for implementation quality and
cost control.

## Non-negotiable routing

- Leader and final authority: `gpt-5.6-sol`.
- Maker: the named `luna_maker` custom agent (`gpt-5.6-luna` / `medium`),
  workspace-write, bounded scope.
- Reviewer: the named `luna_reviewer` custom agent (`gpt-5.6-luna` / `high`),
  read-only, never an author of the slice.
- Sol integrates, synthesizes findings, independently verifies, and accepts.
- CE supplies planning, simplification, code review, learning capture, PR, and
  CI workflows. Do not fork or edit CE plugin internals to enforce routing.

Codex V2 does not reliably expose Luna through a generic spawn model selector.
Therefore dispatch Luna through the named custom-agent types above, never by
passing a Luna `model` or `reasoning_effort` override to a generic spawn.
Treat the configured role and the observed runtime route as different facts.
Claim an actual model/effort only when host completion metadata proves it.

## Entry routing

Resolve CE skill names against the current available-skills catalog; plugin
namespaces vary by host. Never invent a short form that is not listed.

1. For an unclear feature or product problem, use `ce-brainstorm` before
   `ce-plan`.
2. For a clear non-trivial change, use `ce-plan` directly and retain its unified
   plan artifact as the authority.
3. For a difficult bug, use `ce-debug` to establish reproduction and root cause,
   then return implementation ownership to this maker–reviewer loop.
4. For a tiny, obvious, low-risk change, write explicit acceptance criteria in
   the worker packet without forcing a large plan artifact.
5. For read-only diagnosis, explanation, planning, or review, do not infer
   authorization to implement.

If CE is unavailable, stop before write work and report the missing plugin or
skill. Do not silently fall back to retired MP lifecycle skills.

## Leader risk gate

Keep these with Sol unless the user explicitly assigns a qualified owner:

- architecture, public API, schemas, migrations, persistence, dependencies;
- authentication, security controls, IAM, secrets, credentials, privacy;
- sandbox, approval, network, provider, proxy, certificate, MCP, hooks, agent
  configuration, telemetry, and prompt provenance;
- Git history, releases, deployment, production, destructive or live actions;
- ambiguous product or UX decisions and final acceptance.

Luna may gather evidence about these areas but must not decide or mutate them.
When a bounded task discovers one, stop that lane and return it to Sol.

## Maker–reviewer sequence

Read [references/worker-packets.md](references/worker-packets.md) before the
first maker or reviewer dispatch in a run.

### 1. Establish the slice

Sol selects one reviewable vertical slice and records:

- objective and acceptance criteria;
- exact allowed read and write scope;
- verification commands;
- prohibited operations and stop conditions;
- CE plan path and implementation-unit IDs when present.

Do not delegate unresolved design. Parallel makers require disjoint write scopes
and no shared contract, schema, migration, lockfile, or generated surface.

### 2. Dispatch Luna medium

Invoke the maker as an actual subagent: call `agents.spawn_agent` with
`agent_type: "luna_maker"` and `fork_turns: "none"`. The no-history fork is
required when selecting a custom agent type; include the complete bounded
worker packet in the spawn message. Do not use `local_worker`, a generic
`default` agent, or model/effort overrides as a fallback.

Start the packet with this auditable routing record:

`Routing: <task>; selected luna_maker (gpt-5.6-luna/medium); reason: bounded implementation.`

If `luna_maker` is absent or rejected by the runtime, report that limitation
and stop the lane. Do not silently substitute another profile.

The maker may implement and run assigned verification. It may not commit, push,
release, deploy, change dependencies, broaden scope, or spawn subagents.

### 3. Integrate under Sol

Wait for every required maker. Inspect one result at a time, compare the
worktree with the pre-dispatch baseline, reject scope drift, and run the
lightest parent-owned integration check. Do not review a moving diff.

### 4. Dispatch Luna high review

Invoke the reviewer as an actual subagent: call `agents.spawn_agent` with
`agent_type: "luna_reviewer"` and `fork_turns: "none"`, including the complete
bounded review packet in the spawn message. Do not select Luna through generic
model/effort overrides or substitute a different reviewer without user
approval.

Start the packet with this auditable routing record:

`Routing: <task>; selected luna_reviewer (gpt-5.6-luna/high); reason: independent bounded review.`

If `luna_reviewer` is absent or rejected by the runtime, report that limitation
and stop the lane. The effective sandbox must be read-only or isolated from the
leader's writable worktree. Report-only wording is not a security boundary.

Capture worktree status and the review target before dispatch. Require findings
ordered by severity with file/symbol evidence, the violated acceptance
criterion, and a concise remediation direction. The reviewer never edits,
accepts, commits, or releases.

After review, compare the worktree again. Any reviewer write invalidates that
review lane; preserve the evidence, do not integrate the edit, and return
ownership to Sol.

### 5. Synthesize under Sol

Sol verifies reviewer claims, resolves conflicts, and chooses remediation. Send
at most one focused retry to the maker. If the diff changes materially, restore
a stable baseline and rerun affected independent review lanes.

Sol independently runs final verification and decides acceptance. Luna output is
evidence, never the completion authority.

## Orchestration terminal gate

A required maker or reviewer that is still running is unfinished work. Never
send a final response merely because an agent is slow or a wait timed out.

- Treat `wait_agent` timeouts as heartbeats, not completion or blockers.
- Keep progress such as "review is running" in commentary only. Continue
  observing, with a concise user update at least every 60 seconds.
- Collect each required agent's `FINAL_ANSWER`; an interim message is not a
  terminal result.
- If an agent stalls, nudge it, inspect status, then interrupt and restart the
  bounded lane when necessary. Do not convert slowness into a user handoff.
- Before final, synthesize findings, remediate and re-review material changes,
  run Sol verification, and call `list_agents`. Every required descendant must
  be terminal and no required CE tail step may still be running.
- When genuinely blocked on external input, interrupt active descendants and
  capture their state before returning control. Never leave orphaned work.

Use this pre-final gate:

```text
[ ] Required makers are terminal and every FINAL_ANSWER is collected
[ ] Required reviewers are terminal and every FINAL_ANSWER is collected
[ ] Findings are resolved or recorded; material remediation was re-reviewed
[ ] Sol verification and required CE quality-tail steps are complete
[ ] list_agents shows no required running descendants
```

If any box is false, remain in the current turn and continue the orchestration
loop using commentary and agent-wait tools.

## CE quality and shipping tail

After the maker–reviewer loop succeeds:

1. Invoke `ce-simplify-code` for non-mechanical diffs large enough to benefit.
2. Invoke `ce-code-review` in report-only/agent mode for every non-mechanical
   implementation diff. Pass the CE plan path when one exists.
3. Sol applies eligible fixes, reruns affected checks, and records residuals in
   the CE-approved durable sink.
4. Invoke `ce-compound` when the work produced a reusable solution, surprising
   failure mode, or project convention.
5. Use CE commit, PR, feedback, browser-test, dogfood, or babysit skills only
   when the user or repository workflow authorizes those state changes.

For user-facing work, retain final UX and visual judgment with Sol and use the
installed UX/design evaluator skills where applicable.

## Verification and closeout

Before claiming completion, report:

- CE artifact and implementation-unit scope;
- requested, configured, and observed maker/reviewer routes separately;
- files changed and scope-drift result;
- maker verification and independent Sol verification;
- Luna review result and any remediation/re-review;
- CE simplify, code-review, and compound status or justified skips;
- Git, PR, push, and CI status without implying actions that did not occur;
- residual risks and rollback information.

Start a new Codex session after agent, plugin, or skill installation changes so
the available roles and skills refresh.
