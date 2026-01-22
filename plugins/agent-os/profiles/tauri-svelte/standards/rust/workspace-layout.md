# Rust Workspace Layout

## Standard Structure

```
project/
├── Cargo.toml              # Workspace root
├── crates/
│   ├── core/               # Domain logic (pure, no I/O)
│   │   ├── src/
│   │   │   ├── lib.rs
│   │   │   ├── types/
│   │   │   │   ├── mod.rs
│   │   │   │   └── CLAUDE.md
│   │   │   ├── error.rs
│   │   │   └── validator/
│   │   │       ├── mod.rs
│   │   │       └── CLAUDE.md
│   │   ├── tests/
│   │   └── Cargo.toml
│   └── shared/             # Shared utilities
│       └── Cargo.toml
├── apps/
│   └── desktop/
│       ├── src/            # Svelte frontend
│       └── src-tauri/      # Tauri app
│           ├── src/
│           │   ├── lib.rs
│           │   ├── main.rs
│           │   └── commands/
│           └── Cargo.toml
└── tools/                  # CLI tools, converters
    └── my-tool/
        └── Cargo.toml
```

## Workspace Cargo.toml

```toml
[workspace]
resolver = "2"
members = [
    "crates/*",
    "apps/*/src-tauri",
    "tools/*",
]

[workspace.package]
edition = "2024"
authors = ["Your Name"]
license = "MIT"
repository = "https://github.com/org/repo"

[workspace.dependencies]
# Share dependency versions across workspace
serde = { version = "1", features = ["derive"] }
thiserror = "2"
tokio = { version = "1", features = ["full"] }
tracing = "0.1"
```

## Crate Cargo.toml

Reference workspace dependencies:

```toml
[package]
name = "my-crate"
version = "0.1.0"
edition.workspace = true
authors.workspace = true
license.workspace = true

[dependencies]
serde.workspace = true
thiserror.workspace = true
```

## Module CLAUDE.md Files

Place `CLAUDE.md` in complex module directories to provide context:

```
src/validator/
├── mod.rs
├── context.rs
├── report.rs
├── rules/
│   ├── mod.rs
│   └── ...
└── CLAUDE.md    # Explains validator architecture
```

Example content:

```markdown
# Validator Module

## Purpose

Multi-layer validation with batch error reporting.

## Architecture

- `context.rs` - Validation context with path tracking
- `report.rs` - Error/warning collection
- `rules/` - Individual validation rules

## Key Patterns

1. Errors are collected, not thrown
2. Each error includes a path for precise location
3. Validation continues after errors (batch mode)

## Testing

Property-based tests in `tests/proptest_validation.rs`
```

## Layer Responsibilities

| Layer | Location | Responsibility |
|-------|----------|----------------|
| Core | `crates/core/` | Pure domain logic, types, validation |
| Shared | `crates/shared/` | Cross-cutting utilities |
| App | `apps/*/src-tauri/` | Tauri commands, state, I/O |
| Tools | `tools/` | CLI utilities, converters |

## Inter-Crate Dependencies

```
apps/desktop/src-tauri
    └── depends on → crates/core
                         └── depends on → crates/shared
```

Keep core crates free of I/O dependencies for testability.
