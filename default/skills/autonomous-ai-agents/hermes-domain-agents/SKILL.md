---
name: hermes-domain-agents
description: "Provision isolated domain-specific Hermes agents via profiles: decision framework, setup workflow, SOUL.md templating, and config cloning."
version: 1.0.0
author: Hermes Agent
license: MIT
tags: [hermes, profiles, multi-agent, domain-isolation, setup]
---

# Hermes Domain Agents

Set up isolated Hermes agents for specific domains (trading, research, content, etc.) using **Profiles**. Each profile has its own config, skills, memory, plugins, sessions, and SOUL.md — completely independent from other profiles.

## When to Use Profiles

| Need | Solution |
|------|----------|
| Different domains (trading, writing, devops) | **Profile** — full isolation |
| Same domain, different personas | **Profile** with different SOUL.md |
| Same agent, project-specific rules | `.hermes.md` or `AGENTS.md` in project root |
| Parallel subtasks in one session | `delegate_task` |
| Long autonomous missions | Spawn `hermes` process via tmux |
| Scheduled recurring work | `cronjob` tool |

**Rule of thumb:** if the user says "I want a separate agent for X that doesn't interfere with Y", the answer is almost always **Profiles**.

## Setup Workflow

### Step 1: Create the profile
```bash
hermes profile create <name>
# Creates ~/.hermes/profiles/<name>/ with bundled skills synced
# Also creates a wrapper script at ~/.local/bin/<name>
```

### Step 2: Copy model config
New profiles have no `config.yaml` — they inherit from the shell environment. To match an existing agent's model settings, copy the relevant section:

```bash
# Read the source config
cat ~/.hermes/config.yaml  # or ~/.hermes/profiles/<source>/config.yaml

# Write a minimal config to the new profile
# Include: model, terminal, memory, agent, compression, display sections
# Skip: platform-specific sections (telegram, discord, plugins) unless needed
```

**Key config fields to copy:**
- `model.default`, `model.provider`, `model.base_url`, `model.api_key`, `model.api_mode`
- `agent.max_turns`, `agent.reasoning_effort`
- `compression.*` (same threshold behavior)
- `memory.*` (same memory settings)

**Fields to customize per domain:**
- `agent.reasoning_effort` — increase for analytical domains (trading, research)
- `approvals.mode` — may need `smart` for financial operations
- `agent.max_turns` — complex analysis may need more turns

### Step 3: Write SOUL.md
The SOUL.md defines the agent's identity and behavioral constraints. It's loaded every session independently of project context files.

```bash
# Write to: ~/.hermes/profiles/<name>/SOUL.md
```

See `templates/soul-templates.md` for domain-specific SOUL.md examples.

### Step 4: Copy relevant skills
```bash
# List available skills in source profile
hermes skills list  # or: hermes --profile <source> skills list

# Copy specific skills (directories)
cp -r ~/.hermes/skills/<skill-name> ~/.hermes/profiles/<name>/skills/

# Or copy all
cp -r ~/.hermes/skills/* ~/.hermes/profiles/<name>/skills/
```

### Step 5: Verify
```bash
hermes --profile <name> doctor
# Or use the wrapper:
<name> doctor
```

## Usage Patterns

```bash
# Launch with wrapper script (creates shell alias automatically)
<profile-name>

# Or via hermes CLI
hermes --profile <name>
hermes -p <name> chat -q "quick query"

# Switch default profile
hermes profile use <name>

# Check which profile is active
hermes profile list  # ◆ marks the active default

# Temporarily use a profile without switching default
hermes -p <name>
```

## Profile Isolation

Each profile has its own:
```
~/.hermes/profiles/<name>/
├── config.yaml      # Model, agent, display settings
├── SOUL.md          # Agent identity/personality
├── .env             # Profile-specific API keys (overrides shell env)
├── skills/          # Only skills relevant to this domain
├── memories/        # Independent memory store
├── cron/            # Domain-specific scheduled jobs
├── sessions/        # Separate session history
├── plugins/         # Profile-specific plugins
├── logs/            # Isolated logs
└── workspace/       # Working directory
```

**Skills do NOT leak between profiles.** Each profile loads only its own `skills/` directory. This is the primary isolation mechanism — a trading agent's skills never pollute a content pipeline agent.

## Pitfalls

1. **New profile has no config.yaml** — it inherits from shell environment. Always write a config.yaml explicitly to avoid surprises.
2. **API keys in config.yaml vs .env** — if the same key is in both, `.env` wins for the profile. For shared keys, keep them in the global `~/.hermes/.env` and don't duplicate.
3. **Bundled skills are copied on creation** — `hermes profile create` syncs 70+ bundled skills. Remove irrelevant ones to keep the profile focused.
4. **Wrapper script `<name>` is created at `~/.local/bin/`** — make sure this is in `$PATH`.
5. **Config changes require restart** — editing a profile's `config.yaml` takes effect on next launch, not mid-session.
6. **Memory is per-profile** — memories set in one profile don't appear in another. This is by design but can confuse users who expect shared memory.
7. **Skills may not be installed locally** — when setting up a new domain agent, the required skills might only exist on ClawHub. Search `cn.clawhub-mirror.com` by keyword (names don't always match exactly). See `references/clawhub-skill-discovery.md`.

## See Also

- `references/soul-templates.md` — SOUL.md templates for common domains
- `references/config-templates.md` — config.yaml templates for different use cases
- `references/clawhub-skill-discovery.md` — searching/installing skills from ClawHub when not found locally
- `references/stock-trading-agent-architecture.md` — layered skill architecture for stock trading agents + ClawHub catalog
- `hermes-agent` skill — full CLI reference, provider list, toolset list
