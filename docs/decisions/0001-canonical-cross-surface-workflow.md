# ADR 0001: Canonical cross-surface workflow

Status: accepted  
Date: 2026-07-24

## Decision

Git is the source of truth for the shared lifecycle and safe surface fragments. Home-directory Codex files are deployments, not independent policy sources. The portable invariants live in [`policy/engineering-lifecycle.md`](../../policy/engineering-lifecycle.md), while each adapter translates them into native instructions.

Codex synchronization uses an explicit manifest and opt-in installer. Only listed targets may be compared or installed, and differing files receive a recoverable timestamped backup before replacement.

## Consequences

This makes runtime drift visible and reviewable without tracking credentials, machine paths, trust settings, MCP details, caches, histories, databases, or unrelated preferences. Claude Code and Cursor preserve behavioral boundaries but do not promise Codex-only named-agent routing or sandbox enforcement.

## Adoption

Read the [operating guide](../operating-guide.md), review the adapter for the chosen surface, and apply only the documented installation command. Changes to the policy require corresponding adapter and drift-check updates.
