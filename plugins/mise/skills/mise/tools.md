---
name: mise-tools
description: Managing tools, backends, and installations in mise.
---

# Tool Management

Mise manages development tool versions using multiple backends.

## Core Commands

```bash
mise install           # Install all tools from mise.toml
mise ls                # List installed tools
mise ls --current      # Show tools for current directory
mise upgrade           # Upgrade tools to latest
mise uninstall <tool>  # Remove a tool
mise where <tool>      # Show installation path
mise which <cmd>       # Show which binary will be used
```

## Tool Backends

Mise supports installing tools from various sources:

### Core (Languages)
```bash
mise use node@20       # Node.js
mise use python@3.12   # Python
mise use rust@stable   # Rust
mise use go@1.22       # Go
mise use ruby@3.3      # Ruby
mise use java@21       # Java
```

### Bun
```bash
mise use bun@latest    # Bun runtime
```

### npm (Node packages)
```bash
mise use npm:prettier
mise use npm:eslint
mise use npm:typescript
mise use npm:turbo
```

### pipx (Python tools)
```bash
mise use pipx:black
mise use pipx:ruff
mise use pipx:poetry
mise use pipx:httpie
```

### cargo (Rust tools)
```bash
mise use cargo:ripgrep
mise use cargo:fd-find
mise use cargo:bat
mise use cargo:tokei
```

### GitHub Releases
```bash
mise use github:cli/cli           # GitHub CLI
mise use github:BurntSushi/ripgrep
mise use github:sharkdp/fd
mise use github:astral-sh/uv
```

### aqua (CLI tool manager)
```bash
mise use aqua:junegunn/fzf
mise use aqua:jqlang/jq
```

### go (Go packages)
```bash
mise use go:golang.org/x/tools/gopls
mise use go:github.com/golangci/golangci-lint/cmd/golangci-lint
```

## Searching for Tools

```bash
mise search prettier        # Find tools matching name
mise registry               # Browse all available tools
mise ls-remote node         # Available versions for a tool
mise latest node            # Latest version
```

## Configuration in mise.toml

```toml
[tools]
bun = "latest"
python = "3.12"
rust = "stable"

# With options
[tools.bun]
version = "latest"

# Backend-specific
"npm:prettier" = "latest"
"pipx:black" = "24.1"
"cargo:ripgrep" = "14"
```

## Flags

| Flag | Description |
|------|-------------|
| `--global` | Apply to global config |
| `--pin` | Pin exact version |
| `-j <n>` | Parallel installations |

## Anti-Patterns

| Wrong | Why | Correct |
|-------|-----|---------|
| `bun add -g prettier` | Bypasses mise | `mise use npm:prettier` |
| `pip install black` | Uses system pip | `mise use pipx:black` |
| `cargo install ripgrep` | Bypasses mise | `mise use cargo:ripgrep` |
| `brew install bun` | System-wide install | `mise use bun` |

## Upgrading Tools

```bash
# Upgrade all tools
mise upgrade

# Upgrade specific tool
mise upgrade bun

# Upgrade to specific version
mise use bun@1.2
```

## Removing Tools

```bash
mise uninstall bun@1.0      # Remove specific version
mise prune                  # Remove unused versions
```

## Verification

```bash
# List all installed
mise ls

# Check tool location
mise where bun
mise which bun

# Verify version matches
mise exec -- bun --version

# Check for issues
mise doctor
```
