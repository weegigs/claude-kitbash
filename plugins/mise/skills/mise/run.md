---
name: mise-run
description: Execute tasks defined in mise.toml.
---

# mise run

Execute project tasks defined in `mise.toml`.

Tasks are **pre-defined scripts** in the project configuration. Use `mise run` for defined tasks, `mise exec --` for arbitrary commands.

## Usage

```bash
mise run <task> [args...]
```

## Common Tasks

Projects typically define these tasks:

```bash
mise run build        # Build the project
mise run test         # Run tests
mise run dev          # Start development server
mise run lint         # Run linter
mise run fmt          # Format code
mise run check        # Run all checks
```

## Passing Arguments

Arguments after the task name are passed to the task:

```bash
mise run test -- --coverage
mise run build -- --release
mise run lint -- --fix
```

## Listing Available Tasks

```bash
mise tasks ls          # List all defined tasks
mise tasks info <task> # Show task details
```

## How Tasks Are Defined

In `mise.toml`:

```toml
[tasks.build]
run = "cargo build"
description = "Build the project"

[tasks.test]
run = "cargo test"
description = "Run tests"

[tasks.dev]
run = "cargo watch -x run"
description = "Start dev server with hot reload"
```

Or as file tasks in `mise-tasks/`:

```bash
# mise-tasks/build
#!/usr/bin/env bash
#MISE description="Build the project"
cargo build
```

## Task Dependencies

Tasks can depend on other tasks:

```toml
[tasks.check]
depends = ["lint", "test"]
run = "echo 'All checks passed'"
```

## Flags

| Flag | Description |
|------|-------------|
| `-n` | Dry run (show what would run) |
| `-q` | Quiet output |
| `-f` | Force run even if cached |
| `--cd <dir>` | Run from directory |

## Anti-Patterns

| Wrong | Why | Correct |
|-------|-----|---------|
| `mise run npm install` | `npm install` isn't a task | `mise exec -- npm install` |
| `mise exec -- mise run build` | Double wrapping | `mise run build` |
| `mise run cargo build` | `cargo build` isn't a task | `mise exec -- cargo build` |
| `mise run` (no task) | Must specify task | `mise tasks ls` to see tasks |

## Task vs Exec Decision

| Scenario | Use | Example |
|----------|-----|---------|
| Run defined project task | `mise run` | `mise run build` |
| Run arbitrary CLI command | `mise exec --` | `mise exec -- npm install` |
| Check what tasks exist | `mise tasks ls` | `mise tasks ls` |
| One-off command | `mise exec --` | `mise exec -- npx create-app` |

## Verification

```bash
# See all available tasks
mise tasks ls

# Show task definition
mise tasks info build

# Dry run to see what would execute
mise run build -n
```
