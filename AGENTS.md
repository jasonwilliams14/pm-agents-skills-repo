# AGENTS.md — Global Engineering Guardrails

> **This is the single global entry point for the agentic skill system.**
> Any agent tool (Pi, Grok, Claude Code, agy, others) loads this file for judgment
> boundaries, toolchain rules, and the JIT skill dispatcher.
> Tool-specific config (`~/.grok/config.toml`, `~/.claude/CLAUDE.md` for Claude, `~/.pi/agent/settings.json` for Pi)
> handles identity, owner context, and tool-specific settings on top of this file.
>
> **⚠️ Symlink Note:** `~/.claude/CLAUDE.md` is symlinked to `~/.agents/CLAUDE.md` (single source of truth). All projects inherit this configuration. See [SETUP.md](SETUP.md) for architecture details.

---

## 1. Judgment Boundaries (Three-Tier Enforcement)

### NEVER
- **Destructive Operations:** Never delete files, directories, git branches, or run
  destructive commands (`rm -rf`, `git reset --hard`, `git push --force`, `kubectl delete`,
  `terraform destroy`) without explicit user confirmation.
- **Unverified Commits:** Never commit, stage, or push code changes without successfully
  running the workspace test runner/linter first.
- **Legacy Assets:** Never install deprecated libraries or legacy dependencies.
- **File Overwrites:** Never overwrite configuration files outside your designated
  operational scope.

### ASK
- **High-Risk Changes:** Stop and ask before executing refactors, network security changes,
  cluster state modifications, authentication/authorization flow changes, data migrations,
  schema changes, or breaking API changes.
- **Ambiguity:** Ask for clarification if a task instruction conflicts with existing workspace
  configurations or schemas.
- **Architectural Decisions:** Propose with rationale, ask for confirmation — never decide
  unilaterally.

### ALWAYS
- **Verification Loop:** Always execute the workspace linter and test suite before declaring
  a coding task complete.
- **Mermaid Diagrams:** Always render structural, temporal, or workflow visuals using
  Mermaid.js syntax blocks (not ASCII art, not external tools).
- **Immutable Docs:** Always capture architectural decisions and technical documentation in
  `docs/` using Markdown.
- **Skill Delegation:** Always check `~/.agents/skills/` for a specialized capability before
  attempting a complex, multi-step workflow.
- **Codebase Traversal:** Always use grep or regex to locate target code blocks before
  opening a file. Never read more than 150 lines of a single file unless inspecting a
  complete logic flow is strictly required.

---

## 2. Universal Toolchain

Reference `~/.agents/references/universal-toolchain.md`

---

## 3. Documentation

Reference `~/.agents/references/documentation.md` for guidelines and conventions

---

## 4. Deployment & Operations

- **Local testing:** vcluster (preferred) → k3d → kind → Docker Compose. Always test locally.

---

## 5. Skill System (`~/.agents/`)

The global `~/.agents/` directory is a JIT (Just-in-Time) skill dispatcher for specialized tasks.

### Principles
- **Efficiency first, then thoroughness:** Prioritize the most efficient skill for the task, then consider thorough approaches.
- **Skill recommendations:** Recommend new skills as needed, don't force existing skills.
- **Retry logic:** If skill output is weak, retry 1–2 times with adjusted prompt, then escalate to the user.
- **Trust level:** All skills equally trusted (no beta/experimental tiers).
- **Composition limit:** Maximum 1 primary + 2 secondary skills per execution tree.
- **Subagent returns:** Compress into structured YAML summary before returning to parent.

### Skill Loading — Lazy Discovery Only
Skills live in `~/.agents/skills/`. Never preload. Never crawl local `./skills/`.
- **Discovery process:**
  1. Grep manifest for trigger keyword: `grep -i -C 4 '"keyword"' ~/.agents/.skills_manifest.json`
  2. Read only the matching `~/.agents/skills/<name>/SKILL.md`
  3. Unload after use — no cross-task bleed
- **Hard limit:** 1 primary skill + 2 secondary skills per task tree
- **Companion limit:** Load companions only if task crosses domains. Max 2.

### Dispatcher — Pipeline First
Before doing anything, check if the request matches a pipeline in `~/.agents/dispatcher.yaml`.
- **Match found** → load skills in the defined sequence, compress each step's output before passing to the next
- **No match** → grep `.skills_manifest.json` semantic_triggers for the best skill fit
- **Crystallized Insight:** Each pipeline step output = compressed YAML summary (status, changes, errors only)

### Retrieval Order
1. `~/.agents/.skills_manifest.json` — grep for skill (fast lookup)
2. `~/.agents/skills/<name>/SKILL.md` — hydrate only the matched skill
3. Project `AGENTS.md` — local context overrides
4. `~/.agents/templates/` — only during artifact generation

### Context Loading

When a project references `~/.agents/`:
1. Load the project's `AGENTS.md` first (local overrides global).
2. Load this file (`~/.agents/AGENTS.md`) for judgment boundaries and toolchain.
3. Load tool-specific config (e.g. `~/.claude/CLAUDE.md`, Pi settings) for owner context and identity.
4. Match task intent against `dispatcher.yaml` (local) then `~/.agents/dispatcher.yaml` (global).
5. Load relevant skill(s) from `~/.agents/skills/` when the task matches.

If a project has no `AGENTS.md`, fall back to these global rules. Note which files you're using.

### Dispatcher Pipelines

| Pipeline | Trigger Intent | Skill Sequence |
|---|---|---|
| `cluster-lifecycle` | Provision K8s clusters, GitOps bootstrap | platform-engineer → k8s-engineer → k8s-observability-ops |
| `ai-gateway-deployment` | Deploy AI gateway with inference routing | k8s-gateway-api → k8s-gateway-inference → nginx-patterns → k8s-observability-ops |
| `agentic-routing-poc` | Build agentic routing PoC | ai-engineer → nginx-patterns+k8s-gateway-api → k8s-observability-ops → docs-agent |
| `cluster-troubleshooting` | Debug K8s issues | k8s-engineer → platform-engineer → k8s-engineer+platform-engineer → docs-agent |
| `product-definition` | Market gap to PRD | tech-pm → value-proposition → pm-standards → prd-generator → slide-deck-creator |

See `~/.agents/dispatcher.yaml` for full step-by-step definitions.

### Skill Registry

#### Active Skills (in dispatcher pipelines — highest priority)
| Skill | Explicit Triggers | Semantic Triggers (sample) |
|---|---|---|
| `ai-engineer` | ai-engineer, ai-dev | PoC, agentic workflows, LangChain, MCP, Ollama, local LLM |
| `ai-security-patterns` | ai-security-patterns, ai-sec | prompt injection, OWASP LLM, guardrails, jailbreak |
| `k8s-engineer` | k8s-engineer, k8s-sme | Ingress, cluster networking, pod scheduling, vcluster, FluxCD |
| `k8s-gateway-api` | k8s-gateway-api | GatewayClass, HTTPRoute, GRPCRoute, agentgateway |
| `k8s-gateway-inference` | k8s-gateway-inference | InferencePool, model routing, LLM load balancing |
| `k8s-observability-ops` | observability-ops, otel-ops | OpenTelemetry, Prometheus, Grafana, tracing, RED metrics |
| `nginx-patterns` | nginx-patterns, nginx-sme | SSE streaming, proxy buffering, L7 tuning, NGF |
| `platform-engineer` | platform-engineer | infrastructure, K8s admin, GKE, AKS, EKS, cloud provisioning |
| `docs-agent` | docs-agent, documentation | technical writing, ADR, engineer handoff |
| `tech-pm` | tech-pm, product-strategy | feature scoping, roadmap, prioritization |
| `prd-generator` | prd-generator | PRD template, product requirements document |

#### Maintained Skills (available but not in active pipelines)
| Skill | Explicit Triggers | Semantic Triggers (sample) |
|---|---|---|
| `vcluster-dev` | vcluster-dev, vcluster | virtual cluster, multi-cluster testing, lightweight K8s |
| `k8s-ai-expert` | k8s-ai-expert | ML workloads, GPU scheduling, vLLM, KV cache, KEDA |
| `ai-platform-pm` | ai-platform-pm, platform-pm | platform conformance, cross-product, AI portfolio |
| `python-dev-standard` | python-dev-standard | Pydantic, type hinting, async code, clean python |
| `pm-standards` | pm-standards | JTBD, RICE, Jason Standard |
| `value-proposition` | value-proposition | JTBD value prop, competitive advantage |
| `obsidian-markdown` | obsidian-markdown | wikilinks, callouts, frontmatter, embeds |
| `obsidian-cli` | obsidian-cli | search vault, vault tasks, obsidian automation |
| `obsidian-bases` | obsidian-bases | .base files, database views, obsidian formulas |
| `json-canvas` | json-canvas, canvas-files | .canvas, visual mind map, nodes and edges |
| `defuddle` | defuddle | extract web content, clean markdown from URL |
| `slide-deck-creator` | slide-deck-creator, doc-to-slides | presentation, slide deck, PowerPoint |
| `positioning-messaging` | positioning-messaging | competitor messaging, market positioning |
| `google-agents-cli-*` | adk-*, google-agents-cli-* | Google ADK, agent scaffold, deploy, eval, publish |
| `find-skills` | find-skills | what skill, discover capability |

> **Skill path pattern:** `~/.agents/skills/<skill-name>/SKILL.md`

### Validation

```bash
python3 ~/.agents/validate-skills.py --strict
```

Validates: dispatcher pipelines reference valid skills, templates exist, no semantic trigger collisions, adopted status consistent.

---

## 6. Reasoning

Reference `~/.agents/references/reasoning.md` for reasoning style.

---

## 7. Git & Collaboration

Reference `~/.agents/references/git-collab.md` for using git and collaboration.

---

## 8. IP & Publishing

- **Internal:** Git-focused, all work versioned in private repos.
- **Personal:** Blog posts, articles, public research (competitive, technical analysis).
- **Competitive analysis:** Yes — conduct and document competitive research and differentiation.

---

## 9. For Child Workspaces (Multi-Repo Strategy)

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

## 10. Project AGENTS.md Layer

Agent tools that support auto-loading (e.g. Pi) load this file first, then the
project-level `AGENTS.md` on top. Project rules deep-merge and override global
rules where keys conflict. Current project context is injected by the tool —
no action needed.

---

## References

- **Skill System:** `~/.agents/skills/`, `~/.agents/.skills_manifest.json`
- **Execution Rules:** `~/.agents/RULES.md`
- **Quick-Start Lookup:** `~/.agents/USAGE.md`
- **Dispatcher Pipelines:** `~/.agents/dispatcher.yaml`
- **Templates:** `~/.agents/templates/`
- **Skill Maintenance:** `~/.agents/SKILL_MAINTENANCE.md`
- **Tool-specific identity:** `~/.claude/CLAUDE.md` (Claude Code), `~/.pi/agent/settings.json` (Pi)
- **Validation:** `python3 ~/.agents/validate-skills.py --strict`
