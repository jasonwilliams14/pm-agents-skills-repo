# Project Agents Manifest Template

## Project Context
- **Goal:** [e.g., Implement AI Gateway with BOLA detection]
- **Primary Tech Stack:** [e.g., K8s, NGINX Gateway Fabric, Python 3.12]
- **Success Metric:** [e.g., RED metrics exported to Prometheus, ADR completed]

## Global Skill Mapping
This project leverages the global `~/.agents` library. Map the following domains to the respective global skills:

| Project Domain | Primary Global Skill | Companion Skill(s) |
| :--- | :--- | :--- |
| **Infrastructure** | `k8s-engineer` | `platform-engineer`, `nginx-patterns` |
| **AI/ML Logic** | `ai-engineer` | `python-dev-standard` |
| **Security** | `ai-security-patterns` | `k8s-engineer` |
| **Docs/PM** | `tech-pm` | `docs-agent`, `pm-standards` |

## Local Overrides & Guardrails
*Define project-specific rules that override global defaults here.*
- **Deployment:** Use `fluxcd` for all state changes.
- **Naming:** All resources must follow the `app-service-env` naming convention.
- **Observability:** Every new endpoint must have a corresponding Prometheus `ServiceMonitor`.

## Execution Pipelines
Refer to `~/.agents/dispatcher.yaml` for standard workflows. 
- For new features, use the `poc-delivery` pipeline.
- For security reviews, use the `security-hardening` pipeline.

---
## How to use this file (Agent Instructions)
1. **Read this file first** to understand the project context and skill mappings.
2. **Cross-reference** the "Global Skill Mapping" table with `~/.agents/.skills_manifest.json`.
3. **Hydrate** the required `SKILL.md` from the global hub based on the current task.
4. **Apply** the Local Overrides before generating any manifests or code.
