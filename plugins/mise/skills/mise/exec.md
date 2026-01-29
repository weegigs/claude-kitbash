---
name: mise-exec
description: Run commands in the mise environment with correct tool versions.
---

# mise exec

Execute commands with mise-managed tool versions and environment variables.

**This is the most important mise command for agents.** Every CLI tool invocation should use `mise exec --` to ensure correct versions.

## Usage

```bash
mise exec -- <command> [args...]
```

The `--` separates mise arguments from the command to execute.

## Why It Matters

Without `mise exec`, commands use system-installed tools which may:
- Be the wrong version (node 18 vs 20)
- Miss project environment variables
- Behave differently than CI/CD
- Break in unexpected ways

## Common Patterns

### Package Managers
```bash
mise exec -- bun install
mise exec -- bun run build
mise exec -- pnpm install
mise exec -- pip install -r requirements.txt
mise exec -- poetry install
mise exec -- cargo add serde
```

### Build Commands
```bash
mise exec -- bun run build
mise exec -- cargo build --release
mise exec -- go build ./cmd/app
mise exec -- python setup.py build
mise exec -- gradle build
```

### Test Commands
```bash
mise exec -- bun test
mise exec -- pytest -v
mise exec -- cargo test
mise exec -- go test ./...
```

### Development Servers
```bash
mise exec -- bun run dev
mise exec -- cargo watch -x run
mise exec -- flask run
mise exec -- uvicorn app:main --reload
```

### Linting and Formatting
```bash
mise exec -- bun run lint
mise exec -- biome check src/
mise exec -- cargo fmt
mise exec -- black .
mise exec -- ruff check .
```

## Flags

| Flag | Description |
|------|-------------|
| `-c <cmd>` | Execute shell command string |
| `-j <jobs>` | Parallel jobs for tool installation |
| `--cd <dir>` | Change to directory before executing |

## Advanced Usage

### Execute shell command string
```bash
mise exec -c "bun test && bun run build"
```

### Run from different directory
```bash
mise exec --cd packages/api -- bun install
```

## Anti-Patterns

| Wrong | Why | Correct |
|-------|-----|---------|
| `bun install` | Uses system bun | `mise exec -- bun install` |
| `mise exec bun install` | Missing `--` separator | `mise exec -- bun install` |
| `mise exec -- mise run build` | Double wrapping | `mise run build` |
| `mise exec "bun test"` | Quotes the whole command | `mise exec -- bun test` |

## When NOT to Use mise exec

1. **Mise commands themselves** - `mise install`, `mise run`, etc. don't need wrapping
2. **System utilities** - `ls`, `cat`, `grep`, etc. are fine without mise
3. **Git/jj commands** - Version control tools don't need mise
4. **Defined tasks** - Use `mise run <task>` instead

## Verification

```bash
# Check which version mise will use
mise exec -- node --version
mise exec -- python --version
mise exec -- cargo --version

# Compare to system version
node --version           # May differ!
mise exec -- node --version
```
