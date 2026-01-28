# Context7: Library Documentation

Context7 provides up-to-date, version-specific documentation directly from library sources.

## Why Context7?

LLM training data becomes stale. When working with Svelte 5, Tauri v2, or any evolving library, you get:
- Hallucinated APIs that don't exist
- Deprecated patterns from old versions
- Missing features added after training cutoff

Context7 fetches **current official documentation** at query time.

## Availability Check

```
# Required tools
mcp__context7__resolve-library-id
mcp__context7__get-library-docs
```

## Usage Patterns

### Pattern 1: Direct Invocation
Add "use context7" to prompts:
```
use context7 to show me FastAPI authentication patterns
```

### Pattern 2: Two-Step Lookup
1. Resolve library ID:
```
resolve-library-id("sveltekit")
→ Returns: context7-id for SvelteKit
```

2. Fetch documentation:
```
get-library-docs(id, topic="app router", tokens=8000)
```

### Pattern 3: Version-Specific
```
get-library-docs(id, topic="form actions sveltekit")
```

## Best Practices

1. **Be specific with topics** - "svelte runes state derivation" not just "svelte"
2. **Request adequate tokens** - Complex topics need 5000-10000 tokens
3. **Combine with WebSearch** - Context7 for APIs, WebSearch for tutorials
4. **Check freshness** - Documentation includes version info

## Common Libraries

| Library | Good Topics |
|---------|-------------|
| Svelte | runes, stores, transitions, actions |
| SvelteKit | routing, form actions, hooks, load functions |
| TypeScript | utility types, generics, decorators |
| Tailwind | configuration, plugins, dark mode |
| Prisma | schema, queries, migrations |

## Fallback

If Context7 unavailable:
1. Use WebSearch with `site:` operator for official docs
2. Target specific version in query: "SvelteKit 2 routing"
3. Prefer official documentation domains
