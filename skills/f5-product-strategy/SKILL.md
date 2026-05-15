---
name: f5-product-strategy
description: Product strategy and portfolio positioning for F5 offerings, specializing in the convergence of networking (NGINX) and AI (Guardrails, Inference Extensions).
---

# SKILL: F5 Product Strategy + Portfolio Positioning

> Activate when: F5 portfolio, product strategy, better-together narrative,
> leadership alignment, exec comms, GTM strategy, product vision, investment decisions,
> POC-to-product bridge, competitive positioning, F5 product storytelling.

---

## F5 Portfolio Map (Our Context)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    F5 PRODUCT PORTFOLIO                             │
│                                                                     │
│  EDGE / CLOUD                 KUBERNETES              AI            │
│  ─────────────────            ──────────────          ───────────── │
│  F5 Distributed Cloud         NGINX Ingress           AI Guardrails │
│  ├── App Connect              NGINX Gateway Fabric    Red Team      │
│  ├── WAF / Bot / DDoS         F5 CIS (BIG-IP bridge)                │
│  ├── NGINX API Gateway        BIG-IP Next                           │
│  └── Multi-cloud network                                            │
│                                                                     │
│  THE CONVERGENCE POINT:                                             │
│  F5 XC (edge) → NGINX GF (K8s L7) → Gateway Inference (AI L8)       │
│                        ↑                                            │
│               AI Guardrails + Red Team                              │
└─────────────────────────────────────────────────────────────────────┘
```

---

## The "Better Together" Narratives

These are the strategic stories that connect individual POCs to product investment.
Each narrative should be usable in an exec briefing or a leadership review.

### Narrative 1: NGINX + F5 CIS = Scalable K8s Ingress for AI

**One-liner:** "NGINX Gateway Fabric handles AI inference routing at the K8s layer;
F5 CIS in ingress-aware mode gives BIG-IP enterprise customers a clean on-ramp to
AI workloads without rearchitecting their data centre."

**Business impact:**
- Reduces BIG-IP config complexity by 80%+ in AI-scale pod environments
- Extends the life of BIG-IP investments as AI workloads grow
- Positions NGINX GF as the required K8s layer for any F5+BIG-IP enterprise

**POCs that prove it:** POC-001, POC-006

---

### Narrative 2: NGINX + AI Guardrails = Secure AI Traffic at the Application Layer

**One-liner:** "Every NGINX-proxied LLM request can be inspected and policy-enforced
without modifying the application — Guardrails integrates as an NGINX auth_request
module, making AI security a platform capability, not an app responsibility."

**Business impact:**
- AI security becomes a one-time platform integration (vs. every dev team doing it themselves)
- Reduces time to compliant AI deployment from weeks to hours
- Differentiates F5 as the only networking vendor with integrated AI security

**POCs that prove it:** POC-002

---

### Narrative 3: F5 XC = The Multi-Cloud Control Plane for AI

**One-liner:** "F5 Distributed Cloud makes AI inference a utility — workloads run
on the best available infrastructure, XC handles the routing, security, and
connectivity across clouds and on-prem from a single control plane."

**Business impact:**
- Enterprises don't have to choose a single cloud for AI — XC abstracts it
- GPU scarcity is managed globally, not per-cluster
- F5 XC becomes the required infrastructure layer for enterprise AI at scale

**POCs that prove it:** POC-003, POC-005

---

### Narrative 4: Gateway Inference + NGINX GF = K8s-Native AI Serving

**One-liner:** "The Kubernetes Gateway Inference Extension turns K8s into an
AI-native runtime — NGINX Gateway Fabric implements it, making model serving,
LoRA routing, and prefix-cache-aware scheduling first-class K8s operations."

**Business impact:**
- Positions F5/NGINX at the centre of the emerging AI platform stack
- Gateway Inference is a K8s SIG standard — early implementation = market leadership
- Opens the path to F5-specific InferencePool extensions (token budget, Guardrails integration)

**POCs that prove it:** POC-001, POC-004

---

### Narrative 5: GCP Marketplace = AI Security GTM at Cloud Speed

**One-liner:** "By listing F5 AI Guardrails and Red Team on GCP Marketplace,
we turn a multi-week enterprise sales cycle into a one-click GKE deployment —
drawing down customer EDP commitments with no new PO."

**Business impact:**
- New revenue channel via cloud marketplace (20-30% of enterprise software is now marketplace-purchased)
- GCP partnership deepened — F5 becomes a recommended AI security solution on GKE
- Product-led growth motion: try before you buy via Marketplace free tier

**POCs that prove it:** POC-007

---

## POC → Product Bridge

Every POC should end with a clear answer to this question:

> "If we productised this, what would it look like and what would it be worth?"

### Framework: POC → Product Decision Matrix

| POC outcome | Decision | Next step |
|---|---|---|
| Hypothesis validated, high strategic fit | **Productise** | Write PRD, resource engineering team |
| Hypothesis validated, medium fit | **Integrate** | Add as feature to existing product |
| Hypothesis refuted, learnings clear | **Pivot** | Adjust hypothesis, run new POC |
| Hypothesis refuted, no clear path | **Kill** | Document learnings, move on |
| Hypothesis validated, not our space | **Partner** | Find ISV partner to build it |

---

## Leadership Presentation Structure

When taking a POC to leadership, use this structure:

```
1. THE PROBLEM (30 seconds)
   "Enterprises running AI workloads on K8s face [X pain]..."

2. THE INSIGHT (30 seconds)
   "We discovered that [F5 product] can [unique capability]..."

3. THE PROOF (2 minutes)
   "We built a POC that demonstrates [specific outcome].
    Here's the demo / here's the metric."

4. THE OPPORTUNITY (1 minute)
   "At scale, this unlocks [business value]. The market for this is [TAM/context]."

5. THE ASK (30 seconds)
   "We need [resource/decision/investment] to take this to [milestone]."
```

**Total: 5 minutes.** If you can't say it in 5 minutes, you haven't thought it through enough.

---

## Competitive Positioning for AI

### F5's differentiated position
- **Only networking vendor** with integrated AI traffic inspection (Guardrails)
- **Only ingress vendor** with a credible BIG-IP → K8s migration path (CIS + NGINX)
- **Only edge security vendor** with a K8s AI inference integration story (XC + GIE)
- **Multi-cloud AI** without vendor lock-in

### Competitors to be aware of
| Competitor | Strength | F5 differentiation |
|---|---|---|
| Kong (API GW) | AI gateway, developer portal | F5 has security depth (WAF, DDoS, Bot) |
| Istio / Envoy | Service mesh depth | F5 has enterprise support + BIG-IP heritage |
| AWS ALB / GCP LB | Native cloud integration | F5 works across all clouds (XC) |
| Cloudflare | Edge security, AI gateway | F5 has on-prem + K8s depth |
| Apigee | API management | F5 has network-layer security + NGINX |

---

## Strategic Questions (ask before every POC)

1. **Which F5 product does this POC advance?** (be specific)
2. **Which competitor does this displace or differentiate against?**
3. **Which customer segment cares most?** (enterprise K8s, AI startup, cloud-native)
4. **What's the go-to-market motion?** (direct sales, marketplace, partner, self-serve)
5. **What's the investment ask if we productise?** (eng headcount, time to GA)
6. **What's the risk of NOT building this?** (competitive exposure, customer churn)

---

## OKR Template for a POC Program

```markdown
## Objective: Establish F5 as the Reference AI Infrastructure Platform

### KR1: Complete 7 engineer-ready POCs by [date]
Measure: POC count in pm/BACKLOG.md DONE table

### KR2: 3 POCs presented to leadership and moved to product roadmap
Measure: Leadership presentation completed, roadmap item created

### KR3: GCP Marketplace listing submitted for F5 AI Guardrails
Measure: Listing in GCP partner portal, review initiated

### KR4: Reference architecture (XC → NGINX → GIE) documented and available
Measure: Architecture doc published, shared with SE/sales team
```

---

## Related Skills
- `zero-to-launch-k8s-ai` — start every POC with strategic framing
- `handoff-ready` — ensure every POC is engineer-ready
- `ai-security-patterns` — Guardrails and Red Team capabilities
- `marketplace-packaging` — GCP/AWS/Azure listing mechanics
- `nginx-patterns` — NGINX product capabilities
- `f5-cis-patterns` — BIG-IP + NGINX better together