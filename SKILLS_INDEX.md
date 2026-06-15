# Agent Skills Index

This index acts as the routing table for agent capabilities, mapping user intent to specialized, domain-isolated skill directories. 

## Directives for Skill Routing
1. **Lazy Loading:** Do not pre-load a skill manifest into the context window unless the user prompt matches its **Target Alias / Keyword Triggers**.
2. **Dynamic Model Selection:** Do not hardcode specific model names (e.g., `gemini-1.5-pro`). Use the **Model Tier** to map the task to the appropriate host runtime tier.
3. **Primary vs. Secondary Skills:** Maintain a boundary of maximum 1 primary skill and 2 secondary skills per execution tree.

---

## Skill Routing Table

| Skill Directory | Target Alias / Keyword Triggers | Intent Routing Description | Model Tier |
| :--- | :--- | :--- | :--- |
| `skills/ai-engineer` | `ai-engineer`, PoC, agentic workflows, Ollama, llama.cpp, LangChain, MCP | Python PoCs, agentic workflows, testing local LLMs, LangChain/MCP integrations. | **Reasoning** |
| `skills/ai-security-patterns` | prompt injection, jailbreak detection, adversarial inputs, AI security, OWASP LLM Top 10, PII detection, model abuse, content policy, LLM firewalls, AI WAFs, guardrails design | Expertise in F5 AI Guardrails, prompt injection mitigation, and OWASP LLM Top 10 security frameworks. | **Reasoning** |
| `skills/defuddle` | `defuddle`, web page extraction, scrape, simplify web content | Extract clean markdown from web pages, removing clutter to save tokens. | **Speed** |
| `skills/docs-agent` | `docs-agent`, documentation, technical writing, docs/ | Generate, update, or validate documentation in the `docs/` directory. | **Reasoning** |
| `skills/find-skills` | `find-skills`, discover skill, install skill, search skill | Discover and install agent skills based on user capabilities questions. | **Speed** |
| `skills/google-agents-cli-adk-code` | `google-agents-cli-adk-code`, ADK | Google ADK agent development tools. | **Speed** |
| `skills/google-agents-cli-deploy` | `google-agents-cli-deploy`, ADK deploy | Deploy Google ADK agents. | **Speed** |
| `skills/google-agents-cli-eval` | `google-agents-cli-eval`, ADK eval | Evaluate Google ADK agents. | **Speed** |
| `skills/google-agents-cli-observability` | `google-agents-cli-observability`, ADK observability | Instrument observability for Google ADK agents. | **Speed** |
| `skills/google-agents-cli-publish` | `google-agents-cli-publish`, ADK publish | Publish Google ADK agents. | **Speed** |
| `skills/google-agents-cli-scaffold` | `google-agents-cli-scaffold`, ADK scaffold | Scaffold Google ADK agent templates. | **Speed** |
| `skills/google-agents-cli-workflow` | `google-agents-cli-workflow`, ADK workflow | Build workflows for Google ADK agents. | **Speed** |
| `skills/json-canvas` | `json-canvas`, .canvas files, canvas nodes, visual mind maps | Create and edit Obsidian JSON Canvas files (.canvas). | **Speed** |
| `skills/k8s-ai-expert` | `k8s-ai-expert`, ML workloads on K8s, K8s scaling | Guidance for deploying and scaling AI/ML workloads on Kubernetes. | **Reasoning** |
| `skills/k8s-engineer` | `k8s-engineer`, Ingress, Gateway API, Gateway Inference, AI inference on K8s | Kubernetes subject matter expertise (networking, ingress, Gateway API). | **Reasoning** |
| `skills/k8s-gateway-api` | `k8s-gateway-api`, GatewayClass, HTTPRoute, GRPCRoute, ReferenceGrant | Design and implement Kubernetes Gateway API structures. | **Reasoning** |
| `skills/k8s-gateway-inference` | `k8s-gateway-inference`, InferencePool, InferenceModel, model routing | Architect and implement Gateway inference extensions for K8s routing. | **Reasoning** |
| `skills/k8s-observability-ops` | `observability-ops`, OpenTelemetry, Prometheus, Grafana, Jaeger, ServiceMonitor | Workflows for OTEL, Prometheus, and Grafana instrumentation. | **Speed** |
| `skills/nginx-patterns` | nginx, SSE streaming, proxy buffering, upstream retries, agentic traffic routing, NGF HTTPRoute, NGINX observability | Advanced config for NGINX, Ingress Controller, and Gateway Fabric. | **Reasoning** |
| `skills/obsidian-bases` | `obsidian-bases`, .base files, database-like views, note filters | Create and edit Obsidian Bases (.base files) with views and formulas. | **Speed** |
| `skills/obsidian-cli` | `obsidian-cli`, search vault, vault tasks, reload plugins, capture errors | Interact with Obsidian vaults, manage notes, and debug plugins. | **Speed** |
| `skills/obsidian-markdown` | `obsidian-markdown`, wikilinks, callouts, markdown frontmatter | Create and edit Obsidian Flavored Markdown notes and templates. | **Speed** |
| `skills/platform-engineer` | `platform-engineer`, platform engineering, infrastructure, K8s admin | General platform infrastructure engineering and configuration. | **Speed** |
| `skills/pm-standards` | `pm-standards`, JTBD, RICE prioritization, OTEL PM metrics, Jason Standard | Product Management standards, PRD drafting, and strategic prioritization. | **Reasoning** |
| `skills/positioning-messaging` | `positioning-messaging`, competitors messaging, launch copy | Craft product positioning, competitive differentiation, and launch copy. | **Speed** |
| `skills/prd-generator` | `prd-generator`, PRD template, PRD creation | Generate PRDs using modular standards assets. | **Speed** |
| `skills/python-dev-standard` | `python-dev-standard`, Pydantic, type hinting, Google-style docstrings, async code | Python development best practices following standard structures. | **Reasoning** |
| `skills/slide-deck-creator` | `doc-to-slides`, presentation outline, slides | Create presentations and slide deck outlines. | **Speed** |
| `skills/tech-pm` | `tech-pm`, PRD writing, feature scoping, architectural strategy | Technical Product Manager engagement, PRD writing, and feature scoping. | **Reasoning** |
| `skills/value-proposition` | `value-proposition`, JTBD value prop, customer value delivery | Design 6-part Job-To-Be-Done (JTBD) value propositions. | **Reasoning** |

---

## Model Tier Mappings

The hosting runtime environment maps semantic tiers to specific models based on execution constraints (e.g., local vs. cloud, high-reasoning vs. fast-completion):

*   **Speed Tier:**
    *   *Cloud Default:* `gemini-2.0-flash` (or latest flash model)
    *   *Local Fallback:* `mistral:7b` / `llama3:8b`
    *   *Use Case:* Simple operations, parsing logs, file scaffolding, and utility automation.
*   **Reasoning Tier:**
    *   *Cloud Default:* `gemini-2.5-pro` (or latest pro model)
    *   *Local Fallback:* `gemma2:27b` / `llama3:70b`
    *   *Use Case:* Deep architecture design, complex security reviews, complex debugging, code generation, and multi-step plan verification.