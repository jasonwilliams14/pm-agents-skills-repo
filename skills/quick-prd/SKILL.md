---
name: quick-prd
description: Fast-track PRD generation for already-validated features (skip JTBD/RICE re-work). Use when a feature has been validated by POC, customer feedback, or market research and needs specification without re-running discovery.
category: product-management
---

# Quick PRD — Fast-Track Feature Specification

Use this skill when:
- A feature has been validated by a **working POC** and you need the PRD for engineering
- A feature has been **validated by customer research** or market feedback and needs spec
- You're refining a feature **post-POC** with learnings from validation
- You want to **skip JTBD/RICE re-analysis** and jump straight to the spec

**Do NOT use** if you need to validate the feature idea first — use `prd-generator` instead for full JTBD → RICE → PRD flow.

---

## Workflow

### Input
Provide one of:
- **POC learnings:** "Built a POC that validates the core hypothesis. Here's what we learned..."
- **Market validation:** "Customer feedback confirms this is a problem. Here's their feedback..."
- **Feature spec:** "We've narrowed scope to X. Here's what we're building..."

### Process
1. **Intake:** Gather feature name, problem statement, validated assumptions, scope boundaries
2. **Accelerate:** Skip JTBD/RICE analysis (already validated). Jump to spec.
3. **Generate:** Use the same three-part PRD structure (exec / product / engineering) but streamlined — shorter discovery sections, focus on validation evidence + scope + acceptance criteria
4. **Review:** Confirm with you before finalizing

### Output
- Complete PRD (executive summary + product spec + engineering requirements)
- Uses `templates/prd-template.md` but with validation-focused intro
- Ready for engineering handoff or stakeholder review

---

## Key Differences from Full PRD Generator

| Aspect | Full PRD | Quick PRD |
|--------|----------|-----------|
| JTBD analysis | Deep dive → feature value map | Assume validated, reference it |
| RICE scoring | Run full prioritization | Reference existing priority or skip |
| Problem statement | Derived from JTBD | Provided (already validated) |
| Scope | Discovered via research | Negotiated based on POC/feedback |
| Timeline | ~60 min (discovery heavy) | ~15–20 min (spec heavy) |

---

## When to Use This (vs. prd-generator)

```
Start here:
├─ Feature is already validated (POC, customer interviews, competitive analysis)?
│  └─ YES → use quick-prd (15–20 min)
│  └─ NO  → use prd-generator (60 min, includes JTBD/RICE)
│
├─ Refining a POC-validated feature?
│  └─ YES → quick-prd
│  └─ NO  → prd-generator
│
├─ Need to skip the analysis and move to spec?
│  └─ YES → quick-prd
│  └─ NO  → prd-generator
```

---

## Output Example

The PRD includes:
- **Executive Summary:** Brief value prop + business impact (built from validation evidence)
- **Product Specification:** Goals, user personas, feature scope, success metrics
- **Engineering Requirements:** API/data model, performance, integrations, testing strategy
- **Notes:** Tradeoffs made, assumptions held, follow-up work

All three sections are present but **lighter on discovery narrative** — focus is spec + handoff readiness.
