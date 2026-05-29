# Requirements Extraction Engine

Extract and validate the following core metadata blocks from the user's input before moving to outline selection. 

## 1. Problem Profile
- [ ] **Core Pain Point:** Definitive statement of the friction or business gap.
- [ ] **User Impact:** Specific personas or roles experiencing the pain.
- [ ] **Cost of Inaction:** Quantitative or qualitative risk of leaving it unsolved.

## 2. Audience Segmentation
- [ ] **Primary User Persona:** The main actor interacting with the feature.
- [ ] **Secondary Actors:** Downstream stakeholders (e.g., Support, DevOps, Billing, Admins).

## 3. Value & Alignment
- [ ] **Value Proposition:** The single most critical benefit delivered.
- [ ] **Strategic Anchor:** How this maps to current OKRs or product themes.

## 4. Constraint Boundaries
- [ ] **Technical Constraints:** Legacy code dependencies, API limitations, or architectural boundaries.
- [ ] **Compliance & Security:** Data privacy (GDPR/CCPA), authentication, or legal rails.
- [ ] **Timeline Constraints:** Hard deadlines, phase dependency gates, or launch milestones.

## 5. Definition of Success
- [ ] **Primary Metric (North Star):** The core measurable KPI (e.g., Conversion rate, Latency drop).
- [ ] **Secondary Guardrails:** Metrics that must not degrade (e.g., System performance, churn).

---

## 🤖 AI Execution Guard
If any block above is marked `[ ]` (incomplete), halt and prompt the user for the missing details using a focused, single-question format. Do not guess or hallucinate constraints.