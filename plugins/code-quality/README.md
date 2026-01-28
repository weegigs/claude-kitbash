# Code Quality Plugin

Code quality agents, skills, and Codex-powered reviews for writing clean, idiomatic, testable code.

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

### Agents

All agents automatically detect language from target files and load appropriate skills before working.

| Agent | Purpose | Auto-loads |
|-------|---------|------------|
| `@cleaner` | Clean up code for clarity and maintainability | `@cleaner`, `@principles`, language skill |
| `@implementer` | Implement finite-scope tasks with quality standards | `@principles`, language skill |
| `@addresser` | Fix issues identified by reviewers | `@principles`, language skill |
| `@reviewer` | Review code with language-aware pattern checking | `@principles`, language skill |

```
@cleaner Review the changes in src/
@implementer Implement the user validation function
@reviewer Review the changes in src/lib.rs
```

### Skills

| Skill | Purpose |
|-------|---------|
| `@codex` | Neutral Codex CLI base—jj-native patterns, output handling |
| `@codex-review` | Code review via Codex with multi-agent support |
| `@codex-spec-review` | Spec review via Codex with multi-agent support |
| `@cleaner` | Code cleaning methodology |
| `@coding-context` | Detect languages and inject appropriate skills before implementation |
| `@principles` | 12 design principles with Rust/TypeScript examples |
| `@cleaning` | Language-specific patterns (TypeScript, Rust, Tokio, Svelte) |

### Coding Context (`/coding-context`)

Detect languages in target files and inject appropriate skills before implementing code:

```bash
/coding-context                    # Auto-detect from task context
/coding-context src/lib.rs         # Explicit file(s)
/coding-context src/components/    # Explicit directory
```

Automatically loads:
- Language skills (`@rust`, `@typescript`, `@svelte`)
- Framework skills (`@tokio` for async Rust)
- `@principles` for universal quality standards

### SessionStart Hook

On session start, the plugin automatically:
1. Scans the codebase for language composition
2. Reports detected languages and corresponding skills
3. Provides guidance on when to load skills

### Codex Review (`/codex-review`)

Independent code review using Codex CLI. Supports multi-agent review for complex changes:

| Complexity | Agents | Focus Areas |
|------------|--------|-------------|
| Simple (< 100 lines) | 1 | All principles |
| Medium (100-500 lines) | 2 | Design + Standards |
| Complex (> 500 lines) | 3 | Design + Safety + Quality |

```bash
/codex-review              # Review working copy
```

### Codex Spec Review (`/codex-spec-review`)

Independent spec review using Codex CLI. Validates specifications before implementation:

| Complexity | Agents | Focus Areas |
|------------|--------|-------------|
| Simple | 1 | Comprehensive |
| Medium | 2 | Requirements + Execution |
| Complex | 3 | Requirements + Risk + Testability |

```bash
/codex-spec-review         # Review spec for readiness
```

### Principles

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

### Cleaning Skills

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
├── hooks/
│   ├── hooks.json           # SessionStart hook config
│   └── session-start.sh     # Language detection on session start
├── agents/
│   ├── cleaner.md           # Code cleaning with language detection
│   ├── implementer.md       # Implementation with quality standards
│   ├── addresser.md         # Fix review findings
│   └── reviewer.md          # Review with language-aware checking
├── skills/
│   ├── codex/
│   │   └── SKILL.md         # Neutral Codex CLI base
│   ├── codex-review/
│   │   └── SKILL.md         # Multi-agent code review
│   ├── codex-spec-review/
│   │   └── SKILL.md         # Multi-agent spec review
│   ├── cleaner/
│   │   └── SKILL.md         # Cleaning methodology
│   ├── coding-context/
│   │   └── SKILL.md         # Language detection and skill injection
│   ├── principles/
│   │   ├── SKILL.md         # Index of design principles
│   │   └── *.md             # Individual principles
│   └── cleaning/
│       ├── SKILL.md         # Language skill index
│       └── *.md             # Language-specific patterns
└── README.md
```
