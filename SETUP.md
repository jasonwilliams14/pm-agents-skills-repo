# SETUP.md — Global Setup & Architecture

This document explains the symlink architecture that powers your global agent configuration system.

---

## Directory Structure

```
~/.agents/                          # Global agent skill system
├── CLAUDE.md                       # Master config (owner context, standards)
├── AGENTS.md                       # Judgment boundaries, toolchain, skill rules
├── SETUP.md                        # This file (architecture documentation)
├── USAGE.md                        # Quick-start skill lookup
├── dispatcher.yaml                 # Global dispatcher pipelines
├── skills/                         # Skill library (32+ specialized skills)
├── templates/                      # ADR, design doc, PRD templates
├── docs/                           # Internal documentation
└── memory/                         # Session memory (auto-populated)

~/.claude/                          # Claude Code config (symlinked)
└── CLAUDE.md → ../../.agents/CLAUDE.md  # Single source of truth ✓

project-repos/                      # Your working projects
└── */
    └── AGENTS.md                   # Local overrides (points to ~/.agents)
```

---

## Single Source of Truth: The Symlink

### The Pattern

```bash
# ~/.claude/CLAUDE.md is a symlink to ~/.agents/CLAUDE.md
ls -la ~/.claude/CLAUDE.md
# lrwxr-xr-x  1 ja.williams  staff  20 Jun 26 15:06 ~/.claude/CLAUDE.md -> ../.agents/CLAUDE.md
```

**Why this works:**
- Claude Code looks for `CLAUDE.md` in `~/.claude/` (default location)
- The symlink transparently redirects reads to `~/.agents/CLAUDE.md`
- You edit one file, all projects read the same config
- Changes take effect immediately (no rebuild, no cache)

### How It's Loaded

1. **Claude Code session starts** → reads `~/.claude/CLAUDE.md`
2. **Symlink is followed** → actually reads `~/.agents/CLAUDE.md`
3. **Config loads** → owner context, standards, toolchain, philosophy
4. **All projects inherit** → consistent across all repos

---

## Configuration Hierarchy

### Layer 1: Global Defaults (Master)
**File:** `~/.agents/CLAUDE.md`
- Owner context (Jason Williams, role, products, domains)
- Technical standards (Python 3.12+, K8s, OTEL, Git, etc.)
- Work patterns, philosophy, guardrails
- **Single source of truth** — edit here, everywhere reads it

**File:** `~/.agents/AGENTS.md`
- Judgment boundaries (NEVER, ASK, ALWAYS)
- Universal toolchain (languages, frameworks, infra)
- Documentation and communication standards
- Deployment & operations patterns
- Skill system rules and dispatcher pipelines

### Layer 2: Project Overrides (Local)
**File:** `project-repo/AGENTS.md` (when needed)
- Project-specific judgment boundaries or toolchain exceptions
- Points back to `~/.agents/` for defaults
- Loads *before* global config (local takes precedence)

```markdown
# Example project/AGENTS.md

# Project-specific overrides
This project overrides:
- Python version: 3.11 (legacy constraint)
- Inference: Use Model X instead of Y

For all other standards, see: ~/.agents/AGENTS.md
```

### Layer 3: Runtime Context
**File:** `~/.agents/dispatcher.yaml`
- Maps task intent to dispatcher pipelines
- Pipelines chain skills together for complex workflows
- Loaded at runtime when a task matches

---

## Maintenance & Editing

### When to Edit What

| File | When to Edit | Impact |
|------|-------------|--------|
| `~/.agents/CLAUDE.md` | Standards change, new role/product, philosophy shifts | **Global** — all projects immediately affected |
| `~/.agents/AGENTS.md` | Judgment boundaries, toolchain defaults change | **Global** — all projects immediately affected |
| `project/AGENTS.md` | Project-specific exceptions only | **Local** — only affects that project |
| `~/.agents/dispatcher.yaml` | New pipeline workflows | **Global** — new skill orchestrations available |

### Verification

After editing `~/.agents/CLAUDE.md` or `~/.agents/AGENTS.md`:

```bash
# Ensure symlink is still valid
ls -la ~/.claude/CLAUDE.md
# Should show: lrwxr-xr-x ... ~/.claude/CLAUDE.md -> ../.agents/CLAUDE.md

# Test that Claude Code reads it
# (Just start a session — if config loads, you're good)
```

---

## Symlink Integrity

### Verify the Symlink

```bash
# Check it exists and points correctly
file ~/.claude/CLAUDE.md
# Should output: ~/.claude/CLAUDE.md: symbolic link to ../.agents/CLAUDE.md

# Verify the target exists
test -L ~/.claude/CLAUDE.md && echo "Symlink exists" || echo "Broken"

# Read through the symlink
cat ~/.claude/CLAUDE.md | head -5
# Should output the top of ~/.agents/CLAUDE.md
```

### If Symlink Breaks

```bash
# Recreate it
rm ~/.claude/CLAUDE.md
ln -s ../.agents/CLAUDE.md ~/.claude/CLAUDE.md
ls -la ~/.claude/CLAUDE.md  # Verify it's created
```

---

## Context Loading Order

When Claude starts work on a project:

1. **Project context first** — reads `project-repo/AGENTS.md` (if exists)
2. **Global context** — reads `~/.agents/AGENTS.md` (via symlink: `~/.claude/CLAUDE.md` → `~/.agents/CLAUDE.md`)
3. **Dispatcher pipelines** — loads `project-repo/dispatcher.yaml` (if exists), then `~/.agents/dispatcher.yaml`
4. **Skills** — loads from `~/.agents/skills/` (indexed by dispatcher match)

---

## Quick Checklist

- [ ] `~/.agents/CLAUDE.md` exists and is version-controlled in `~/.agents/.git`
- [ ] `~/.claude/CLAUDE.md` is a symlink to `../.agents/CLAUDE.md`
- [ ] Each project repo has an `AGENTS.md` that references `~/.agents/` for defaults
- [ ] `~/.agents/dispatcher.yaml` is up-to-date with active skill pipelines
- [ ] `~/.agents/skills/` contains your 32+ specialized skills

---

## Related Files

- **CLAUDE.md** — Owner context, philosophy, technical standards (symlinked from ~/.agents/)
- **AGENTS.md** — Judgment boundaries, toolchain, skill system rules
- **USAGE.md** — Quick-start skill lookup and dispatcher guide
- **dispatcher.yaml** — Skill pipeline definitions
- **RULES.md** — Execution rules for skills
- **SKILL_MAINTENANCE.md** — Versioning, deprecation, skill lifecycle
