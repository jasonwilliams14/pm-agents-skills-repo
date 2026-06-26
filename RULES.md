# Global Execution Rules

## 1. Skill Loading & Context Slicing (Lazy Discovery)
- **Location:** All core skills reside in `~/.agents/skills/`.
- **Global Priority:** Unless the active workspace is explicitly designated as a skill development repository (containing a local `.skill-lock.json`), always default immediately to search and load skills from the global `~/.agents/` directory. Do not crawl the local project directory looking for `./skills/` or `./workflows/`.
- **Zero Preloading:** Never preload full skill manifests or indices by default.
- **Process:**
  1. Scan trigger keywords and intent routes against the global `~/.agents/.skills_manifest.json` file.
  2. **Fast Lookup:** To avoid reading the entire manifest, run a fast grep search for the trigger keyword:
     `grep -i -C 4 '"trigger-word"' ~/.agents/.skills_manifest.json`
  3. Hydrate the active session context *only* with the matching `SKILL.md` file contents from the target skill directory.
  4. Wipe/unload the loaded skill context as soon as the consolidated payload is returned to the parent thread to prevent token bleed.
- **Prefer:** Atomic, specialized skills, precise file boundaries, low token footprint.
- **Avoid:** Context flooding, cross-domain logic pollution, redundant definitions.

---

## 2. Multi-Skill Composition
- If a workflow spans multiple domains, isolate execution:
  - Identify and invoke the **Primary Skill** first.
  - Augment with **Secondary Skills** sequentially, only if required.
- **Hard Boundaries:** Maximum 1 primary skill and 2 secondary skills per execution tree.
- **Compressed Returns:** Subagent return values must be compressed before returning to the parent loop. Instruct subagents to summarize execution outputs into a structured YAML metadata block (e.g., showing status, changes, and errors) and exclude raw build logs or unchanged configuration files unless explicitly requested.

---

## 3. Retrieval Strategy & Hierarchy
- **Order of Operations:** 
  1. `~/.agents/.skills_manifest.json` (Discovery via grep lookup)
  2. Targeted `SKILL.md` (Hydration)
  3. Workspace `AGENTS.md` (Local Context Override)
  4. Workflow Playbooks (Process execution)
  5. Templates (Only during artifact generation)
- **Local Overrides:** A project-level `AGENTS.md`, `CLAUDE.md` or  `GEMINI.md` found in the current working directory always takes precedence over global rules. Local configs deep-merge with global rules, with local keys taking absolute precedence.

---

## 4. Reasoning Style & Technical Standards
- **Tone:** Concise, direct, operationally realistic, architecture-first. No conversational filler.
- **Architectural Priorities:** Clarity, production-grade recommendations, observability, and structural correctness.
- **Technical Focus:** 
  - Containerized, repeatable workflows (Docker Compose, Kubernetes, FluxCD).
  - API-first designs, streaming-aware architectures, and reusable automation.
  - Clear separation between infrastructure engineering and knowledge graph (Obsidian) management.

---

## 5. Prompt Caching & Session Structure
- **Static First:** To leverage prompt caching, large static configuration files (`AGENTS.md`, `RULES.md`, `.skills_manifest.json`) must be structured at the absolute beginning of the context window.


## 6. Dispatcher Execution Logic
- **Pipeline First:** When a user request is received, first attempt to match the intent to a pipeline in `~/.agents/dispatcher.yaml`. If a match is found, spawn subagents sequentially following the defined `sequence`.
- **Semantic Fallback:** If no pipeline matches, use the `semantic_triggers` in `~/.agents/.skills_manifest.json` to identify the Primary Skill.
- **Compositional Expansion:** Once a Primary Skill is identified, check its `companion_skills`. Load them only if the task requires cross-domain expertise.
- **Template Enforcement:** Always check the `preferred_templates` list for the active skill before generating an artifact. If a template exists in `~/.agents/templates/`, it MUST be used as the structural foundation.
- **Result Compression:** Each step in a pipeline must output a "Crystallized Insight" (compressed summary) to be passed to the next subagent in the chain, preventing context bloat.

---

## 7. Skill Adoption Tiers

Every skill in `.skills_manifest.json` has an `adopted_status` field indicating its lifecycle stage:

### active
- **Definition:** Used in one or more dispatcher pipelines. Core to your daily practice.
- **Support Level:** Highest priority. Updated quarterly, actively tested.
- **Current Skills:**
  - `ai-engineer` — AI PoCs, agentic logic
  - `ai-security-patterns` — GenAI security guardrails
  - `k8s-gateway-api` — Kubernetes routing design
  - `k8s-gateway-inference` — Model routing & inference
  - `k8s-observability-ops` — Kubernetes observability & tracing
  - `k8s-engineer` — Kubernetes troubleshooting & networking
  - `nginx-patterns` — NGINX optimization & routing
  - `docs-agent` — Technical writing & ADRs
  - `tech-pm` — Product strategy & PRD writing
  - `prd-generator` — PRD generation
  - `platform-engineer` — Infrastructure & cluster provisioning

### maintained
- **Definition:** Available but not in active dispatcher pipelines. Maintained for backward compatibility and specialized tasks.
- **Support Level:** Low-to-medium priority. Updates lag active skills.
- **Current Skills:**
  - `google-agents-cli-*` (7 skills) — Google ADK agent tooling
  - `obsidian-*` (3 skills) — Obsidian knowledge management
  - `json-canvas` — Obsidian Canvas files
  - `positioning-messaging` — Competitive positioning
  - `slide-deck-creator` — Slide deck generation
  - `python-dev-standard` — Python best practices
  - `value-proposition` — JTBD value propositions
  - `pm-standards` — Product management frameworks
  - `find-skills` — Skill discovery helper
  - `defuddle` — Web content extraction

### deprecated
- **Definition:** Marked for removal. Replaced by newer skill or no longer needed.
- **Timeline:** 90-day removal timeline from deprecation date.
- **What to do:** Use replacement skill listed in deprecation notice.
- **How to track:** See `SKILL_MAINTENANCE.md` deprecation timeline section.

---

## 8. Skill Health & Maintenance

### Validation
- Run `python ~/.agents/validate-skills.py --strict` before committing major changes
- Validation checks for:
  - Skill SKILL.md files exist
  - Dispatcher pipelines reference valid skills
  - Templates referenced actually exist
  - No semantic trigger collisions
  - Adopted status is consistent with pipeline membership

### Versioning
- Skills follow **Semantic Versioning** (MAJOR.MINOR.PATCH)
  - MAJOR: Breaking API change (skill charter shifts, companion skills change)
  - MINOR: Non-breaking addition (new triggers, new companions, new templates)
  - PATCH: Bug fix / clarification (typo, wording, link fixes)
- See `SKILL_MAINTENANCE.md` for complete versioning guide

### Quarterly Audits
- **Schedule:** First Thursday of each quarter (Sept 5, Dec 5, Mar 5, Jun 5)
- **Checklist:** See `SKILL_MAINTENANCE.md` Quarterly Skill Health Audit section
- **Deliverables:** Updated manifest, archived deprecated skills, refreshed lookup index
