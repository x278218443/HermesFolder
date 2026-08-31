# ClawHub Skill Discovery Workflow

When skills aren't found locally, use ClawHub (the community skill registry) to search and install.

## Primary Mirror (China)

**URL:** `https://cn.clawhub-mirror.com/`

This is the Chinese mirror of ClawHub with faster access from China. Full search and install support.

### Search Workflow

1. Navigate to `https://cn.clawhub-mirror.com/`
2. Click "搜索" in the top nav
3. Enter keywords — **do NOT rely on exact name matching**

### Critical: Names Don't Always Match

Users often provide skill names from memory or documentation that differ from the actual ClawHub slug. Examples:

| User says | ClawHub actual | Match type |
|-----------|---------------|------------|
| `akshare-stock` | `akshare-stock` | Exact ✅ |
| `web-search-proxy` | `proxy-web-search` | Word order swapped ⚠️ |
| `astock-report` | `astock-report` | Exact ✅ |
| `china-stock-analysis` | `china-stock-analysis` | Exact ✅ |

**Strategy:** Search by keyword first (e.g. "stock", "financial", "monitor"), then scan results for the closest match. If no exact match, search with partial names or related terms.

### Install

```bash
hermes skills install <skill-id>
# Or from the ClawHub mirror specifically:
hermes skills install https://cn.clawhub-mirror.com/skills/<skill-id>
```

## Hermes Skills Hub

**URL:** `https://hermes-agent.nousresearch.com/skills/`

The official Hermes skills hub. May have different skills than ClawHub. Currently less stable than the ClawHub mirror.

## Local Search (First)

Always search locally first before going online:

```bash
# Search by name
find ~/.hermes/skills -maxdepth 4 -name "SKILL.md" | grep -i "<keyword>"

# Search by content
grep -r "keyword" ~/.hermes/skills/ --include="*.md" -l

# Full system search
find /home -maxdepth 6 -name "SKILL.md" | xargs grep -l "keyword"
```

## Pitfalls

1. **Hermes skills search can timeout** — `hermes skills search <query>` may hang on slow connections. Fall back to browser-based ClawHub search.
2. **ClawHub has many forks/variants** — the same base skill may appear under multiple names (e.g. `china-stock-analysis` has 8+ variants). Pick the one with the most features or the original author's version.
3. **Some skills require API keys** — check `check_requirements()` and `requires_env` in the SKILL.md before installing in a production agent.
4. **Skills from ClawHub are community-contributed** — review the SKILL.md for security concerns before installing in a production agent.
