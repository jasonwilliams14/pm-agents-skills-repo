# Agents Folder
This folder contains the core configuration, skills, workflows, and templates used by the OpenCode agent system, including integrations with pi.dev and Gemini. It serves as the central repository for domain-specific knowledge, automated workflows, and reusable components that enhance the agent's capabilities.

## Folder Layout
```
.agents/
├── global-config/          # Global configuration files for different LLM providers
│   ├── .gitignore          # Git ignore rules for the global config
│   └── GEMINI.md           # Gemini-specific configuration and settings
├── skills/                 # Domain-specific skill modules that extend agent capabilities
│   ├── ai-engineer/        # AI Engineer skill modules
│   ├── ai-security-patterns/ # AI security frameworks and guardrails
│   ├── defuddle/           # Web content extraction and simplification
│   ├── docs-agent/         # Technical documentation writing
│   ├── find-skills/        # Skill discovery and installation helper
│   ├── google-agents-cli-*/# Google ADK agent development tools
│   ├── json-canvas/        # Obsidian Canvas file manipulation
│   ├── k8s-ai-expert/      # AI/ML workload deployment on Kubernetes
│   ├── k8s-engineer/       # Kubernetes networking and Gateway API
│   ├── k8s-gateway-api/    # K8s Gateway API configurations
│   ├── k8s-gateway-inference/ # K8s Gateway Inference routing
│   ├── k8s-observability-ops/ # K8s OpenTelemetry, Prometheus, and Grafana workflows
│   ├── nginx-patterns/     # NGINX configuration and optimization
│   ├── obsidian-*/         # Obsidian note & knowledge management tools
│   ├── platform-engineer/  # Kubernetes and general platform infrastructure
│   ├── pm-standards/       # Product management frameworks and standards
│   ├── positioning-messaging/ # Competitive positioning and messaging
│   ├── prd-generator/      # Modular PRD generation
│   ├── python-dev-standard/ # Python development best practices
│   ├── slide-deck-creator/ # Slides and presentation creation
│   ├── tech-pm/            # Feature scoping and product roadmap design
│   └── value-proposition/  # JTBD customer value proposition design
├── templates/              # Reusable templates for various document types
│   ├── ai-gateway-architecture-spec.md   # AI gateway design specifications
│   ├── architecture-decision-record.md   # ADR template
│   ├── conference-talk-outline.md        # Presentation outline template
│   ├── flux-gitops-repo-structure.md     # GitOps repository structure
│   ├── k3d-demo-cluster-script.md        # Local Kubernetes cluster setup
│   ├── k8s-inference-deployment.md       # K8s AI inference deployment
│   ├── k8s-manifest-conventions.md       # Kubernetes manifest standards
│   ├── nginx-*                         # NGINX configuration templates
│   └── technical-design-doc.md           # Technical design document template
└── workflows/              # Step-by-step procedural guides for common tasks
    ├── ai-gateway-design.md        # AI gateway design workflow
    ├── k8-gitops-deployments.md    # Kubernetes GitOps deployment process
    ├── kubernetes-routing.md       # Kubernetes traffic routing guide
    ├── technical-storytelling.md   # Technical communication framework
    └── k8s-troubleshooting.md      # Kubernetes issue resolution workflow
```

## How Skills Use Workflows and Templates
Skills in this system are designed to be modular, domain-specific extensions that can be dynamically loaded based on user intent. Each skill follows a standardized structure:

### Skill Structure
```
skills/skill-name/
├── SKILL.md                  # Core skill definition and instructions
└── references/               # Supporting documentation and templates
    ├── reference-topic.md  # Detailed reference materials
    └── templates/            # Skill-specific templates (when applicable)
```

### Integration with Workflows
When a skill is activated, it can reference and utilize workflows in the following ways:
1. **Direct Reference**: Skills can reference workflow files as part of their instructions
   - Example: The `k8s-engineer` skill might reference `workflows/k8s-troubleshooting.md` when debugging Kubernetes issues
2. **Sequential Execution**: Skills can recommend or trigger specific workflows
   - Example: After diagnosing an issue with `k8s-engineer`, it might suggest following the `k8-gitops-deployments.md` workflow for resolution
3. **Context Enhancement**: Workflows provide structured, step-by-step procedures that skills can incorporate into their guidance

### Integration with Templates
Skills leverage templates to ensure consistency and reduce repetitive work:
1. **Template References**: Skills reference specific templates in their usage guidelines
   - Example: The `pm-standards` skill references templates in its references/templates.md file for stakeholder communication
2. **Template Adaptation**: Skills may adapt or extend base templates for domain-specific use cases
   - Example: The `docs-agent` skill might use `technical-design-doc.md` as a base but add AI-specific sections
3. **Template Generation**: Some skills can generate new content based on templates
   - Example: The `find-skills` skill might use templates to create skill discovery reports

### Activation Mechanism
Skills are activated through:
- Explicit invocation via the `skill` tool
- Automatic triggering based on keyword matching in user prompts
- Context-aware suggestions from the agent based on current task

When activated, a skill:
1. Loads its core `SKILL.md` file
2. Makes its reference materials available
3. Can reference workflows and templates as needed
4. Provides domain-specific guidance to enhance the agent's capabilities

This modular design allows for easy extension and customization while maintaining consistency across different domains of expertise.
