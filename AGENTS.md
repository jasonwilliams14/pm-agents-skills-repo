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

## Git & Collaboration
- Commit/PR guidelines.
- Branching strategy.

---

## 2. Universal Toolchain Context

| Domain | Allowed Frameworks & Tools | Execution Constraint |
| :--- | :--- | :--- |
| **Languages** | Python, Node.js, TypeScript | Default to Python for AI PoCs. Enforce strict typing in TS/Python. |
| **Infrastructure** | k3d, kind, docker | Local testing only. |
| **Kubernetes/GitOps** | kubectl, fluxcd, helm | Treat cluster state as read-only for diagnostics. Use Flux for state mutation. |
| **Observability** | OpenTelemetry (otel) | Instrument logs and traces on all new gateway/agentic infrastructure. |

