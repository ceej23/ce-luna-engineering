# Worker packet contracts

Use these shapes as checklists, not prose templates to copy blindly. Exclude
conversation history and architecture rationale that the worker does not need.

## Luna maker packet

Include:

1. Routing record: `Routing: <task>; selected luna_maker (gpt-5.6-luna/medium); reason: bounded implementation.`
2. Absolute working directory.
3. Objective and CE plan/unit identifiers.
4. Allowed read scope.
5. Exact write scope.
6. Acceptance criteria stated as observable behavior.
7. Exact verification commands.
8. Prohibited operations:
   - files outside scope;
   - architecture, API, schema, migration, dependency, security, sandbox,
     credential, Git, release, deployment, production, or destructive changes;
   - subagent spawning.
9. Stop conditions for ambiguity, unexpected changes, missing tools, or scope
   expansion.
10. Return contract: files changed, verification commands/results, blockers and
   residual risks.

Before dispatch, capture `git status --short` and the relevant diff without
altering unrelated user work.

## Luna reviewer packet

Include:

1. Routing record: `Routing: <task>; selected luna_reviewer (gpt-5.6-luna/high); reason: independent bounded review.`
2. Absolute working directory and read-only requirement.
3. Stable review base and target diff.
4. CE plan path, unit IDs, and acceptance criteria.
5. Review axes appropriate to the slice: correctness, regression, tests,
   accessibility, UX, performance, or maintainability.
6. Explicit exclusions: no edits, commits, pushes, acceptance, architecture or
   security-policy decisions, or subagent spawning.
7. Findings contract:
   - severity;
   - file and line or symbol;
   - direct evidence;
   - violated requirement or criterion;
   - impact;
   - bounded remediation direction.
8. Return `no findings` explicitly when the evidence supports it.

Capture worktree status immediately before and after the reviewer. A changed
worktree invalidates the lane even when the reviewer claims it was report-only.

## Sol synthesis checklist

- Confirm every finding against the source and diff.
- Separate correctness from preference.
- Keep security, architecture, product, UX, and acceptance decisions with Sol.
- Apply or delegate only bounded remediation.
- Re-review after a material diff change.
- Run parent-owned verification after the final change.
- Preserve CE review artifacts and durable residual records.
