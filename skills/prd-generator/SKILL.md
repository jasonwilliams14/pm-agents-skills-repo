---
name: prd-generator
description: Generates comprehensive Product Requirement Documents (PRDs) based on user requirements and predefined outlines. Use when a user needs to draft, refine, or expand a product feature or enhancement into a formal specification.
category: product-management
---

# PRD Generator

## Overview
The `prd-generator` skill streamlines the creation of Product Requirement Documents. It uses a structured approach to gather requirements, select the appropriate PRD outline, and generate a detailed document that aligns with product standards.

## Workflow

### 1. Requirements Gathering
When starting a new PRD, first consult [requirements.md](references/requirements.md) to ensure all necessary data points are captured. This includes:
- Problem Statement
- Target Audience
- Core Value Proposition
- Key Constraints

### 2. Outline Selection
Based on the complexity and type of feature, choose an appropriate outline from [outlines.md](references/outlines.md). Common types include:
- **Standard PRD:** For general features.
- **Technical PRD:** For infrastructure or backend changes.
- **UX-Focused PRD:** For frontend or user-interaction heavy features.

### 3. Generation
Utilize templates in the `assets/` directory to scaffold the initial document. Merge the gathered requirements with the selected outline.

### 4. Refinement
Iterate on the draft by adding success metrics, edge cases, and technical considerations.

## Resources

- **Outlines:** [outlines.md](references/outlines.md) - Definitions of PRD structures.
- **Workflows:** [workflows.md](references/workflows.md) - Procedures for requirements gathering and stakeholder alignment.
- **Templates:** See `assets/` for markdown and document templates.
