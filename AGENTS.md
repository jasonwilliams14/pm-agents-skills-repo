# AGENTS.md — Global Engineering Guardrails

> **This is the single global entry point for the agentic skill system.** Tool-specific config (e.g., `~/.claude/CLAUDE.md`) handles identity and tool-specific settings.

---

## 1. Judgment Boundaries (Three-Tier Enforcement)

### NEVER
- **Destructive Operations:** Never delete files, directories, or git branches without explicit user confirmation.
- **Unverified Commits:** Never commit, stage, or push code changes without successfully running the workspace test runner/linter first.
- **Legacy Assets:** Never install deprecated libraries or legacy dependencies.
- **File Overwrites:** Never overwrite configuration files outside your designated operational scope.

### ASK
- **High-Risk Changes:** Stop and ask before executing refactors, network security changes, or cluster state modifications.
- **Ambiguity:** Ask for clarification if a task instruction conflicts with existing workspace configurations or schemas.

### ALWAYS
- **Verification Loop:** Always execute the workspace linter and test suite before declaring a coding task complete.
- **Mermaid Diagrams:** Always render structural, temporal, or workflow visuals using Mermaid.js syntax blocks (not ASCII art, not external tools).
- **Immutable Docs:** Always capture architectural decisions and technical documentation in `docs/` using Markdown.
- **Skill Delegation:** Always check `~/.agents/skills/` for a specialized capability before attempting a complex, multi-step workflow.
- **Codebase Traversal:** Always use grep or regex to locate target code blocks before opening a file. Never read more than 150 lines of a single file unless inspecting a complete logic flow is strictly required.

---

## 2. Universal Toolchain

| Domain | Allowed Frameworks & Tools | Execution Constraint |
|:---|:---|:---|
| **Languages** | Python, Node.js, TypeScript | Default to Python for AI PoCs. Enforce strict typing in TS/Python. |
| **Python** | Python 3.12+, Pydantic v2 | OTEL instrumentation is a nice-to-have during POCs/prototyping — add it when it adds value, not a hard gate. |
| **Kubernetes** | Gateway API v1.1+, Inference Extensions | Prefer Gateway API over legacy Ingress. Use `InferencePool`, `InferenceModel` for AI workloads. |
| **Infrastructure** | vcluster, k3d, kind, Docker, Docker Compose | Priority order: vcluster > k3d > kind > Docker. GCP for GKE clusters. |
| **DevOps** | GitHub Actions, GitLab CI, Helm | Use GitHub Actions by default. |
| **K8s/GitOps** | kubectl, FluxCD, Helm | Treat cluster state as read-only for diagnostics. Use Flux for state mutation. |
| **Observability** | OpenTelemetry, Prometheus, Grafana | Recommended for kubernetes/gateway/agentic infrastructure as it matures; optional during early-stage POCs. |
| **Stack defaults** | Python + NGINX NJS + CrewAI/LangGraph | For agentic patterns. |
| **IDE** | VS Code, Zed, Antigravity | Shell: ZSH (no profile requirements). |

---

## 3. Documentation & Communication

### Three-Part Structure
All strategic docs and PRDs use separate versions for different audiences:
- **Executive version** — Value proposition, risk, business impact, timeline
- **Product version** — User outcomes, feature scope, success metrics
- **Engineering version** — Technical logic, constraints, implementation details, testing strategy

### Locations
- **Code:** GitHub (code repos), GitLab (pipelines)
- **Strategic docs:** Confluence
- **Project docs:** `docs/` folder (ADRs, design docs, technical specs)
- **Personal research:** Obsidian vault (not shared/published)

### Templates
- **ADRs:** `~/.agents/templates/architecture-decision-record.md`
- **Design Docs:** `~/.agents/templates/technical-design-doc.md`

### Communication Style
- Formal writing with quality prose. Visual emphasis: Mermaid diagrams for all architecture, workflows, decision flows.
- Executive summaries first, detail second. No jargon unless explained.

---

## 4. Deployment & Operations

- **Deployment:** Canary deployments, traffic splitting, progressive rollouts, automated rollbacks. Primary platform: Kubernetes with GitOps (FluxCD/ArgoCD).
- **Local testing:** vcluster (preferred) → k3d → kind → Docker Compose. Always test locally before proposing to engineering.
- **Multi-cloud:** Follow Kubernetes and GitOps best practices across GCP, AWS, Azure.

---

## 5. Skill System (`~/.agents/`)

The global `~/.agents/` directory is a JIT (Just-in-Time) skill dispatcher for specialized tasks.

### Principles
- **Efficiency first, then thoroughness:** Prioritize the most efficient skill for the task, then consider thorough approaches.
- **Skill recommendations:** Recommend new skills as needed — don't force existing skills.
- **Retry logic:** If skill output is weak, retry 1–2 times with adjusted prompt, then escalate to the user.
- **Trust level:** All skills equally trusted (no beta/experimental tiers).
- **Composition limit:** Maximum 1 primary + 2 secondary skills per execution tree.
- **Subagent returns:** Compress into structured YAML summary before returning to parent.

### Context Loading

When a project references `~/.agents/`:
1. Load the project's `AGENTS.md` first (local overrides global).
2. Load this file (`~/.agents/AGENTS.md`) for judgment boundaries and toolchain.
3. Reference `~/.claude/CLAUDE.md` for owner context, identity, and philosophy.
4. Match task intent against `dispatcher.yaml` (local) then `~/.agents/dispatcher.yaml` (global).
5. Load relevant skill(s) from `~/.agents/skills/` when the task matches.

If a project has no `AGENTS.md`, fall back to these global rules. Note which files you're using.

### Dispatcher Pipelines (Global)

| Pipeline | Steps |
|----------|-------|
| `cluster-lifecycle` | K8s provisioning + FluxCD bootstrap + Prometheus/Grafana |
| `ai-gateway-deployment` | GatewayClass/HTTPRoute → InferencePool → NGINX tuning → tracing |
| `agentic-routing-poc` | AI agentic logic → L7 routing → OTEL tracing → ADR handoff |
| `cluster-troubleshooting` | Diagnostics → root cause → remediation → post-mortem |
| `product-definition` | Strategic intent → JTBD → RICE → PRD → exec slides |

See `~/.agents/dispatcher.yaml` for full definitions. `~/.agents/USAGE.md` for quick-start skill lookup.

### Validation

```bash
python3 ~/.agents/validate-skills.py --strict
```

Validates: dispatcher pipelines reference valid skills, templates exist, no semantic trigger collisions, adopted status consistent.

---

## 6. Git & Collaboration

- **Branching:** Atomic feature/fix branches (`feature/add-dynamic-routing`, `fix/nginx-timeout`). Never commit to `main`/`master` directly.
- **Commits:** Semantic messages (`feat:`, `fix:`, `docs:`, `chore:`, `test:`). Include manual testing steps in PRs, link related issues.
- **Code quality:** Run linter and test suite before declaring tasks complete. Type hints mandatory. `ruff` for Python, `pytest` for tests.
- **Architecture:** API-first designs, streaming-aware (SSE, WebSockets), infrastructure-as-code (Terraform, Helm, FluxCD).

---

## 7. IP & Publishing

- **Internal:** Git-focused, all work versioned in private repos.
- **Personal:** Blog posts, articles, public research (competitive, technical analysis).
- **Competitive analysis:** Yes — conduct and document competitive research and differentiation.

---

## 8. For Child Workspaces (Multi-Repo Strategy)

When a project repo contains a local `AGENTS.md` that references `~/.agents/`:

```markdown
# child-project/AGENTS.md
This project inherits from ~/.agents/:
- Use judgment boundaries from ~/.agents/AGENTS.md
- Use skill system from ~/.agents/skills/
- Use dispatcher pipelines from ~/.agents/dispatcher.yaml

Local overrides: [none, or list specific overrides]
```

Load child workspace `AGENTS.md` first (local takes precedence), then fall back to `~/.agents/` for referenced files.

---

## References

- **Skill System:** `~/.agents/skills/`, `~/.agents/.skills_manifest.json`
- **Execution Rules:** `~/.agents/RULES.md`
- **Quick-Start Lookup:** `~/.agents/USAGE.md`
- **Dispatcher Pipelines:** `~/.agents/dispatcher.yaml`
- **Templates:** `~/.agents/templates/`
- **Skill Maintenance:** `~/.agents/SKILL_MAINTENANCE.md`
- **Owner Context & Philosophy:** `~/.claude/CLAUDE.md`
- **Validation:** `python3 ~/.agents/validate-skills.py --strict`