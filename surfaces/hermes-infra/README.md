# Hermes Infra to Codex composition

This adapter applies when a production infrastructure operator delegates
repository engineering to a standalone Codex process. It is intentionally
different from direct Codex Desktop and CLI use, which remain the default
engagements.

## Authority topology

```text
Chris
  -> Hermes Infra: operational controller
  -> one standalone Codex process: repository-engineering Sol
       -> required Tier 2/3 Luna maker/reviewer topology when those lanes are selected
  -> Hermes Infra: deployment, rollback and live verification
```

This is one repository-engineering lifecycle inside Codex. Infra does not wrap
it in a second maker/reviewer lifecycle or create another panel for the same
repository outcome.

## Independent lanes and acceptance

Infra classifies the outer operational lane. Codex classifies the inner
repository lane. The lanes may differ: a live deployment remains operational
Tier 3 even when its isolated repository edit is Tier 1. Repository
architecture, public API or schema, migration, dependency, security,
credential, privacy, production-code, external-write, or irreversible triggers
still promote the inner repository lane to Tier 3.

Codex makes engineering acceptance only. Infra makes operational acceptance
after separately authorized deployment and live health verification. Neither
acceptance substitutes for the other.

## Infra ownership

Infra owns:

- Chris's operational intent and approval capture;
- live current-state inspection and failure-layer diagnosis;
- live-risk classification and reversible remediation choices;
- production controls, credentials, and service lifecycle actions;
- deployment, rollback, live health verification, and operational acceptance;
- separation of Hermes state from retired OpenClaw state; and
- GitHub operations restricted to Chris's personal `ceej23` repositories, with
  no access to the `wesdigital` organization.

## Engineering Sol ownership

The standalone Codex process owns:

- repository framing within Infra's immutable outcome;
- inner lane selection, technical design, and architecture;
- maker/reviewer routing inside the single engineering root; Tier 2/3 requires
  Sol, one or more bounded makers, and at least one independent integrated
  reviewer before the first write;
- integration, focused checks, at most one broad Sol check by default;
- engineering acceptance; and
- an operator-ready return contract.

Codex may refine technical acceptance criteria. It stops rather than
reinterpreting ambiguous product or operational intent.

Tier 2/3 publishes `Lane | Budget | Agents | Units` and requires Sol, one or
more bounded makers, and an independent integrated reviewer before the first
write. Use multiple makers only for genuinely independent, non-overlapping
units; record IDs and owned paths, adding dependency/order only when needed.
Sol integrates all units before review. If mandatory capacity is unavailable,
mutation stops unless facts justify reclassification.

## Invocation packet

Infra sends one bounded packet containing:

```text
Immutable repository outcome:
Repository and worktree:
Evidence and current-state observations:
Allowed reads:
Exact writes:
Engineering acceptance criteria:
Verification commands or expectations:
Outer operational lane:
Remaining engineering budget:

Authority:
  inspect: granted|withheld
  design: granted|withheld
  implement: granted|withheld
  review: granted|withheld
  commit: granted|withheld
  push_or_pr: granted|withheld
  release: granted|withheld
  deploy_or_rollback: withheld
  credentials: withheld
  production_or_live_services: withheld

Prohibited operations:
Stop conditions:
Return contract:
```

Unspecified authority is withheld. `codex --yolo exec` grants tool capability;
it does not change the authority record.

## Hard boundary

Nested Codex and Luna agents must not:

- SSH back into the same VPS or another operator-controlled host;
- deploy, roll back, restart, stop, or control services;
- access production credentials, secrets, or state;
- perform live health verification;
- broaden GitHub access beyond the repositories and organizations explicitly
  authorized in the packet, including any access to `wesdigital`; or
- commit, push, release, or perform another external write unless that exact
  authority is granted.

Discovery of a required prohibited action or ambiguous authority stops the
engineering lane and returns control to Infra.

## Operator-ready return

Codex returns:

- selected repository lane and consumed budget;
- changed files or stable diff scope;
- focused and broad checks with results;
- maker/reviewer routing and findings when selected;
- engineering acceptance or blockers;
- residual risks and rollback-relevant notes;
- commit, push, release, and other delivery states without implication;
- exact operator steps or preconditions; and
- confirmation that no SSH, deployment, service control, credential access, or
  live verification occurred.

Infra performs only the separately authorized deployment-specific and live
verification that follows. It does not repeat repository review unless new
evidence or a changed deployment artifact invalidates engineering acceptance.
