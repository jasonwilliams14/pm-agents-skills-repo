# CLAUDE.md — Jason Williams Global Standards

This file provides guidance to Claude Code when working with code, analysis, designs, and documentation.

---

## ENVIRONMENT & API CONFIGURATION

Claude Code in this environment routes through an internal F5 proxy:

- `ANTHROPIC_BASE_URL`: `https://f5ai.pd.f5net.com/anthropic`
- Default model: `sonnet[1m]` (claude-sonnet-4-6 with 1M context)
- Haiku alias → `claude-haiku-4-5`, Opus alias → `claude-opus-4-6[1m]`
- Agent teams and fork subagents are enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, `CLAUDE_CODE_FORK_SUBAGENT=1`)

---

## OWNER CONTEXT: JASON WILLIAMS

### Role & Responsibilities
- **Title:** Principal TPM & Solutions Architect at F5
- **Core function:** Identify and escalate risk, needs, and value
- **Stakeholders:** Architects, engineers, Director of Product Managers, Solutions/Sales Engineers
- **Market:** Enterprise, large and mid-market customers

### Products Owned
- **F5 AI Guardrails** — GenAI security, prompt injection, jailbreak detection, content policy
- **F5 Red Team** — Offensive security testing, threat modeling
- **NGINX Ingress Controller** — Kubernetes ingress networking
- **NGINX Gateway Fabric** — Advanced K8s gateway and routing
- **F5 Distributed Cloud (XC)** — Multi-cloud platform and sovereignty

### Primary Domains
- **AI Security** — Guardrails, prompt injection, adversarial inputs, PII detection
- **Kubernetes Networking** — Gateway API, routing, load balancing, traffic control
- **SaaS / Multi-Cloud Sovereignty** — Multi-cloud architectures, compliance, data residency

### Work Pattern
- **Daily:** Designing, research, analysis, presentations, POCs (local K8s environments, some coding)
- **Artifacts:** Bi-monthly releases, proof-of-concept validation, architecture documentation
- **Philosophy:** POC-First — validate with working code and demos, not slides. Documentation is born from functional prototypes.

---

## TECHNICAL STANDARDS

### Languages & Frameworks
- **Python:** 3.12+ exclusively. Strict Pydantic v2 for all data models. Mandatory OpenTelemetry instrumentation — no POC is complete without traces/metrics.
- **Kubernetes:** Prefer Gateway API v1.1+ over legacy Ingress. Use Gateway Inference Extensions (`InferencePool`, `InferenceModel`) for AI workloads.
- **Stack defaults:** Python + NGINX NJS + CrewAI/LangGraph patterns.
- **Infrastructure:** Ubuntu 24.04, Docker, Docker Compose, vcluster, k3d, kind (in that priority order).
- **Observability:** OpenTelemetry (mandatory on all new infrastructure).

### Code Handoff
- Engineers take over POCs and review/modify code as needed
- Code must be production-ready: type hints, linting, OTEL instrumentation
- Clear commit history and documentation for engineering takeover

---

## DOCUMENTATION & COMMUNICATION

### Documentation Locations
**Primary:** GitHub (code repos), GitLab (pipelines), Confluence (strategic docs)  
**Local:** `docs/` folder in projects (ADRs, design docs, technical specs)  
**Personal research:** Obsidian vault (not shared/published)

### Documentation Structure
- **Three-part approach:** Create separate versions for different audiences
  - **Executive version** — Value proposition, risk, business impact, timeline
  - **Engineering version** — Technical logic, constraints, implementation details, testing strategy
  - **Product version** — User outcomes, feature scope, success metrics
- **Format:** Formal writing with quality prose. Visual clarity via Mermaid diagrams (architecture, flows, sequences)
- **Approval:** Jason approves before handoff to engineering

### Document Templates
- **ADRs:** Use `~/.agents/templates/architecture-decision-record.md` for all major architectural decisions
- **Design Docs:** Use `~/.agents/templates/technical-design-doc.md` for feature designs
- **Future:** PRD template (to be added)

### Communication Style
- Formal and casual as context requires
- Quality writing: clear, concise, no jargon unless explained
- Visual emphasis: Mermaid diagrams for all architecture, workflows, and decision flows
- Executive summaries first, detail second

---

## DEPLOYMENT & OPERATIONS

### Deployment Standards
- **Ready for deploy:** Properly booted up, working as expected, passing all checks
- **Modern practices:** Canary deployments, traffic splitting, progressive rollouts, automated rollbacks
- **Primary platform:** Kubernetes with GitOps (FluxCD / ArgoCD)
- **Multi-cloud:** Follow Kubernetes and GitOps best practices across GCP, AWS, Azure

### Local Testing
- **Preferred:** vcluster for isolated K8s environments
- **Secondary:** k3d for lightweight clusters, kind for local testing
- **Docker:** Docker Compose for simple container orchestration
- **POC validation:** Always test locally before proposing to engineering

---

## INTELLECTUAL PROPERTY & VISIBILITY

### Publishing Strategy
- **Internal systems:** Git-focused, all work versioned in private repos
- **Personal publications:** Blog posts, articles, public research (competitive, technical analysis)
- **Competitive analysis:** Yes, conduct and document competitive research and differentiation

### Brand & Communication
- Technical storytelling: positioning, narratives, competitive differentiation
- POC-first demonstrates value before claims
- Evidence-based: working systems + metrics prove capability

---

## TOOLS & ENVIRONMENT

### Development Tools
- **IDE/Editor:** VS Code (primary), Zed, Antigravity
- **Shell:** ZSH (no profile requirements)
- **Git:** Conventional commits (feat:, fix:, docs:, chore:, test:)
- **Version control:** GitHub, GitLab

### Infrastructure & Observability
- **Container orchestration:** Docker, Docker Compose (simple), vcluster, k3d, kind (K8s, in priority order)
- **Observability stack:** Prometheus → Grafana → Cloud provider tools (in that priority)
- **Kubernetes:** Treat cluster state as read-only for diagnostics, use FluxCD for mutations
- **Configuration:** Helm for templating, kubectl for deployment

---

## SKILL SYSTEM INTEGRATION (`~/.agents/`)

The global `~/.agents/` directory is a JIT (Just-in-Time) skill dispatcher for specialized tasks.

### Core Principles
- **Efficiency first, then thoroughness:** Prioritize most efficient skill for task, then consider thorough approaches
- **Skill recommendations:** Claude should recommend new skills as needed (don't force existing skills)
- **Retry logic:** If skill produces weak output, retry 1-2 times with adjusted prompt, then escalate to Jason for guidance
- **Trust level:** All 32 skills equally trusted (no beta/experimental tiers)

### Dispatcher Pipelines (Pre-defined Workflows)
- `cluster-lifecycle` — K8s provisioning + FluxCD bootstrap + Prometheus/Grafana baseline
- `ai-gateway-deployment` — GatewayClass/HTTPRoute → InferencePool → NGINX tuning → tracing
- `agentic-routing-poc` — AI agentic logic → L7 routing → OTEL tracing → ADR handoff
- `cluster-troubleshooting` — Diagnostics → root cause → remediation → post-mortem
- `product-definition` — Strategic intent → JTBD value map → RICE → PRD → exec slides

**Note:** See `~/.agents/USAGE.md` for quick-start skill lookup and `~/.agents/dispatcher.yaml` for full pipeline definitions.

### Skill Composition Limits
- Maximum 1 primary skill + 2 secondary skills per execution tree
- Subagent returns must be compressed into a structured YAML summary before returning to parent
- Use dispatcher pipelines for complex multi-skill orchestration

---

## STRUCTURAL GUARDRAILS

### Diagrams & Visuals
- **Always render structural/temporal/workflow visuals using Mermaid.js syntax** (not ASCII art, not external tools)
- Diagrams should be in markdown code blocks for GitHub/GitLab compatibility

### Documentation
- Capture all architectural decisions and technical docs in project `docs/` directory as `.md` files
- ADRs required for major architectural shifts
- Use templates from `~/.agents/templates/`

### Destructive Operations
- **Never delete files, directories, or branches without explicit user confirmation**
- Stop and ask before running `rm -rf`, `git reset --hard`, `git push --force`, or equivalent
- Investigate before deleting; may be in-progress user work

### High-Risk Changes
- **Stop and confirm before executing:**
  - Refactors affecting multiple files/services
  - Network security changes (firewall, policies, access control)
  - Cluster state modifications (via kubectl, not FluxCD)
  - Changes to authentication/authorization flows
  - Data migration or schema changes
  - Breaking API changes

### Code Inspection
- Use grep/regex to locate target code blocks before opening files (avoid unnecessary reads)
- Avoid reading more than 150 lines of a single file unless inspecting a complete logic flow

---

## STANDARDS & BEST PRACTICES

### Commits & PRs
- **Atomic commits:** Feature/fix branches (e.g., `feature/add-dynamic-routing`, `fix/nginx-timeout`). Never commit to `main`/`master` directly.
- **Semantic commit messages:** `feat:`, `fix:`, `docs:`, `chore:`, `test:` prefixes
- **PR requirements:** Include manual testing steps, link related issues, describe all changes

### Code Quality
- Run linter and test suite before declaring tasks complete
- Type hints mandatory (Python, TypeScript)
- Linting: `ruff` for Python
- Testing: `pytest` for Python, appropriate framework per language

### Architecture & Design
- Favor API-first designs with clear contracts
- Streaming-aware architectures (SSE, WebSockets for real-time)
- Infrastructure-as-code: Terraform, Helm, FluxCD manifests
- Container everything: Docker for local dev, K8s for production

### Observability
- All new Kubernetes/gateway/agentic infrastructure must be OTEL-instrumented
- Mandatory: spans for request tracing, metrics for latency/errors/throughput
- Dashboards in Prometheus/Grafana for visualization

---

## WHAT CLAUDE SHOULD NOT DO

- Commit code without your approval (ask first for significant changes)
- Push to remote without confirmation
- Delete branches, files, or directories without asking
- Run destructive git operations (`reset --hard`, `push --force`)
- Skip pre-commit hooks or linting
- Deploy to production without explicit approval
- Make architectural decisions without consulting (propose with rationale, ask for confirmation)

---

## FUTURE SECTIONS (TODO)

The following sections will be added when refined:
- **Section 2:** Weekly/monthly work rhythm and pain points
- **Section 3:** Testing requirements, security boundaries, breaking change policies, dependency constraints
- **Section 8:** Decision boundaries (low-risk, medium-risk, high-risk thresholds)
- **Section 10:** Success criteria and metrics across different work types

---

## REFERENCES

- Skill System: `~/.agents/RULES.md` (execution rules), `~/.agents/USAGE.md` (quick-start)
- Skill Validation: `python3 ~/.agents/validate-skills.py --strict`
- Dispatcher Pipelines: `~/.agents/dispatcher.yaml`
- Templates: `~/.agents/templates/`
- Maintenance: `~/.agents/SKILL_MAINTENANCE.md` (versioning, deprecation)
