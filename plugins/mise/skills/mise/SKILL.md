---
name: mise
description: Mise development environment management. Use when running CLI tools, managing tool versions, or executing project tasks.
---

# Mise Development Environment

This project uses **mise** for development environment management. All external CLI commands must run through mise to ensure correct tool versions and environment.

## Critical Rule

**ALL bash commands that use project tools MUST be wrapped with `mise exec --`**

This ensures:
- Correct tool versions (node, python, rust, etc.)
- Project environment variables are loaded
- Consistent behavior across machines

## Quick Reference

| Operation | Command |
|-----------|---------|
| Run CLI tool | `mise exec -- <command>` |
| Run project task | `mise run <task>` |
| Install tools | `mise install` |
| Set tool version | `mise use <tool>@<version>` |
| View environment | `mise env` |
| List installed | `mise ls` |
| Check setup | `mise doctor` |

## Command Wrapping Pattern

```bash
# CORRECT - Uses mise environment
mise exec -- bun install
mise exec -- cargo build
mise exec -- pytest tests/

# WRONG - Bypasses mise, uses system tools
bun install           # May use wrong bun version
cargo build           # May use wrong rust version
pytest tests/         # May use wrong python version
```

## When to Use Each Command

| Scenario | Command | Example |
|----------|---------|---------|
| Run any CLI tool | `mise exec --` | `mise exec -- bun test` |
| Run defined task | `mise run` | `mise run build` |
| Install project tools | `mise install` | `mise install` |
| Add new tool | `mise use` | `mise use bun@latest` |

## Configuration Detection

Mise is active when any of these files exist:
- `mise.toml` (preferred)
- `.mise.toml`
- `mise.local.toml`
- `.tool-versions` (legacy)

## Anti-Patterns

| Wrong | Why | Correct |
|-------|-----|---------|
| `bun install` | Bypasses mise tool versions | `mise exec -- bun install` |
| `cargo build` | Uses system rust, not project | `mise exec -- cargo build` |
| `python script.py` | Wrong python version | `mise exec -- python script.py` |
| `pnpm dev` | Bypasses environment | `mise exec -- pnpm dev` |
| `mise run bun install` | Tasks are for defined scripts, not arbitrary commands | `mise exec -- bun install` |

## Correct Usage Examples

### Package Management
```bash
# Bun/Node.js
mise exec -- bun install
mise exec -- bun add lodash
mise exec -- pnpm add lodash

# Python
mise exec -- pip install -r requirements.txt
mise exec -- poetry install

# Rust
mise exec -- cargo add serde
mise exec -- cargo build --release
```

### Running Tests
```bash
mise exec -- bun test
mise exec -- pytest
mise exec -- cargo test
mise exec -- go test ./...
```

### Development Servers
```bash
mise exec -- bun run dev
mise exec -- cargo watch -x run
mise exec -- flask run
```

### Project Tasks (defined in mise.toml)
```bash
mise run build        # Run the 'build' task
mise run test         # Run the 'test' task
mise run lint         # Run the 'lint' task
mise run dev          # Run the 'dev' task
```

## Verification

```bash
mise doctor           # Check mise setup
mise ls               # List installed tools
mise env              # Show environment variables
mise where node       # Show tool installation path
```

## See Also

Individual command skills for detailed usage:
- `exec.md` - Running commands in mise environment
- `run.md` - Executing defined tasks
- `use.md` - Managing tool versions
- `env.md` - Environment variables
- `tools.md` - Tool management and backends
