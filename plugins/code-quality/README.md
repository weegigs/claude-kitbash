# Code Quality Plugin

Code quality agents and language-specific cleaning skills for writing clean, idiomatic, testable code.

## Core Philosophy

This plugin emphasizes three architectural principles:

### 1. Imperative Shell, Functional Core

Separate code into two layers:
- **Functional Core**: Pure functions with no side effects—deterministic, easily testable
- **Imperative Shell**: Thin layer handling I/O that coordinates the core

This separation is the foundation for effective testing.

### 2. Property-Based Testing Over Unit Tests

Pure functions enable property-based testing, which is far more powerful than static unit tests:
- Unit tests verify ONE specific case
- Property tests verify invariants across THOUSANDS of generated inputs
- Property tests find edge cases you'd never think to write

Libraries: `fast-check` (TypeScript), `proptest` (Rust)

### 3. Snapshot Testing for Data Structures

Catch unintended changes to complex data structures:
- Transformations, serialization formats, error shapes
- State machine transitions
- API response structures

Libraries: `vitest` (TypeScript), `insta` (Rust)

## Components

### Agent: cleaner

Expert code cleaner. Loads `@cleaner` skill for methodology and `@principles` for design standards.

```
@cleaner Review the changes in src/
```

### Command: codex-review

Request independent code review from Codex. Loads `@codex-review` skill for process.

```
/codex-review
```

### Skills: cleaner

Code cleaning methodology—process for enhancing clarity, consistency, and maintainability.

### Skills: codex-review

Independent code review process using Codex and shared quality principles.

### Skills: principles

Core design principles with do/don't examples in Rust and TypeScript:

| Principle | Description |
|-----------|-------------|
| `@architecture` | Imperative shell, functional core |
| `@illegal-states` | Make illegal states unrepresentable |
| `@single-responsibility` | One reason to change per unit |
| `@open-closed` | Open for extension, closed for modification |
| `@parse-dont-validate` | Validated types at boundaries |
| `@composition` | Prefer composition over inheritance |
| `@explicit-dependencies` | No hidden globals or implicit state |
| `@fail-fast` | Surface errors immediately with context |
| `@domain-errors` | Errors should be identifiable for action |
| `@immutability` | Const/readonly by default |
| `@no-stringly-typed` | Unions/enums over magic strings |
| `@happy-path` | Left-hand side is the happy path (Go style) |

### Skills: cleaning

Language-specific patterns loaded automatically by the agent or used standalone:

| Skill | Description |
|-------|-------------|
| `@typescript` | Pure functional TypeScript—discriminated unions, branded types, Result/Option |
| `@rust` | Core Rust idioms—ownership, newtype, error handling, trait patterns |
| `@tokio` | Async Rust—spawning, channels, select!, graceful shutdown |
| `@svelte` | Svelte 5 runes + SvelteKit 2—reactivity, load functions, form actions |

## Directory Structure

```
code-quality/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   └── cleaner.md           # Loads @cleaner and @principles
├── commands/
│   └── codex-review.md      # Loads @codex-review and @principles
├── skills/
│   ├── cleaner/
│   │   └── SKILL.md         # Cleaning methodology
│   ├── codex-review/
│   │   └── SKILL.md         # Review process
│   ├── principles/
│   │   ├── SKILL.md         # Index of design principles
│   │   ├── architecture.md
│   │   ├── illegal-states.md
│   │   ├── single-responsibility.md
│   │   ├── open-closed.md
│   │   ├── parse-dont-validate.md
│   │   ├── composition.md
│   │   ├── explicit-dependencies.md
│   │   ├── fail-fast.md
│   │   ├── domain-errors.md
│   │   ├── immutability.md
│   │   ├── no-stringly-typed.md
│   │   └── happy-path.md
│   └── cleaning/
│       ├── SKILL.md         # Language skill index
│       ├── typescript.md
│       ├── rust.md
│       ├── tokio.md
│       └── svelte.md
└── README.md
```
