# Controlled PRD Lifecycle Workflow

Execute this workflow strictly as a sequential state machine. Never jump phases without explicit user approval.

## 🟢 PHASE 1: Data Verification (Stop & Check)
- Run the `requirements.md` engine against the user's initial prompt.
- **Gate:** If data is missing, output the missing fields as a concise bulleted list and stop. Do not proceed to drafting.

## 🟡 PHASE 2: Route Selection (Acknowledge)
- Classify the feature using `outlines.md`.
- **Gate:** Output: *"Feature classified as [Standard/Technical/UX]. Ready to load the corresponding template. Proceed? (Y/N)"*

## 🔵 PHASE 3: Iterative Section Drafting (Lean Execution)
- Load the approved template asset.
- **Anti-Bloat Rule:** Do not generate the entire document at once. Draft a maximum of **two sections** at a time (e.g., Title/Summary, then Problem/Goals).
- **Gate:** Wait for user feedback or a "continue" command before drafting the next block of requirements.

## 🟠 PHASE 4: Guardrail Pass
- Inject a mandatory `Edge Cases`, `Non-Goals`, and `Out of Scope` block to prevent scope creep.
- Review non-functional requirements against the core constraints captured in Phase 1.