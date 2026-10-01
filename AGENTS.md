# AGENTS.md — Global Engineering Guardrails

Single entry for judgment, toolchain, and JIT skills. Tool-specific identity lives in
`~/.grok/config.toml` (Grok), `~/.claude/CLAUDE.md` (Claude Code), `~/.pi/agent/settings.json` (Pi).

Pipelines and skill index stay on disk: `~/.agents/dispatcher.yaml` and
`~/.agents/.skills_manifest.json`. Open those files when needed; do not treat this
document as a copy of either.

## Owner

Principal TPM & Solutions Architect. Escalate risk, needs, and value.
Products: All things Kubernetes, AI in Kubernetes, NGINX Ingress Controller, NGINX Gateway Fabric
Domains: AI security, Kubernetes (Gateway API, inference, CKA/CKAD/Kubestronaut certs), multi-cloud sovereignty, gen-AI/agents.
POC-first: working code before slides. Docs come from prototypes.
Python 3.12+, Pydantic v2, Gateway API v1.1+ (`InferencePool`, `InferenceModel`, evolving Kubernetes KEP and GEP).
Local K8s: vcluster → k3d → kind → Docker Compose. GitOps (FluxCD / ArgoCD)

## 1. Judgment Boundaries

### NEVER
- Delete files, directories, or git branches, or run `rm -rf`, `git reset --hard`,
  `git push --force`, `kubectl delete`, `terraform destroy` without explicit confirmation.
- Commit, stage, or push without a successful workspace linter/test run.
- Install deprecated libraries.
- Overwrite configuration outside the current operational scope.

### ASK
- Refactors across multiple files/services, network/security policy, cluster state,
  authn/authz, data/schema migration, breaking APIs.
- Instructions that conflict with existing workspace config or schemas.
- Architectural decisions: propose with rationale, wait for confirmation.

### ALWAYS
- Run the workspace linter and tests before calling a coding task complete.
- Render structure, sequence, and workflow as Mermaid in markdown fences.
- Put ADRs and technical docs in project `docs/` as Markdown.
- For a complex workflow, grep `~/.agents/.skills_manifest.json` and load at most
  one primary skill plus two secondary skills.
- Locate code with grep/regex before opening a file. Read more than 150 lines only
  when a full logic flow is required.

## 2. Universal Toolchain

`~/.agents/references/universal-toolchain.md`

## 3. Documentation

`~/.agents/references/documentation.md`

## 4. Deployment & Operations

Test locally before proposing to engineering. Treat live cluster state as read-only
for diagnostics; mutate via FluxCD.

## 5. Skill System (`~/.agents/`)

JIT only. Never preload skill bodies. Never crawl a project `./skills/` tree.

1. Match `~/.agents/dispatcher.yaml` (project copy first, then global). On a hit,
   load skills in that sequence and compress each step to YAML (status, changes, errors).
2. Otherwise grep `~/.agents/.skills_manifest.json`, then read only
   `~/.agents/skills/<name>/SKILL.md`.
3. Max 1 primary + 2 secondary per tree. Retry a weak skill once or twice, then ask.
4. Templates (`~/.agents/templates/`) only when generating an artifact.
5. Project `AGENTS.md` overrides this file.

Pipelines (open `~/.agents/dispatcher.yaml` for the sequence):
`cluster-lifecycle`, `ai-gateway-deployment`, `agentic-routing-poc`,
`cluster-troubleshooting`, `product-definition`.

Recommend a new skill when the job is repeatable and no existing skill fits.
Validate with `python3 ~/.agents/validate-skills.py --strict` when editing skills
or the dispatcher.

## 6. Reasoning

`~/.agents/references/reasoning.md`

## 7. Git & Collaboration

`~/.agents/references/git-collab.md`
Conventional commits (`feat:`, `fix:`, `docs:`, `chore:`, `test:`). Feature branches;
never commit straight to `main`/`master`.

## 8. IP & Publishing

Internal work in private git. Personal: posts and competitive/technical analysis.
Competitive research is in scope.

## 9. Child workspaces

A repo `AGENTS.md` may inherit:

```markdown
This project inherits from ~/.agents/:
- Judgment: ~/.agents/AGENTS.md
- Skills: ~/.agents/skills/
- Pipelines: ~/.agents/dispatcher.yaml
Local overrides: [none, or list]
```

Load the project file first, then this file.

## Communication Style

Formal or casual as the audience requires. Clear, concise prose; explain jargon.
Lead with the answer or executive summary, then detail.
No emojis, icons, or decorative symbols unless the user asks for them in an artifact.

## References

- Skills / manifest: `~/.agents/skills/`, `~/.agents/.skills_manifest.json`
- Dispatcher: `~/.agents/dispatcher.yaml`
- Rules / usage: `~/.agents/RULES.md`, `~/.agents/USAGE.md`
- Templates: `~/.agents/templates/`
