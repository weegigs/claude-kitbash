---
name: mise-env
description: View and manage environment variables in mise.
---

# mise env

View environment variables that mise will set for the current directory.

## Usage

```bash
mise env              # Show all environment variables
mise env -s bash      # Show as bash export statements
mise env -s json      # Show as JSON
```

## Setting Environment Variables

In `mise.toml`:

```toml
[env]
DATABASE_URL = "postgresql://localhost/myapp"
NODE_ENV = "development"
LOG_LEVEL = "debug"
```

## Environment Sources

Mise loads environment from:

1. `mise.toml` `[env]` section
2. `mise.local.toml` (for secrets, git-ignored)
3. `.env` files (if configured)
4. Tool-specific variables (e.g., `PATH`)

## Dynamic Values

```toml
[env]
# Reference other variables
PATH = "{{env.HOME}}/bin:{{env.PATH}}"

# Project root
PROJECT_ROOT = "{{config_root}}"

# Command output
GIT_SHA = "$(git rev-parse --short HEAD)"
```

## Template Variables

| Variable | Description |
|----------|-------------|
| `{{env.VAR}}` | Reference environment variable |
| `{{config_root}}` | Directory containing mise.toml |
| `{{cwd}}` | Current working directory |

## Flags

| Flag | Description |
|------|-------------|
| `-s <shell>` | Output format: bash, zsh, fish, json |
| `--json` | Output as JSON |

## Setting Inline

```bash
mise set DATABASE_URL=postgresql://localhost/myapp
mise set NODE_ENV=development
```

## Unsetting

```bash
mise unset DATABASE_URL
```

## Anti-Patterns

| Wrong | Why | Correct |
|-------|-----|---------|
| `export NODE_ENV=dev` | Not persisted, not shared | Add to `mise.toml` |
| `.env` without config | Mise won't load it automatically | Configure in `mise.toml` |
| Hardcoded secrets in mise.toml | Tracked in git | Use `mise.local.toml` |

## Local Overrides (mise.local.toml)

For secrets and machine-specific settings:

```toml
# mise.local.toml (git-ignored)
[env]
DATABASE_URL = "postgresql://user:pass@prod/myapp"
API_KEY = "secret-key-here"
```

## Loading .env Files

Configure in `mise.toml`:

```toml
[env]
_.file = ".env"           # Load .env file
_.file = [".env", ".env.local"]  # Multiple files
```

## Verification

```bash
# Show all environment
mise env

# Check specific variable
mise env | grep DATABASE_URL

# Export to current shell (temporary)
eval "$(mise env -s bash)"
```
