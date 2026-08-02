# Canonical engineering assessment policy

This policy defines how deployments of the CE + Sol/Luna lifecycle collect and assess workflow-alignment evidence. It supplements, and never replaces, the lifecycle authority in [`engineering-lifecycle.md`](engineering-lifecycle.md).

## Assessment invariants

- A substantive coding run is an implementation, refactor, bug-fix, test, or infrastructure change that modifies a repository or dispatches a maker or reviewer. Read-only analysis and tiny mechanical edits may be recorded voluntarily but are not required to emit a bundle.
- An instrumented substantive run uses one correlation ID and records only allowlisted lifecycle facts in a versioned evidence bundle.
- Every control declares the host capability that supports it: `enforced`, `observed`, `attested`, or `unsupported`. Adapter wording alone is never proof of enforcement.
- Requested, configured, observed, and unknown model or agent routing facts remain distinct. Missing runtime metadata is `unknown`.
- Sol owns acceptance, external-write authorization, policy changes, exception approval, and every decision that changes the assessment contract.

## Conformance state machine

An evidence bundle progresses in order from `COLLECTING` to `SEALED` to `VALIDATED`. Validation then records one terminal control result:

- `PASS`: every applicable control has valid, sufficient evidence.
- `FAIL`: a validated control was violated.
- `UNVERIFIED`: evidence is missing, malformed, stale, unsupported, sensitive, tampered, or otherwise insufficient.
- `EXCEPTION`: an approved, run-scoped waiver accompanies an underlying `FAIL` or `UNVERIFIED` result.

Terminal results are immutable. `EXCEPTION` does not replace its underlying result with `PASS`, and no conformance result accepts work, authorizes an external write, or changes policy.

Assessment is optional, post-execution, and report-only. It stays off the
engineering critical path: an absent bundle never blocks mutation or
acceptance, while malformed supplied evidence is `UNVERIFIED` only as an
assessment result. The validator reports recorded facts; it does not prove
that a host dispatched the recorded actors.

## Evidence and privacy

Bundles contain only fields defined in `assessment/schema/run-events-v1.tsv` and capability declarations in `assessment/schema/capability-matrix-v1.tsv`. They may include repository-relative identifiers, policy and adapter digests, Git object identifiers, lifecycle control IDs, bounded status values, and opaque identifiers for permitted artifacts.

The validator verifies the policy digest and bundle structure; it does not read or authenticate external artifact contents. An artifact reference is evidence of where a permitted, separately governed record is held, not proof of that record's contents. Signed capture or external artifact authentication is deferred until a host can provide it without widening the privacy boundary.

The local validator requires Python 3 from the standard library for its
descriptor-relative safe-open helper. It uses no third-party package. Python 3,
descriptor-relative opens, or the platform's no-follow primitive may be absent;
in any such case validation fails closed as `UNVERIFIED` before reading the
bundle.

Bundles must not contain raw prompts, transcripts, diffs, source, absolute paths, environment values, credentials, machine settings, connector data, histories, caches, databases, personal configuration, or unbounded command output. Redaction occurs before a bundle is sealed. A detected prohibited value makes the affected control `UNVERIFIED`; diagnostics remain local and must not reproduce the rejected value.

## Exceptions

An exception records the affected run and control, the underlying result, approver, reason, expiry, and policy version. It is non-transferable across runs and policy versions, expires by default, and may be revoked. A reviewer write, an integrity mismatch, or evidence of unauthorized delivery cannot be waived into `PASS`.

## Model-assisted assessment

Model-assisted assessment consumes only sealed, redacted, validator-approved summaries. It may classify routine evidence or produce cited, confidence-qualified recommendations. It may not modify a bundle, validator result, policy, adapter, deployment, approval, Git state, release, or production system.

Adopting a recommendation follows the normal policy-first contribution flow: Sol or an explicitly authorized human approves the change, affected adapters and checks are updated, and the resulting change is independently reviewed.

## Isolated weekly windows

Assessment state is local and keyed by the explicit agent and repository
identifiers. Agents must never share, aggregate, or read another identity's
records. A completed window is a UTC ISO week with at least 20 validated
summaries. Keep no more than 13 closed windows. Routine candidates require the
same signal in two consecutive covered windows; a severe validated `FAIL` is
an immediate candidate. Late summaries are ingested into the current open
week. Partial reports are on-demand and ephemeral. Approximately 30 runs per
week is expected volume, not a threshold.

The due check is idempotent and report-only. It must not register an operating
system scheduler, create shared records, aggregate across identities, mutate
delivery state, edit policy automatically, or create/approve proposals.
