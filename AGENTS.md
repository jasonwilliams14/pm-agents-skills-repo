# AGENTS.md — Global Engineering Guardrails

## 1. Judgment Boundaries (Three-Tier Enforcement)

### NEVER
* **Destructive Operations:** Never delete files, directories, or git branches without explicit user confirmation.
* **Unverified Commits:** Never commit, stage, or push code changes without successfully running the workspace test runner/linter first.
* **Legacy Assets:** Never install deprecated libraries or legacy dependencies.
* **File Overwrites:** Never overwrite configuration files outside your designated operational scope.

### ASK
* **High-Risk Changes:** Stop and ask for confirmation before executing refactors, network security changes, or cluster state modifications.
* **Ambiguity:** Ask for clarification if a task instruction conflicts with existing workspace configurations or schemas.

### ALWAYS
* **Verification Loop:** Always execute the workspace linter and test suite before declaring a coding task complete.
* **Standardized Diagrams:** Always render structural, temporal, or workflow visuals using **Mermaid.js** syntax blocks.
* **Immutable Docs:** Always capture architectural decisions and technical documentation inside the `docs/` directory using strictly formatted Markdown (`.md`).
* **Skill Delegation:** Always check `~/.agents/skills/` for a specialized capability before attempting a complex, multi-step workflow.
* **Codebase Traversal:** Always use grep or specific regex searches to locate target code blocks before opening a file.
* **File Inspection Limits:** Never read more than 150 lines of code in a single file unless inspecting a complete logic flow is strictly required.


## Git & Collaboration
* **Branching Strategy:** Create atomic feature/fix branches (e.g., `feature/add-dynamic-routing` or `fix/nginx-timeout`). Never commit directly to `main` or `master`.
* **Commit/PR Guidelines:** Write structured semantic commit messages (e.g., `feat:`, `fix:`, `docs:`, `chore:`). Keep pull requests tightly scoped and describe all code changes alongside manual testing steps.

---

## 2. Universal Toolchain Context

| Domain | Allowed Frameworks & Tools | Execution Constraint |
| :--- | :--- | :--- |
| **Languages** | Python, Node.js, TypeScript | Default to Python for AI PoCs. Enforce strict typing in TS/Python. |
| **Infrastructure** | k3d, kind, docker, vcluster | GCP for GKE kubernetes clusters. |
| **DevOps** | github actions, gitlab ci, helm | Use GitHub Actions by default for standard workflows. |
| **Kubernetes/GitOps** | kubectl, fluxcd, helm | Treat cluster state as read-only for diagnostics. Use Flux for state mutation. |
| **Observability** | OpenTelemetry (otel) | Instrument logs and traces on all new kubernetes/gateway/agentic infrastructure. |

---

## 3. Context Loading Protocol (MANDATORY FOR CLAUDE)

**This section enforces the agentic workflow system. Claude MUST execute this protocol before responding to ANY task in this workspace or in child workspaces that reference ~/.agents/.**

### The Protocol: Five-Step Context Load

Claude shall load local context in this exact order:

1. **Local AGENTS.md** (judgment boundaries & toolchain) — Load FIRST, always
2. **Local CLAUDE.md** (standards, owner context, skill system) — Load SECOND, always
3. **dispatcher.yaml** (intent → skill sequence pipelines) — Load if present; match request intent
4. **RULES.md** (orchestration & execution rules) — Reference for agentic decision-making
5. **.skills_manifest.json** (skill registry, semantic triggers) — Load for skill discovery & composition

### Execution Checkpoint: Before Responding

Claude MUST perform this checkpoint explicitly:

```
1. Scan current working directory for local AGENTS.md
   ✓ If exists → Load immediately (overrides global rules)
   ✗ If missing → Note: "No local AGENTS.md, using global rules from ~/.agents/"

2. Scan current working directory for local CLAUDE.md
   ✓ If exists → Load immediately (overrides ~/.claude/CLAUDE.md)
   ✗ If missing → Note: "No local CLAUDE.md, using global standards"

3. Scan current working directory for dispatcher.yaml
   ✓ If exists → Match user request intent against pipelines
   ✗ If missing → Fall back to semantic skill lookup in .skills_manifest.json

4. Load RULES.md
   → Reference Rule 34 (Retrieval Strategy Hierarchy)
   → Reference Rule 6 (Dispatcher Execution Logic)
   → Reference Rule 56 (Template Enforcement)

5. Load .skills_manifest.json (grep for semantic triggers)
   → Use this for skill discovery ONLY if no dispatcher pipeline matches
```

### Show Your Reasoning (Transparency)

After loading context, Claude MUST explicitly communicate:

```
📋 Local context loaded:
  ✓ AGENTS.md found (loading judgment boundaries)
  ✓ CLAUDE.md found (loading standards)
  ✓ dispatcher.yaml found (checking for matching pipeline)

🔍 Intent matching:
  Your request: "[user task]"
  Dispatcher pipeline: [matched-pipeline-name] or "No match, using semantic skill lookup"
  Recommended skills: [skill-1] → [skill-2] → [skill-3]
  Skill composition limit: 1 primary + 2 secondary (per CLAUDE.md Rule 154-157)
  Affected templates: [template-name.md]
```

### Failure Modes (Stop and Ask)

If Claude cannot load context:

```
❌ Context loading failed:
  - Local AGENTS.md not found (required for judgment boundaries)
  - dispatcher.yaml not readable (required for intent routing)
  - .skills_manifest.json not found (required for skill discovery)

→ STOP. Ask user: "Does this workspace have a local AGENTS.md? Should I use global ~/.agents/ rules?"
```

### For Child Workspaces (Multi-Repo Strategy)

When a project repo contains a local AGENTS.md or CLAUDE.md that references ~/.agents/:

```
# child-project/AGENTS.md
This project inherits from ~/.agents/:
- Use judgment boundaries from parent AGENTS.md
- Use skill system from parent CLAUDE.md
- Use dispatcher pipelines from parent dispatcher.yaml
- Use skills from parent ~/.agents/skills/

Local overrides: [none, or list specific overrides]
```

Claude shall:
1. Load child workspace AGENTS.md/CLAUDE.md FIRST (Rule 34: local overrides)
2. Then fall back to ~/.agents/ for referenced files
3. Merge local + global rules (child takes precedence)

### Validation: Run Before Declaring Task Complete

Before declaring a task complete, Claude shall:

```bash
python3 ~/.agents/validate-skills.py --strict
```

This validates:
- Dispatcher pipelines reference valid skills
- Templates referenced in pipeline steps exist
- No semantic trigger collisions
- Adopted status consistent with pipeline membership
