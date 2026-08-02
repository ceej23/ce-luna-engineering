## Engineering lifecycle

The complete portable Codex policy is [`../../AGENTS.md`](../../AGENTS.md).
Use this fragment only when merging the lifecycle section into an existing
personal or repository-specific `AGENTS.md`.

Use `ce-luna-engineering` as the governing framework and the canonical policy
at `policy/engineering-lifecycle.md`. Classify before execution and publish a
lane, budget, and topology before delegation or Standard/High-risk mutation.
Observe and Sol-only Small work may classify inline without a formal routing
declaration; Standard uses one or more bounded makers and at least one
independent integrated reviewer; High-risk uses the same minimum plus only
focused, risk-justified specialists. Tier 3 always wins. Tier 2/3 topology is
fail-closed before the first write and must include Sol, a maker, and an
independent reviewer; three agents is a baseline, not a ceiling. Multiple
makers require rationale, non-overlapping ownership, dependencies, integration
order, and budget; Sol integrates all units before review, and missing capacity
stops mutation rather than falling back to Sol-only.

Explicitly requested browser-local or single-user artifact replacements may be
Tier 1 Small when bounded and unrelated state is preserved. One-file local
artifacts use one focused validation with no specialist review fan-out.

Sol owns framing, planning, architecture, security, integration, synthesis,
verification, and engineering acceptance. Whenever a maker or reviewer is
selected, preserve exact scope, stop conditions, evidence, independence, and
authorization gates. Architecture and specialist quality practices are
trigger-based lenses inside the selected lane, not mandatory nested workflows.

Direct Codex Desktop and CLI use is the default:
user -> Sol -> optional lane-selected Luna.
For a mediated infrastructure engagement, the operational controller retains
live approval, credentials, service control, deployment, rollback, live
verification, and operational acceptance. Use exactly one repository-
engineering Sol with any maker/reviewer internal to that root; nested
engineering agents must not SSH, deploy, control services, access production
credentials or state, or live-verify.

Track inspect, design, implementation, review, commit, push or pull request,
release, deployment or rollback, credentials, and production authority
separately. Tool access, including `--yolo`, is capability rather than
authority.

Workers return a checkpoint after roughly 10 minutes without material progress;
Standard checkpoints around 30 minutes and stops for reassessment at its
60-minute budget. Review is normally bounded to 15–20 minutes and returns
partial findings or a blocker rather than lingering. Frontend/browser
verification uses one canonical local HTTP preview rooted at the resolved
target; after two failed attempts, switch approach or report the verification
gap and stop.

After acceptance, allow at most three minutes to reassess; material scope
expansion is a fresh task and must preserve the accepted target.

For substantive instrumented work, produce only the allowlisted lifecycle evidence required by `policy/engineering-assessment.md`, validate it before assessment, and preserve `UNVERIFIED` when the runtime cannot prove a required control. Assessment remains report-only and never replaces Sol acceptance or external-write authorization.

This fragment is an adapter, not a complete personal `AGENTS.md`; keep local domain rules and personal settings outside this repository.
