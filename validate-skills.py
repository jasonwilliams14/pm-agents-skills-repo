#!/usr/bin/env python3
"""
Validate skill manifest integrity against dispatcher pipelines and templates.

This script prevents silent failures where pipelines reference missing skills,
broken dependency chains, or non-existent templates.

Usage:
    python validate-skills.py              # Check all
    python validate-skills.py --strict     # Fail on warnings, not just errors
    python validate-skills.py --skip-index # Skip generating lookup index

Exit codes:
    0 = all checks passed
    1 = errors found (or warnings in strict mode)
"""
import json
import yaml
import sys
from pathlib import Path
from typing import List, Dict, Set
import argparse

# Paths
AGENTS_HOME = Path.home() / ".agents"
MANIFEST_PATH = AGENTS_HOME / ".skills_manifest.json"
DISPATCHER_PATH = AGENTS_HOME / "dispatcher.yaml"
TEMPLATES_DIR = AGENTS_HOME / "templates"
SKILLS_DIR = AGENTS_HOME / "skills"
LOOKUP_INDEX_PATH = AGENTS_HOME / ".skills_lookup_index.json"

# Color output
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
BLUE = "\033[94m"
RESET = "\033[0m"


class SkillValidator:
    """Validate the skill system integrity."""

    def __init__(self, strict: bool = False):
        """Initialize validator.

        Args:
            strict: If True, warnings are treated as errors
        """
        self.strict = strict
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.manifest: Dict = {}
        self.dispatcher: Dict = {}
        self.load_configs()

    def load_configs(self) -> None:
        """Load manifest and dispatcher configs."""
        if not MANIFEST_PATH.exists():
            self.errors.append(f"Manifest not found: {MANIFEST_PATH}")
            return
        if not DISPATCHER_PATH.exists():
            self.errors.append(f"Dispatcher not found: {DISPATCHER_PATH}")
            return

        try:
            with open(MANIFEST_PATH) as f:
                self.manifest = json.load(f)
        except json.JSONDecodeError as e:
            self.errors.append(f"Manifest JSON parse error: {e}")
            return

        try:
            with open(DISPATCHER_PATH) as f:
                self.dispatcher = yaml.safe_load(f)
        except yaml.YAMLError as e:
            self.errors.append(f"Dispatcher YAML parse error: {e}")
            return

    def validate_skill_exists(self, skill_name: str) -> bool:
        """Check if skill SKILL.md file exists."""
        if not skill_name:
            return False
        skill_path = SKILLS_DIR / skill_name / "SKILL.md"
        return skill_path.exists()

    def validate_template_exists(self, template_name: str) -> bool:
        """Check if template file exists."""
        if not template_name:
            return False
        template_path = TEMPLATES_DIR / template_name
        return template_path.exists()

    def validate_dependency_chain(self, chain: str) -> List[str]:
        """Parse and validate a dependency chain.

        Args:
            chain: String like "skill-1 -> skill-2 -> skill-3"

        Returns:
            List of missing skill names
        """
        if not chain or not chain.strip():
            return []
        skills = [s.strip() for s in chain.split("->")]
        missing = [s for s in skills if not self.validate_skill_exists(s)]
        return missing

    def check_manifest_integrity(self) -> None:
        """Validate each skill in manifest."""
        print(f"\n{BLUE}[1/5] Checking manifest integrity...{RESET}")

        if not self.manifest:
            self.errors.append("Manifest is empty or failed to load")
            return

        for skill_name, skill_config in self.manifest.items():
            # Check SKILL.md exists
            if not self.validate_skill_exists(skill_name):
                self.errors.append(
                    f"Skill '{skill_name}' in manifest but SKILL.md missing "
                    f"(expected: {SKILLS_DIR / skill_name / 'SKILL.md'})"
                )
                continue

            # Check dependency chains
            chain = skill_config.get("composition", {}).get("dependency_chain", "")
            if chain and (missing := self.validate_dependency_chain(chain)):
                self.errors.append(
                    f"{skill_name}: dependency chain broken — missing {missing}"
                )

            # Check templates
            for template in skill_config.get("artifacts", {}).get(
                "preferred_templates", []
            ):
                if not self.validate_template_exists(template):
                    self.errors.append(
                        f"{skill_name}: preferred template '{template}' missing "
                        f"(expected: {TEMPLATES_DIR / template})"
                    )

            # Check adopted_status is one of valid values
            adopted_status = skill_config.get("meta", {}).get("adopted_status")
            if adopted_status and adopted_status not in [
                "active",
                "maintained",
                "deprecated",
            ]:
                self.warnings.append(
                    f"{skill_name}: adopted_status '{adopted_status}' not in "
                    "[active, maintained, deprecated]"
                )

        if not self.errors:
            print(f"  {GREEN}✓ All {len(self.manifest)} skills have valid SKILL.md files{RESET}")

    def check_dispatcher_integrity(self) -> None:
        """Validate dispatcher pipelines reference valid skills."""
        print(f"{BLUE}[2/5] Checking dispatcher pipelines...{RESET}")

        if not self.dispatcher:
            self.warnings.append("Dispatcher is empty or failed to load")
            return

        pipelines = self.dispatcher.get("intent_pipelines", {})
        if not pipelines:
            self.warnings.append("No intent_pipelines found in dispatcher")
            return

        for pipeline_name, pipeline in pipelines.items():
            for step in pipeline.get("sequence", []):
                skill = step.get("skill")
                step_num = step.get("step")

                if not skill:
                    self.errors.append(
                        f"Pipeline '{pipeline_name}' step {step_num}: no skill specified"
                    )
                    continue

                if skill not in self.manifest:
                    self.errors.append(
                        f"Pipeline '{pipeline_name}' step {step_num}: skill '{skill}' not in manifest"
                    )

                template = step.get("template")
                if template and not self.validate_template_exists(template):
                    self.errors.append(
                        f"Pipeline '{pipeline_name}' step {step_num}: template '{template}' missing"
                    )

                # Check companion skills exist
                companion = step.get("companion")
                if companion and companion not in self.manifest:
                    self.errors.append(
                        f"Pipeline '{pipeline_name}' step {step_num}: companion skill '{companion}' not in manifest"
                    )

        if not self.errors:
            print(f"  {GREEN}✓ All {len(pipelines)} pipelines reference valid skills{RESET}")

    def check_semantic_trigger_collisions(self) -> None:
        """Check for duplicate semantic triggers across skills."""
        print(f"{BLUE}[3/5] Checking for semantic trigger collisions...{RESET}")

        all_triggers: Dict[str, str] = {}
        collision_count = 0

        for skill_name, skill_config in self.manifest.items():
            for trigger in skill_config.get("routing", {}).get(
                "semantic_triggers", []
            ):
                trigger_lower = trigger.lower()
                if trigger_lower in all_triggers:
                    self.warnings.append(
                        f"Semantic trigger '{trigger}' used by both "
                        f"'{all_triggers[trigger_lower]}' and '{skill_name}' — "
                        "prioritize via explicit_triggers"
                    )
                    collision_count += 1
                else:
                    all_triggers[trigger_lower] = skill_name

        if collision_count == 0:
            print(f"  {GREEN}✓ No semantic trigger collisions detected{RESET}")

    def validate_adopted_status_consistency(self) -> None:
        """Warn if active skills not in pipelines, or maintained skills are in pipelines."""
        print(f"{BLUE}[4/5] Checking adopted_status consistency...{RESET}")

        active_skills: Set[str] = {
            name
            for name, config in self.manifest.items()
            if config.get("meta", {}).get("adopted_status") == "active"
        }
        skills_in_pipelines: Set[str] = set()

        for pipeline in self.dispatcher.get("intent_pipelines", {}).values():
            for step in pipeline.get("sequence", []):
                skills_in_pipelines.add(step.get("skill"))
                if companion := step.get("companion"):
                    skills_in_pipelines.add(companion)

        # Warn if active skills not used in any pipeline
        unused_active = active_skills - skills_in_pipelines
        if unused_active and self.strict:
            for skill in sorted(unused_active):
                self.warnings.append(
                    f"Active skill '{skill}' not in any dispatcher pipeline — "
                    "consider downgrading to 'maintained'"
                )

        if not unused_active:
            print(f"  {GREEN}✓ All active skills are used in dispatcher pipelines{RESET}")

    def generate_lookup_index(self) -> bool:
        """Generate .skills_lookup_index.json for O(1) keyword lookup.

        Returns:
            True if successful, False otherwise
        """
        print(f"{BLUE}[5/5] Generating lookup index...{RESET}")
        try:
            lookup_index: Dict[str, List[str]] = {}
            for skill_name, skill_config in self.manifest.items():
                triggers = (
                    skill_config.get("routing", {}).get("explicit_triggers", [])
                    + skill_config.get("routing", {}).get("semantic_triggers", [])
                )
                lookup_index[skill_name] = list(set(triggers))  # Dedupe

            with open(LOOKUP_INDEX_PATH, "w") as f:
                json.dump(lookup_index, f, indent=2)
            print(f"  {GREEN}✓ Lookup index written to .skills_lookup_index.json{RESET}")
            return True
        except Exception as e:
            self.errors.append(f"Failed to generate lookup index: {e}")
            return False

    def run(self, generate_index: bool = True) -> bool:
        """Run all validations.

        Args:
            generate_index: Whether to generate lookup index

        Returns:
            True if validation passed, False otherwise
        """
        print(f"\n{BLUE}{'='*70}")
        print(f"SKILL SYSTEM VALIDATION")
        print(f"{'='*70}{RESET}")

        self.check_manifest_integrity()
        self.check_dispatcher_integrity()
        self.check_semantic_trigger_collisions()
        self.validate_adopted_status_consistency()

        if generate_index:
            self.generate_lookup_index()

        # Report results
        print(f"\n{BLUE}{'='*70}")
        print(f"RESULTS")
        print(f"{'='*70}{RESET}")

        if self.errors:
            print(f"\n{RED}ERRORS ({len(self.errors)}){RESET}")
            for err in self.errors:
                print(f"  ❌ {err}")

        if self.warnings:
            print(f"\n{YELLOW}WARNINGS ({len(self.warnings)}){RESET}")
            for warn in self.warnings:
                print(f"  ⚠️  {warn}")

        if not self.errors and not self.warnings:
            print(f"\n{GREEN}✅ All checks passed.{RESET}")
            return True

        if self.errors:
            print(f"\n{RED}❌ Validation failed due to {len(self.errors)} error(s).{RESET}")
            return False

        if self.warnings and self.strict:
            print(f"\n{RED}❌ Validation failed in strict mode due to {len(self.warnings)} warning(s).{RESET}")
            return False

        print(f"\n{YELLOW}⚠️  Validation passed but {len(self.warnings)} warning(s) found.{RESET}")
        return True


def main() -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Validate skill manifest and dispatcher integrity",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python validate-skills.py              # Basic validation
  python validate-skills.py --strict     # Fail on warnings
  python validate-skills.py --skip-index # Skip lookup index generation
        """,
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Fail on warnings, not just errors",
    )
    parser.add_argument(
        "--skip-index",
        action="store_true",
        help="Skip generating lookup index",
    )
    args = parser.parse_args()

    validator = SkillValidator(strict=args.strict)
    success = validator.run(generate_index=not args.skip_index)
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
