# PI_WORKFLOW.md — Startup Prompt for pi


```
You are working with an agentic AI workflow system designed by Jason Williams.
This system uses structured context, skill routing, and dispatcher pipelines.

Before you help me with ANY task, load this context in order:

1️⃣  LOCAL CONTEXT (Current Working Directory)
   • Check if AGENTS.md exists in the current project folder
   • Check if CLAUDE.md exists in the current project folder
   • If either exists, load them FIRST (they override everything else)
   • If neither exists, note: "Using parent ~/.agents/ rules"

2️⃣  GLOBAL CONTEXT (~/.agents/)
   • If no local AGENTS.md, load: ~/.agents/AGENTS.md
   • If no local CLAUDE.md, load: ~/.agents/CLAUDE.md
   • Load: ~/.agents/dispatcher.yaml
   • Load: ~/.agents/RULES.md
   • Load: ~/.agents/.skills_manifest.json

3️⃣  MACHINE CONFIG
   • Reference: ~/.agents/MACHINE_CONFIG.yaml (skill composition limits, judgment boundaries)

4️⃣  MATCH MY REQUEST TO A PIPELINE
   • Check if my request matches a dispatcher pipeline (cluster-lifecycle, ai-gateway-deployment, agentic-routing-poc, cluster-troubleshooting, product-definition)
   • If match: Show me the skill sequence and ask for confirmation
   • If no match: Use semantic skill lookup in .skills_manifest.json

5️⃣  SHOW YOUR REASONING
   After loading context, ALWAYS show:
   ```
     Local context loaded:
     ✓ AGENTS.md [found/not found]
     ✓ CLAUDE.md [found/not found]
     ✓ dispatcher.yaml [found/not found]

   🔍 Intent matching:
     Your request: "[your task]"
     Dispatcher pipeline: [matched-pipeline or "No match"]
     Recommended skills: [skill-1] → [skill-2] → [skill-3]
     Skill composition: 1 primary + 2 secondary max
     Affected templates: [template-name.md]
   ```

6️⃣  ENFORCE JUDGMENT BOUNDARIES
   From AGENTS.md + MACHINE_CONFIG.yaml, enforce:
   • NEVER: destructive operations without user confirmation
   • NEVER: unverified commits
   • ASK: before high-risk changes
   • ALWAYS: use Mermaid diagrams for visuals
   • ALWAYS: check ~/.agents/skills/ for specialized capability

7️⃣  BEFORE DECLARING COMPLETE
   Always tell me: "Before I declare this complete, run: python3 ~/.agents/validate-skills.py --strict"
   (I'll run this in Claude Code or manually)

---

Treat this workflow as a **decision protocol**, not just a set of rules.
The goal is to route requests to the right specialized skills in the right order.
If anything is ambiguous, ask me for clarification rather than guessing.
```

---

## When to Paste This

**Paste this startup prompt at the beginning of a pi conversation when:**
- ✅ You're working on a new task
- ✅ You're switching to a different project
- ✅ The context seems to have drifted
- ✅ You're unsure which skills to use

**You DON'T need to paste it again if:**
- ✓ You're continuing the same task in the same project
- ✓ The context is already established in the conversation

---

## How pi Will Use This

Once you paste this startup prompt, pi will:

1. **Load context** from your project (AGENTS.md, CLAUDE.md, dispatcher.yaml)
2. **Show its reasoning** visibly (you'll see the context loading steps)
3. **Recommend skills** based on dispatcher pipelines or semantic triggers
4. **Ask for confirmation** before proceeding (especially for high-risk changes)
5. **Enforce judgment boundaries** (ask before destructive operations)
6. **Remind you** to run validation before declaring complete

---

## Example: Using pi for an AI Gateway Design Task

**You:** [Paste the startup prompt above, then add:]

```
I want to design an AI inference gateway with model routing and failover.
What should I do first?
```

**pi will respond:**

```
📋 Local context loaded:
  ✓ AGENTS.md found (loading project constraints)
  ✓ CLAUDE.md found (loading standards)
  ✓ dispatcher.yaml found (checking pipelines)

🔍 Intent matching:
  Your request: "Design AI inference gateway"
  Dispatcher pipeline: ai-gateway-deployment ✓
  
  Recommended skill sequence:
    1. k8s-gateway-api → Design GatewayClass & HTTPRoute
    2. k8s-gateway-inference → Configure InferencePool & model routing
    3. nginx-patterns → Optimize proxy, buffering, SSE for LLM
    4. k8s-observability-ops → Add OTEL tracing for inference latency

  Templates to use:
    • ~/.agents/templates/ai-gateway-architecture-spec.md
    • ~/.agents/templates/k8s-inference-deployment.md
    • ~/.agents/templates/nginx-model-routing.md

Should I proceed with this skill sequence?
```

**You:** Yes, use the ai-gateway-deployment pipeline

**pi continues:** [Works through each skill in sequence, referencing templates and showing reasoning]

**pi at end:** Before I declare this complete, run: `python3 ~/.agents/validate-skills.py --strict`

---

## Quick Reference: Dispatcher Pipelines

These are the predefined workflow pipelines pi should recognize:

| Pipeline | When to Use | Skills |
|----------|-----------|--------|
| `cluster-lifecycle` | Provision K8s + GitOps + monitoring | platform-engineer → k8s-engineer → k8s-observability-ops |
| `ai-gateway-deployment` | Deploy AI gateway | k8s-gateway-api → k8s-gateway-inference → nginx-patterns → k8s-observability-ops |
| `agentic-routing-poc` | Build agentic router | ai-engineer → nginx-patterns + k8s-gateway-api → k8s-observability-ops → docs-agent |
| `cluster-troubleshooting` | Debug K8s issues | k8s-engineer → platform-engineer → docs-agent |
| `product-definition` | Write PRD | tech-pm → value-proposition → pm-standards → prd-generator → slide-deck-creator |

---

## Troubleshooting: pi Questions

### "I don't have access to your local files"

That's expected. pi can't read files directly, but you can:
- Copy-paste relevant content from AGENTS.md, CLAUDE.md, or templates
- Tell pi: "I'm in the repo-ai-gateway-poc project, which has these constraints: [paste from AGENTS.md]"
- Use this workflow: **You provide context → pi applies it → you validate results**

### "How do I know which template to use?"

Reference the MACHINE_CONFIG.yaml Templates section, or ask:
- "Which ~/.agents/templates/ file should I use for this ADR?"
- pi will recommend based on the dispatcher pipeline

### "How do I validate the output?"

Copy the generated files, commit them to your project, then run:
```bash
python3 ~/.agents/validate-skills.py --strict
```

---

## Integration with Claude Code

**In Claude Code:** Context loads automatically (AGENTS.md Section 3)
**In pi:** You paste this startup prompt to enable the same behavior

**Both tools** will then:
- Load local context first
- Match intent to dispatcher pipelines
- Recommend skills in sequence
- Enforce judgment boundaries
- Ask for validation before completing

This creates a **unified workflow** across both agents.

---

## For Jason: Testing This

To test pi with this workflow:
1. Open a pi conversation
2. Copy-paste the startup prompt (the section marked "STARTUP PROMPT FOR PI")
3. Give pi a task: "Design an AI gateway"
4. Verify pi shows intent matching and recommended skill sequence
5. Verify pi asks before high-risk changes
6. Verify pi reminds you to run validation

If pi successfully does all 5 steps, the dual-agent workflow is working.

## References

- **MACHINE_CONFIG.yaml** — Structured config for both agents
- **AGENTS.md Section 3** — Automatic context loading (Claude Code only)
- **dispatcher.yaml** — Dispatcher pipelines (skills + sequences)
- **.skills_manifest.json** — Skill registry & semantic triggers
- **USAGE.md** — Skill quick-start guide
