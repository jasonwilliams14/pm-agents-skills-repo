# Templates Analysis & Improvement Roadmap

**Date:** 2026-07-14  
**Reviewer:** Claude Code  
**Scope:** Strategic review of `/Users/ja.williams/.agents/templates/` for workflow efficiency and quality.

---

## EXECUTIVE SUMMARY

Your templates directory contains **12 files** covering ADR, design docs, K8s/NGINX configurations, and presentations. The analysis reveals:

- ✅ **Strengths:** Strong domain-specific coverage (K8s, NGINX, AI inference), pragmatic configurations
- ⚠️ **Gaps:** Missing templates for critical workflows (PRD, runbooks, security reviews, POC validation checklists)
- 🔄 **Opportunities:** Incomplete guidance details, missing cross-references, weak integration between templates, no skill dispatching metadata

**Impact:** Your POC-first methodology and quality standards aren't fully captured in templates. Engineers taking over code lack runbooks; POCs lack validation gates; design decisions lack security/cost dimensions.

---

## DETAILED FINDINGS

### 1. ARCHITECTURAL DECISION RECORD (ADR)
**File:** `architecture-decision-record.md`

**Current State:**
- Minimal skeleton (16 lines)
- Missing critical sections for F5 context

**Issues:**
- ❌ No "Decision Stakeholders" field (architects, product, legal, security?)
- ❌ No "Cost/Performance Impact" section (CAPEX, OPEX, latency implications?)
- ❌ No "Approval Sign-off" (how will you track acceptance?)
- ❌ No "Dependency on Other ADRs" field (helps engineers understand decision chains)
- ❌ No guidance on "Related AI Security Implications" (Guardrails, prompt injection, data residency)

**Quality Impact:**
- ADRs are incomplete for handoff to engineering
- Security and cost decisions are implicit, not explicit
- No clear approval workflow

**Recommended Improvements:**
```markdown
+ Add "Decision Stakeholders" (Architects, Product, Security, Finance)
+ Add "Cost/Performance Impact" (with metrics)
+ Add "Approval / Sign-off" section (with names and dates)
+ Add "Related Decisions & Dependencies" (link to other ADRs)
+ Add "AI Security Considerations" subsection (Guardrails, compliance, data residency)
+ Add "Rollback Plan" (how to undo if needed?)
+ Add "Success Metrics / How We'll Know It Worked" (measurement criteria)
```

---

### 2. TECHNICAL DESIGN DOC
**File:** `technical-design-doc.md`

**Current State:**
- 22 sections, reasonable structure
- Covers architecture, components, data flow

**Issues:**
- ❌ No "Success Criteria / Definition of Done" section
- ❌ No "Testing Strategy" (unit, integration, load, security, chaos)
- ❌ No "API Contracts" or "Interface Specifications" section
- ❌ No "Operational Runbook" (how to deploy, monitor, troubleshoot?)
- ❌ No "Dependency Matrix" (what systems must exist first?)
- ❌ Missing audience-specific variants (exec vs. engineering vs. product)
- ❌ No reference to ADR(s) this doc implements

**Quality Impact:**
- Engineers must infer testing strategy
- Operational knowledge is tribal (not documented)
- No clear success gates for POC validation

**Recommended Improvements:**
```markdown
+ Add "Success Criteria / Definition of Done"
+ Add "Testing Strategy & Coverage" (unit/integration/load/chaos/security)
+ Add "API/Interface Specifications" (OpenAPI schema or schema section)
+ Add "Operational Runbook" (deploy, monitor, troubleshoot, scale)
+ Add "Dependency Matrix" (what must exist first)
+ Add "Related ADRs" (which architectural decisions does this implement?)
+ Add "Audience-specific variants" (exec summary, engineering detail, product outcomes)
```

---

### 3. AI GATEWAY ARCHITECTURE SPEC
**File:** `ai-gateway-architecture-spec.md`

**Current State:**
- Concise, focused on gateway patterns
- Covers routing, performance, security, deployment

**Issues:**
- ❌ No "Cost Model" section (throughput pricing, model endpoint costs, infrastructure)
- ❌ No "Rate Limiting & Quota Enforcement" details (per-tenant? per-model? per-user?)
- ❌ No "Failover & Circuit Breaker" strategy (what happens when model endpoint is down?)
- ❌ No "Multi-tenant Isolation" validation checklist (important for enterprise!)
- ❌ No "Mermaid diagram directive" (template says insert, but no example structure)
- ❌ No "Fallback Models" section (what if premium model is exhausted?)
- ❌ Guardrails integration is implicit (should be explicit required check)

**Quality Impact:**
- Missing enterprise requirements (multi-tenancy, cost control, failover)
- No clear fallback handling for production resilience
- Diagram directives are vague

**Recommended Improvements:**
```markdown
+ Add "Cost Model & Budget Enforcement"
+ Add "Rate Limiting Strategy" with per-tenant/per-model breakdown
+ Add "Failover & Circuit Breaker Patterns"
+ Add "Multi-tenant Isolation Checklist"
+ Add "Fallback Model Selection Logic"
+ Add "Guardrails Integration & Compliance Hooks"
+ Provide concrete Mermaid diagram example (not just directive)
```

---

### 4. K8S MANIFEST CONVENTIONS
**File:** `k8s-manifest-conventions.md`

**Current State:**
- 11 lines with key conventions
- Covers basic K8s requirements and Flux patterns

**Issues:**
- ❌ No "Namespace Isolation Rules" (how to separate by env/team?)
- ❌ No "RBAC & Service Account" conventions
- ❌ No "Resource Quota & Limits" template (CPU, memory, storage)
- ❌ No "Pod Disruption Budget" guidance (for safe deployments)
- ❌ No "Liveness/Readiness Probe" conventions
- ❌ No "ConfigMap vs. Secret" decision guidelines
- ❌ No "Image Pull Secrets" or "Registry Auth" patterns
- ❌ No "OpenTelemetry Instrumentation" labels/annotations (your standard!)
- ❌ No "Annotations & Labels Taxonomy" (which labels are required?)

**Quality Impact:**
- Manifests lack consistency across teams
- OTEL instrumentation is not mandated in templates
- Security (RBAC, secrets) is underspecified

**Recommended Improvements:**
```markdown
+ Expand to comprehensive manifest checklist (40-50 lines)
+ Add namespace isolation patterns
+ Add RBAC & service account templates
+ Add resource quota/limits templates
+ Add pod disruption budget guidance
+ Mandate OTEL labels/annotations
+ Add ConfigMap vs. Secret decision tree
+ Add image pull secret patterns
```

---

### 5. NGINX AI CORE CONFIG
**File:** `nginx-ai-core-config.md`

**Current State:**
- Excellent reference for streaming timeouts
- Covers NIC and NGF patterns side-by-side

**Issues:**
- ❌ No "Backpressure & Buffering" section (what to do when client reads slowly?)
- ❌ No "Connection Pool Exhaustion" handling (error codes, fallback behavior)
- ❌ No "Request Size Limits" (max payload for prompts, context windows)
- ❌ No "Header Manipulation" for OTEL/tracing headers
- ❌ No "Error Handling & Retries" for LLM failures (distinguish 5xx/rate-limit/timeout)
- ❌ No "Metrics Emission" guidance (which NGINX vars to expose?)

**Quality Impact:**
- Missing operational safeguards (backpressure, pool limits)
- Error handling is implicit
- Tracing integration needs clarification

**Recommended Improvements:**
```markdown
+ Add "Backpressure & Flow Control" section
+ Add "Connection Pool Exhaustion" patterns
+ Add "Request/Response Size Limits"
+ Add "OTEL Header Propagation" directive block
+ Add "Error Handling & Retry Classification"
+ Add "Metrics Emission & Prometheus Integration"
```

---

### 6. NGINX MODEL ROUTING
**File:** `nginx-model-routing.md`

**Current State:**
- Three clear patterns (header-based, path-based, auth_request)
- Covers F5 Guardrails integration

**Issues:**
- ❌ No "Model Preference / Fallback Logic" pattern (what if user-preferred model is unavailable?)
- ❌ No "Cost-based Routing" (route high-value requests to premium, budget requests to local)
- ❌ No "Load Balancing Strategy Across Models" (round-robin vs. least-connections for multi-model)
- ❌ No "Sticky Sessions" pattern (important for stateful agents)
- ❌ No "Request Transformation" pattern (normalize request format across model APIs)
- ❌ Auth_request example for Guardrails is good, but lacks "timeout & fallback" guidance

**Quality Impact:**
- Routing logic is incomplete for cost optimization
- No patterns for high-availability multi-model setups
- Agent stickiness is missing (important for your agentic use cases!)

**Recommended Improvements:**
```markdown
+ Add "Model Fallback & Preference Resolution" pattern
+ Add "Cost-based Model Selection" pattern
+ Add "Load Balancing Across Models" guidance
+ Add "Sticky Sessions for Stateful Agents" pattern
+ Add "Request/Response Transformation" pattern (normalization)
+ Expand Guardrails integration with timeout/fallback
```

---

### 7. NGINX AGENTIC CONFIG
**File:** `nginx-agentic-config.md`

**Current State:**
- Focused on long-lived connections
- Covers tool fan-out routing and safe retry policies

**Issues:**
- ❌ No "Agentic Orchestration Loop" visualization (request → tool calls → agent decision → loop back)
- ❌ No "Tool Call Tracing" section (how to trace fan-out requests back to parent agent?)
- ❌ No "Streaming Agent Steps" guidance (how to expose agent thinking to client?)
- ❌ No "Timeout Strategy per Tool Type" (search ≠ code execution ≠ LLM call)
- ❌ No "Circuit Breaker for Tool Failures" (if search service fails, how does agent respond?)
- ❌ No "Maximum Agent Loop Depth" safeguard (prevent infinite loops)

**Quality Impact:**
- Missing visibility into agentic workflows (no tracing patterns)
- Tool timeouts are not differentiated by type
- Reliability safeguards are incomplete

**Recommended Improvements:**
```markdown
+ Add "Agentic Orchestration & Request Tracing" section with Mermaid diagram
+ Add "Tool Call Tracing" (parent-child request IDs, span linkage)
+ Add "Streaming Agent Steps" pattern (for exposing thinking)
+ Add "Tool-specific Timeout Matrix" (search vs. code vs. LLM)
+ Add "Circuit Breaker & Tool Failover" pattern
+ Add "Loop Depth & Timeout Guards" for safety
```

---

### 8. K3D DEMO CLUSTER SCRIPT
**File:** `k3d-demo-cluster-script.md`

**Current State:**
- Minimal, 11 lines
- Basic k3d setup with traefik disabled

**Issues:**
- ❌ No "GPU/Device Support" instructions (how to enable GPU for vLLM?)
- ❌ No "Volume Mounting" guidance (where to mount model cache, data?)
- ❌ No "Environment Variable Setup" (.env files, secrets?)
- ❌ No "Networking Configuration" (allow host access, port forwarding)
- ❌ No "Registry Access" (how to pull private images from Harbor or GHCR?)
- ❌ No "Monitoring Stack Setup" (Prometheus, Grafana preinstall?)
- ❌ No "Post-creation Steps" (helm install gateway, deploy sample app)
- ❌ No "Cleanup & Teardown" instructions

**Quality Impact:**
- POC setup is incomplete; engineers must reverse-engineer cluster config
- GPU support for local LLM testing is missing
- No guidance for getting from empty cluster to "ready for demo"

**Recommended Improvements:**
```markdown
+ Expand script with conditional GPU support
+ Add volume mounting for models & data
+ Add environment variable / .env setup
+ Add registry auth configuration
+ Add "Optional: Install Monitoring Stack" section
+ Add "Post-creation: Deploy Gateway & Sample App" steps
+ Add complete cluster teardown instructions
```

---

### 9. FLUX GITOPS REPO STRUCTURE
**File:** `flux-gitops-repo-structure.md`

**Current State:**
- Basic directory layout (8 lines)
- Shows infrastructure vs. apps separation

**Issues:**
- ❌ No "Kustomization Strategy" (overlays for dev/staging/prod?)
- ❌ No "Secrets Management" guidance (Sealed Secrets, SOPS, external vault?)
- ❌ No "HelmRelease Conventions" (versioning, rollback strategy)
- ❌ No "Health Checks & Alerts" (Flux monitoring, drift detection)
- ❌ No "Multi-cluster Setup" (how to organize for multi-region?)
- ❌ No "OTEL & Observability Infrastructure" placement (where in structure?)
- ❌ No "GitOps Workflow" (PR approval, auto-merge, deployment gates)
- ❌ No "Tenancy / Multi-team" support (RBAC, quotas, access control)

**Quality Impact:**
- GitOps setup lacks production readiness
- Secrets management is underspecified (security risk)
- No clear observability infrastructure layout
- Multi-cluster/multi-tenant patterns are missing

**Recommended Improvements:**
```markdown
+ Expand to 30-40 line comprehensive structure
+ Add Kustomization overlays for env separation
+ Add secrets management strategy (Sealed Secrets or SOPS)
+ Add HelmRelease conventions & rollback strategy
+ Add OTEL infrastructure placement
+ Add monitoring/alerting for Flux drift & health
+ Add multi-cluster & multi-tenant patterns
+ Add GitOps workflow & deployment gates
```

---

### 10. NGINX OBSERVABILITY
**File:** `nginx-observability.md`

**Current State:**
- Good custom JSON log format
- ConfigMap example with AI fields
- Prometheus metrics table

**Issues:**
- ❌ No "Structured Logging Best Practices" (what fields are mandatory?)
- ❌ No "Trace Context Propagation" (W3C Trace Context, Jaeger/OTEL integration)
- ❌ No "Custom Metrics Emission" (lua script example for custom counters?)
- ❌ No "Grafana Dashboard" template (which metrics to visualize?)
- ❌ No "Alert Rules" (what thresholds should trigger pages?)
- ❌ No "OpenTelemetry Instrumentation" section (OTEL sidecar, collector config)
- ❌ No "Cost Attribution" metrics (model cost per request, per tenant)
- ❌ No "Multi-model Observability" (differentiate metrics by model tier)

**Quality Impact:**
- Observability is partial (logs + some metrics, missing traces)
- No clear alert strategy
- No cost visibility (important for enterprise!)
- OTEL integration is missing (violates your mandatory standard)

**Recommended Improvements:**
```markdown
+ Add "Structured Logging Schema" (mandatory fields & taxonomy)
+ Add "W3C Trace Context & OTEL Propagation" section
+ Add "Custom Metrics Emission" (Lua or NGINX modules)
+ Add sample "Grafana Dashboard" queries
+ Add "Prometheus Alert Rules" (with thresholds)
+ Add "OpenTelemetry Collector Configuration"
+ Add "Cost Attribution Metrics" (per-model, per-tenant)
+ Add "Multi-model Observability" patterns
```

---

### 11. K8S INFERENCE DEPLOYMENT
**File:** `k8s-inference-deployment.md`

**Current State:**
- Excellent end-to-end example (vLLM + GIE + HTTPRoute)
- Shows LoRA support and resource limits

**Issues:**
- ❌ No "Autoscaling Strategy" (HPA metrics, target utilization, cooldown)
- ❌ No "Model Caching & Optimization" (cache warming, pruning strategies)
- ❌ No "Cost Optimization" section (spot instances, right-sizing, bin-packing)
- ❌ No "Multi-model Orchestration" (how to load-balance across different model instances)
- ❌ No "Safety Guardrails Integration" (where does Guardrails sidecar go?)
- ❌ No "OTEL Instrumentation" (how to instrument vLLM for spans/metrics?)
- ❌ No "Health Check & Readiness" guidance (how to probe LLM health without false positives?)
- ❌ No "Failure Handling" (pod restart policy, circuit breaker integration)

**Quality Impact:**
- No guidance for production scaling (HPA)
- Cost optimization is missing (important for POC budgets!)
- OTEL instrumentation is missing (violates your standard)
- Guardrails integration is assumed, not shown

**Recommended Improvements:**
```markdown
+ Add "Autoscaling & Resource Planning" with HPA example
+ Add "Model Caching & Optimization" strategies
+ Add "Cost Optimization" (spot instances, right-sizing)
+ Add "Multi-model Orchestration" patterns
+ Add "Safety Guardrails Sidecar" integration
+ Add "OTEL Instrumentation" (vLLM tracing)
+ Add "Health Check Patterns" (avoiding false positives on slow responses)
+ Add "Failure Handling & Recovery" strategy
```

---

### 12. CONFERENCE TALK OUTLINE
**File:** `conference-talk-outline.md`

**Current State:**
- 8-section skeleton
- Covers narrative arc (problem → demo → lessons → Q&A)

**Issues:**
- ❌ No "Slide Design Guidance" (visuals, typography, diagrams)
- ❌ No "Demo Script & Failsafes" (what to do if demo breaks live?)
- ❌ No "Time Allocations" (how long for each section?)
- ❌ No "Audience Engagement" tactics (live polls, Q&A handling)
- ❌ No "Competitive Positioning" section (positioning F5 AI/K8s vs. alternatives)
- ❌ No "Call to Action" (what do you want audience to do afterward?)
- ❌ No "Backup Slides" for deep dives
- ❌ Generic structure doesn't reflect F5/AI/K8s domain

**Quality Impact:**
- Presentation template is too generic for enterprise technical talks
- No demo failsafe strategy (risky for live conferences)
- Missing positioning narrative (competitive advantage unclear)

**Recommended Improvements:**
```markdown
+ Add "Slide Design & Visual Language" guidance
+ Add "Demo Script & Failsafe Playbook"
+ Add "Time Allocations" per section
+ Add "Audience Engagement & Q&A Handling"
+ Add "Competitive Positioning" section
+ Add "Call to Action & Next Steps"
+ Add "Backup Slides for Deep Dives"
+ Tailor to F5 AI/K8s technical talks (not generic)
```

---

## MISSING TEMPLATES (HIGH IMPACT)

The following critical templates are **missing** and should be added:

### A. PRD Template (Product Requirements Document)
**Why:** Your CLAUDE.md mentions "PRD template (to be added)". Enterprise product decisions need formal PRDs before engineering.

**Should cover:**
- User personas & JTBD (Jobs-to-be-Done)
- Acceptance criteria & success metrics
- Competitive analysis & positioning
- Roadmap & phases
- Risks & mitigations

---

### B. POC Validation Checklist
**Why:** You follow "POC-first" methodology, but there's no formal gate for when a POC is "done" and ready for engineering handoff.

**Should cover:**
- Functional validation (does it do what we promised?)
- Performance testing (latency, throughput, cost benchmarks)
- Security review (OWASP top 10, Guardrails integration)
- Operational readiness (monitoring, alerts, runbook)
- Documentation completeness (ADR, design doc, architectural diagrams)
- Code quality (type hints, linting, test coverage)
- Handoff sign-off criteria

---

### C. Security Review Checklist
**Why:** F5 AI Guardrails is a core product, but no template guides security analysis.

**Should cover:**
- Prompt injection attack surface
- Data privacy & PII handling
- Multi-tenant isolation verification
- Compliance scope (GDPR, SOC2, FedRAMP if relevant)
- OWASP LLM Top 10 mapping
- F5 Guardrails integration points
- Threat model & risk assessment
- Sign-off from security/compliance

---

### D. Kubernetes Troubleshooting Runbook
**Why:** Your templates cover deployment, but not operational troubleshooting (critical for POC handoff).

**Should cover:**
- Common pod failures (CrashLoopBackOff, OOMKilled, pending)
- Network debugging (DNS, service discovery, network policies)
- Performance issues (high latency, timeout, connection exhaustion)
- Scaling problems (HPA not triggering, node capacity)
- Data plane issues (gateway routing, HTTPRoute not matching)
- OTEL/observability diagnostics (missing traces, metrics)
- Recovery procedures & escalation

---

### E. AI Agentic Workflow Checklist
**Why:** You emphasize agentic patterns, but no template captures agentic POC requirements.

**Should cover:**
- Agent loop safety (max depth, timeout, escape criteria)
- Tool call orchestration & fan-out patterns
- Error handling & fallback logic
- Observability (request tracing, tool metrics)
- Cost estimation (tool calls × model cost)
- Testing strategy (happy path, edge cases, failure injection)

---

### F. API Contract / OpenAPI Template
**Why:** Design docs mention APIs but don't include schema/spec template.

**Should cover:**
- OpenAPI 3.1 skeleton
- Request/response schemas
- Error handling & status codes
- Rate limiting & quota headers
- OTEL context propagation headers
- Authentication & authorization
- Example cURL/Python requests

---

### G. Cost & Capacity Planning Template
**Why:** Enterprise deals require cost justification; no template captures POC budgeting.

**Should cover:**
- Infrastructure costs (compute, storage, network)
- Model API costs (per-token pricing, commit discounts)
- Observability costs (metrics, logs, traces)
- Support & SLA costs
- ROI analysis (speed, accuracy, risk reduction)
- Contingency & variance ranges

---

## CROSS-TEMPLATE INTEGRATION GAPS

Your templates are **siloed** — they don't reference each other or form a coherent workflow:

| Template | References | Missing Links |
|---|---|---|
| ADR | (none) | Should link to related design docs, cost analysis, tech design doc |
| Tech Design Doc | (none) | Should link to ADR(s) it implements, testing strategy, deployment runbook |
| Gateway Spec | (none) | Should link to K8s manifests, observability config, cost model |
| K3d Cluster Script | (none) | Should link to Flux structure, monitoring setup, inference deployment |
| Nginx Configs (4 files) | (cross-reference among themselves) | Should link to observability metrics, K8s integration, agentic patterns |

**Impact:** Engineers must manually connect the dots; context is fragmented.

**Recommendation:** Add a "Quick Start Workflow" guide that shows which templates to use in sequence for common scenarios (e.g., "Building an AI Gateway POC" → ADR → Tech Design Doc → K8s Manifests → NGINX Config → Observability → Validation Checklist).

---

## MISSING METADATA & SKILL DISPATCHING

Your CLAUDE.md defines a "Skill System Integration" with dispatcher pipelines, but templates have **no skill dispatching metadata**:

**Currently:**
```markdown
# Architecture Decision Record (ADR)
## Status
...
```

**Should include:**
```markdown
---
type: decision-document
skills:
  - agentic-routing-poc  # Recommends this skill for implementation
  - k8s-gateway-api      # For Gateway API expertise
  - ai-security-patterns # For Guardrails & threat modeling
urgency: critical|high|medium
stakeholders: architects|product|security|finance
otel-mandatory: true
related-adrs: [ADR-001, ADR-003]
---
```

**Impact:** Skills/agents can't auto-recommend themselves; no tagging for search.

---

## SUMMARY TABLE: IMPROVEMENT PRIORITY

| Template | Type | Completeness | Priority | Effort | Impact |
|---|---|---|---|---|---|
| ADR | Decision | 50% | 🔴 HIGH | 1-2h | Stakeholder clarity, cost visibility |
| Tech Design Doc | Architecture | 70% | 🔴 HIGH | 2-3h | Testing strategy, runbook, DOD |
| Gateway Spec | Infrastructure | 65% | 🟠 MEDIUM | 2-3h | Enterprise requirements, fallback logic |
| K3d Cluster | Operations | 30% | 🟠 MEDIUM | 1-2h | POC setup completeness, GPU support |
| K8s Manifests | Standards | 40% | 🔴 HIGH | 2-3h | OTEL integration, security, consistency |
| Nginx AI Config | Infrastructure | 75% | 🟠 MEDIUM | 1-2h | Backpressure, pool exhaustion |
| Model Routing | Infrastructure | 65% | 🟠 MEDIUM | 1-2h | Fallback, cost-based routing, stickiness |
| Agentic Config | Infrastructure | 60% | 🟠 MEDIUM | 1-2h | Tracing, loop safety, circuit breaker |
| Observability | Monitoring | 55% | 🔴 HIGH | 2-3h | OTEL, dashboards, alerts, cost metrics |
| Inference Deployment | Operations | 70% | 🟠 MEDIUM | 2-3h | HPA, cost optimization, guardrails |
| Flux GitOps | Operations | 25% | 🔴 HIGH | 2-3h | Secrets, multi-cluster, drift detection |
| Conference Talk | Communication | 40% | 🟢 LOW | 1h | Demo failsafe, positioning |
| **MISSING: POC Validation** | Process | 0% | 🔴 HIGH | 2h | Process gate for engineering handoff |
| **MISSING: Security Review** | Process | 0% | 🔴 HIGH | 2h | OWASP/Guardrails compliance verification |
| **MISSING: PRD** | Product | 0% | 🔴 HIGH | 2-3h | Formal product requirements |
| **MISSING: Runbooks** | Operations | 0% | 🟠 MEDIUM | 3-4h | K8s troubleshooting, incident response |

---

## RECOMMENDED NEXT STEPS

### Phase 1: Foundation (Weeks 1-2)
**High-impact templates that unlock everything else:**

1. **Create POC Validation Checklist** (2h)
   - Formal gate before engineering handoff
   - Combines functional, performance, security, operational readiness
   
2. **Enhance ADR Template** (1-2h)
   - Add stakeholders, cost/performance impact, approval sign-off
   - Link to related ADRs and design docs

3. **Enhance Tech Design Doc Template** (2-3h)
   - Add testing strategy, runbook, API specs, success criteria
   - Link to ADRs it implements

4. **Enhance K8s Manifest Conventions** (2-3h)
   - Mandatory OTEL labels/annotations (enforces your standard)
   - RBAC, resource quotas, pod disruption budgets

### Phase 2: Infrastructure (Weeks 3-4)
**Operationalize agentic and gateway patterns:**

5. **Enhance Observability Template** (2-3h)
   - Add OTEL instrumentation (mandatory standard)
   - Add Grafana dashboard examples
   - Add Prometheus alert rules & cost metrics

6. **Create Security Review Checklist** (2h)
   - Map to OWASP LLM Top 10 & F5 Guardrails
   - Formalize compliance verification

7. **Create PRD Template** (2-3h)
   - JTBD, RICE scoring, competitive positioning
   - Per your "product definition" dispatcher pipeline

8. **Enhance Agentic Config** (1-2h)
   - Add Mermaid diagram for orchestration flow
   - Add tracing patterns, loop safety, circuit breaker

### Phase 3: Completeness (Weeks 5-6)
**Fill remaining gaps:**

9. **Create K8s Troubleshooting Runbook** (3-4h)
   - Pod failure diagnosis, network debugging, scaling issues
   - OTEL diagnostics

10. **Create Kubernetes Runbook** (2h)
    - Cluster provisioning, FluxCD bootstrap, Prometheus setup

11. **Create Cost & Capacity Planning Template** (2h)
    - Infrastructure + model API + observability costs
    - ROI analysis

12. **Create API Contract / OpenAPI Template** (1-2h)
    - OpenAPI 3.1 skeleton
    - OTEL headers, auth, rate limiting

### Phase 4: Integration (Week 7)
**Connect everything and add metadata:**

13. **Add Skill Dispatching Metadata** (1-2h)
    - Add `---` frontmatter to all templates
    - Link to dispatcher pipelines (agentic-routing-poc, ai-gateway-deployment, etc.)

14. **Create "Quick Start Workflows" Guide** (1-2h)
    - "Build AI Gateway POC" → which templates in which order
    - "Deploy Agentic Routing" → similar
    - "Troubleshoot K8s Performance" → diagnostics workflow

15. **Update MEMORY.md with Template Index** (30min)
    - One-line entry per template
    - Linked to dispatcher pipelines

---

## SKILLS TO ENGAGE

When implementing these improvements, suggest the following skills:

| Task | Recommended Skill(s) | Why |
|---|---|---|
| Enhance ADR/Tech Design/PRD | `docs-agent` | Expert technical writer for quality prose |
| Security checklist + Guardrails integration | `ai-security-patterns` | F5 guardrails, OWASP LLM Top 10 expertise |
| K8s manifests, runbooks, troubleshooting | `k8s-engineer` | Gateway API, Kubernetes deep expertise |
| Observability: OTEL, Prometheus, Grafana | `k8s-observability-ops` | OTEL instrumentation, metrics, dashboards |
| NGINX config enhancements | `nginx-patterns` | NGINX expert for NIC/NGF patterns |
| Agentic workflow patterns | `ai-engineer` | CrewAI/LangGraph, agentic orchestration patterns |
| Cost & capacity planning | `platform-engineer` | Cloud resource optimization, cost modeling |
| Workflow diagram generation | (built-in Mermaid) | Architecture & sequence diagrams |

---

## SUCCESS CRITERIA

After improvements, you should have:

✅ **Complete workflow clarity:** Engineers can pick up a POC and deploy to production without reverse-engineering your decisions.

✅ **Mandatory safety gates:** POC validation checklist, security review, and sign-off gates are formal, not tribal.

✅ **OTEL as first-class:** All templates reference OTEL instrumentation; it's not an afterthought.

✅ **Cost visibility:** Every POC comes with cost estimates and actual spend tracking.

✅ **Agentic patterns documented:** Complex tool orchestration, tracing, and loop safety are codified.

✅ **Skill integration:** Templates tag recommended skills; Claude can suggest the right expert without asking.

✅ **Cross-template coherence:** Templates reference each other; engineers follow a clear sequence, not a random menu.

---

**Next Action:** Select a starting template from Phase 1 above, and we'll collaboratively enhance it with the recommended skills. Which would you like to tackle first?
