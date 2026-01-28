# Search & Research Skills

Enhance search and research workflows with specialized tools and patterns.

## Tool Selection Guide

Match tool to need (see `search:patterns` for detailed hierarchy):

| Need | Tool | Strength |
|------|------|----------|
| Quick facts | WebSearch | Fast, always available |
| Library docs | Context7 | Current APIs, version-specific |
| Code examples | Context7 | Framework patterns, official usage |
| Deep research | Perplexity | Synthesis with citations |
| Parallel investigation | Explore agents | Multi-threaded research |

## MCP Availability Check

Before using MCP-dependent features, verify availability:

```
# Context7 tools
mcp__context7__resolve-library-id
mcp__context7__get-library-docs

# Perplexity tools
mcp__perplexity__perplexity_ask
mcp__perplexity__perplexity_reason
```

If tools are unavailable, fall back to WebSearch with targeted queries.

## Date Guard

All searches are validated against current date. Queries containing years older than the current year are blocked to prevent stale results.

**Opt-out**: Add "historical" to your query for intentional past data lookups.

## Progressive Enhancement

Start simple, escalate based on results (see `search:patterns` for full model):

| Level | Tools | Trigger to Escalate |
|-------|-------|---------------------|
| 1 | WebSearch | Insufficient results |
| 2 | + Context7/Perplexity | Need docs or synthesis |
| 3 | + Explore agents | Multi-faceted question |
| 4 | + User checkpoints | High-stakes decision |

**Key principle**: Escalation is reactive (based on results), not predictive. User approval required before Level 3+.

## Sub-Skills

- `search:context7` - Library documentation patterns
- `search:perplexity` - Deep research workflows
- `search:patterns` - General search best practices
- `search:deep-research` - Multi-step investigation workflow
- `search:verify` - Source verification and fact-checking
- `search:plan` - Research planning before execution
