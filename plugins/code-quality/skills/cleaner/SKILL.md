---
name: cleaner
description: Code cleaning methodology. Enhance clarity, consistency, and maintainability while preserving functionality.
---

# Code Cleaning

Expert methodology for enhancing code clarity, consistency, and maintainability while preserving exact functionality.

## Core Mandate

**Preserve Functionality**: Never change what the code does—only how it expresses it. All original features, outputs, and behaviors must remain intact.

## Quality Principles

Load `@principles` for the complete set of design principles. Key principles to apply:

1. **Make Illegal States Unrepresentable** — discriminated unions over boolean flags
2. **Single Responsibility** — one reason to change per unit
3. **Open-Closed** — open for extension, closed for modification
4. **Parse, Don't Validate** — validated types at boundaries
5. **Prefer Composition Over Inheritance** — combine simple pieces
6. **Make Dependencies Explicit** — no hidden globals
7. **Fail Fast and Loudly** — surface errors immediately
8. **Domain Errors** — errors should be identifiable for action
9. **Prefer Immutability** — const/readonly by default
10. **Avoid Stringly-Typed Code** — unions/enums over magic strings
11. **Happy Path Left** — early returns, reduce nesting

## Code-Level Refinements

Beyond macro principles, apply these refinements:

### Clarity Over Brevity

```typescript
// ❌ Clever but obscure
const r = d > 0 ? (a > b ? a : b) : c;

// ✅ Clear intent
function selectResult(delta: number, a: number, b: number, c: number): number {
  if (delta <= 0) return c;
  return a > b ? a : b;
}
```

### Reduce Nesting

```typescript
// ❌ Deep nesting
function process(x) {
  if (x) {
    if (x.valid) {
      if (x.ready) {
        return doWork(x);
      }
    }
  }
  return null;
}

// ✅ Early returns
function process(x) {
  if (!x) return null;
  if (!x.valid) return null;
  if (!x.ready) return null;
  return doWork(x);
}
```

### Eliminate Redundancy

Remove duplicate logic, dead code, and unnecessary abstractions. But preserve helpful abstractions that improve organization.

## Refinement Process

1. **Identify** recently modified code sections
2. **Analyze** for macro-level principle violations
3. **Apply** refinements prioritizing high-impact changes
4. **Verify** all functionality remains unchanged
5. **Document** only significant changes that affect understanding

## Scope

Focus on recently modified code unless explicitly instructed to review a broader scope.

## Balance

Avoid over-cleaning that could:

- Reduce clarity or maintainability
- Create overly clever solutions
- Combine too many concerns
- Remove helpful abstractions
- Prioritize "fewer lines" over readability
- Make code harder to debug or extend

## Language-Specific Skills

When cleaning code, identify the language and apply the appropriate skill:

| Language/Framework | Skill | Focus |
|-------------------|-------|-------|
| TypeScript | `@typescript` | Discriminated unions, branded types, Result/Option, composition |
| Rust | `@rust` | Ownership, borrowing, error handling, trait patterns |
| Rust + Tokio | `@tokio` | Async patterns, channels, select!, graceful shutdown |
| Svelte 5 / SvelteKit | `@svelte` | Runes ($state, $derived, $effect), load functions, form actions |

### Skill Selection Process

1. **Identify primary language** from file extension and content
2. **Detect framework/runtime** (Tokio for async Rust, SvelteKit for .svelte files)
3. **Load relevant skills** - language first, then framework
4. **Apply idioms** - language-specific patterns on top of macro principles
