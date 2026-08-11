# Agentic Workflow Daily Usage Guide

**Jason Williams, Principal TPM & Solutions Architect**  
Last Updated: 2026-07-18

---

## OVERVIEW

Your agentic workflow system is a **skill dispatcher** that routes your requests to specialized domain experts (skills), then orchestrates them into multi-step pipelines. Instead of doing everything yourself, you describe what you want and the system figures out which experts to involve and in what order.

**Core Principle:** Skills are lazy-loaded, lightweight, and composed *only when needed*. You don't manage dozens of agents manually—Claude loads the right expertise for your current task, executes it, and unloads the context to keep your session clean.

---

## THE THREE PATTERNS YOU USE DAILY

### Pattern 1: Single-Skill Tasks (80% of your work)

**When:** You need expertise in one domain  
**How:** Ask Claude directly, naming the skill if helpful  
**Time:** 15 minutes to 2 hours  

**Examples:**
- "Use **docs-agent** to write an ADR for our inference routing design"
- "Use **ai-security-patterns** to audit our LLM surface for prompt injection vectors"
- "Use **nginx-patterns** to optimize our gateway for streaming responses"

**What happens:**
1. Claude loads the skill context
2. Skill executes its workflow (Understand → Decide → Execute → Verify)
3. You get a deliverable (document, code, configuration)
4. Skill context is unloaded

**Best for:** Architecture decisions, documentation, security reviews, optimization work.

---

### Pattern 2: Dispatcher Pipelines (15% of your work)

**When:** Your task spans multiple domains AND a pipeline already exists for it  
**How:** Ask Claude to run the pipeline by name  
**Time:** 2–4 hours (depends on pipeline)  

**Pipelines Available:**

#### `cluster-lifecycle`
**Use when:** Provisioning a new Kubernetes cluster  
**Sequence:** platform-engineer → k8s-engineer → k8s-observability-ops  
**Output:** Production-ready cluster with GitOps & monitoring  

**Example request:**
```
Run the cluster-lifecycle pipeline to:
- Provision a vcluster for my AI gateway POC
- Bootstrap FluxCD to sync from my GitHub repo
- Install Prometheus/Grafana for baseline monitoring
```

**What you get:**
- Provisioned cluster (vcluster, k3d, or cloud provider)
- FluxCD configured with automated syncing
- Prometheus scraping targets and Grafana dashboards
- All ready to deploy your application

---

#### `ai-gateway-deployment`
**Use when:** Deploying an AI inference gateway with model routing  
**Sequence:** k8s-gateway-api → k8s-gateway-inference → nginx-patterns → k8s-observability-ops  
**Output:** Gateway manifests, NGINX config, tracing setup  

**Example request:**
```
Run the ai-gateway-deployment pipeline to:
- Define a GatewayClass and HTTPRoute for my model router
- Configure InferencePool to route requests to Claude vs. Gemini endpoints
- Optimize NGINX for streaming responses (SSE)
- Add OpenTelemetry tracing for latency analysis
```

**What you get:**
- Kubernetes Gateway API manifests (production-ready)
- InferencePool configuration with model routing rules
- NGINX core optimization for buffering, retries, streaming
- Observability dashboards for inference latency

---

#### `agentic-routing-poc`
**Use when:** Building a proof-of-concept for agentic request routing  
**Sequence:** ai-engineer → nginx-patterns + k8s-gateway-api → k8s-observability-ops → docs-agent  
**Output:** Working router + ADR + tracing dashboards  
**Time:** 2–3 weeks (POC → handoff to engineering)

**Example request:**
```
Run the agentic-routing-poc pipeline to:
- Design an agentic router that classifies requests (e.g., "this is a security query" vs. "this is a product question")
- Implement semantic routing using L7 routing headers
- Instrument with OpenTelemetry for decision tracing
- Write an ADR documenting the design and handing it off to engineering
```

**What you get:**
- Agentic routing logic (CrewAI/LangGraph patterns)
- Kubernetes + NGINX routing implementation
- Traces showing each request's routing decision
- ADR + implementation guide for engineers

---

#### `cluster-troubleshooting`
**Use when:** Diagnosing and fixing Kubernetes cluster issues  
**Sequence:** k8s-engineer → platform-engineer → k8s-engineer + platform-engineer → docs-agent  
**Output:** Root cause + fix + post-mortem  
**Time:** 1–3 hours

**Example request:**
```
Run the cluster-troubleshooting pipeline on [cluster-name] because:
- Pods are stuck in CrashLoopBackOff
- I see high memory pressure on the nodes
- I need to identify the root cause and fix it
```

**What you get:**
- Diagnostic analysis (logs, events, resource metrics)
- Root cause (app bug, node misconfiguration, cloud provider issue, etc.)
- Applied fix with verification
- Post-mortem doc for knowledge base

---

#### `product-definition`
**Use when:** Moving from market gap to full PRD  
**Sequence:** tech-pm → value-proposition → pm-standards → prd-generator → slide-deck-creator  
**Output:** PRD document + executive slides  
**Time:** 2–3 days

**Example request:**
```
Run the product-definition pipeline for the "AI Governance Platform" because:
- We see market gap in compliance-aware AI routing
- Sales is asking for a positioning deck by Friday
- I need PRD + slides for the exec review
```

**What you get:**
- Strategic intent document
- JTBD value map (what job are customers hiring this to do?)
- Prioritized feature set (RICE scores)
- Full PRD with user stories, acceptance criteria, success metrics
- Executive slide deck ready for investor/customer presentation

---

### Pattern 3: Manual Multi-Skill Composition (5% of your work)

**When:** Your task spans multiple domains BUT no dispatcher pipeline exists for it  
**How:** Ask Claude to use skill A, then skill B, then skill C sequentially  
**Time:** Varies  

**Example:**
```
1. Use ai-engineer to design an agentic prompt-injection detector
2. Use ai-security-patterns to audit the detection logic for evasion techniques
3. Use docs-agent to write a security architecture doc
```

**Rules:**
- Maximum composition: 1 primary skill + 2 secondary skills per step
- Output from skill 1 feeds into skill 2's input
- If this becomes a regular workflow, propose adding it to dispatcher.yaml

---

## YOUR DAILY WORKFLOW

### Morning: POC Design & Architecture

**Scenario 1: You need to design an AI gateway for a customer**

```
Ask Claude:
"Use the ai-engineer skill to design an agentic request router for my customer's 
AI platform. They need to:
- Route requests to different LLMs based on cost/latency trade-offs
- Block malicious prompts using guardrails
- Log all requests for compliance

I need a decision tree, architecture diagram, and implementation strategy."
```

**What happens:**
- ai-engineer skill loads
- Outputs: Architecture diagram (Mermaid), decision tree, pseudo-code for routing logic
- Time: ~1 hour

**Next step:** Once you have the design, ask for implementation:

```
"Use the k8s-gateway-api skill to implement the router I designed. 
Here's the decision tree [paste output from previous step]. 
Generate Kubernetes manifests for GatewayClass and HTTPRoute."
```

---

### Mid-Day: Deployment & Validation

**Scenario 2: You're deploying an AI gateway to a test cluster**

```
Ask Claude:
"Run the ai-gateway-deployment pipeline to deploy my AI router to my local vcluster. 
I need:
- GatewayClass and HTTPRoute definitions
- Model routing via InferencePool
- NGINX optimized for streaming responses (our customers use WebSocket + SSE)
- OpenTelemetry tracing so I can see request flows"
```

**What happens:**
1. k8s-gateway-api loads → generates Gateway API manifests
2. k8s-gateway-inference loads → generates InferencePool config
3. nginx-patterns loads → generates NGINX core optimization config
4. k8s-observability-ops loads → generates OTEL instrumentation
5. You get deployable Kubernetes manifests + NGINX config + tracing dashboards

**Time:** 3–4 hours  
**Output:** Everything ready to `kubectl apply`

---

### Late Afternoon: Documentation & Handoff

**Scenario 3: You're documenting the design for engineering handoff**

```
Ask Claude:
"Use the docs-agent skill to write an Architecture Decision Record for our 
AI gateway design. Here's what we decided [paste design notes]:

- We chose InferencePool for model routing (vs. custom webhook router)
- We're using L7 header-based routing for cost-optimized failover
- We're tracing with OpenTelemetry using GenAI semantic conventions

Template: architecture-decision-record.md
I need this in 2 hours for engineering review."
```

**What happens:**
- docs-agent loads
- Reads the ADR template
- Generates an ADR with context, decision, rationale, consequences, alternatives
- Output: Markdown file ready to commit

**Time:** 1 hour

---

### Security Review Scenario

**Scenario 4: You're auditing a new AI feature for security**

```
Ask Claude:
"Use the ai-security-patterns skill to audit our new LLM routing feature 
for prompt injection, jailbreaks, and PII leakage. 

The feature:
- Takes user queries and routes them to Claude/Gemini based on semantic similarity
- Passes the full user context (name, email, organization) as system prompt
- Stores responses in a shared cache indexed by request hash

I need a threat model, vulnerability report, and remediation plan."
```

**What happens:**
- ai-security-patterns loads
- Analyzes the feature against OWASP LLM Top 10
- Identifies vulnerabilities (e.g., "system prompt injection via organization field")
- Outputs: Threat model, vulnerability severity matrix, remediation roadmap

**Time:** 1–2 hours

---

## QUICK REFERENCE: WHEN TO USE WHICH PATTERN

| Scenario | Pattern | Skills | Time |
|----------|---------|--------|------|
| "Design an AI component" | Single-skill | ai-engineer | 1-2 hrs |
| "Write architecture docs" | Single-skill | docs-agent | 1 hr |
| "Security audit of LLM feature" | Single-skill | ai-security-patterns | 1-2 hrs |
| "Optimize NGINX config" | Single-skill | nginx-patterns | 1 hr |
| "Deploy AI gateway end-to-end" | Pipeline | ai-gateway-deployment | 3-4 hrs |
| "Provision test cluster" | Pipeline | cluster-lifecycle | 2-4 hrs |
| "Fix broken K8s cluster" | Pipeline | cluster-troubleshooting | 1-3 hrs |
| "Write full PRD + slides" | Pipeline | product-definition | 2-3 days |
| "Design agentic router POC" | Pipeline | agentic-routing-poc | 2-3 wks |
| "Design + secure + document" | Manual composition | ai-engineer → ai-security-patterns → docs-agent | 3-4 hrs |

---

## THE SKILL QUICK-START REFERENCE

### Domain: AI & Security

#### ai-engineer
**What:** Design agentic logic, PoCs, LLM integrations  
**Triggers:** "PoC", "agentic AI", "LangChain", "Ollama", "MCP", "workflow design"  
**Output:** Architecture diagram, pseudo-code, decision tree  

```
Ask: "Use ai-engineer to design a multi-turn conversation system 
with memory management and tool calling for my assistant."
```

---

#### ai-security-patterns
**What:** Audit LLMs for injection, PII, jailbreaks; build guardrails  
**Triggers:** "prompt injection", "jailbreak", "OWASP LLM", "PII", "guardrails"  
**Output:** Threat model, vulnerability report, remediation plan  

```
Ask: "Use ai-security-patterns to threat-model our LLM API 
and propose guardrails for production deployment."
```

---

### Domain: Kubernetes & Infrastructure

#### platform-engineer
**What:** Provision K8s clusters (vcluster, k3d, cloud providers), set up GitOps  
**Triggers:** "provision cluster", "bootstrap", "infrastructure", "GitOps"  
**Output:** Provisioning scripts, FluxCD repo structure, deployment manifests  

```
Ask: "Use platform-engineer to provision a vcluster called 'ai-gateway-dev' 
with 4GB RAM, 2 cores, and bootstrap it with FluxCD."
```

---

#### k8s-engineer
**What:** Design K8s networking, troubleshoot issues, deploy applications  
**Triggers:** "Kubernetes networking", "troubleshoot K8s", "deploy", "routing"  
**Output:** Kubernetes manifests, diagnostic reports, remediation steps  

```
Ask: "Use k8s-engineer to design a Service/Ingress architecture 
for my multi-tenant AI platform with traffic isolation."
```

---

#### k8s-gateway-api
**What:** Design Gateway API architectures (GatewayClass, HTTPRoute, traffic splitting)  
**Triggers:** "Gateway API", "advanced routing", "traffic splitting", "L7 routing"  
**Output:** Gateway API manifests, routing rules, traffic policies  

```
Ask: "Use k8s-gateway-api to design a GatewayClass with HTTPRoutes 
for cost-optimized model failover (use Claude API for primary, Gemini for secondary)."
```

---

#### k8s-gateway-inference
**What:** Configure InferencePool, model routing, semantic routing  
**Triggers:** "InferencePool", "model routing", "inference", "LLM routing"  
**Output:** InferencePool manifests, model affinity rules, routing policies  

```
Ask: "Use k8s-gateway-inference to set up InferencePool routing 
that prioritizes fast models for latency-sensitive queries and powerful models for complex queries."
```

---

#### k8s-observability-ops
**What:** Add OpenTelemetry, Prometheus, Grafana, tracing  
**Triggers:** "observability", "tracing", "metrics", "OTEL", "Prometheus", "Grafana"  
**Output:** OTEL instrumentation, Prometheus scrape configs, Grafana dashboards  

```
Ask: "Use k8s-observability-ops to instrument my AI gateway 
with OpenTelemetry tracing and build a latency/error dashboard."
```

---

### Domain: Networking & APIs

#### nginx-patterns
**What:** Optimize NGINX for caching, streaming, agentic routing, buffering  
**Triggers:** "NGINX", "streaming", "SSE", "buffering", "reverse proxy", "L7 routing"  
**Output:** NGINX config, optimization recommendations, performance tuning  

```
Ask: "Use nginx-patterns to optimize my NGINX gateway 
for Server-Sent Events (SSE) responses from LLMs."
```

---

### Domain: Product & Strategy

#### tech-pm
**What:** Capture strategic intent, scope features, roadmap design  
**Triggers:** "strategic intent", "feature scoping", "roadmap", "product strategy"  
**Output:** Strategic brief, feature list, prioritization framework  

```
Ask: "Use tech-pm to capture the strategic intent for our new 
'AI Governance' product line and outline the phased roadmap."
```

---

#### value-proposition
**What:** Build JTBD (Jobs-To-Be-Done) value propositions  
**Triggers:** "JTBD", "value proposition", "customer jobs", "outcome-driven"  
**Output:** 6-part value map, customer journey, success metrics  

```
Ask: "Use value-proposition to map the JTBD for our AI governance platform. 
Customers are hiring it to: control LLM costs, prevent data leakage, and meet compliance."
```

---

#### pm-standards
**What:** Apply RICE prioritization, product frameworks  
**Triggers:** "RICE", "prioritization", "frameworks", "estimation"  
**Output:** Scored feature matrix, roadmap, business case  

```
Ask: "Use pm-standards to run RICE prioritization on these three features, 
scoring by reach, impact, confidence, and effort."
```

---

#### prd-generator
**What:** Generate full PRD from requirements  
**Triggers:** "PRD", "product requirements", "specification"  
**Output:** Complete PRD document (vision, features, acceptance criteria, success metrics)  

```
Ask: "Use prd-generator to create a full PRD for the AI Governance Platform 
based on [strategic intent from tech-pm, JTBD from value-proposition, 
RICE scores from pm-standards]."
```

---

#### slide-deck-creator
**What:** Generate executive presentations from documents  
**Triggers:** "slides", "presentation", "deck", "PowerPoint"  
**Output:** PowerPoint presentation ready to present  

```
Ask: "Use slide-deck-creator to create a 15-slide executive deck 
about our AI Governance Platform based on the PRD and JTBD mapping."
```

---

### Domain: Documentation

#### docs-agent
**What:** Write ADRs, design docs, technical specs, engineer handoff  
**Triggers:** "write docs", "ADR", "design doc", "technical writing", "engineer handoff"  
**Output:** Markdown documents (ADR, design doc, technical spec)  
**Templates:** architecture-decision-record.md, technical-design-doc.md  

```
Ask: "Use docs-agent with the architecture-decision-record template 
to document our decision to use Gateway API instead of custom webhook routing."
```

---

### Domain: Utilities

#### defuddle
**What:** Extract clean markdown from web pages (remove ads, navigation, clutter)  
**Triggers:** "extract content", "scrape", "clean web content"  
**Output:** Clean markdown suitable for saving to Obsidian  

```
Ask: "Use defuddle to clean up this Kubernetes documentation 
[paste URL] and save it as structured markdown."
```

---

## COMPOSING SKILLS FOR COMPLEX WORK

If you need multiple skills but **no dispatcher pipeline exists**, compose them manually:

**Example: "Design, secure, and document an agentic gateway"**

```
Step 1: Use ai-engineer to design the agentic routing logic
Ask: "Design an agentic router that classifies requests by intent and cost-sensitivity. 
Output: architecture diagram, decision tree, pseudo-code."

Step 2: Use ai-security-patterns to audit the design
Ask: "Audit the router design [paste output from step 1] for prompt injection, 
data leakage, and evasion techniques. Output: threat model, vulnerabilities, fixes."

Step 3: Use docs-agent to document it
Ask: "Write an ADR documenting the router design [paste outputs from steps 1-2]. 
Template: architecture-decision-record.md"

Output: 3-4 hours for design + security audit + documentation
```

**Rules:**
- Skills execute sequentially (not in parallel)
- Output from step N becomes input to step N+1
- Maximum 1 primary + 2 secondary skills per step (don't chain more than 3 steps)

---

## DISPATCHER PIPELINE EXECUTION FLOW

When you ask Claude to run a dispatcher pipeline, here's what happens behind the scenes:

```
User Request (e.g., "Run ai-gateway-deployment pipeline")
    ↓
Claude matches intent to dispatcher.yaml → finds "ai-gateway-deployment" pipeline
    ↓
Dispatcher loads sequence: k8s-gateway-api → k8s-gateway-inference → nginx-patterns → k8s-observability-ops
    ↓
Step 1: Load k8s-gateway-api skill
  - Understand your requirements (model types, traffic splitting, failover)
  - Design Gateway API architecture
  - Generate GatewayClass + HTTPRoute manifests
  - Output: Kubernetes manifests + configuration summary
    ↓
Step 2: Load k8s-gateway-inference skill (with output from step 1 as context)
  - Understand your model routing requirements
  - Configure InferencePool based on your models
  - Generate model affinity rules
  - Output: InferencePool manifests + routing rules
    ↓
Step 3: Load nginx-patterns skill (with outputs from steps 1-2 as context)
  - Understand your traffic patterns (streaming, batch, real-time)
  - Optimize NGINX for your specific needs
  - Generate NGINX core config
  - Output: NGINX configuration + tuning recommendations
    ↓
Step 4: Load k8s-observability-ops skill (with all prior outputs as context)
  - Understand your monitoring requirements
  - Add OpenTelemetry instrumentation
  - Generate Prometheus scrape configs
  - Create Grafana dashboards
  - Output: OTEL config + Prometheus config + dashboard definitions
    ↓
Final Output:
  - All Kubernetes manifests (gateway, inference pool, NGINX, observability)
  - All configuration files
  - Deployment guide
  - Ready to run: kubectl apply -f manifests/
```

---

## HANDLING DISPATCHER PIPELINE OUTPUT

When a pipeline completes, you'll get:

1. **Crystallized Summary** — What was done, key decisions, outputs
2. **Deliverables** — Code, manifests, configuration files
3. **Next Steps** — How to deploy, test, verify

**Example output from ai-gateway-deployment:**

```
## Summary
✅ Gateway API design completed
✅ InferencePool routing configured for Claude (primary) + Gemini (secondary)
✅ NGINX optimized for streaming responses
✅ OpenTelemetry instrumentation added

## Deliverables
- k8s-manifests/
  ├── gatewayclass.yaml
  ├── httproute.yaml
  ├── inferencepool.yaml
- nginx-config/
  ├── upstream.conf (model failover rules)
  ├── location.conf (streaming optimization)
- otel-config/
  ├── collector-deployment.yaml
  ├── instrumentation.yaml

## Next Steps
1. kubectl apply -f k8s-manifests/ k8-manifests/
2. kubectl apply -f otel-config/
3. Port-forward to Jaeger: kubectl port-forward svc/jaeger 16686:16686
4. Test: curl -v http://localhost/api/query?model=gpt-4
5. View traces: http://localhost:16686
```

---

## BEST PRACTICES FOR DAILY USE

### 1. Be Specific With Context
Instead of: "Design an AI router"  
Say: "Design an AI router that routes requests based on cost-sensitivity. 
Use Claude API for priority queries (cost 10x but 2x latency), 
Gemini for non-critical queries. Output a decision tree and NGINX routing rules."

### 2. Chain Outputs
Don't re-explain the same context in each request. When using manual composition:
```
Step 1: "Use ai-engineer to design X. Output: architecture diagram + pseudo-code."
Step 2: "Use ai-security-patterns to audit [the design from step 1]. Output: threat model + fixes."
```

### 3. Request Templates Early
When you know you'll use a dispatcher pipeline, check if templates exist:
```
"Run the agentic-routing-poc pipeline. I need:
- ADR (using architecture-decision-record.md template)
- Design doc (using technical-design-doc.md template)
- Implementation guide"
```

### 4. Verify Output Before Handoff
For engineering handoff, always ask for:
- Clear deployment instructions
- Testing checklist
- Monitoring setup

Example:
```
"Use docs-agent to write an engineer handoff doc for our AI gateway. Include:
1. How to deploy (kubectl commands)
2. How to verify it's working (health checks, test queries)
3. How to monitor (OTEL dashboards, alerts)
4. Troubleshooting guide
Template: technical-design-doc.md"
```

### 5. Iterate Within a Skill
If the first output isn't quite right, keep iterating with the same skill:
```
Request 1: "Use nginx-patterns to optimize for SSE responses."
[Get output]

Request 2: "That's good, but I also need to optimize for WebSocket connections. 
Update the NGINX config to handle both SSE and WebSocket with connection pooling."
```

### 6. Know When to Create a New Dispatcher Pipeline
If you find yourself composing the same 3-4 skills together regularly:
- Document the sequence
- Write the pipeline definition (see dispatcher.yaml)
- Run validation: `python ~/.agents/validate-skills.py --strict`
- Commit it to your system

Example:
```
feat(pipeline): add ai-security-hardening pipeline

This pipeline audits an AI feature for security and documents the fixes.
Sequence: ai-engineer (analyze) → ai-security-patterns (audit) → docs-agent (document)
```

---

## YOUR SKILL MATURITY MODEL

### Level 1: Single Skills (Now)
You're using one skill at a time. You know the triggers and can request specific skills by name.

**Examples:**
- "Use docs-agent to write an ADR"
- "Use ai-security-patterns to audit this feature"
- "Use platform-engineer to provision a vcluster"

---

### Level 2: Dispatcher Pipelines (Next)
You're running multi-step workflows by pipeline name. You know when a pipeline exists that covers your use case.

**Examples:**
- "Run the ai-gateway-deployment pipeline"
- "Run the product-definition pipeline"
- "Run the cluster-troubleshooting pipeline"

---

### Level 3: Custom Composition (Advanced)
You're combining skills that don't have a pipeline yet. You know how to chain outputs and when to create new pipelines.

**Examples:**
- "Design → secure → document my agentic router" (3-skill composition)
- "Propose a new dispatcher pipeline for [use case]"
- "Extend the ai-gateway-deployment pipeline to include cost optimization"

---

### Level 4: System Maintenance (Rare)
You're creating new skills, updating pipelines, and managing the system as it scales.

**Examples:**
- "Create a new skill for [domain]" (requires IMPLEMENTATION_GUIDE.md Part 2)
- "Update the dispatcher pipeline definitions"
- "Run quarterly skill health audit" (see SKILL_MAINTENANCE.md)

---

## COMMON MISTAKES TO AVOID

### ❌ Mistake 1: Over-specifying the skill
```
❌ "Use ai-engineer and also add security and also write the docs"
✅ "Use ai-engineer to design the router. Then I'll ask for ai-security-patterns."
```

### ❌ Mistake 2: Asking a skill to do something outside its domain
```
❌ "Use k8s-engineer to optimize my NGINX config"
✅ "Use nginx-patterns to optimize my NGINX config"
```

### ❌ Mistake 3: Not using dispatcher pipelines when they exist
```
❌ "Use k8s-gateway-api, then k8s-gateway-inference, then nginx-patterns, then k8s-observability-ops"
✅ "Run the ai-gateway-deployment pipeline"
```

### ❌ Mistake 4: Re-explaining context in chained requests
```
❌ Step 1: "Design a router that routes based on cost and latency"
   Step 2: "I have a router that routes based on cost and latency. Secure it please."
✅ Step 1: "Design a router that routes based on cost and latency"
   Step 2: "Secure the router you just designed [pasting output from step 1]"
```

### ❌ Mistake 5: Asking for output in the wrong format
```
❌ "Use ai-security-patterns to audit this, but please output a PDF"
✅ "Use ai-security-patterns to audit this. Output: Markdown threat model + remediation checklist"
```

---

## TROUBLESHOOTING

### Q: I asked for a skill but Claude didn't invoke it
**A:** Skills are lazy-loaded based on semantic triggers. Either:
1. Explicitly request it: "Use **skill-name** to..."
2. Or use a keyword from the semantic triggers list (see USAGE.md)

---

### Q: I asked for a dispatcher pipeline but Claude didn't run it
**A:** Either:
1. The pipeline name isn't exactly right (check dispatcher.yaml)
2. Your intent didn't clearly match the pipeline (rephrase the request)
3. You asked for something that requires manual composition instead

---

### Q: Can I run two pipelines in parallel?
**A:** No. Pipelines run sequentially. If you need to work on two things in parallel, open two separate conversation windows with Claude.

---

### Q: The skill output didn't match what I expected
**A:** Iterate within the same skill:
```
"That's close, but I also need [missing thing]. Update the [output] to include..."
```

Or switch to a different skill if you need a different domain:
```
"That design is good. Now use ai-security-patterns to audit it for vulnerabilities."
```

---

### Q: How do I know if a new pipeline is worth creating?
**A:** Create a dispatcher pipeline if:
1. You'll run this workflow more than 2-3 times
2. The skills always execute in the same order
3. Output from skill N feeds into skill N+1

If it's a one-off, just compose the skills manually.

---

## YOUR NEXT 7 DAYS

### Day 1: Get Familiar with Single Skills
- Pick one task you'd normally do manually
- Request a single skill to do it
- Example: "Use docs-agent to write an ADR for [decision]"

### Day 2-3: Try a Dispatcher Pipeline
- Run one of the existing pipelines
- Example: "Run the cluster-lifecycle pipeline to provision my test cluster"

### Day 4-5: Manual Multi-Skill Composition
- Compose 2-3 skills for a complex task
- Example: "Design → secure → document an agentic router"

### Day 6: Document & Iterate
- Use docs-agent to write handoff docs
- Iterate on the output until it's production-ready

### Day 7: Reflect & Plan
- Which workflows did you run most?
- Do you see a pattern that's missing a dispatcher pipeline?
- Are there new skills you'd create?

---

## REFERENCE CARD (Print This)

```
QUICK SKILL TRIGGERS:

Design: ai-engineer ("agentic AI", "PoC", "LangChain")
Secure: ai-security-patterns ("prompt injection", "jailbreak", "guardrails")
Deploy K8s: k8s-engineer ("troubleshoot", "networking", "deploy")
Gateway API: k8s-gateway-api ("advanced routing", "traffic splitting")
Inference: k8s-gateway-inference ("model routing", "InferencePool")
Observe: k8s-observability-ops ("tracing", "metrics", "OTEL")
Infra: platform-engineer ("provision", "cluster", "GitOps")
NGINX: nginx-patterns ("streaming", "SSE", "buffering", "L7 routing")
Strategy: tech-pm ("strategic intent", "feature scope", "roadmap")
Product: prd-generator ("requirements", "PRD", "spec")
Docs: docs-agent ("ADR", "design doc", "technical writing")

QUICK PIPELINE TRIGGERS:

cluster-lifecycle → Provision K8s cluster + GitOps + monitoring
ai-gateway-deployment → Deploy inference gateway with routing
agentic-routing-poc → Build agentic router + tracing + ADR
cluster-troubleshooting → Diagnose + fix cluster issues + post-mortem
product-definition → Strategic intent → PRD → slides

COMPOSITION RULE:
Max 1 primary + 2 secondary skills per step
Chain outputs: output from step N → input to step N+1
If chaining 3+ steps regularly, propose a new dispatcher pipeline
```

---

## NEXT STEPS

1. **Bookmark this guide:** `~/.agents/DAILY_USAGE_GUIDE.md`
2. **For specific skills:** See USAGE.md (has full skill reference)
3. **For pipeline details:** See dispatcher.yaml
4. **For execution rules:** See RULES.md
5. **For new skills:** See IMPLEMENTATION_GUIDE.md Part 2
6. **Validate system:** `python ~/.agents/validate-skills.py --strict`

---

**Last Updated:** 2026-07-18  
**Author:** Jason Williams, Principal TPM & Solutions Architect  
**System:** Claude Code + Agentic Workflow Dispatcher
