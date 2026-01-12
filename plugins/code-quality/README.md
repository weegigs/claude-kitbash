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

### Agent: code-cleaner

Expert code cleaner that applies macro-level design principles:

- Make illegal states unrepresentable
- Single responsibility principle
- Parse, don't validate
- Prefer composition over inheritance
- Make dependencies explicit
- Fail fast and loudly
- Prefer immutability

```
@code-cleaner Review the changes in src/
```

### Skills: cleaning

Language-specific patterns loaded automatically by the agent or used standalone:

| Skill | Description |
|-------|-------------|
| `typescript` | Pure functional TypeScript—discriminated unions, branded types, Result/Option, iterator helpers |
| `rust` | Core Rust idioms—ownership, newtype, error handling, trait patterns |
| `tokio` | Async Rust—spawning, channels, select!, graceful shutdown |
| `svelte` | Svelte 5 runes + SvelteKit 2—reactivity, load functions, form actions |

#### Standalone Usage

```
How should I structure this TypeScript module? @typescript
```

```
What's the idiomatic way to handle this error in Rust? @rust
```

## Directory Structure

```
code-quality/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   └── code-cleaner.md
├── skills/
│   └── cleaning/
│       ├── SKILL.md
│       ├── typescript.md
│       ├── rust.md
│       ├── tokio.md
│       └── svelte.md
└── README.md
```
