# Dispatcher Gap Analysis

**Date:** 2026-06-26  
**Scope:** Review current dispatcher.yaml against Jason's actual work domains (CLAUDE.md)

---

## CURRENT STATE

**5 pipelines covering:**
1. ✅ `cluster-lifecycle` — K8s provisioning + GitOps + monitoring
2. ✅ `ai-gateway-deployment` — Inference gateway deployment
3. ✅ `agentic-routing-poc` — Agentic routing POC
4. ✅ `cluster-troubleshooting` — Cluster diagnostics + remediation
5. ✅ `product-definition` — PRD writing process

---

## GAPS & MISSING PIPELINES

Based on CLAUDE.md, Jason owns/works on:

### Products/Domains
- **F5 AI Guardrails** — Security-focused GenAI
- **F5 Red Team** — Offensive security testing
- **NGINX Ingress Controller** — K8s ingress
- **NGINX Gateway Fabric** — Advanced K8s gateway
- **F5 Distributed Cloud (XC)** — Multi-cloud platform

### Primary Domains
- **AI Security** — Prompt injection, jailbreaks, guardrails
- **Kubernetes Networking** — Ingress, Gateway API, routing
- **SaaS / Multi-Cloud Sovereignty** — Cloud deployment patterns

### Key Patterns
- **POC-First** — Validate with working code
- **OTEL Instrumentation** — All new infra must be instrumented
- **Three-part docs** — Executive, Engineering, Product versions
- **Architecture ADRs** — Major decisions documented

---

## IDENTIFIED GAPS

### 🔴 CRITICAL: AI Security Pipeline Missing

**What's missing:** F5 AI Guardrails is a core product, but no pipeline for:
- Building AI security (guardrails, prompt injection detection, jailbreak detection)
- Auditing LLM surface
- Implementing content policy filters
- Documenting security model

**Current:** Only `agentic-routing-poc` touches `ai-security-patterns` (as secondary skill)

**Should be:** Full pipeline: `ai-security-hardening` or `ai-guardrails-deployment`

**Suggested pipeline:**
```yaml
ai-security-hardening:
  description: "Build and deploy AI security guardrails"
  sequence:
    - step: 1
      role: SecurityArchitect
      skill: ai-security-patterns
      output: "Threat model & guardrail requirements"
    - step: 2
      role: AIEngineer
      skill: ai-engineer
      companion: ai-security-patterns
      output: "Guardrails implementation (filters, sanitizers)"
    - step: 3
      role: Verifier
      skill: k8s-observability-ops
      output: "Security event tracing & monitoring"
    - step: 4
      role: TechnicalWriter
      skill: docs-agent
      output: "Security architecture & threat model ADR"
```

---

### 🟡 HIGH: NGINX Configuration Pipeline Missing

**What's missing:** NGINX is core to your work (NGINX Ingress, Gateway Fabric), but no standalone pipeline for:
- Designing NGINX configurations
- Optimizing routing, buffering, streaming
- Model-specific tuning (LLM, inference)
- Performance validation

**Current:** `nginx-patterns` appears in `ai-gateway-deployment` and `agentic-routing-poc`, but no dedicated pipeline

**Should be:** `nginx-optimization` or `gateway-performance-tuning`

**Suggested pipeline:**
```yaml
nginx-optimization:
  description: "Design and optimize NGINX configurations for performance"
  sequence:
    - step: 1
      role: NetworkEngineer
      skill: nginx-patterns
      output: "NGINX configuration design (routing, buffering, retries)"
    - step: 2
      role: Architect
      skill: k8s-gateway-api
      companion: nginx-patterns
      output: "Gateway API resource definitions"
    - step: 3
      role: ObservabilityExpert
      skill: k8s-observability-ops
      output: "NGINX metrics & latency tracing"
    - step: 4
      role: TechnicalWriter
      skill: docs-agent
      output: "Performance tuning guide & ADR"
```

---

### 🟡 HIGH: Red Team / Penetration Testing Pipeline Missing

**What's missing:** F5 Red Team is a product, but no pipeline for:
- Designing red team exercises
- Planning attack scenarios
- Documenting findings
- Building defensive recommendations

**Current:** No skills in manifest for red team / pen testing

**Should be:** Either create `red-team-exercise` pipeline OR add new skill(s) for red team methodology

**Note:** This may require new skills (e.g., `red-team-strategist`, `pen-tester`) depending on scope

---

### 🟡 HIGH: Multi-Cloud Deployment Pipeline Missing

**What's missing:** F5 XC (Distributed Cloud) is core, but no pipeline for:
- Designing multi-cloud architectures
- Deploying across clouds (GCP, AWS, Azure)
- Managing sovereignty constraints
- Cost optimization across clouds

**Current:** `cluster-lifecycle` covers single-cloud (vcluster, k3d, GKE, AKS, EKS) but not **multi-cloud orchestration**

**Should be:** `multi-cloud-deployment` pipeline

**Suggested pipeline:**
```yaml
multi-cloud-deployment:
  description: "Design and deploy workloads across multiple cloud providers"
  sequence:
    - step: 1
      role: ArchitecturePrincipal
      skill: platform-engineer
      output: "Multi-cloud architecture (connectivity, networking, failover)"
    - step: 2
      role: CloudEngineer
      skill: platform-engineer
      companion: k8s-engineer
      output: "Cloud-specific provisioning (GCP/AWS/Azure)"
    - step: 3
      role: NetworkEngineer
      skill: nginx-patterns
      output: "Multi-cloud routing & load balancing"
    - step: 4
      role: ComplianceExpert
      skill: docs-agent
      output: "Sovereignty & compliance documentation"
    - step: 5
      role: ObservabilityExpert
      skill: k8s-observability-ops
      output: "Cross-cloud observability & metrics"
```

---

### 🟠 MEDIUM: Documentation & Storytelling Pipeline Missing

**What's missing:** Jason does "technical storytelling" (positioning, executive comms) but no pipeline for:
- Crafting value propositions
- Creating technical narratives
- Positioning against competitors
- Launch narratives

**Current:** `product-definition` covers PRD/slides, but not **positioning/messaging**

**Should be:** `technical-storytelling` pipeline

**Note:** There's a template at `~/.agents/templates/conference-talk-outline.md` and a skill `positioning-messaging`, but no orchestrated pipeline

**Suggested pipeline:**
```yaml
technical-storytelling:
  description: "Craft technical narratives, positioning, and launch stories"
  sequence:
    - step: 1
      role: Strategist
      skill: value-proposition
      output: "JTBD value proposition"
    - step: 2
      role: PositioningExpert
      skill: positioning-messaging
      output: "Competitive differentiation & positioning"
    - step: 3
      role: Storyteller
      skill: tech-pm
      output: "Launch narrative & key messages"
    - step: 4
      role: Designer
      skill: slide-deck-creator
      output: "Conference talk / executive presentation"
```

---

### 🟠 MEDIUM: Knowledge Management / Documentation Pipeline Missing

**What's missing:** Obsidian skills exist but no orchestrated pipeline for:
- Capturing architectural decisions in knowledge vault
- Creating markdown notes from technical docs
- Building canvas/graph views of architecture
- Managing knowledge base

**Current:** `docs-agent` can write docs, but no pipeline that leverages Obsidian integration

**Should be:** `knowledge-capture` pipeline

**Suggested pipeline:**
```yaml
knowledge-capture:
  description: "Capture and organize technical knowledge in Obsidian vault"
  sequence:
    - step: 1
      role: TechnicalWriter
      skill: docs-agent
      output: "Technical documentation (ADRs, design docs)"
    - step: 2
      role: KnowledgeManager
      skill: obsidian-markdown
      output: "Markdown notes with wikilinks & frontmatter"
    - step: 3
      role: ArchitectureVisualizer
      skill: json-canvas
      companion: obsidian-markdown
      output: "Architecture canvas/graph visualization"
    - step: 4
      role: Indexer
      skill: obsidian-cli
      output: "Vault indexing & search optimization"
```

---

### 🟢 LOW: Python Development / Backend Pipeline

**What's missing:** Python is a primary language (Pydantic v2, async, OTEL) but no pipeline for:
- Scaffolding Python projects
- Applying Python standards
- Code review & optimization

**Current:** `python-dev-standard` skill exists but no dispatcher pipeline

**Note:** This may not need a pipeline if Python work is typically ad-hoc. But if Jason regularly scaffolds new Python services, a pipeline could be useful.

**Optional pipeline:**
```yaml
python-service-scaffold:
  description: "Scaffold and configure new Python services with Jason's standards"
  sequence:
    - step: 1
      role: BackendEngineer
      skill: python-dev-standard
      output: "Project structure & dependency setup"
    - step: 2
      role: DevOpsEngineer
      skill: platform-engineer
      output: "Docker & k8s deployment config"
    - step: 3
      role: ObservabilityExpert
      skill: k8s-observability-ops
      output: "OTEL instrumentation & monitoring"
    - step: 4
      role: TechnicalWriter
      skill: docs-agent
      output: "Service documentation & runbooks"
```

---

## SUMMARY: RECOMMENDED ADDITIONS

| Priority | Pipeline Name | Purpose | New Skills Needed? |
|----------|---------------|---------|-------------------|
| 🔴 CRITICAL | `ai-security-hardening` | Build AI guardrails & security | No (use existing) |
| 🟡 HIGH | `nginx-optimization` | Optimize NGINX for performance | No (use existing) |
| 🟡 HIGH | `multi-cloud-deployment` | Deploy across cloud providers | No (extend platform-engineer) |
| 🟡 HIGH | `red-team-exercises` | Plan red team / pen testing | **Yes** (need red-team skill) |
| 🟠 MEDIUM | `technical-storytelling` | Craft positioning & narratives | No (use existing) |
| 🟠 MEDIUM | `knowledge-capture` | Organize docs in Obsidian vault | No (use existing) |
| 🟢 LOW | `python-service-scaffold` | Scaffold Python services | No (use existing) |

---

## DECISION FRAMEWORK

**Add to dispatcher.yaml if:**
- ✅ It's a **repeatable workflow** (you do it regularly)
- ✅ It involves **multiple domains** requiring skill orchestration
- ✅ There's a **clear sequence** (A → B → C)
- ✅ It maps to **your documented products/domains** (CLAUDE.md)

**Skip if:**
- ❌ It's a one-off task
- ❌ It's already well-covered by existing pipelines
- ❌ The user can just invoke a single skill

---

## NEXT STEPS

1. **Review the 7 suggested pipelines above** — which are critical to your workflow?
2. **Identify gaps:** Are there other domains/products missing?
3. **Decide on new skills:** Do you need a `red-team-*` skill family?
4. **Update dispatcher.yaml** with 2-3 critical pipelines first
5. **Run validation:** `python3 ~/.agents/validate-skills.py --strict`
6. **Test:** Invoke a pipeline with Claude Code to verify flow

---

## FILES TO UPDATE

Once you decide which pipelines to add:
1. **dispatcher.yaml** — Add new `intent_pipelines`
2. **SKILL_MANIFEST.json** — Update `primary_for` field for relevant skills (mark which pipeline each skill is in)
3. **RULES.md** — Update Section 7 "Adopted Skills" to reflect new pipelines
4. **USAGE.md** — Add new workflows to the "COMMON WORKFLOWS" section
5. **CHANGELOG.md** — Document the new pipelines

Then run validation and test.
