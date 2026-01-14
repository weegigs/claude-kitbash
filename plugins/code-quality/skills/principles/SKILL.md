---
name: principles
description: Core code quality principles. Reference from code reviews, cleaning agents, and workflow checks.
---

# Code Quality Principles

These principles guide all code review and quality assessment. Each principle has detailed examples in both Rust and TypeScript.

## Architecture

| Principle | Description |
|-----------|-------------|
| `@architecture` | Imperative shell, functional core—separate pure logic from I/O |

## Design Principles

| Principle | Description |
|-----------|-------------|
| `@illegal-states` | Make illegal states unrepresentable via type design |
| `@single-responsibility` | One reason to change per unit |
| `@parse-dont-validate` | Validated types at boundaries |
| `@composition` | Prefer composition over inheritance |
| `@open-closed` | Open for extension, closed for modification |
| `@explicit-dependencies` | No hidden globals or implicit state |
| `@fail-fast` | Surface errors immediately with context |
| `@domain-errors` | Errors should be identifiable to allow action |
| `@immutability` | Const/readonly by default |
| `@no-stringly-typed` | Unions/enums over magic strings |
| `@happy-path` | Left-hand side is the happy path (Go style early returns) |

## Code-Level Standards

- **Clarity over brevity**: Explicit, readable code over clever one-liners
- **Reduce nesting**: Use early returns to flatten conditionals
- **Eliminate redundancy**: Remove duplicate logic and dead code
- **No workarounds**: Fix root causes, never suppress lints without explicit approval

## Testing Strategy

1. **Property-based testing** for pure functions—verify invariants across thousands of inputs
2. **Snapshot testing** for complex data structures—catch unintended changes
3. **Integration tests** for the imperative shell—verify I/O coordination

## Review Checklist

When reviewing code, verify:

- [ ] Types prevent invalid states (no interacting boolean flags)
- [ ] Functions have single responsibility
- [ ] Validation happens at boundaries, not scattered throughout
- [ ] Dependencies are explicit (no hidden globals)
- [ ] Errors surface immediately with context
- [ ] Mutations are justified and isolated
- [ ] No magic strings where types would work
- [ ] No lint suppressions without explicit approval
