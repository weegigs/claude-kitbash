---
name: cleaning
description: Language-specific code cleaning patterns. Use alongside the code-cleaner agent or independently for language idioms.
---

# Code Cleaning Skills

Language and framework-specific patterns for writing clean, idiomatic code.

## Available Skills

| Skill | Use When |
|-------|----------|
| `typescript` | Pure functional TypeScript - discriminated unions, branded types, composition |
| `rust` | Rust idioms - ownership, error handling, trait patterns |
| `tokio` | Async Rust - spawning, channels, structured concurrency |
| `svelte` | Svelte 5 runes + SvelteKit 2 - reactivity, load functions, form actions |

## Usage

### With code-cleaner agent

The agent automatically identifies the language and applies relevant skills:

```
@code-cleaner Review the changes in src/
```

### Standalone

Reference skills directly for language-specific guidance:

```
How should I structure this TypeScript module? @typescript
```

## Skill Selection

When cleaning code, identify:

1. **Primary language** → Load base skill (typescript, rust)
2. **Framework/runtime** → Load additional skill (tokio, svelte)
3. **Apply in order** → Language basics first, then framework patterns
