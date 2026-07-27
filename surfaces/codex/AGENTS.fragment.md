## Engineering lifecycle

The complete portable Codex policy is [`../../AGENTS.md`](../../AGENTS.md).
Use this fragment only when merging the lifecycle section into an existing
personal or repository-specific `AGENTS.md`.

Use `ce-luna-engineering` as the governing framework and the canonical policy
at `policy/engineering-lifecycle.md`. Classify before execution and publish a
lane, budget, and topology before mutation or delegation. Observe and Small may
be Sol-only; Standard uses one bounded maker and one independent reviewer;
High-risk uses the full boundaries plus only focused, risk-justified
specialists. Tier 3 always wins.

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

For substantive instrumented work, produce only the allowlisted lifecycle evidence required by `policy/engineering-assessment.md`, validate it before assessment, and preserve `UNVERIFIED` when the runtime cannot prove a required control. Assessment remains report-only and never replaces Sol acceptance or external-write authorization.

This fragment is an adapter, not a complete personal `AGENTS.md`; keep local domain rules and personal settings outside this repository.
