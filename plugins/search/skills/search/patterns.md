---
name: patterns
description: Search patterns and best practices. Reference for query construction, progressive enhancement model, and tool selection hierarchy.
---

# Search Patterns & Best Practices

General patterns for effective search and research.

## The Search Hierarchy

Choose tools based on need (most to least specialized):

1. **Context7** - Library/framework documentation
2. **Perplexity** - Research requiring synthesis
3. **WebSearch** - General queries, specific sites

## Query Construction

### Use Current Year
The date-guard hook blocks stale years. Always use current year for recent info:
```
# Good - no year (relies on search recency)
"Svelte 5 runes patterns"

# Good - current year (run `date +%Y` if unsure)
"Tauri v2 plugin development <current-year>"

# Blocked (unless historical)
"Svelte 4 stores 2023"

# Allowed with opt-out
"historical: JavaScript framework evolution"
```

### Be Specific
```
# Vague (poor results)
"typescript async"

# Specific (good results)
"typescript async await error handling try catch patterns"
```

### Use Site Operators
```
# Official documentation
"site:svelte.dev runes state management"

# Specific platforms
"site:github.com tauri plugin template"
```

## Research Workflows

### Quick Lookup
```
WebSearch("exact thing I need")
```

### Library Documentation
```
1. Context7: resolve-library-id("library-name")
2. Context7: get-library-docs(id, topic="specific feature")
```

### Deep Research
```
1. Perplexity: perplexity_ask("broad question")
2. Review citations
3. Follow up with specific queries
4. Context7 for implementation details
```

### Comparative Analysis
```
1. Perplexity: perplexity_reason("compare X vs Y for use case Z")
2. WebSearch for specific benchmarks/examples
3. Context7 for API differences
```

## Anti-Patterns

### Don't
- Use old years in queries (blocked by date-guard)
- Make vague single-word searches
- Ignore available specialized tools
- Skip citation verification for critical info

### Do
- Specify current year for recent information
- Use complete, specific queries
- Match tool to task (Context7 for docs, Perplexity for research)
- Combine tools for comprehensive answers

## Error Recovery

### "MCP tool not available"
Fall back in order:
1. Try alternative MCP tool
2. Use WebSearch with targeted query
3. Note limitation in response

### "Date guard blocked"
1. Update query with current year
2. Or add "historical" for intentional past lookups

### "No results found"
1. Broaden query terms
2. Try different tool
3. Rephrase question

## Progressive Enhancement

**Canonical reference** — other skills reference this section.

Don't over-engineer simple searches. Start light, escalate based on *results*, not assumptions.

### The Four Levels

| Level | Approach | Tools | Typical Use |
|-------|----------|-------|-------------|
| 1 | Quick lookup | WebSearch | Simple facts, URLs, current events |
| 2 | Standard | + Context7 or Perplexity | Library docs, synthesis needed |
| 3 | Deep | + Parallel Explore agents | Multi-faceted, comparative analysis |
| 4 | Exhaustive | + User checkpoints | Critical decisions, high stakes |

**Reality check**: 80% of research completes at Level 1-2. Level 3+ is rare and requires user consent.

### Escalation Triggers

Escalate when current level produces:

| Signal | Action |
|--------|--------|
| Insufficient results | Try different tool at same level |
| Conflicting information | Add `search:verify` step |
| Need current API docs | Add Context7 |
| Need synthesis/comparison | Add Perplexity |
| Multi-faceted question | Escalate to Level 3 (with approval) |

### User Approval Points

**Ask before:**
- Spawning 2+ parallel research agents
- Shifting from quick lookup to deep research
- Major scope expansion beyond original question

**Don't ask for:**
- Standard tool fallbacks (WebSearch → Perplexity)
- Single additional search to fill gaps
- Routine verification of critical claims

### Anti-Pattern: Premature Escalation

```python
# BAD: Jumping straight to Level 3
user_asks("What's the Svelte 5 syntax for state?")
# Agent spawns 3 parallel research threads ❌

# GOOD: Start at Level 1, escalate if needed
WebSearch("Svelte 5 state syntax runes")  # Level 1
# If insufficient → Context7 for docs      # Level 2
# If conflicting → verify + ask user       # Escalation decision
```

### Decision Flowchart

```
Start → WebSearch
         ↓
    Sufficient? → Yes → Done
         ↓ No
    Need docs? → Context7
    Need synthesis? → Perplexity
         ↓
    Still insufficient?
         ↓
    Multi-faceted? → Ask user → Parallel agents (Level 3)
         ↓
    Critical decision? → Add checkpoints (Level 4)
```

## Related Skills

| Skill | Use For |
|-------|---------|
| `search:plan` | Structure complex research before starting |
| `search:deep-research` | Multi-step investigation workflow |
| `search:verify` | Validate critical claims |
| `search:context7` | Library documentation patterns |
| `search:perplexity` | Synthesis and reasoning tasks |
