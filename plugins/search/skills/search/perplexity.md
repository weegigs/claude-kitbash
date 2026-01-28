# Perplexity: Deep Research

Perplexity provides synthesized answers with citations through multi-step web research.

## Why Perplexity?

Unlike simple web search, Perplexity:
- Performs **multi-step research** autonomously
- **Synthesizes** information from multiple sources
- Provides **cited sources** for verification
- Uses **reasoning** for complex questions

## Availability Check

```
# Required tools
mcp__perplexity__perplexity_ask     # Research queries
mcp__perplexity__perplexity_reason  # Complex reasoning
```

## Tool Selection

| Tool | Use Case |
|------|----------|
| `perplexity_ask` | Factual research, current events, comparisons |
| `perplexity_reason` | Complex analysis, multi-step problems, synthesis |

## Usage Patterns

### Pattern 1: Research Query
```
perplexity_ask({
  messages: [{
    role: "user",
    content: "Compare authentication strategies for SvelteKit apps"
  }]
})
```

### Pattern 2: Reasoning Task
```
perplexity_reason({
  messages: [{
    role: "user",
    content: "Analyze tradeoffs between Prisma and Drizzle for a high-write workload"
  }]
})
```

### Pattern 3: Conversational Follow-up
```
perplexity_ask({
  messages: [
    { role: "user", content: "What is the Tauri framework?" },
    { role: "assistant", content: "..." },
    { role: "user", content: "How does it compare to Electron for desktop apps?" }
  ]
})
```

## Best Practices

1. **Ask complete questions** - Perplexity works best with full context
2. **Use reasoning for analysis** - `perplexity_reason` for comparisons/tradeoffs
3. **Verify citations** - Check sources for critical information
4. **Combine with Context7** - Perplexity for concepts, Context7 for APIs

## When to Use Perplexity vs WebSearch

| Scenario | Tool |
|----------|------|
| "What is X?" | Either works |
| "Compare X vs Y" | Perplexity (reason) |
| "Current status of X" | Perplexity (ask) |
| "Quick fact lookup" | WebSearch |
| "Find specific page" | WebSearch |
| "Synthesize research" | Perplexity |

## Fallback

If Perplexity unavailable:
1. Use multiple WebSearch queries
2. Manually synthesize results
3. Note lack of citation verification
