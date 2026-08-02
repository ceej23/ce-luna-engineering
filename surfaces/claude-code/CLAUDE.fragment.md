## CE + Sol/Luna lifecycle

Follow the locally adopted canonical engineering lifecycle policy. Classify the
work before execution and use the smallest safe lane. Observe and Small may be
Sol-only; Standard uses one or more bounded makers and at least one independent
integrated reviewer; High-risk uses the same minimum plus only risk-justified
specialists. Sol
retains intent, planning, architecture, security, integration, synthesis,
verification, and engineering acceptance.

For Tier 2/3, the declared topology is fail-closed before the first write and
must include Sol, a maker, and an independent reviewer; user silence cannot
downgrade it. Three agents is a baseline, not a ceiling. Multiple makers need
non-overlapping ownership, dependencies, integration order, rationale, and
budget; Sol integrates all units before review, and unavailable capacity stops
mutation rather than falling back to Sol-only.

For an explicitly requested, bounded, reversible browser-local or single-user
artifact replacement that preserves unrelated state, a one-file local artifact
must not fan out specialist review: run one focused validation and stop. This
never suppresses a named Tier 1 review trigger or Tier 2/3 promotion; promote
when any trigger applies.

Whenever a worker is selected, use a bounded packet with exact scope and
evidence. Required review reads a stable target, reports findings, and does not
author or accept it. Architecture and specialist quality practices are
trigger-based lenses rather than universal nested workflows.

Workers checkpoint after roughly 10 minutes without material progress;
Standard checkpoints around 30 minutes and stops for reassessment at its
60-minute budget. Review is normally bounded to 15–20 minutes and returns
partial findings or a blocker rather than lingering. Frontend/browser
verification uses one canonical local HTTP preview rooted at the resolved
target; after two failed attempts, switch approach or report the verification
gap and stop.

After acceptance, allow at most three minutes to reassess a newly discovered
issue. If it is a new outcome or material scope expansion, stop, preserve the
accepted target, and start a fresh task rather than churning in the old root.

Direct use is the default. In a mediated infrastructure engagement, keep
repository engineering inside one engineering root and leave approval,
credentials, service control, deployment, rollback, live verification, and
operational acceptance with the operational controller. Nested engineering
agents must not SSH, deploy, control services, access production credentials or
state, or perform live verification. Tool capability does not grant those
authorities.

Keep inspect, design, implementation, review, commit, push or pull request,
release, deployment or rollback, credentials, and production authority
separate.

When host evidence is available, attach only the allowlisted lifecycle facts required by the locally adopted assessment policy. This adapter does not claim Codex named-agent routing, model selection, sandbox enforcement, approval enforcement, or equivalent host controls; unavailable controls remain unverified.
