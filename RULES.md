# Global Execution Rules

## 1. Skill Loading & Context Slicing
- **Location:** All core skills reside in `~/.agents/skills/`.
- **Zero Preloading:** Never load full skill manifests by default.
- **Process:**
  1. Parse intent against global constraints.
  2. Scan `SKILLS_INDEX.md` for semantic alignment or keyword triggers.
  3. Hydrate the session *only* with the matching `SKILL.md`.
- **Prefer:** Atomic, specialized skills, precise file boundaries, low token footprint.
- **Avoid:** Context flooding, cross-domain logic pollution, redundant definitions.

---

## 2. Multi-Skill Composition
- If a workflow spans multiple domains, isolate execution:
  - Identify and invoke the **Primary Skill** first.
  - Augment with **Secondary Skills** sequentially, only if required.
- **Hard Boundaries:** Maximum 1 primary skill and 2 secondary skills per execution tree.

---

## 3. Retrieval Strategy & Hierarchy
- **Order of Operations:** 
  1. `SKILLS_INDEX.md` (Discovery)
  2. Targeted `SKILL.md` (Hydration)
  3. Workspace `AGENTS.md` (Local Context Override)
  4. Workflow Playbooks (Process execution)
  5. Templates (Only during artifact generation)
- **Local Overrides:** A project-level `AGENTS.md` or `GEMINI.md` found in the current working directory always takes precedence over global rules for domain-specific context.

---

## 4. Reasoning Style & Technical Standards
- **Tone:** Concise, direct, operationally realistic, architecture-first. No conversational filler.
- **Architectural Priorities:** Clarity, production-grade recommendations, observability, and structural correctness.
- **Technical Focus:** 
  - Containerized, repeatable workflows (Docker Compose, Kubernetes, FluxCD).
  - API-first designs, streaming-aware architectures, and reusable automation.
  - Clear separation between infrastructure engineering and knowledge graph (Obsidian) management.