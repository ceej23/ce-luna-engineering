## CE + Sol/Luna lifecycle

Follow [`policy/engineering-lifecycle.md`](../../policy/engineering-lifecycle.md). Sol retains intent, planning, architecture, security, integration, synthesis, verification, acceptance, and authorization for external writes. Implementers work only in bounded packets with exact scope and evidence. An independent reviewer reads a stable change read-only, reports severity and remediation, and does not author or accept it.

All software-repository changes use this lifecycle. Read-only inspection,
explanation, planning, and documentation-only work may use a proportionate
direct workflow, but this exception does not cover code, test, configuration,
or other behavior-changing edits. Stop before write work if the surface cannot
provide the required lifecycle capability.

Claude Code should express these behavioral boundaries in its native project instructions. This adapter does not claim Codex named-agent routing, model selection, sandbox enforcement, or equivalent host controls.
