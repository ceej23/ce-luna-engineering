# Canonical engineering lifecycle

This repository is the canonical, reviewable source for the CE + Sol/Luna workflow. The vendor-neutral policy owns lifecycle semantics; Codex, Claude Code, and Cursor files are adapters that cite this policy.

All software-repository changes must follow this lifecycle. Read-only
inspection, explanation, planning, and documentation-only work may use a
proportionate direct workflow, but must not be used to bypass lifecycle gates
for code, test, configuration, or other behavior-changing edits. If a surface
cannot provide the required lifecycle capability, stop before write work and
report the limitation rather than silently substituting another workflow.

## Invariants

- Sol owns intent, planning, architecture, security, integration, synthesis, verification, and final acceptance.
- Luna makers implement only bounded units with exact file ownership and observable criteria.
- An independent Luna reviewer inspects a stable diff read-only and reports evidence-backed findings; the reviewer must not author the slice.
- External writes (Git, releases, deployment, production, credentials, and live services) require explicit authorization from Sol.
- Verification evidence is required before acceptance; unexpected scope or a control-bearing decision stops the worker and returns it to Sol.

## Authority and state

Git-tracked policy and adapter fragments are canonical. Installed files under a user's home directory are deployments and may be checked for drift. Machine local settings, credentials, caches, histories, databases, trust settings, connectors, and personal preferences are explicitly not canonical and must never be copied by this project.

Surface adapters may express native syntax and capabilities, but may not claim unsupported routing, sandbox, or approval guarantees. Change lifecycle meaning here first, then update every affected adapter and its verification guidance.

Assessment semantics, evidence privacy, capability declarations, and conformance outcomes are owned by [`engineering-assessment.md`](engineering-assessment.md). Assessment results are evidence for Sol; they do not grant acceptance, authorization, release, deployment, or policy-change authority.
