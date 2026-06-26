# Skill Maintenance & Lifecycle

This document defines how skills evolve, version, and deprecate over time.

---

## VERSIONING SCHEME

Skills follow **Semantic Versioning** (MAJOR.MINOR.PATCH):

### MAJOR (x.0.0) — Breaking API Change
**When to bump:**
- Skill charter or persona fundamentally shifts (e.g., `k8s-gateway-api` transitions from v1 to v2 specs)
- Companion skills change (existing pipelines may break)
- Preferred templates change
- Primary purpose changes

**Actions required:**
- Update all references in dispatcher pipelines
- Announce deprecation in CHANGELOG.md
- Review affected projects

**Example:**
```
v1.0.0 → v2.0.0: k8s-gateway-api refocused from legacy Ingress to Gateway API v1
```

### MINOR (x.y.0) — Non-Breaking Addition
**When to bump:**
- New semantic triggers added (doesn't break existing trigger behavior)
- New companion skills added (old companions still valid)
- New preferred templates added
- New workflow steps added

**Actions required:**
- Update `.skills_manifest.json` version
- Document new triggers/companions in SKILL.md
- Run `validate-skills.py` to confirm no new collisions
- Update CHANGELOG.md

**Example:**
```
v1.2.0 → v1.3.0: k8s-gateway-api adds new semantic trigger "AgentGateway"
```

### PATCH (x.y.z) — Bug Fix & Clarification
**When to bump:**
- Typo fixes in SKILL.md
- Clarification to persona or workflow (no logic change)
- Broken link fixes
- README improvements

**Actions required:**
- Update SKILL.md only
- No version bump required in manifest
- Update CHANGELOG.md with minor note

**Example:**
```
Fix: Correct typo in k8s-gateway-api SKILL.md WORKFLOW section
```

---

## VERSION FORMAT IN MANIFEST

Every skill in `.skills_manifest.json` includes version metadata:

```json
{
  "my-skill": {
    "meta": {
      "name": "My Skill Display Name",
      "tier": "Reasoning|Speed",
      "version": "1.2.3",
      "adopted_status": "active|maintained|deprecated",
      "last_updated": "2026-06-26"
    }
  }
}
```

**Update order:**
1. Update SKILL.md (always)
2. Update manifest `version` field (for MINOR/MAJOR bumps)
3. Update manifest `last_updated` field (always)
4. Update manifest `adopted_status` if needed
5. Run `validate-skills.py --strict`
6. Update CHANGELOG.md

---

## DEPRECATION TIMELINE

When a skill is no longer needed:

### Phase 1 (Day 0): Mark as Deprecated

**In `.skills_manifest.json`:**
```json
{
  "deprecated-skill": {
    "meta": {
      "name": "Deprecated Skill",
      "version": "0.5.0",
      "adopted_status": "deprecated",
      "last_updated": "2026-06-26"
    },
    "deprecated": {
      "from_version": "0.5.0",
      "replacement_skill": "new-skill-name",
      "timeline": "2026-09-26",
      "reason": "Replaced by new-skill-name which handles X better"
    }
  }
}
```

**Actions:**
- [ ] Remove from any active dispatcher pipelines
- [ ] Update SKILLS_INDEX.md to mark as "Deprecated (removal target: T+90)"
- [ ] Add deprecation note to skill's SKILL.md front matter:
  ```markdown
  ---
  name: deprecated-skill
  description: [DEPRECATED] Use new-skill-name instead
  ---
  
  **STATUS: DEPRECATED**
  
  This skill is deprecated as of v0.5.0 and will be archived on 2026-09-26.
  Use [[new-skill-name]] instead.
  ```
- [ ] Commit with message:
  ```
  deprecation(skill): mark deprecated-skill for removal
  
  Deprecated: deprecated-skill → use new-skill-name instead
  Removal timeline: 2026-09-26 (90 days)
  Reason: Replaced by new-skill-name
  ```

### Phase 2 (Day 60-90): Archive & Remove

After 90 days (when 2026-09-26 arrives):

**Actions:**
- [ ] Create archive directory:
  ```bash
  mkdir -p ~/.agents/.archive/skills
  cp -r ~/.agents/skills/deprecated-skill ~/.agents/.archive/skills/deprecated-skill-v0.5.0
  ```
- [ ] Remove from manifest entirely
- [ ] Delete from `~/.agents/skills/deprecated-skill/`
- [ ] Run validation: `python ~/.agents/validate-skills.py --strict`
- [ ] Update CHANGELOG.md:
  ```markdown
  ### Removed
  - `deprecated-skill` (archived as deprecated-skill-v0.5.0)
  ```
- [ ] Commit:
  ```
  remove(skill): archive deprecated-skill
  
  Removed from manifest and moved to .archive/skills/deprecated-skill-v0.5.0
  Use new-skill-name for this functionality.
  ```

---

## UPDATING SEMANTIC TRIGGERS

When a new keyword/phrase should activate a skill:

**Process:**

1. **Check for collisions:**
   ```bash
   grep -i '"your-new-trigger"' ~/.agents/.skills_manifest.json
   ```
   If found, skill collision detected — resolve it.

2. **Add to manifest:**
   ```json
   "semantic_triggers": [
     "existing-trigger",
     "your-new-trigger"
   ]
   ```

3. **Document in SKILL.md:**
   ```markdown
   ## Semantic Triggers (When user says)
   - "existing phrase"
   - "your new phrase"
   ```

4. **Validate:**
   ```bash
   python ~/.agents/validate-skills.py --strict
   ```

5. **Update version:**
   - Bump MINOR version (e.g., 1.2.0 → 1.3.0)
   - Update `last_updated` field

6. **Commit:**
   ```
   feat(skill): add new semantic triggers to skill-name (v1.2.0 → v1.3.0)
   
   - Added semantic trigger: "your-new-trigger"
   - Updated SKILL.md with new trigger documentation
   ```

---

## UPDATING COMPANION SKILLS

When a skill needs new companion skills:

**Process:**

1. **Add to manifest:**
   ```json
   "composition": {
     "primary_for": [...],
     "companion_skills": ["existing-companion", "new-companion"],
     "dependency_chain": "skill-1 -> your-skill-name -> new-companion"
   }
   ```

2. **Document in SKILL.md:**
   ```markdown
   ## Common Compositions
   - **Primary:** your-skill-name
   - **Companion 1:** existing-companion
   - **Companion 2:** new-companion (for enhanced security)
   
   When to pair: Use new-companion when you need X behavior.
   ```

3. **Test:**
   ```bash
   python ~/.agents/validate-skills.py --strict
   ```

4. **Update version:**
   - MINOR bump if old companions still work
   - MAJOR bump if old companions no longer work

5. **Commit:**
   ```
   feat(skill): add new companion skill to your-skill-name
   
   - Added companion: new-companion
   - Updated dependency_chain to include new-companion
   ```

---

## UPDATING PREFERRED TEMPLATES

When a skill should prefer a new template:

**Process:**

1. **Verify template exists:**
   ```bash
   ls ~/.agents/templates/new-template.md
   ```

2. **Update manifest:**
   ```json
   "artifacts": {
     "preferred_templates": ["old-template.md", "new-template.md"],
     "output_standard": "Markdown"
   }
   ```

3. **Document in SKILL.md which template to use when:**
   ```markdown
   ## Preferred Templates
   - **For feature design:** use new-template.md
   - **For ADR:** use architecture-decision-record.md
   ```

4. **Test:** `python ~/.agents/validate-skills.py --strict`

5. **Bump MINOR version**

---

## ADDING A NEW SKILL

See **IMPLEMENTATION_GUIDE.md Part 2, Section 2.1** for complete checklist.

Quick summary:
1. Create `~/.agents/skills/your-skill-name/SKILL.md`
2. Update `.skills_manifest.json` with metadata
3. Run `validate-skills.py --strict` (must pass)
4. Test manually with Claude Code
5. Add to dispatcher pipeline (if core task)
6. Commit with semantic message

---

## QUARTERLY SKILL HEALTH AUDIT

**Schedule:** First Thursday of each quarter (Sept 5, Dec 5, Mar 5, Jun 5)

**Checklist:**

- [ ] **Run validation:**
  ```bash
  python ~/.agents/validate-skills.py --strict
  ```

- [ ] **Check for stale versions:**
  - Find skills with `version < X` (more than 2 major releases old)
  - Consider MAJOR version bump for alignment
  - Check if semantic triggers need updates (e.g., K8s API evolved)

- [ ] **Audit adopted_status:**
  - [ ] **active** skills: verify they appear in `dispatcher.yaml`
  - [ ] **maintained** skills: check if used in past 6 months
    ```bash
    git log --oneline --all --grep="skill-name" | head -5
    ```
  - [ ] **deprecated** skills: past removal timeline? Archive them.

- [ ] **Regenerate lookup index:**
  ```bash
  python ~/.agents/validate-skills.py
  ```

- [ ] **Update SKILLS_INDEX.md** with current adoption status

- [ ] **Review CHANGELOG.md** and ensure all changes documented

- [ ] **Commit audit results:**
  ```
  chore(skill): Q2 skill health audit
  
  - Validated all 32 skills
  - Updated adopted_status for 3 skills
  - Archived 1 deprecated skill
  - Regenerated lookup index
  ```

---

## CHANGELOG FORMAT

Keep a `CHANGELOG.md` at `~/.agents/CHANGELOG.md` documenting all skill changes.

**Format:**

```markdown
# Skill System Changelog

## [1.2.0] - 2026-06-26

### Added
- New skill: k8s-gateway-inference (v1.0.0) for model routing
- New semantic triggers: "model routing", "LLM load balancing"
- New template: k8s-inference-deployment.md

### Changed
- k8s-gateway-api v1.5.0 → v1.6.0: added new semantic triggers
- Updated dispatcher pipeline: ai-gateway-deployment to include k8s-gateway-inference

### Fixed
- Fixed broken dependency chain in k8s-observability-ops

### Deprecated
- k8s-ai-expert (use k8s-gateway-inference instead) — removal target: 2026-09-26

### Removed
- None this release

## [1.1.0] - 2026-06-15

### Added
- New semantic triggers for ai-engineer skill
- New companion skill support in docs-agent

### Fixed
- Fixed semantic trigger collision between k8s-engineer and k8s-gateway-api

## [1.0.0] - 2026-06-01

### Added
- Initial skill manifest with 30 skills
- Dispatcher pipeline system with 5 pipelines
- validate-skills.py validation script
- SKILL_MAINTENANCE.md maintenance guide
```

**Update on:**
- Every MAJOR/MINOR version bump
- When skills are added/deprecated/removed
- Quarterly after audit

---

## BEST PRACTICES

### ✅ DO

- **Run validate-skills.py before committing:** Catches silent failures
- **Update CHANGELOG.md immediately:** Future-you needs context
- **Test dependency chains:** New versions may break existing pipelines
- **Announce deprecations early:** Give 90 days notice
- **Keep semantic triggers specific:** Avoid overly broad keywords (e.g., "config" matches too many skills)
- **Document companion skills:** Why are these skills paired together?

### ❌ DON'T

- **Skip validation:** Broken manifests cascade into broken pipelines
- **Mix MAJOR changes with other updates:** One breaking change per commit
- **Remove deprecated skills immediately:** Respect the 90-day timeline
- **Silently change skill behavior:** Update version number + CHANGELOG
- **Create skills without dispatcher pipelines:** If it's important, it's in a pipeline
- **Duplicate semantic triggers across skills:** Use explicit_triggers to differentiate

---

## REFERENCES

- [[RULES.md]] — Global execution rules
- [[dispatcher.yaml]] — Intent-based pipelines
- [.skills_manifest.json](.skills_manifest.json) — Skill registry
- [[IMPLEMENTATION_GUIDE.md]] — Complete skill addition/update process
- [[validate-skills.py]] — Validation automation
