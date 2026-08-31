# Config Templates for Domain-Specific Profiles

Copy the relevant section into `~/.hermes/profiles/<name>/config.yaml`. Always include the `model` section — a new profile without config.yaml inherits from shell env, which may not have the right API keys.

---

## Minimal Config (reuse default model)

```yaml
model:
  default: mimo-v2.5
  provider: xiaomicoding
  base_url: https://token-plan-cn.xiaomimimo.com/v1
  api_key: <YOUR_API_KEY>
  api_mode: chat_completions

terminal:
  backend: local
  cwd: .
  timeout: 180

memory:
  memory_enabled: true
  user_profile_enabled: true
  memory_char_limit: 2200
  user_char_limit: 1375

agent:
  max_turns: 60
  verbose: false
  reasoning_effort: medium

compression:
  enabled: true
  threshold: 0.5
  target_ratio: 0.2

approvals:
  mode: 'off'

display:
  compact: false
  tool_progress: all
  streaming: true
  skin: default
```

---

## Analytical Domain (Trading, Research) — Higher reasoning

Same as minimal, but with:
```yaml
agent:
  max_turns: 80          # More turns for complex analysis
  reasoning_effort: high  # Deeper reasoning
```

---

## Content Domain (Writing, Video) — Balanced

Same as minimal, but consider:
```yaml
agent:
  max_turns: 40          # Fewer turns needed
  reasoning_effort: medium

display:
  show_reasoning: true    # Show thinking process for creative work
```

---

## Key Config Differences by Domain

| Setting | Trading/Research | Content | DevOps |
|---------|-----------------|---------|--------|
| `reasoning_effort` | `high` | `medium` | `medium` |
| `max_turns` | 60-80 | 30-50 | 40-60 |
| `approvals.mode` | `smart` | `off` | `smart` |
| `compression.threshold` | 0.5 (default) | 0.6 (compress less) | 0.5 |

---

## Sharing API Keys Across Profiles

If multiple profiles use the same API key, keep it in the global `~/.hermes/.env`:

```bash
# ~/.hermes/.env
XIAOMI_API_KEY=your-key-here
```

Then in each profile's `config.yaml`, reference the provider without duplicating the key. Profiles inherit `.env` from the global location unless they have their own `.env`.
