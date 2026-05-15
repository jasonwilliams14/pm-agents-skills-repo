# Skill Index

## nginx-patterns

Topics:
- nginx
- reverse proxy
- API gateway
- SSE
- chunked transfer
- streaming
- njs
- AI gateway traffic

Use When:
- debugging streaming
- designing ingress
- explaining HTTP behavior
- implementing proxy architectures

---

## ai-security, ai-gateway

Topics:
- LLM routing
- AI gateways
- AI guardrails, red team
- token accounting
- rate limiting
- prompt inspection
- inference orchestration

Use When:
- building AI platforms
- model routing discussions
- GenAI infrastructure planning

---

## k8s-sme

Topics:
- Gateway API
- Inference Extensions
- FluxCD
- k3d
- Ingress
- AI Inference Routing
- platform engineering

Use When:
- cluster architecture
- AI inference routing design
- local K8s POCs
- GitOps automation

---

## obsidian-knowledge

Topics:
- Obsidian
- vault organization
- markdown workflows
- MCP integration
- knowledge retrieval

Use When:
- second brain workflows
- vault automation
- AI-assisted knowledge systems

---

## Directives for Multi-Skill Sequences
1. **Lookup Priority:** Read the semantic intent description first to verify exact matches.
2. **Isolation Guarantee:** Executing a skill via its directory path spins up an independent subagent context loop, wiping local memory once the consolidated payload is returned.
3. **Directory Access:** Activating a skill dynamically whitelists only its specific subfolder inside `~/.agents/skills/[name]/`.

# Agent Skills Index

This index acts as the primary routing table for lazy loading capabilities. The execution engine parses this index on session boot to map user intent to specialized, domain-isolated skill directories.

| Skill Directory | Target Alias / Keyword Triggers | Intent Routing Description (For Gemini Matcher) | Default Model Tier |
| :--- | :--- | :--- | :--- |
| `skills/nginx-patterns` | nginx, nginx-ingress, nginx-gateway-fabric, proxy_buffering, Server-Sent Events, chunked transfer, njs. | Debugging streaming connections, designing ingress topologies for LLM traffic, implementing NGINX Gateway Fabric routing. |
| `skills/ai-gateway` | LLM routing, AI gateways, guardrails, red-teaming, token accounting, rate limiting, prompt inspection, inference orchestration. | Building AI platforms, enterprise model routing discussions, GenAI infrastructure architecture and planning. |
| `skills/k8s-sme` | Gateway API, InferencePool, InferenceModel, FluxCD, k3d, k8s-ingress, ReferenceGrant, HTTPRoute. | Cluster architecture design, AI inference routing on K8s, GitOps deployment automation, and local K8s POCs. |
| `skills/obsidian-knowledge` | Obsidian app mechanics, vault taxonomy, markdown workflows, Model Context Protocol (MCP) integration, knowledge retrieval. | Second brain personal workflows, automated vault hygiene, building AI-assisted knowledge management systems. |
| `skills/orchestrator` | `@orchestrator`, plan, roadmap, workflow | Strategic planning, blueprinting multi-agent tasks, and mapping high-level workspace execution strategies. | `gemini-3-pro` |
| `skills/capture` | `@capture`, ingest, inbox, meeting, note | Parsing raw textual logs, ideas, system telemetry, or meeting transcripts into atomic fleeting structures. | `gemini-3-flash` |
| `skills/linker` | `@linker`, backlink, MOC, graph, connect | Analyzing file repositories to generate strict bidirectional links, update index maps, and maximize structural graph density. | Local: `gemma4:31b` |
| `skills/reviewer` | `@reviewer`, audit, taxonomy, validate | Validating ontology adherence, checking metadata formatting against standards, and finding overlapping data duplicates. | `gemini-3-pro` |
| `skills/synthesizer` | `@synthesizer`, extract, insight, trend | Deep analytical synthesis of multiple source documents to generate comprehensive permanent insights or technical specs. | `gemini-3-pro` |
| `skills/gardener` | `@gardener`, clean, archive, fix-links, hygiene | Automated system maintenance, pruning dead connections, cleaning tag structures, and archiving obsolete project assets. | Local: `mistral:7b` |

---

## Skill Activation Rules
1. **Lazy Evaluation:** Do not hydrate a session with a full domain `SKILL.md` body unless the user prompt maps explicitly to the corresponding "Operational Routing Triggers".
2. **Context Clearance:** When a skill execution loop finishes, return the unified technical summary to the primary thread and un-load the domain context to prevent token bleed.