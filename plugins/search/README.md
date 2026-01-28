# Search Plugin

Search and research enhancement skills with progressive enhancement and date validation guards.

## Version

**v1.1.0**

## Core Philosophy

### Progressive Enhancement

Start simple, escalate based on results—not assumptions about complexity:

| Level | Tools | Trigger |
|-------|-------|---------|
| 1 | WebSearch | Insufficient results |
| 2 | + Context7/Perplexity | Need docs or synthesis |
| 3 | + Explore agents | Multi-faceted question |
| 4 | + User checkpoints | High-stakes decision |

80% of research completes at Level 1-2. Level 3+ requires user consent.

### Date Guard

All searches are validated against current date. Queries containing years older than the current year are blocked to prevent stale results.

**Opt-out**: Add "historical" to your query for intentional past data lookups.

## Skills

| Skill | Purpose |
|-------|---------|
| `search:` | Main skill with tool selection guide |
| `search:patterns` | Canonical reference for query construction and escalation |
| `search:deep-research` | Multi-step investigation workflow |
| `search:verify` | Source verification and fact-checking |
| `search:plan` | Research planning before execution |
| `search:context7` | Library documentation patterns |
| `search:perplexity` | Deep research with synthesis |

## Tool Selection

Match tool to need:

| Need | Tool | Strength |
|------|------|----------|
| Quick facts | WebSearch | Fast, always available |
| Library docs | Context7 | Current APIs, version-specific |
| Code examples | Context7 | Framework patterns, official usage |
| Deep research | Perplexity | Synthesis with citations |
| Parallel investigation | Explore agents | Multi-threaded research |

## MCP Dependencies

Optional MCP servers enhance capabilities:

```
# Context7 (library documentation)
mcp__context7__resolve-library-id
mcp__context7__get-library-docs

# Perplexity (deep research)
mcp__perplexity__perplexity_ask
mcp__perplexity__perplexity_reason
```

Falls back to WebSearch when MCP tools unavailable.

## Hooks

### Date Guard Hook

Validates search queries to prevent stale results:
- Blocks queries containing years older than current year
- Opt-out with "historical" keyword for intentional past lookups

## Directory Structure

```
search/
├── .claude-plugin/
│   └── plugin.json
├── hooks/
│   ├── hooks.json
│   └── date-guard.sh
├── skills/
│   └── search/
│       ├── SKILL.md           # Main skill
│       ├── patterns.md        # Query patterns, escalation model
│       ├── deep-research.md   # Multi-step investigation
│       ├── verify.md          # Source verification
│       ├── plan.md            # Research planning
│       ├── context7.md        # Library docs patterns
│       └── perplexity.md      # Deep research patterns
├── CHANGELOG.md
└── README.md
```
