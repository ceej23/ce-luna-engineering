# Worker packet contracts

Use these shapes as checklists, not prose templates to copy blindly. Exclude
conversation history and architecture rationale that the worker does not need.

## Luna maker packet

Include:

1. Selected lane, budget, and routing reason.
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

For substantive instrumented work, the Sol-owned closeout records only the
allowlisted lifecycle facts from the canonical assessment policy. Makers must
not collect prompts, transcripts, source, diffs, absolute paths, environment
values, or command output for assessment.

Before dispatch, capture `git status --short` and the relevant diff without
altering unrelated user work.

## Luna reviewer packet

Include:

1. Selected lane, review trigger, and routing reason.
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
- Retry once only when reviewer infrastructure fails transiently against an
  unchanged target.
- After remediation changes the target, run one focused independent re-review
  of affected axes.
- Treat P0/P1 as blocking by default. Treat any acceptance, safety, security,
  policy, authorization, or rollout violation as blocking regardless of
  numeric severity; other P2/P3 findings may be deferred.
- Run parent-owned verification after the final change.
- Preserve CE review artifacts and durable residual records.
- Seal and validate the minimal assessment bundle after synthesis when the run
  is instrumented. Treat the result as evidence, not acceptance.
- Only after Sol accepts, use the installed assessment runtime for validation,
  ingestion, and the idempotent report-only weekly due check. Makers never
  access assessment state. Missing, drifted, or failed cadence is
  `UNVERIFIED` setup drift and cannot delay or reverse acceptance.

## Mediated operator packet

When an operational controller invokes one repository-engineering Sol, include:

1. Immutable repository outcome and available evidence.
2. Repository/worktree, allowed reads, and exact writes.
3. Outer operational lane if known; engineering Sol selects the inner
   repository lane independently.
4. Separate authority states for inspect, design, implement, review, commit,
   push/PR, release, deploy/rollback, credentials, and production.
5. Explicit prohibitions on nested SSH, deployment, service control,
   production credentials/state, and live verification.
6. Engineering acceptance criteria, checks, stop conditions, remaining budget,
   and return contract.

The engineering return covers changed files or diff, checks, review result,
residual risks, rollback-relevant notes, delivery state, and operator steps.
The operator retains live authorization, deployment, rollback, verification,
and operational acceptance.
