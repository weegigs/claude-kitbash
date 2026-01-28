---
name: cleaning
description: Language-specific code cleaning patterns. Use alongside the code-cleaner agent or independently for language idioms.
---

# Code Cleaning Skills

Language and framework-specific patterns for writing clean, idiomatic code. **Load the appropriate skill BEFORE working on code in that language.**

## Available Skills

| Skill | Extension | Use When |
|-------|-----------|----------|
| `@typescript` | `.ts`, `.tsx` | Pure functional TypeScript - discriminated unions, branded types, composition |
| `@rust` | `.rs` | Rust idioms - ownership, Option combinators, error handling, trait patterns |
| `@tokio` | `.rs` + async | Async Rust - spawning, channels, structured concurrency |
| `@svelte` | `.svelte` | Svelte 5 runes + SvelteKit 2 - reactivity, load functions, form actions |

## Auto-Detection

Detect language from file extensions and load skills:

```
.rs          → @rust (+ @tokio if async)
.ts, .tsx    → @typescript
.svelte      → @svelte + @typescript
```

## Usage

### With code-cleaner agent

The agent identifies the language and loads relevant skills automatically:

```
@code-cleaner Review the changes in src/
```

### With code review

Load language skills to enhance review depth:

```
/codex-review  # Reviews against principles
@rust          # Load Rust idioms for deeper review
```

### Standalone

Reference skills directly for language-specific guidance:

```
How should I structure this TypeScript module? @typescript
```

## Skill Layering

When cleaning code, load in order:

1. **Quality principles** (`@principles`) — Universal design rules
2. **Language skill** (`@rust`, `@typescript`) — Language-specific idioms
3. **Framework skill** (`@tokio`, `@svelte`) — Runtime-specific patterns

Each layer adds more specific patterns on top of general principles.
