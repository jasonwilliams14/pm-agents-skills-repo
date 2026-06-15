# How It Works: The JIT Agent Dispatcher Engine

## Overview
Traditional AI agent setups use "Mega-Prompts"—loading every rule and capability into the context window. This leads to **Context Dilution**, where the model loses precision as the prompt grows.

Our architecture uses a **Hub-and-Spoke JIT (Just-in-Time) Hydration** model. Expertise is stored globally and "hydrated" into the session only when a specific intent is detected.

---

## The Three-Layer Architecture

### 1. The Global Hub (`~/.agents`)
This is the "Source of Truth" and contains the expertise library.
- **Skill Manifest (`.skills_manifest.json`)**: The routing table. It maps *Intent* → *Skill*.
- **Skill Library (`skills/`)**: Isolated `SKILL.md` files containing deep domain expertise.
- **Template Gallery (`templates/`)**: Standardized output formats (ADRs, PRDs, POC, etc.).

### 2. The Project Spoke (`/repo/AGENTS.md`)
Each project has a "Context Map." This tells the agent:
- Which global skills are relevant to this specific codebase.
- Local overrides (e.g., "In this repo, 'deploy' means FluxCD, not Helm").

### 3. The Dispatcher (The Router)
The Router acts as the API Gateway. Its execution flow is:
**Intent Analysis** → **Pipeline Match** → **Skill Hydration** → **Crystallized Output**.

---

## The Hydration Process: How "Lazy Loading" Works

Instead of pre-loading 30 skills, the agent follows these steps:

1. **Discovery:** The agent reads the user prompt and scans `~/.agents/.skills_manifest.json` using semantic triggers ("BOLA" triggers `ai-security-patterns`).
2. **Hydration:** The agent reads **only** the specific `SKILL.md` associated with that trigger. This is "Hydration"—injecting specialized knowledge into the current context.
3. **Execution:** The subagent performs the task using the hydrated expertise.
4. **Crystallization:** The subagent summarizes its findings into a "Crystallized Insight" (a dense technical summary) and returns it to the parent.
5. **De-hydration:** The specialized skill context is wiped from the active window to prevent token bleed and "logic pollution."

## Why This Is Better
- **Prompt Efficiency:** We only use tokens for the expertise actually required for the current step.
- **Deterministic Quality:** By using a `dispatcher.yaml` pipeline, we ensure that a PoC always follows the "Jason Standard" (Plan → Build → Observe → Doc).
- **Scalability:** Adding a new skill doesn't bloat the prompt; it just adds a new entry to the manifest.
