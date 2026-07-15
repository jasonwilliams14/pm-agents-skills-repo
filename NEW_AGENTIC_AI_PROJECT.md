# NEW_AGENTIC_AI_PROJECT.md

**How to Bootstrap a New Project Repository with the Agentic AI Workflow System**

---

## Overview

When you create a new project repository (e.g., `repo-ai-gateway`, `repo-k8s-cluster`, `repo-guardrails-poc`), it should inherit from `~/.agents/` as its canonical skill and template system.

This document explains:
1. **What files to create** in the new project
2. **What inheritance model** to use
3. **When to override** vs. when to inherit
4. **Example AGENTS.md and CLAUDE.md** for a child project

---

## Architecture: Parent-Child Relationship

```
~/.agents/ (PARENT — CANONICAL)
├── AGENTS.md (global judgment boundaries)
├── CLAUDE.md (global standards + skill system)
├── dispatcher.yaml (5 intent pipelines)
├── .skills_manifest.json (32 skills)
├── RULES.md (execution rules)
└── skills/ + templates/

    ↓ Referenced by

project-repo/ (CHILD — LOCAL OVERRIDES)
├── AGENTS.md (inherits parent, adds local constraints)
├── CLAUDE.md (inherits parent, customizes if needed)
├── docs/ (project-specific ADRs, design docs)
├── src/ (project code)
└── .claude/settings.json (optional: project-specific hooks)
```

**Key principle:** Child projects load their own AGENTS.md/CLAUDE.md FIRST, then fall back to `~/.agents/` for referenced skills, templates, and dispatcher pipelines.

---

## What to Create in a New Project

### Minimal Setup (2 files)

Every new project should have:

1. **AGENTS.md** (judgment boundaries for THIS project)
2. **CLAUDE.md** (standards overrides, if any)

**Do NOT copy** dispatcher.yaml, RULES.md, or .skills_manifest.json — reference the parent versions.

---

## AGENTS.md Template (Child Project)

**Purpose:** Define judgment boundaries and constraints specific to this project.

```markdown
# AGENTS.md — [Project Name]

## Inheritance Model

This project inherits from the canonical `~/.agents/` system:

- **Skill system:** Use dispatcher pipelines and skills from `~/.agents/dispatcher.yaml` and `~/.agents/skills/`
- **Execution rules:** Reference `~/.agents/RULES.md`
- **Templates:** Use templates from `~/.agents/templates/`
- **Judgment boundaries:** Inherit from `~/.agents/AGENTS.md`, with local additions below

---

## 1. Project-Specific Judgment Boundaries

### NEVER
* [Add any project-specific destructive operation constraints, if different from parent]
* Example: "Never delete the `/models` directory (contains licensed model weights)"

### ASK
* [Add any project-specific ambiguities that need clarification]
* Example: "Ask before modifying the cost attribution logic (impacts billing)"

### ALWAYS
* [Add any project-specific verification requirements]
* Example: "Always run the smoke test suite before declaring a deployment complete"
* Example: "Always update COST_TRACKING.md with new infrastructure cost estimates"

---

## 2. Local Toolchain Overrides (if different from parent)

| Domain | Override | Reason |
| :--- | :--- | :--- |
| **Kubernetes** | Use k3d (not vcluster) | Faster iteration for local testing |
| **Observability** | Add Jaeger to baseline | Need distributed tracing for agentic workflows |
| **[Domain]** | [Override] | [Reason] |

**If no overrides needed, delete this section and use parent ~/.agents/AGENTS.md directly.**

---

## 3. Validation & Testing

Before declaring a task complete:

```bash
# Run parent skill validation
python3 ~/.agents/validate-skills.py --strict

# Run project-specific tests (if any)
pytest tests/ -v

# Check documentation completeness
ls docs/ADR-*.md docs/DESIGN-*.md
```

---

## References

- Parent system: `~/.agents/AGENTS.md` (inherit all items not overridden above)
- Parent rules: `~/.agents/RULES.md`
- Skill system: `~/.agents/USAGE.md`
- Dispatcher pipelines: `~/.agents/dispatcher.yaml`
```

---

## CLAUDE.md Template (Child Project)

**Purpose:** Project-specific standards, constraints, or customizations.

**When to create:** Only if the project has standards DIFFERENT from global `~/.claude/CLAUDE.md`.

**Common overrides:**
- Different models (e.g., use Haiku instead of Sonnet for cost optimization)
- Different infrastructure preferences (e.g., AWS instead of GCP)
- Custom documentation structure (e.g., Confluence instead of GitHub)
- Project-specific approval gates

```markdown
# CLAUDE.md — [Project Name]

## Inheritance Model

This project inherits global standards from `~/.claude/CLAUDE.md`. 

**Local overrides are listed below.** All other sections use parent standards.

---

## Project-Specific Standards

### Model Selection (Override)
- **Global standard:** Use Sonnet[1M]
- **Project override:** Use Haiku (cost-optimized for proof-of-concept)
- **Reason:** Budget constraint; latency tolerance allows smaller model

### Infrastructure (Override)
- **Global standard:** vcluster preferred for K8s
- **Project override:** k3d (faster bootstrap for POC validation)
- **Reason:** Time-to-deployment critical; sacrifice isolation for speed

### Documentation (Override)
- **Global standard:** docs/ folder (project repo)
- **Project override:** docs/ folder + Confluence (for cross-team visibility)
- **Reason:** This is a strategic initiative; execs need real-time status updates

### Cost Tracking (Addition)
- **Requirement:** Update `docs/COST_TRACKING.md` after every infrastructure change
- **Why:** This POC has a fixed budget; visibility prevents overruns
- **Format:** Timestamp, change, estimated cost delta, cumulative cost

---

## Approval Gates (Override)

This project requires explicit approval before:
- Any GCP infrastructure changes (billing impact, compliance review)
- Any changes to prompt engineering logic (affects model output quality)
- Merging to main branch (project lead sign-off required)

---

## References

- Parent standards: `~/.claude/CLAUDE.md` (use all items not overridden above)
- Skill system: `~/.agents/CLAUDE.md` (Section: Skill System Integration)
- Project cost tracking: `docs/COST_TRACKING.md`
```

---

## Example: Real Project Setup

### Scenario: New AI Gateway POC (`repo-ai-gateway-poc`)

**Step 1: Create AGENTS.md**

```markdown
# AGENTS.md — AI Gateway POC

## Inheritance Model

This project inherits judgment boundaries from `~/.agents/AGENTS.md`.

---

## 1. Project-Specific Constraints

### ALWAYS
* Always validate rate-limiting rules before deploying (affects customer SLAs)
* Always update `docs/COST_MODEL.md` when adding new inference endpoints
* Always run chaos tests against failover logic before declaring POC complete

### ASK
* Ask before adding a new AI model provider (requires security review + cost approval)

---

## References

- Parent guardrails: `~/.agents/AGENTS.md`
- Testing guide: `docs/TESTING.md` (local, in this repo)
- Cost model: `docs/COST_MODEL.md` (local, in this repo)
```

**Step 2: Create CLAUDE.md**

```markdown
# CLAUDE.md — AI Gateway POC

## Inheritance Model

This project inherits standards from `~/.claude/CLAUDE.md`, with overrides below.

---

## Model Selection (Override)

**Global standard:** Sonnet[1M]  
**Project override:** Sonnet 5 (latest, better reasoning for architecture decisions)  
**Reason:** Gateway design is critical; pay for quality

---

## Documentation Structure (Addition)

- `docs/ADR-*.md` — Architectural decisions (inherit from `~/.agents/templates/architecture-decision-record.md`)
- `docs/DESIGN-*.md` — Technical design docs (inherit from `~/.agents/templates/technical-design-doc.md`)
- `docs/COST_MODEL.md` — Infrastructure cost tracking (project-specific)
- `docs/TESTING_STRATEGY.md` — Load test results + chaos test outcomes (project-specific)

---

## Approval Gates

Before merging to main:
1. ✅ All tests passing (via GitHub Actions)
2. ✅ Cost estimate reviewed (no surprises)
3. ✅ ADR reviewed by Jason (architecture decisions locked)

---

## References

- Parent standards: `~/.claude/CLAUDE.md`
- Skill system: `~/.agents/CLAUDE.md` (Section: Skill System Integration)
```

**Step 3: Create docs/ folder**

```
repo-ai-gateway-poc/
├── AGENTS.md
├── CLAUDE.md
├── docs/
│   ├── ADR-001-gateway-api-choice.md (uses ~/*.agents/templates/architecture-decision-record.md)
│   ├── DESIGN-inference-routing.md (uses ~/.agents/templates/technical-design-doc.md)
│   ├── COST_MODEL.md (project-specific)
│   └── TESTING_STRATEGY.md (project-specific)
├── src/
├── k8s/
└── tests/
```

**Step 4: When Claude starts in this repo**

Claude's context loading protocol (from AGENTS.md Section 3):

```
1. Scan for repo/AGENTS.md → FOUND ✓
   Load: "Always validate rate limits, always update cost model"
   
2. Scan for repo/CLAUDE.md → FOUND ✓
   Load: "Use Sonnet 5 (not Sonnet[1M]), add cost approval gate"

3. Scan for repo/dispatcher.yaml → NOT FOUND
   Fall back to: ~/.agents/dispatcher.yaml
   Check for matching pipelines...
   Found: "ai-gateway-deployment" pipeline matches request

4. Recommended skill sequence:
   k8s-gateway-api → k8s-gateway-inference → nginx-patterns → k8s-observability-ops
   
5. Templates to use:
   ADRs: ~/.agents/templates/architecture-decision-record.md
   Design docs: ~/.agents/templates/technical-design-doc.md
```

---

## Quick Checklist: Creating a New Project

```bash
# 1. Create the repo
mkdir repo-[project-name]
cd repo-[project-name]
git init

# 2. Add AGENTS.md
cat > AGENTS.md << 'EOF'
# AGENTS.md — [Project Name]

## Inheritance Model
This project inherits from ~/.agents/ system.
- Skill system: ~/.agents/dispatcher.yaml + skills/
- Execution rules: ~/.agents/RULES.md
- Judgment boundaries: ~/.agents/AGENTS.md (+ local additions below)

## 1. Project-Specific Constraints
[Add any local judgment boundaries here]

## References
- Parent: ~/.agents/AGENTS.md
EOF

# 3. Add CLAUDE.md (if overrides needed)
cat > CLAUDE.md << 'EOF'
# CLAUDE.md — [Project Name]

## Inheritance Model
Inherit from ~/.claude/CLAUDE.md and ~/.agents/CLAUDE.md.

## Local Overrides
[Add project-specific standards here]

## References
- Parent standards: ~/.claude/CLAUDE.md
- Skill system: ~/.agents/CLAUDE.md
EOF

# 4. Create docs/ folder
mkdir docs

# 5. Test the setup
python3 ~/.agents/validate-skills.py --strict
```

---

## When to Override vs. Inherit

| Question | Action |
|---|---|
| Does this project need different judgment boundaries? | Create local AGENTS.md |
| Does this project need different technical standards? | Create local CLAUDE.md |
| Does this project need different skills/pipelines? | No — reference parent ~/.agents/dispatcher.yaml |
| Does this project need different templates? | No — use parent ~/.agents/templates/ |
| Does this project need a different validation? | Add to local AGENTS.md ALWAYS section |

**Default:** Inherit everything from ~/.agents/. Override only when necessary.

---

## Summary

**For every new project:**

1. ✅ **Create AGENTS.md** with local judgment boundaries (inherit parent guardrails)
2. ✅ **Create CLAUDE.md** ONLY if you have standard overrides (optional)
3. ✅ **Create docs/ folder** for project-specific ADRs and design docs
4. ✅ **Reference ~/.agents/** for skills, templates, dispatcher pipelines
5. ✅ **Use context loading protocol** (Section 3 of ~/.agents/AGENTS.md) automatically

Claude will handle the rest.
