# ADR 0002: Engineering workflow assessment

Status: accepted  
Date: 2026-07-24

## Decision

The repository will assess workflow alignment from sealed, privacy-minimised lifecycle evidence rather than transcripts or configuration claims. The canonical assessment policy owns evidence, capability, exception, and conformance semantics. Surface adapters declare only capabilities their host can establish.

Validation uses the terminal results `PASS`, `FAIL`, `UNVERIFIED`, and `EXCEPTION`. These are evidence states, not acceptance or delivery authority. A model-assisted assessor is report-only and may recommend changes only through the existing human-approved policy-first workflow.

## Consequences

This makes cross-surface limitations visible, keeps runtime data out of canonical policy, and permits comparable periodic reports without central telemetry. It also requires a strict evidence allowlist, a capability matrix, fixture-backed validation, and explicit exception records.
