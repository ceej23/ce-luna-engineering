from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def normalized(text: str) -> str:
    for dash in ("\N{EN DASH}", "\N{EM DASH}", "\N{NON-BREAKING HYPHEN}"):
        text = text.replace(dash, "-")
    return " ".join(text.casefold().split())


DOCUMENTS = {
    "canonical policy": read("policy/engineering-lifecycle.md"),
    "README": read("README.md"),
    "portable Codex policy": read("AGENTS.md"),
    "operating guide": read("docs/operating-guide.md"),
    "Hermes Infra adapter": read("surfaces/hermes-infra/README.md"),
    "Codex adapter": read("surfaces/codex/AGENTS.fragment.md"),
    "Codex surface skill": read(
        "surfaces/codex/skills/ce-luna-engineering/SKILL.md"
    ),
    "Claude Code adapter": read("surfaces/claude-code/CLAUDE.fragment.md"),
    "Cursor adapter": read("surfaces/cursor/engineering-workflow.mdc"),
    "package skill": read("skills/ce-luna-engineering/SKILL.md"),
    "bundled README reference": read(
        "skills/ce-luna-engineering/references/operating-model.md"
    ),
    "package metadata": read(
        "skills/ce-luna-engineering/agents/openai.yaml"
    ),
    "Codex surface metadata": read(
        "surfaces/codex/skills/ce-luna-engineering/agents/openai.yaml"
    ),
    "Codex worker packets": read(
        "surfaces/codex/skills/ce-luna-engineering/references/worker-packets.md"
    ),
}
NORMALIZED = {name: normalized(text) for name, text in DOCUMENTS.items()}
MANIFEST = read("manifest/codex-files.tsv")
SKILL_MANIFEST = read("manifest/ce-luna-skill-files.tsv")


class PolicyContractTestCase(unittest.TestCase):
    def assert_fragments(
        self, document_name: str, fragments: tuple[str, ...]
    ) -> None:
        document = NORMALIZED[document_name]
        missing = [
            fragment
            for fragment in fragments
            if normalized(fragment) not in document
        ]
        self.assertFalse(
            missing,
            f"{document_name} is missing contract fragments: {missing}",
        )

    def assert_any_fragment(
        self,
        document_name: str,
        concept: str,
        alternatives: tuple[str, ...],
    ) -> None:
        document = NORMALIZED[document_name]
        self.assertTrue(
            any(normalized(fragment) in document for fragment in alternatives),
            f"{document_name} does not express {concept}; expected one of "
            f"{alternatives}",
        )


class CanonicalProportionalityContractTests(PolicyContractTestCase):
    def test_canonical_policy_defines_all_four_tiers(self) -> None:
        scenarios = {
            "Tier 0": (
                "Tier 0: Observe",
                "no target mutation",
                "Sol only",
                "no maker or reviewer",
            ),
            "Tier 1": (
                "Tier 1: Small",
                "localized, reversible, known solution",
                "Sol or one bounded maker",
                "review only on a named trigger",
            ),
            "Tier 2": (
                "Tier 2: Standard",
                "ordinary mutation",
                "one maker",
                "reviewer",
                "one remediation/re-review",
            ),
            "Tier 3": (
                "Tier 3: High-risk",
                "architecture",
                "public API",
                "security",
                "credentials",
                "production",
                "external writes",
                "Tier 3 always wins",
            ),
        }
        for scenario, fragments in scenarios.items():
            with self.subTest(scenario=scenario):
                self.assert_fragments("canonical policy", fragments)

    def test_canonical_policy_does_not_force_low_risk_delegation(self) -> None:
        self.assert_fragments(
            "canonical policy",
            (
                "Tier 0 and Tier 1 may be Sol-only",
                "smallest lane that contains the risk",
                "review only on a named trigger",
            ),
        )


class TopologyAndAuthorityContractTests(PolicyContractTestCase):
    def test_direct_codex_is_default_and_mediation_is_special(self) -> None:
        for document_name in (
            "canonical policy",
            "README",
            "operating guide",
            "Codex adapter",
            "Codex surface skill",
            "package skill",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(
                    document_name,
                    ("direct", "Codex Desktop", "CLI", "default", "mediated"),
                )
                self.assert_any_fragment(
                    document_name,
                    "the special mediated Infra-to-Codex composition",
                    (
                        "distinct composition",
                        "special composition",
                        "separate composition",
                        "is a composition",
                        "mediated infrastructure engagement",
                    ),
                )

    def test_acceptance_and_each_authority_are_separate_states(self) -> None:
        required = (
            "engineering acceptance",
            "operational acceptance",
            "inspect",
            "design",
            "review",
            "commit",
            "push",
            "release",
            "deployment",
            "rollback",
            "credential",
            "production",
            "separate",
        )
        for document_name in (
            "canonical policy",
            "README",
            "portable Codex policy",
            "operating guide",
            "Codex adapter",
            "Codex surface skill",
            "Claude Code adapter",
            "Cursor adapter",
            "package skill",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(document_name, required)
                self.assert_any_fragment(
                    document_name,
                    "separate implementation authority",
                    ("implementation", "implement"),
                )
                self.assert_any_fragment(
                    document_name,
                    "separate pull-request authority",
                    ("pull request", "push_or_pr", "push/pr"),
                )

    def test_outer_and_inner_lanes_may_differ(self) -> None:
        for document_name in (
            "canonical policy",
            "operating guide",
            "Codex surface skill",
            "package skill",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(
                    document_name,
                    ("outer", "operational lane", "inner", "repository lane"),
                )
                self.assert_any_fragment(
                    document_name,
                    "independent outer and inner lane classification",
                    (
                        "may differ",
                        "classified independently",
                        "can differ",
                    ),
                )

    def test_nested_codex_has_no_operational_authority(self) -> None:
        required = (
            "nested",
            "must not",
            "SSH",
            "deploy",
            "control services",
            "production credentials or state",
        )
        for document_name in (
            "canonical policy",
            "portable Codex policy",
            "operating guide",
            "Codex adapter",
            "Codex surface skill",
            "Claude Code adapter",
            "Cursor adapter",
            "package skill",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(document_name, required)
                self.assert_any_fragment(
                    document_name,
                    "the live-verification prohibition",
                    ("live-verify", "perform live verification"),
                )

    def test_sol_only_low_risk_work_avoids_formal_declaration(self) -> None:
        for document_name in (
            "canonical policy",
            "README",
            "package skill",
            "bundled README reference",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(
                    document_name,
                    (
                        "Tier 0 and Sol-only Tier 1",
                        "without a formal routing declaration",
                        "before delegation or any Tier 2 or Tier 3 mutation",
                    ),
                )

    def test_tool_capability_never_grants_authority(self) -> None:
        for document_name in (
            "canonical policy",
            "portable Codex policy",
            "operating guide",
            "Codex adapter",
            "Codex surface skill",
            "package skill",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(document_name, ("yolo", "capability"))
                self.assert_any_fragment(
                    document_name,
                    "capability not granting authority",
                    (
                        "capability, not authority",
                        "capability rather than authority",
                        "capability does not grant authority",
                        "tool capability, including `--yolo`, is not authority",
                        "tool access does not authorize",
                    ),
                )

    def test_hermes_adapter_preserves_operator_specific_boundaries(self) -> None:
        self.assert_fragments(
            "Hermes Infra adapter",
            (
                "one standalone Codex process",
                "one repository-engineering lifecycle inside Codex",
                "engineering acceptance",
                "operational acceptance",
                "outer operational lane",
                "inner repository lane",
                "codex --yolo exec",
                "capability",
                "authority",
                "must not",
                "SSH",
                "deploy",
                "control services",
                "production credentials",
                "live health verification",
                "ceej23",
                "wesdigital",
                "OpenClaw",
            ),
        )


class ReviewAndQualityTailContractTests(PolicyContractTestCase):
    def test_bounded_progress_and_frontend_preview_are_explicit(self) -> None:
        required = (
            "roughly 10 minutes",
            "30 minutes",
            "60-minute budget",
            "15-20 minutes",
            "canonical local HTTP preview",
            "two failed attempts",
            "verification gap",
        )
        for document_name in (
            "canonical policy",
            "README",
            "portable Codex policy",
            "Codex adapter",
            "Codex surface skill",
            "Claude Code adapter",
            "Cursor adapter",
            "package skill",
            "bundled README reference",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(document_name, required)

    def test_architecture_and_specialist_tails_are_triggered(self) -> None:
        for document_name in (
            "canonical policy",
            "README",
            "portable Codex policy",
            "Codex adapter",
            "Codex surface skill",
            "Claude Code adapter",
            "Cursor adapter",
            "package skill",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(
                    document_name, ("architecture", "specialist")
                )
                self.assert_any_fragment(
                    document_name,
                    "trigger-based quality tails",
                    (
                        "trigger-based",
                        "named-risk lenses",
                        "only for a named risk",
                        "selected-lane or named-risk lenses",
                    ),
                )
                self.assert_any_fragment(
                    document_name,
                    "quality tails not being universal",
                    (
                        "not universal",
                        "rather than made universal",
                        "rather than universal nested workflows",
                        "never mandatory nested workflows",
                        "not mandatory nested workflows",
                        "never nested mandatory lifecycles",
                    ),
                )

    def test_retry_and_re_review_have_distinct_preconditions(self) -> None:
        required = (
            "reviewer",
            "transient",
            "infrastructure failure",
            "unchanged",
            "remediation",
            "changes",
            "focused",
            "re-review",
            "affected",
        )
        for document_name in (
            "canonical policy",
            "README",
            "Codex surface skill",
            "package skill",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(document_name, required)

    def test_blocking_is_criterion_aware(self) -> None:
        required = (
            "P0",
            "P1",
            "block",
            "default",
            "safety",
            "policy",
            "authorization",
            "acceptance",
            "regardless",
            "numeric severity",
            "P2",
            "P3",
            "defer",
        )
        for document_name in (
            "canonical policy",
            "README",
            "portable Codex policy",
            "Codex surface skill",
            "package skill",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(document_name, required)


class CrossSurfaceDriftContractTests(PolicyContractTestCase):
    def test_each_adapter_and_skill_declares_proportional_routing(self) -> None:
        for document_name in (
            "portable Codex policy",
            "Codex adapter",
            "Codex surface skill",
            "Claude Code adapter",
            "Cursor adapter",
            "package skill",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(
                    document_name,
                    ("Observe", "Small", "Standard", "High-risk"),
                )
                self.assert_any_fragment(
                    document_name,
                    "smallest risk-containing lane",
                    (
                        "smallest lane that contains the risk",
                        "smallest safe lane",
                        "classify before execution",
                        "classifies the request before execution",
                    ),
                )

    def test_each_surface_rejects_legacy_universal_delegation(self) -> None:
        legacy_phrases = (
            "all software-repository changes must follow this lifecycle",
            "all software-repository changes use this lifecycle",
            "all software-repository changes must use `ce-luna-engineering`",
            "for every software-repository change, invoke `ce-luna-engineering`",
            "dispatch only the named `luna_maker`",
            "for every non-mechanical implementation diff",
        )
        for document_name in DOCUMENTS:
            document = NORMALIZED[document_name]
            found = [
                phrase
                for phrase in legacy_phrases
                if normalized(phrase) in document
            ]
            with self.subTest(document=document_name):
                self.assertFalse(
                    found,
                    f"{document_name} retains universal delegation language: "
                    f"{found}",
                )

    def test_codex_skill_source_is_independently_manifested(self) -> None:
        self.assertIn("skills/ce-luna-engineering/SKILL.md\tSKILL.md", SKILL_MANIFEST)
        self.assertNotIn("skills/ce-luna-engineering", MANIFEST)

    def test_canonical_skill_install_does_not_revert_to_codex_home(self) -> None:
        installer = read("scripts/install-codex.sh")
        checker = read("scripts/check-codex-drift.sh")
        for script in (installer, checker):
            self.assertIn(".agents/skills/ce-luna-engineering", script)
            self.assertNotIn('.codex/skills/ce-luna-engineering', script)

    def test_skill_migration_distinguishes_target_override_from_discovery(self) -> None:
        for document_name in ("README", "bundled README reference"):
            document = NORMALIZED[document_name]
            self.assertIn("ce_skill_root", document)
            self.assertTrue(
                "not a runtime discovery selector" in document
                or "never a runtime discovery selector" in document
            )
            self.assertIn(".agents/skills/ce-luna-engineering", document)
        self.assertIn("ce_skill_root", NORMALIZED["operating guide"])
        self.assertIn(".agents/skills/ce-luna-engineering", NORMALIZED["operating guide"])
        self.assertIn("$codex_home/skills", NORMALIZED["README"])
        self.assertIn("destination parent", NORMALIZED["README"])

    def test_installed_skill_uses_authoritative_package_source(self) -> None:
        manifest_rows = {
            tuple(line.split("\t", 1))
            for line in SKILL_MANIFEST.replace("\r\n", "\n").splitlines()
            if line and not line.startswith("#")
        }
        package_files = {
            "SKILL.md",
            "agents/openai.yaml",
            "references/operating-model.md",
            "references/LICENSE",
        }
        for relative_file in package_files:
            with self.subTest(file=relative_file):
                self.assertIn(
                    (
                        f"skills/ce-luna-engineering/{relative_file}",
                        relative_file,
                    ),
                    manifest_rows,
                )

    def test_local_artifact_exception_keeps_review_triggers_and_promotion(self) -> None:
        bounded_rule = (
            "For an explicitly requested, bounded, reversible browser-local or "
            "single-user artifact replacement that preserves unrelated state, a "
            "one-file local artifact must not fan out specialist review: run one "
            "focused validation and stop. This never suppresses a named Tier 1 "
            "review trigger or Tier 2/3 promotion"
        )
        for document_name in (
            "package skill",
            "Codex surface skill",
            "Claude Code adapter",
            "Cursor adapter",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(document_name, (bounded_rule,))

    def test_completion_stop_and_migration_guidance_are_contractual(self) -> None:
        stop = (
            "at most three minutes",
            "newly discovered issue",
            "new outcome",
            "material scope expansion",
            "preserve the accepted target",
            "start a fresh task",
        )
        migration = (
            "inventory every",
            "precedence",
            "preserve RTK",
            "fresh task",
            "rollback",
            "drift",
        )
        for document_name in ("package skill", "README", "Codex surface skill"):
            with self.subTest(document=document_name):
                self.assert_fragments(document_name, stop)
                self.assert_fragments(document_name, migration)

    def test_claude_and_cursor_use_canonical_post_acceptance_stop(self) -> None:
        canonical = (
            "After acceptance, allow at most three minutes to reassess a newly "
            "discovered issue. If it is a new outcome or material scope "
            "expansion, stop, preserve the accepted target, and start a fresh "
            "task rather than churning in the old root."
        )
        for document_name in ("Claude Code adapter", "Cursor adapter"):
            with self.subTest(document=document_name):
                self.assert_fragments(document_name, (canonical,))

    def test_openai_metadata_preserves_proportional_routing(self) -> None:
        for document_name in (
            "package metadata",
            "Codex surface metadata",
        ):
            with self.subTest(document=document_name):
                self.assert_fragments(
                    document_name,
                    ("proportional", "classify", "smallest safe", "lane"),
                )
                self.assertNotIn(
                    normalized("with Luna maker and reviewer lanes"),
                    NORMALIZED[document_name],
                )

    def test_worker_packets_cover_lane_review_and_mediated_authority(
        self,
    ) -> None:
        self.assert_fragments(
            "Codex worker packets",
            (
                "selected lane",
                "review trigger",
                "transient",
                "unchanged target",
                "remediation changes the target",
                "focused independent re-review",
                "Mediated operator packet",
                "inspect",
                "design",
                "implement",
                "review",
                "commit",
                "push/PR",
                "release",
                "deploy/rollback",
                "credentials",
                "production",
                "nested SSH",
                "live verification",
            ),
        )


if __name__ == "__main__":
    unittest.main()
