---
name: product-decision-record
description: Create product-level decision records for scope, targeting, and tradeoff choices. Captures *product decisions* (which features, which customers, which tradeoffs) the way ADRs capture technical decisions — ensures alignment and creates an audit trail.
category: product-management
---

# Product Decision Record (PDR)

Use this skill to document **product-level decisions** in a structured format:
- Feature scope boundaries and what we *chose not* to build
- Target customer segment (and who we deprioritized)
- Feature tradeoffs (fast vs. complete, broad vs. deep, simple vs. powerful)
- Why we chose this approach over alternatives
- Consequences for users, roadmap, and future work

---

## When to Use

Use a Product Decision Record when:
- You've made a **significant scope decision** (e.g., "MVP will include X but not Y")
- You've chosen a **target customer** or segment (e.g., "starting with SMB, not enterprise")
- You've made a **tradeoff call** that affects future features (e.g., "streaming-first, not batch-first")
- You want to **document why** an alternative was rejected (and when to revisit it)
- You need an **audit trail** connecting product decisions to PRDs, POCs, and engineering ADRs

---

## Structure

A PDR captures:

```markdown
# PDR-XXX: [Decision Name]

## Status
Proposed | Accepted | Superseded

## Problem Statement
Why did this decision need to be made? What triggered it?

## Decision
What did we decide? Be specific about scope, target, or tradeoff.

## Rationale
Why this choice? What evidence supports it? (POC results, customer feedback, market analysis)

## Alternatives Considered
What else did we consider? Why did we reject the alternatives?

## Consequences
- **For Users:** How does this affect the product experience?
- **For Roadmap:** What does this unblock? What does this defer?
- **For Engineering:** What does this constrain or enable technically?

## Related Decisions
- Links to other PDRs this decision depends on
- Links to PRDs that implement this decision
- Links to technical ADRs that follow from this decision

## Review & Approval
Approved by: [Product, Engineering, Leadership]
Date: [YYYY-MM-DD]
```

---

## Key Differences: PDR vs. ADR

| Aspect | ADR (Technical) | PDR (Product) |
|--------|-----------------|---------------|
| **Owner** | Engineers | PMs + Product Leadership |
| **Scope** | Architecture, API design, tech choices | Feature scope, targeting, tradeoffs |
| **Audience** | Engineers building the system | PMs, leadership, future feature builders |
| **Example** | "Use Gateway API v1.1+ over Ingress" | "MVP targets SMB, defer enterprise features" |
| **Lifespan** | Technical choices (often long-lived) | Feature decisions (may shift with market) |

---

## Workflow

1. **Intake:** Describe the decision and why it's important
2. **Intake:** Gather context: what were the alternatives? what evidence supports this choice?
3. **Structure:** Organize into PDR format
4. **Link:** Connect to related PRDs, POCs, ADRs
5. **Archive:** Store in `docs/decision/` alongside ADRs

---

## Output Location

PDRs live in `docs/decision/` alongside technical ADRs:
```
docs/decision/
├── ADR-001-gateway-api-v1.md        (technical)
├── PDR-001-smb-first-targeting.md   (product)
├── ADR-002-otel-instrumentation.md  (technical)
└── PDR-002-streaming-first-design.md (product)
```

---

## When to Create a PDR

Create a PDR when:
- ✅ Making a feature scope decision that shapes the roadmap
- ✅ Choosing a target customer segment
- ✅ Making a tradeoff that defers or removes features
- ✅ Rejecting a feature idea (for audit trail + "when to revisit")

Do NOT create a PDR for:
- ❌ Routine feature specifications (use PRD instead)
- ❌ Technical choices (use ADR instead)
- ❌ Minor scope tweaks without tradeoff implications

---

## Example

```markdown
# PDR-001: AI Guardrails MVP — SMB-First Targeting

## Status
Accepted (2026-09-01)

## Problem Statement
We have three potential market segments: SMB (10–1000 users), mid-market (1k–10k), enterprise (10k+).
Each has different needs, pricing models, and feature requirements. We need to focus to ship a strong MVP.

## Decision
We will target **SMB** as the primary market for the MVP. Features will be simple, self-serve, and low-friction.
We will defer enterprise features (advanced RBAC, multi-tenancy, compliance dashboards) to v1.1+.

## Rationale
- POC validation with 3 SMB prospects showed strong product-market fit
- Smaller deployment footprint means faster iteration cycles
- Simplified feature set (7 core controls vs. 20+) reduces engineering timeline by 60%
- SMB pricing ($99–499/mo) has higher gross margin than seat-based enterprise pricing

## Alternatives Considered
1. **Enterprise-first:** Larger deal sizes, but 6+ month sales cycle, complex customization
   → Rejected: delays MVP, high integration costs
2. **Horizontal (all segments):** Broad appeal, but 2x feature complexity
   → Rejected: MVP scope explodes, ships Q4 instead of Q2
3. **Mid-market:** Balance between, but weakest product-market fit in research
   → Rejected: loses focus, doesn't leverage our AI expertise in smaller deployments

## Consequences
- **For Users:** Simpler, faster setup. No advanced compliance features yet. May not suit large orgs.
- **For Roadmap:** Unblocks Q2 MVP. Enterprise features → Q3 v1.1 after SMB validation.
- **For Engineering:** Smaller surface area (7 controls). Use this to focus quality + OTEL instrumentation.

## Related Decisions
- PDR-002: Streaming-First API Design (consequence: simplifies SMB UX)
- ADR-001: Python 3.12 + FastAPI (technical foundation for rapid iteration)
- PRD-001: AI Guardrails MVP Specification

## Approved By
- Jason Williams (Principal TPM) — 2026-09-01
- Engineering Lead (to confirm feasibility) — 2026-09-01
```

---

## Composing with Other Skills

**PDR + PRD workflow:**
1. Use `product-decision-record` to lock in scope/targeting decisions
2. Use `prd-generator` or `quick-prd` to spec the feature based on that decision
3. Reference the PDR in the PRD (traceability)

**PDR + ADR workflow:**
1. Use `product-decision-record` to capture the product tradeoff
2. Use `docs-agent` (ADR) to capture the technical implementation tradeoff that follows
3. Link them bidirectionally (PDR → "driven by this technical ADR", ADR → "driven by this product decision")

**PDR + POC workflow:**
1. Run a POC
2. Use `product-decision-record` to capture learnings as a decision
3. Use `quick-prd` to spec based on that validated decision
