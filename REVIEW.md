# Agents Folder Architecture Review

**Date:** 2026-06-26  
**Reviewer:** Claude Code (Haiku 4.5)  
**Scope:** Global `~/.agents/` skill system architecture, composition, and operational patterns

---

## SUMMARY: Excellent Foundation, 3 Critical Optimizations

Your agents setup is **architecturally sound** and **production-ready**, with a well-defined intent-pipeline system, lazy-loading discipline, and clear skill boundaries. The following optimizations will tighten operational efficiency and reduce future maintenance burden.

---

## 1. STRENGTHS ✅

### 1.1 Intent-Based Dispatch (dispatcher.yaml)
- **5 pre-defined pipelines** covering your core domains: cluster lifecycle, AI gateway, agentic routing, troubleshooting, and product definition.
- **Clear sequencing** with role/skill/output annotations — subagents know exactly what to produce and what the next step consumes.
- **Companion skills** properly annotated (e.g., `platform-engineer` + `k8s-engineer` for cluster lifecycle step 2).

**Verdict:** This is how skill composition *should* work. The `agentic-routing-poc` pipeline is particularly well-scoped (AIArchitect → NetworkEngineer → ObservabilityExpert → TechnicalWriter).

### 1.2 Lazy-Loading & Context Discipline
- **RULES.md** enforces zero preloading — skills hydrate on-demand via grep lookup against `.skills_manifest.json`.
- **Max composition boundary:** 1 primary + 2 secondary skills per execution tree (hard-coded in RULES section 2).
- **Compressed returns:** Explicit requirement for subagents to output "Crystallized Insights" (YAML metadata) before passing to the next step.

**Verdict:** This prevents context bloat and keeps skills from leaking into each other's namespaces. Well-executed.

### 1.3 Skill Definitions (32 skills)
- **Clear YAML structure** in `.skills_manifest.json`: `meta`, `routing` (explicit + semantic triggers), `composition` (companion skills, dependency chains), and `artifacts` (preferred templates).
- **Focused personas:** Each skill has a tight charter (e.g., `ai-engineer` = Python PoCs + local LLMs + LangChain; `k8s-gateway-api` = Gateway API design + build-first mindset).
- **Separation of concerns:** K8s skills (`k8s-engineer`, `k8s-gateway-api`, `k8s-gateway-inference`, `k8s-observability-ops`, `k8s-ai-expert`) are properly partitioned by domain (networking, inference, observability, ML scaling).

**Verdict:** Skills are domain-isolated and reusable. No Swiss-Army-knife skills.

### 1.4 CLAUDE.md Alignment
- Your global `CLAUDE.md` (in `~/.claude/`) mirrors the agents folder's execution standards: Python 3.12+, strict Pydantic v2, mandatory OTel, Gateway API v1.1+ for K8s.
- **POC-First philosophy** is consistently reinforced across both files.

**Verdict:** There is coherent signal-to-noise ratio between project instructions and global skill system.

---

## 2. CRITICAL GAPS & RECOMMENDATIONS 🔴

### 2.1 MISSING: Skill Versioning & Deprecation Strategy
**Problem:**  
- `.skills_manifest.json` includes `version` (e.g., "1.1.0"), but there is **no changelog, deprecation timeline, or breaking-change log** for skill evolution.
- No guidance on how to handle **skill drift** (e.g., when `k8s-gateway-api` specs shift due to K8s updates or your opinions change).
- No **skill-level semantic triggers update process** — if you discover a new intent keyword, how does it get safely merged into the manifest without manual git conflicts?

**Recommendation:**  
Create a **`SKILL_MAINTENANCE.md`** file at `~/.agents/` that documents:

```markdown
# Skill Maintenance & Lifecycle

## Versioning Scheme
- MAJOR: Breaking API change (skill charter or persona shift)
- MINOR: New semantic triggers, new companion skills, new templates
- PATCH: Bug fixes, clarifications, typo fixes

## Deprecation Timeline
- Mark skill as `deprecated: true` in manifest
- Document replacement skill in the skill's SKILL.md front matter
- Retain skill in `.skills_manifest.json` for 2 releases, then remove

## Updating Semantic Triggers
1. Test new trigger keyword against existing skills to avoid collisions
2. Add to `semantic_triggers` list in manifest
3. Document in skill's SKILL.md WORKFLOW section

## Updating Companion Skills
- Companion skill changes require MAJOR version bump
- Re-test downstream pipelines in dispatcher.yaml
```

**Impact:** Prevents skill collisions, clarifies update burden, and makes your skill system resilient to evolution.

---

### 2.2 CRITICAL: Skill-to-Skill Dependency Chain Validation
**Problem:**  
- `.skills_manifest.json` documents `dependency_chain` (e.g., `"ai-engineer -> ai-security-patterns -> docs-agent"`), but there is **no validation tool** to verify these chains actually execute in order.
- The `agentic-routing-poc` pipeline lists `docs-agent` with template `architecture-decision-record.md`, but there is **no check** that this template actually exists or that `docs-agent` is configured to use it.
- Example from manifest: `defuddle -> obsidian-markdown -> obsidian-cli` — but what if a future update breaks this chain?

**Recommendation:**  
Create a **validation script** at `~/.agents/validate-skills.py`:

```python
#!/usr/bin/env python3
"""Validate skill manifest integrity against dispatcher pipelines and templates."""
import json, yaml, sys
from pathlib import Path

MANIFEST_PATH = Path.home() / ".agents" / ".skills_manifest.json"
DISPATCHER_PATH = Path.home() / ".agents" / "dispatcher.yaml"
TEMPLATES_DIR = Path.home() / ".agents" / "templates"
SKILLS_DIR = Path.home() / ".agents" / "skills"

def validate_skill_exists(skill_name: str) -> bool:
    """Check if skill SKILL.md file exists."""
    skill_path = SKILLS_DIR / skill_name / "SKILL.md"
    return skill_path.exists()

def validate_template_exists(template_name: str) -> bool:
    """Check if template file exists."""
    template_path = TEMPLATES_DIR / template_name
    return template_path.exists()

def validate_dependency_chain(chain: str) -> list[str]:
    """Parse and validate a dependency chain."""
    skills = [s.strip() for s in chain.split("->")]
    missing = [s for s in skills if not validate_skill_exists(s)]
    return missing

# Load manifest and dispatcher
with open(MANIFEST_PATH) as f:
    manifest = json.load(f)
with open(DISPATCHER_PATH) as f:
    dispatcher = yaml.safe_load(f)

errors = []

# Validate each skill in manifest
for skill_name, skill_config in manifest.items():
    if not validate_skill_exists(skill_name):
        errors.append(f"❌ Skill '{skill_name}' in manifest but SKILL.md missing")
    
    # Validate dependency chains
    chain = skill_config.get("composition", {}).get("dependency_chain", "")
    if chain and (missing := validate_dependency_chain(chain)):
        errors.append(f"❌ {skill_name}: dependency chain broken — missing {missing}")
    
    # Validate templates
    for template in skill_config.get("artifacts", {}).get("preferred_templates", []):
        if not validate_template_exists(template):
            errors.append(f"❌ {skill_name}: preferred template '{template}' missing")

# Validate dispatcher pipelines
for pipeline_name, pipeline in dispatcher.get("intent_pipelines", {}).items():
    for step in pipeline.get("sequence", []):
        skill = step.get("skill")
        if skill not in manifest:
            errors.append(f"❌ Pipeline '{pipeline_name}' step {step.get('step')}: skill '{skill}' not in manifest")
        
        template = step.get("template")
        if template and not validate_template_exists(template):
            errors.append(f"❌ Pipeline '{pipeline_name}' step {step.get('step')}: template '{template}' missing")

# Report
if errors:
    for err in errors:
        print(err)
    sys.exit(1)
else:
    print("✅ All skills, templates, and dependency chains validated.")
    sys.exit(0)
```

Run this before major dispatcher changes or skill updates:
```bash
python ~/.agents/validate-skills.py
```

**Impact:** Prevents silent failures where a pipeline expects a skill/template that no longer exists.

---

### 2.3 HIGH: Missing Skill Metrics & Adoption Tracking
**Problem:**  
- No log of which skills are *actively used* vs. *dead weight*.
- Skills like `google-agents-cli-*` (7 skills!) seem to be **multi-vendor Google-specific tooling** that may not align with your F5 + NGINX + Kubernetes focus.
- No signal on whether `positioning-messaging` or `json-canvas` are worth maintaining.

**Recommendation:**  

1. **Add `adopted_status` to manifest:**
   ```json
   "ai-engineer": {
     "meta": { "name": "...", "tier": "...", "version": "1.1.0", "adopted_status": "active" },
     ...
   }
   ```
   Status values: `active` (used in pipelines), `maintained` (available but not in active pipelines), `deprecated` (marked for removal).

2. **Tag skills used in active pipelines:**
   - `ai-engineer` → active (in `agentic-routing-poc`)
   - `k8s-gateway-api` → active (in `ai-gateway-deployment`)
   - `google-agents-cli-scaffold` → maintained (available but not in any dispatcher pipeline)
   - Add to SKILLS_INDEX.md.

3. **Create an adoption audit in RULES.md:**
   ```markdown
   ## Skill Adoption Tiers
   
   **Active (Core to Your Practice):**
   - ai-engineer, ai-security-patterns, k8s-gateway-api, k8s-gateway-inference, nginx-patterns, docs-agent, tech-pm, prd-generator
   
   **Maintained (Available but Not in Core Pipelines):**
   - google-agents-cli-*, json-canvas, obsidian-bases, obsidian-cli, positioning-messaging
   
   **Candidates for Deprecation (Review Quarterly):**
   - [none currently, but flag if a skill hasn't been used in 6 months]
   ```

**Impact:** Clarifies skill health and surfaces unused tooling that could be archived or removed.

---

### 2.4 MEDIUM: Dispatcher Pipeline Input/Output Contracts
**Problem:**  
- `dispatcher.yaml` shows what *skill* runs and what *output* it produces, but **no schema** for how that output is consumed by the next step.
- Example: `cluster-lifecycle` step 2 (GitOpsEngineer) is a "companion" to step 1 (CloudArchitect), but there is **no documented interface** between them.
  - Does step 2 consume the raw output from step 1?
  - Does it expect a specific YAML structure?
  - What if step 1 outputs an ambiguous result (e.g., "cluster created, but with warnings")?

**Recommendation:**  
Extend `dispatcher.yaml` with **input/output contracts**:

```yaml
intent_pipelines:
  cluster-lifecycle:
    description: "..."
    sequence:
      - step: 1
        role: CloudArchitect
        skill: platform-engineer
        output: "Cluster Provisioning (vcluster/k3d/Cloud Provider)"
        output_schema: |
          {
            "cluster_name": "string",
            "provider": "vcluster|k3d|gke|eks|aks",
            "kubeconfig_path": "string",
            "cluster_ready": "bool",
            "warnings": ["string"]
          }
      - step: 2
        role: GitOpsEngineer
        skill: k8s-engineer
        companion: platform-engineer
        input_from: step-1
        input_schema: "cluster_name, provider, kubeconfig_path"
        output: "FluxCD/ArgoCD Bootstrap & Repository Sync"
```

**Impact:** Subagents know exactly what shape of data they're receiving and what to produce. Prevents ambiguity.

---

### 2.5 LOW-TO-MEDIUM: Skill Documentation Standardization
**Problem:**  
- Skill SKILL.md files have inconsistent **structure and tone**.
  - `ai-engineer/SKILL.md`: Concise persona + constraints + execution standards + workflow (4 sections).
  - `k8s-gateway-api/SKILL.md`: Persona + core competency map + anti-patterns (3 sections, different order).
  - No standardized sections for "What to Watch For" or "Common Pitfalls."

**Recommendation:**  
Create a **SKILL.md template** at `~/.agents/templates/skill-template.md`:

```markdown
---
name: {{skill-name}}
description: {{One-line trigger description for system reminders}}
---

# PERSONA
[2-3 sentences on the role, mindset, and core competency]

# TRIGGERS & WHEN TO USE
## Explicit Triggers
- `{{keyword-1}}`
- `{{keyword-2}}`

## Semantic Triggers (When user says)
- "{{phrase that activates this skill}}"
- "{{another phrase}}"

## When NOT to Use
- {{Scenario where this skill should defer to another}}

# CONSTRAINTS & PERMISSIONS
* [x] EXECUTION: {{What this skill can and cannot run}}
* [x] FILE EDITING: {{Allowed file types}}

# CORE COMPETENCY MAP
| Domain | Key Concepts |
|--------|-------------|

# EXECUTION STANDARDS
1. {{Standard 1}}
2. {{Standard 2}}

# WORKFLOW
1. {{Step 1}}
2. {{Step 2}}
3. {{Step 3}}

# WHAT TO WATCH FOR (Anti-Patterns)
- {{Anti-pattern 1}} → Fix by {{remedy}}
- {{Anti-pattern 2}} → Fix by {{remedy}}

# REFERENCES
- [Template 1](../templates/{{template}}.md)
- [Workflow 1](../workflows/{{workflow}}.md)
```

Then update all 32 skills to this standard. Use it as a pre-flight checklist before adding new skills.

**Impact:** Skills become more discoverable, consistent, and maintainable.

---

## 3. OPERATIONAL RECOMMENDATIONS 🔵

### 3.1 Automate Skill Lookup Performance
**Current:** Grep against `.skills_manifest.json` (572 lines, ~21KB) is fast for single lookups but can be optimized.

**Suggestion:**  
Create a **lightweight index** (`~/.agents/.skills_lookup_index.json`) that maps trigger keywords to skill names:

```json
{
  "ai-engineer": ["ai-engineer", "poc", "agentic", "ollama", "langchain"],
  "k8s-gateway-api": ["k8s-gateway-api", "gatewayclass", "httproute"],
  ...
}
```

Regenerate this index whenever `.skills_manifest.json` changes (add a pre-commit hook or include it in the validation script above).

**Impact:** O(1) keyword → skill lookup instead of grep parsing.

### 3.2 Create a `USAGE.md` for Common Workflows
**Current:** Skills are defined, but there's no "cheat sheet" for common multi-skill sequences.

**Suggestion:**  
Add `~/.agents/USAGE.md`:

```markdown
# Quick-Start Skill Combinations

## "I want to deploy an AI gateway"
1. Load `k8s-gateway-api` (design GatewayClass/HTTPRoute)
2. Load `k8s-gateway-inference` (InferencePool/model routing)
3. Load `nginx-patterns` (proxy buffering, SSE)
4. Load `k8s-observability-ops` (trace latency)
→ Matches `dispatcher.yaml` pipeline: `ai-gateway-deployment`

## "I want to troubleshoot my cluster"
1. Load `k8s-engineer` (diagnostics)
2. Load `platform-engineer` (infrastructure root cause)
3. Load `docs-agent` (post-mortem)
→ Matches dispatcher pipeline: `cluster-troubleshooting`

## "I want to write a PRD"
1. Load `tech-pm` (strategic intent)
2. Load `value-proposition` (JTBD)
3. Load `pm-standards` (RICE)
4. Load `prd-generator` (write PRD)
5. Load `slide-deck-creator` (exec slides)
→ Matches dispatcher pipeline: `product-definition`
```

**Impact:** New users (or future-you) can instantly find the right skill combination without reading dispatcher.yaml.

### 3.3 Monitor Skill Stale Patterns
**Suggestion:**  
Add a quarterly review checklist to `RULES.md`:

```markdown
## Quarterly Skill Health Audit
- [ ] Run `validate-skills.py` — all checks pass
- [ ] Check `.skills_manifest.json` for skills with `version < X` (more than 2 major releases old)
- [ ] Verify adopted_status = "active" skills are still in use (grep dispatcher.yaml + project git history)
- [ ] Archive "maintained" skills not used in past 6 months
- [ ] Regenerate `.skills_lookup_index.json`
```

**Impact:** Skill system stays lean and relevant.

---

## 4. SUMMARY TABLE: Changes by Effort

| Change | Effort | Impact | Priority |
|--------|--------|--------|----------|
| Create `SKILL_MAINTENANCE.md` | 30 min | Clarifies skill evolution | High |
| Build `validate-skills.py` | 1 hour | Prevents silent failures | Critical |
| Add `adopted_status` to manifest | 45 min | Surfaces dead weight | High |
| Create `SKILL.md` template | 30 min | Standardizes skill docs | Medium |
| Build `.skills_lookup_index.json` | 30 min | O(1) keyword lookup | Low |
| Add `USAGE.md` cheat sheet | 30 min | UX improvement | Medium |
| Add quarterly audit checklist | 15 min | Long-term health | Low |

---

## 5. NEXT STEPS

1. **This week:** Implement `validate-skills.py` (blocks future silent failures).
2. **This week:** Create `SKILL_MAINTENANCE.md` (documents your skill evolution process).
3. **Next week:** Add `adopted_status` to manifest and audit Google ADK skills (are they core to your practice?).
4. **Backlog:** Standardize SKILL.md template (high ROI for consistency).
5. **Quarterly:** Run skill health audit checklist.

---

## OVERALL VERDICT

Your agents folder is **well-architected and disciplined**. The dispatcher pipeline system, lazy-loading rules, and skill composition boundaries are *exactly* what a high-functioning skill system should look like. The three critical gaps are **not architectural flaws** — they're **operational debt** (validation, versioning, and dependency tracking) that will compound as you scale the skill count. Address these in order: **validate first, then document versioning, then track adoption.**

The system is ready for heavy use. Ship it.
