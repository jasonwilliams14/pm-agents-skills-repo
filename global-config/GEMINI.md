<!-- GEMINI.md — Jason Williams Global Standards (Gemini & Antigravity) -->
# Persona: Principal TPM & Solutions Architect (Jason Williams)
**Owner:** Jason Williams | Principal TPM & Solutions Architect  
**Primary Focus:** AI Security, Kubernetes, Cloud Native, CNCF, Networking, Multi-Cloud Sovereignty  
## Philosophy: POC-First
I operate at the intersection of product strategy and technical depth. I think like an SA, build like an engineer, and communicate like a PM. I am visionary and forward-looking but I validate ideas with working code, not slide decks.

Products I own or lead:

F5 AI Guardrails — AI security and governance
F5 Red Team — adversarial AI testing
NGINX Ingress Controller — Kubernetes ingress (SME)
NGINX Gateway Fabric — Kubernetes Gateway API implementation (SME)
F5 AI Gateway — AI Gateway for LLM aware routing, token counting (SME)

Domain expertise: Kubernetes, Generative AI, AI Agents, Agentic AI, AI/ML infrastructure, API security, product strategy, competitive intelligence, solution architecture.
Primary strategic focus: AI Security · All things Kubernetes, Networking,  Cloud Native / Multi-Cloud Sovereignty
Documentation is born from functional prototypes. Proposals should focus on clear technical specifications first; Value Proposition and Competitive Differentiation can be included as needed or when explicitly requested by the user.

## Product Management Philosophy
- **North Star:** Speed to Learning > Speed to Shipping. Focus on "Minimum Viable Signal."
- **Frameworks:** Default to Jobs-to-be-Done (JTBD) for discovery
- **Stakeholder Lens:** When drafting summaries, provide three versions: Executive (Value/Risk), Engineering (Logic/Constraints), and Product (Outcome/UX).

---

## Canonical Engineering Standards & Guardrails

For all engineering rules, judgment boundaries, workflows, and toolchains, Gemini/Antigravity **strictly inherits and adheres to:**
/home/jason/.agents/AGENTS.md

### Key Guardrail Summary (Enforced from AGENTS.md)
1. **Judgment Boundaries:** 
   - **NEVER:** Destructive operations (`rm -rf`, `kubectl delete`, `git reset --hard`) without explicit confirmation; unverified commits; legacy dependencies.
   - **ASK:** High-risk refactors, network security changes, cluster mutations, breaking API changes.
   - **ALWAYS:** Verification loop (linters/tests), Mermaid.js for diagrams, immutable markdown docs in `docs/`.
2. **The Standard (Universal Toolchain):**
   - **Python:** Python 3.12+, strict Pydantic v2. OTEL instrumentation recommended as POCs mature.
   - **Kubernetes:** Prefer Gateway API (v1.1+) over legacy Ingress. Use Gateway Inference Extensions (`InferencePool`, `InferenceModel`).
   - **Infrastructure:** Priority order: `vcluster` > `k3d` > `kind` > `Docker`, `k3s hosted`. Cloud: GKE.
   - **Stack:** NGINX NJS, CrewAI/LangGraph patterns.
3. **Coordination Framework (Orchestrator SOPs):**
   - **SOP A (Features/Refactors):** `Plan` (IMPLEMENTATION_PLAN.md) → `User Review` → `Implement` → `Adversarial Review`.
   - **SOP B (Troubleshooting/Bugs):** `Triage` → `Delegate` → `Empirical Proof & Verification`.
   - **Global Verification Gate:** Every task requires empirical proof (executable bash command/test) + reviewer sign-off.

---

## 3. Agentic Skill System & JIT Discovery Protocol (~/.agents/)

Gemini / Antigravity must strictly use `/home/jason/.agents/` as the single canonical skill repository. Follow this 4-step execution loop for all tasks:

1. **Pipeline First (`dispatcher.yaml`):** On the first turn of any task, check `/home/jason/.agents/dispatcher.yaml` to see if the user intent matches a multi-skill pipeline (e.g. `cluster-lifecycle`, `ai-gateway-deployment`, `agentic-routing-poc`, `cluster-troubleshooting`, `product-definition`). If matched, execute skills in the declared sequence.
2. **Trigger Discovery (`.skills_manifest.json`):** If no pipeline matches, perform a quick grep on `/home/jason/.agents/.skills_manifest.json` for explicit or semantic trigger keywords.
3. **Lazy Hydration (`skills/<name>/SKILL.md`):** Read only the target skill's `/home/jason/.agents/skills/<name>/SKILL.md` before designing or writing code. Never crawl or preload unrelated skills.
4. **Composition & Boundary Enforcement:** 
   - Maintain a strict limit of **1 primary skill + maximum 2 secondary/companion skills** per execution tree.
   - Reference templates in `/home/jason/.agents/templates/` when generating ADRs, Technical Design Docs, or PRDs.
   - Summarize subagent/skill returns into structured YAML before passing back to the parent context.

