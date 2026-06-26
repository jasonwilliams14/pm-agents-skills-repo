# SKILL.md Standardization Template

This template defines the standard structure for all SKILL.md files. Use this to ensure consistency across the 32+ skills in the system.

---

## TEMPLATE

```markdown
---
name: {{skill-name-slug}}
description: {{One-line description (max 100 chars) for system reminders — what this skill does}}
---

# PERSONA

[2-3 sentences describing who you are, your expertise, and your mindset when this skill is activated. Answer: "Who am I and what am I an expert in?"]

Example:
> You are a Principal Kubernetes Engineer specializing in Gateway API design and infrastructure routing. You favor build-first mindset: concrete YAML examples over abstract explanations. You have deep expertise in GatewayClass, HTTPRoute, and Kubernetes networking patterns.

## Core Expertise
- {{Domain 1}} — {{1-2 word description}}
- {{Domain 2}} — {{1-2 word description}}
- {{Domain 3}} — {{1-2 word description}}

---

# TRIGGERS & WHEN TO USE

## Explicit Triggers
Use these keywords to explicitly invoke this skill:
- `{{keyword-1}}`
- `{{keyword-2}}`
- `{{keyword-3}}`

Example:
- `k8s-gateway-api`
- `gateway`
- `gatewayclass`

## Semantic Triggers (When user says)
These phrases activate this skill via intent matching:
- "{{phrase that activates this skill}}"
- "{{another phrase}}"
- "{{a third phrase}}"

Example:
- "design a GatewayClass for my service"
- "how do I configure HTTPRoute for traffic splitting"
- "I need to implement Gateway API in my cluster"

## When NOT to Use
Identify scenarios where this skill should **defer to another skill** (reference by name):

- Don't use me for {{Scenario A}}, use [[other-skill-name]] instead
- Don't use me for {{Scenario B}}, use [[another-skill-name]] instead

Example:
- Don't use me for infrastructure provisioning, use [[platform-engineer]] instead
- Don't use me for NGINX config, use [[nginx-patterns]] instead

---

# CONSTRAINTS & PERMISSIONS

## Execution
* [x] EXECUTION: {{What CLI commands this skill can run}}
  - Example: `[x] kubectl, helm, fluxctl` but `[ ] aws cli, terraform`
* [x] FILE EDITING: {{What file types this skill can edit}}
  - Example: `[x] .yaml, .md` but `[ ] Python source code`

## Security & Safety
{{Optional: Mention any security-critical constraints}}

---

# CORE COMPETENCY MAP

Build a table showing the domains this skill covers and key concepts within each:

| Domain | Key Concepts |
|--------|-------------|
| {{Domain 1}} | {{Concept A}}, {{Concept B}}, {{Concept C}} |
| {{Domain 2}} | {{Concept D}}, {{Concept E}} |
| {{Domain 3}} | {{Concept F}} |

Example:
| Domain | Key Concepts |
|--------|-------------|
| Kubernetes Routing | GatewayClass, Gateway, HTTPRoute, ParentReference, ReferenceGrant |
| Traffic Splitting | weight-based routing, header-based routing, hostname routing |
| Load Balancing | round-robin, least-connections, sticky sessions |

---

# EXECUTION STANDARDS

List 3-5 core principles you follow when executing tasks. Each principle should have a brief "Why" statement.

1. **{{Principle 1}}** — Why: {{Why this matters}}
   - Example: **Build-first mindset** — Why: Working YAML is better than abstract explanations

2. **{{Principle 2}}** — Why: {{Why this matters}}
   - Example: **Portability** — Why: Demos must run locally on k3d or in shared environments

3. **{{Principle 3}}** — Why: {{Why this matters}}
   - Example: **No legacy patterns** — Why: Gateway API v1.1+ is the forward path

4. **{{Principle 4}}** — Why: {{Why this matters}}

5. **{{Principle 5}}** — Why: {{Why this matters}} (optional)

---

# WORKFLOW

When this skill is activated, what is the step-by-step workflow you follow?

## Step 1: {{Understand}}
{{What you do in this step}} — {{What you're trying to learn}}

Example:
> Understand the user's cluster topology, traffic patterns, and routing needs. Ask clarifying questions: single-region or multi-region? Ingress Controller or bare Gateway API? What traffic profiles?

## Step 2: {{Decide}}
{{What decision you're making}}

Example:
> Decide on GatewayClass selection (NGINX, Cilium, Contour?) and HTTPRoute design (path-based, header-based, or semantic routing?)

## Step 3: {{Execute}}
{{What you're building/writing/configuring}}

Example:
> Generate YAML manifests for GatewayClass, Gateway, and HTTPRoute. Include comments explaining each resource and its purpose.

## Step 4: {{Verify}}
{{How you're testing/validating}}

Example:
> Verify by applying manifests to k3d cluster and testing actual traffic flow. Check that routes match intended behavior.

---

# WHAT TO WATCH FOR (Anti-Patterns)

Flag these issues proactively if you see them in user's code/config:

- **{{Anti-pattern 1}}** → Fix by {{remedy}}
  - Bad: {{Concrete bad example}}
  - Good: {{Concrete good example}}

- **{{Anti-pattern 2}}** → Fix by {{remedy}}
  - Bad: {{Concrete bad example}}
  - Good: {{Concrete good example}}

- **{{Anti-pattern 3}}** → Fix by {{remedy}} (optional)

Example:
- **ReferenceGrant missing for cross-namespace routing** → Fix by adding ReferenceGrant to grant permissions
  - Bad: HTTPRoute in namespace-A references Service in namespace-B without ReferenceGrant
  - Good: ReferenceGrant allows namespace-A HTTPRoute to reference namespace-B Service

- **Gateway listeners mismatch with HTTPRoute parentRefs** → Fix by aligning listener names and ports
  - Bad: HTTPRoute specifies `parentRef.port: 8080` but Gateway listener on port 80
  - Good: HTTPRoute parentRef matches Gateway listener name and port exactly

---

# COMMON COMPOSITIONS

This skill often works with other skills. Document which ones and why:

| Companion Skill | When to Pair | Example Pipeline |
|----------|-----------|-----------|
| [[other-skill-1]] | {{When you need X expertise}} | {{pipeline-name}} |
| [[other-skill-2]] | {{When you need Y expertise}} | {{another-pipeline}} |

Example:
| Companion Skill | When to Pair | Example Pipeline |
|----------|-----------|-----------|
| [[k8s-engineer]] | When you need K8s networking troubleshooting | cluster-troubleshooting |
| [[nginx-patterns]] | When you need NGINX optimization | ai-gateway-deployment |
| [[docs-agent]] | When you need to document the design | agentic-routing-poc |

---

# REFERENCES

Links to supporting documentation, templates, and workflows:

- **Template 1:** [{{Template Name}}](../templates/{{template-file}}.md) — {{When to use}}
- **Template 2:** [{{Another Template}}](../templates/{{another-template}}.md) — {{When to use}}
- **Workflow:** [{{Workflow Name}}](../workflows/{{workflow-file}}.md) — {{What it covers}}
- **Dispatcher Pipeline:** `dispatcher.yaml` → `{{pipeline-name}}` — {{What the pipeline does}}

Example:
- **Template:** [k8s-manifest-conventions.md](../templates/k8s-manifest-conventions.md) — When writing Kubernetes manifests
- **Template:** [architecture-decision-record.md](../templates/architecture-decision-record.md) — When documenting major decisions
- **Workflow:** [kubernetes-routing.md](../workflows/kubernetes-routing.md) — Step-by-step routing design
- **Dispatcher Pipeline:** `dispatcher.yaml` → `ai-gateway-deployment` — Full AI gateway design workflow

---

# NOTES FOR FUTURE MAINTAINERS

{{Optional section: Anything non-obvious that future maintainers should know}}

Example:
> K8s Gateway API is rapidly evolving. This skill targets v1.1+ specs. If a new major version (v2.0) is released, this skill will need MAJOR version bump and dispatcher pipeline review.

---
```

---

## STANDARDIZATION CHECKLIST

When creating or updating a SKILL.md file, verify:

- [ ] **Front Matter:** `name` and `description` present
- [ ] **PERSONA:** 2-3 sentences + Core Expertise bullets
- [ ] **TRIGGERS & WHEN TO USE:** Explicit triggers, semantic triggers, "when NOT to use"
- [ ] **CONSTRAINTS & PERMISSIONS:** What can/cannot execute and edit
- [ ] **CORE COMPETENCY MAP:** Table with 3+ domains
- [ ] **EXECUTION STANDARDS:** 3-5 principles with "Why" explanations
- [ ] **WORKFLOW:** 4 steps (Understand → Decide → Execute → Verify)
- [ ] **WHAT TO WATCH FOR:** 2-3 anti-patterns with bad/good examples
- [ ] **COMMON COMPOSITIONS:** Table showing companion skills
- [ ] **REFERENCES:** Links to templates, workflows, dispatcher pipelines
- [ ] **NOTES (optional):** Future maintainer guidance if needed

---

## SECTION DESCRIPTIONS

### PERSONA
**Purpose:** Establish who you are and your expertise.  
**What to include:** 2-3 sentences on your role, mindset, and core competency.  
**Why:** Orients Claude Code toward your perspective and priorities.

**Example length:** 3-5 sentences + 3 bullet points

---

### TRIGGERS & WHEN TO USE
**Purpose:** Define how this skill is activated.  
**Explicit triggers:** Keywords that explicitly invoke this skill (e.g., `ai-engineer`, `k8s-gateway-api`).  
**Semantic triggers:** Phrases that activate via intent matching (e.g., "how do I design a GatewayClass").  
**When NOT to use:** Scenarios where another skill is better.

**Why:** Prevents skill collisions and clarifies scope boundaries.

**Example length:** 3-8 keywords, 3-8 phrases, 2-3 "when not to use" scenarios

---

### CONSTRAINTS & PERMISSIONS
**Purpose:** State what you can and cannot do.  
**Execution:** What CLI tools you can run (kubectl, helm, Python, etc.).  
**File editing:** What file types you can modify (.yaml, .md, .py, etc.).

**Why:** Prevents misuse and sets clear operational boundaries.

**Example length:** 2 checkboxes + notes

---

### CORE COMPETENCY MAP
**Purpose:** Show the domains this skill covers.  
**What to include:** 3-4 domains, with 3-5 key concepts per domain.

**Why:** Reader can instantly see what this skill knows about.

**Example:** 3-5 rows, 2-3 concepts per row

---

### EXECUTION STANDARDS
**Purpose:** State your core principles.  
**What to include:** 3-5 principles, each with a "Why" explanation.

**Why:** Orients decisions toward your values (build-first, security-first, etc.).

**Example length:** 3-5 bullets, 1-2 sentences each

---

### WORKFLOW
**Purpose:** Show the step-by-step process you follow.  
**Steps:** Typically Understand → Decide → Execute → Verify (4 steps).  
**Each step:** 1-2 sentences describing what you do and why.

**Why:** Users know what to expect when they activate this skill.

**Example length:** 4-5 steps, 2-3 sentences per step

---

### WHAT TO WATCH FOR
**Purpose:** Flag anti-patterns proactively.  
**What to include:** 2-3 common mistakes, with concrete bad/good examples.

**Why:** Prevents user from making preventable mistakes.

**Example length:** 2-3 items, bad/good examples for each

---

### COMMON COMPOSITIONS
**Purpose:** Show which skills work best together.  
**What to include:** Table with companion skills, when to pair, and which dispatcher pipeline uses them.

**Why:** Users can compose skills for complex tasks without reading dispatcher.yaml.

**Example:** 2-4 companion skills

---

### REFERENCES
**Purpose:** Link to supporting docs, templates, and workflows.  
**What to include:** Links to templates (if any), workflows, and dispatcher pipelines that use this skill.

**Why:** Users know where to find more detailed information.

**Example:** 2-4 references

---

## APPLYING THE TEMPLATE

### For New Skills
1. Copy this template
2. Fill in all sections (all are required)
3. Run SKILL.md through this checklist
4. Add to `.skills_manifest.json`
5. Run `validate-skills.py --strict`

### For Existing Skills
1. Open current SKILL.md
2. Reorder sections to match template (if different)
3. Add any missing sections
4. Ensure each section has required content
5. Verify checklist items pass
6. Update version (PATCH or MINOR depending on changes)

### Common Pitfalls to Avoid
- ❌ **Too long PERSONA:** Keep to 2-3 sentences + 3 bullets
- ❌ **Missing "When NOT to use":** Always clarify scope boundaries
- ❌ **No anti-patterns section:** This is where you add real value
- ❌ **Vague WORKFLOW steps:** Be specific (what exactly are you doing?)
- ❌ **No references:** Link to relevant templates and workflows
- ❌ **Generic examples:** Use real examples from your projects

---

## REFERENCES

- [[SKILL_MAINTENANCE.md]] — Versioning and updating skills
- [[IMPLEMENTATION_GUIDE.md]] — Complete skill system guide
- [[USAGE.md]] — How to find and use skills
