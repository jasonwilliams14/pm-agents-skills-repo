## PRD Generator skill

How to use from agent coding tool:

```bash
You are executing a modular PRD generation skill. 

Here is your extraction engine rule:
### Requirements Extraction Engine
Extract and validate the following core metadata blocks from the user's input before moving to outline selection:
1. Problem Profile (Core Pain Point, User Impact)
2. Audience Segmentation (Primary User, Secondary Actors)
3. Value Proposition
4. Constraint Boundaries (Technical, Compliance, Timeline)
5. Definition of Success (Primary Metric)

CRITICAL RULE: If any block above is incomplete, halt and prompt the user for the missing details using a focused, single-question format. Do not guess or hallucinate constraints. Do not generate the PRD yet.

---
USER INPUT: "I want to add a 'Save for Later' bookmark button to our e-commerce product pages so users can return to items they like."
```
