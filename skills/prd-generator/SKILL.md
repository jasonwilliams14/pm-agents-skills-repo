---
name: prd-generator
description: Orchestrates PRD generation using targeted, modular assets.
category: product-management
---
# PRD Generator Orchestrator

## Phase Control
Do not execute all steps at once. Assess the current state of the conversation and execute ONLY the corresponding file:

1. **Phase 1: Ingestion** -> Load `references/requirements.md`. Interview the user. Do not generate a document yet.
2. **Phase 2: Classify & Select** -> Based on Phase 1, ask the user to confirm the PRD type (Standard, Technical, UX). ONLY load the matching outline from `references/outlines.md`.
3. **Phase 3: Compilation** -> Inject the structured data into the specific asset template from `assets/`.