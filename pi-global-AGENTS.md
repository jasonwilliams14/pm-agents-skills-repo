# Global Agent Context — Jason Williams
# Loaded automatically by Pi at startup before any project AGENTS.md

## Identity & System Overview
This agent operates within a structured agentic AI workflow system. All skills,
pipelines, and execution rules live in `~/.agents/`. This file is the Pi-native
bootstrap that activates that system automatically on every session.

---

## Execution Rules (from ~/.agents/RULES.md)

### Skill Loading — Lazy Discovery Only
- Skills live in `~/.agents/skills/`. Never preload. Never crawl local `./skills/`.
- Discovery process:
  1. Grep manifest for trigger keyword: `grep -i -C 4 '"keyword"' ~/.agents/.skills_manifest.json`
  2. Read only the matching `~/.agents/skills/<name>/SKILL.md`
  3. Unload after use — no cross-task bleed
- Hard limit: **1 primary skill + 2 secondary skills** per task tree

### Dispatcher — Pipeline First
Before doing anything, check if the request matches a pipeline in `~/.agents/dispatcher.yaml`.
- **Match found** → load skills in the defined sequence, compress each step's output before passing to the next
- **No match** → grep `.skills_manifest.json` semantic_triggers for the best skill fit
- Each pipeline step output = "Crystallized Insight" (compressed YAML summary: status, changes, errors only)

### Retrieval Order
1. `~/.agents/.skills_manifest.json` — grep for skill (fast lookup)
2. `~/.agents/skills/<name>/SKILL.md` — hydrate only the matched skill
3. Project `AGENTS.md` — local context overrides (already loaded by Pi)
4. `~/.agents/templates/` — only during artifact generation

### Reasoning Style
- Concise, direct, architecture-first. No conversational filler.
- Production-grade recommendations. Observability built in.
- Prefer: containerized workflows, FluxCD GitOps, API-first designs.

### Safety Boundaries
- NEVER execute destructive operations (`rm`, `kubectl delete`, `terraform destroy`) without explicit user confirmation
- NEVER commit unverified changes
- ALWAYS ask before high-risk or irreversible actions

---

## Dispatcher Pipelines (from ~/.agents/dispatcher.yaml)

| Pipeline | Trigger Intent | Skill Sequence |
|---|---|---|
| `cluster-lifecycle` | Provision K8s clusters, GitOps bootstrap | platform-engineer → k8s-engineer → k8s-observability-ops |
| `ai-gateway-deployment` | Deploy AI gateway with inference routing | k8s-gateway-api → k8s-gateway-inference → nginx-patterns → k8s-observability-ops |
| `agentic-routing-poc` | Build agentic routing PoC | ai-engineer → nginx-patterns+k8s-gateway-api → k8s-observability-ops → docs-agent |
| `cluster-troubleshooting` | Debug K8s issues | k8s-engineer → platform-engineer → k8s-engineer+platform-engineer → docs-agent |
| `product-definition` | Market gap to PRD | tech-pm → value-proposition → pm-standards → prd-generator → slide-deck-creator |

---

## Skill Registry (from ~/.agents/.skills_manifest.json)

### Active Skills (in dispatcher pipelines — highest priority)
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

### Maintained Skills (available but not in active pipelines)
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
> **Companion limit:** Load companions only if task crosses domains. Max 2.

---

## Project AGENTS.md Layer
Pi auto-loads this file first, then the project-level `AGENTS.md` on top.
Project rules deep-merge and override global rules where keys conflict.
Current project context is already injected by Pi — no action needed.

---

## Validation
Before declaring any skill-related task complete:
```bash
python3 ~/.agents/validate-skills.py --strict
```
