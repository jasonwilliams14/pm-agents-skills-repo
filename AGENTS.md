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

