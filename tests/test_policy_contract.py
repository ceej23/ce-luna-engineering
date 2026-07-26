from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
README = (ROOT / "README.md").read_text(encoding="utf-8")
SKILL = (
    ROOT / "skills" / "ce-luna-engineering" / "SKILL.md"
).read_text(encoding="utf-8")
REFERENCE = (
    ROOT
    / "skills"
    / "ce-luna-engineering"
    / "references"
    / "operating-model.md"
).read_text(encoding="utf-8")
OPENAI = (
    ROOT / "skills" / "ce-luna-engineering" / "agents" / "openai.yaml"
).read_text(encoding="utf-8")
NORMALIZED_README = " ".join(README.split())
NORMALIZED_SKILL = " ".join(SKILL.split())


class TierRoutingContractTests(unittest.TestCase):
    def test_routes_representative_scenarios(self) -> None:
        scenarios = {
            "read-only diagnosis": (
                "**Tier 0: Observe**",
                "No target mutation",
                "no maker or reviewer",
                "15 minutes",
            ),
            "localized reversible edit": (
                "**Tier 1: Small**",
                "Localized, reversible, known solution",
                "review only on a named trigger",
                "30 minutes",
            ),
            "ordinary cross-cutting change": (
                "**Tier 2: Standard**",
                "Ordinary mutation",
                "one remediation/re-review maximum",
                "60 minutes",
            ),
            "security or production change": (
                "**Tier 3: High-risk**",
                "security, credentials",
                "production, external writes",
                "Explicit task budget",
            ),
        }
        for scenario, expected_fragments in scenarios.items():
            with self.subTest(scenario=scenario):
                for fragment in expected_fragments:
                    self.assertIn(fragment, README)

    def test_high_risk_precedence_and_showcase_gate_are_explicit(self) -> None:
        self.assertIn("a Tier 3 trigger always wins", README)
        self.assertIn(
            "direction-selection lane only when no Tier 3 trigger applies",
            NORMALIZED_README,
        )
        self.assertIn("human selection", README)
        self.assertIn("visual-fidelity contract", README)
        self.assertIn("Renderer-only variants", README)

    def test_observe_and_small_are_not_forced_through_delegation(self) -> None:
        for document in (README, SKILL):
            self.assertIn("Tier 0 and Tier 1 may be Sol-only", document)
            self.assertNotIn(
                "For a tiny change, the lead may use a compact packet",
                document,
            )


class BudgetAndTerminationContractTests(unittest.TestCase):
    def test_context_and_root_limits_are_published(self) -> None:
        for fragment in (
            "Full-history delegation requires written justification",
            "one accepted outcome or immutable target per root",
            "When material scope expansion arrives after acceptance, stop",
            "Do not implement it in the current root",
            "require a fresh task for the new outcome",
            "authority delta + remaining budget",
        ):
            self.assertIn(fragment, NORMALIZED_README)

    def test_mutating_work_requires_a_routing_declaration(self) -> None:
        for document in (NORMALIZED_README, NORMALIZED_SKILL):
            self.assertIn(
                "Lane: [selected lane] | Budget: [time/cost limit] | Agents: [topology]",
                document,
            )
            self.assertIn(
                "Do not begin mutating work",
                document,
            )
            self.assertIn("explicit budget", document)

    def test_review_and_terminal_limits_are_published(self) -> None:
        for fragment in (
            "P0 and P1 findings block",
            "P2 and P3 findings go to the backlog",
            "one reviewer attempt and one retry",
            "Suggestions do not reopen the",
            "Do not create review panels by default",
            "at most one broad",
        ):
            self.assertIn(fragment, NORMALIZED_README)

    def test_budget_breach_stops_instead_of_escalating(self) -> None:
        self.assertIn(
            "Report progress, evidence, and remaining risk instead of silently escalating",
            NORMALIZED_README,
        )
        self.assertIn(
            "On budget breach, stop and report progress, evidence, and remaining risk",
            NORMALIZED_SKILL,
        )


class SafetyAndDistributionContractTests(unittest.TestCase):
    def test_luna_boundaries_remain_when_roles_are_used(self) -> None:
        for fragment in (
            "Whenever a Luna maker or reviewer is used",
            "Do not give a maker architecture",
            "Review is read-only",
            "external writes require separate explicit user authorization",
        ):
            self.assertIn(fragment, README + "\n" + SKILL)

    def test_bundled_reference_matches_readme(self) -> None:
        marker = "<!-- BEGIN CANONICAL README -->"
        self.assertIn(marker, REFERENCE)
        bundled = REFERENCE.split(marker, 1)[1].lstrip("\r\n")
        self.assertEqual(
            bundled.replace("\r\n", "\n"),
            README.replace("\r\n", "\n"),
        )

    def test_openai_metadata_routes_to_smallest_safe_lane(self) -> None:
        self.assertIn("proportional CE + Sol/Luna", OPENAI)
        self.assertIn("classify this task", OPENAI)
        self.assertIn("smallest safe CE + Sol/Luna lane", OPENAI)


if __name__ == "__main__":
    unittest.main()
