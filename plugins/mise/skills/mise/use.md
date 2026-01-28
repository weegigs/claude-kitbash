---
name: mise-use
description: Set and manage tool versions in mise.
---

# mise use

Install tools and set versions for the current project.

## Usage

```bash
mise use <tool>@<version>
mise use <tool>              # Latest version
```

## Common Tools

```bash
# Node.js
mise use node@20
mise use node@lts

# Python
mise use python@3.12
mise use python@3

# Rust
mise use rust@stable
mise use rust@1.75

# Go
mise use go@1.22

# Ruby
mise use ruby@3.3

# Java
mise use java@21
```

## Version Formats

| Format | Example | Behavior |
|--------|---------|----------|
| Exact | `node@20.10.0` | Specific version |
| Major | `node@20` | Latest 20.x |
| Prefix | `node@20.10` | Latest 20.10.x |
| Latest | `node` | Latest stable |
| LTS | `node@lts` | Latest LTS |

## Scope Flags

| Flag | Description |
|------|-------------|
| (none) | Write to `mise.toml` in current directory |
| `--global` | Write to `~/.config/mise/config.toml` |
| `--pin` | Pin to exact version |

## Examples

```bash
# Set node 20 for this project
mise use node@20

# Pin exact version
mise use --pin node@20.10.0

# Set global default
mise use --global python@3.12

# Multiple tools at once
mise use node@20 python@3.12 rust@stable
```

## Backends

Mise supports tools from various sources:

```bash
# npm packages
mise use npm:prettier
mise use npm:eslint

# Python tools via pipx
mise use pipx:black
mise use pipx:ruff

# Rust tools via cargo
mise use cargo:ripgrep
mise use cargo:fd-find

# GitHub releases
mise use github:astral-sh/uv

# Go packages
mise use go:golang.org/x/tools/gopls
```

## Querying Versions

```bash
# Available remote versions
mise ls-remote node

# Latest version
mise latest node

# Search for tools
mise search prettier
```

## After Adding Tools

```bash
# Install the tools (usually automatic)
mise install

# Verify installation
mise ls
mise where node
```

## Anti-Patterns

| Wrong | Why | Correct |
|-------|-----|---------|
| `nvm use 20` | Bypasses mise | `mise use node@20` |
| `pyenv install 3.12` | Bypasses mise | `mise use python@3.12` |
| `rustup default stable` | Bypasses mise | `mise use rust@stable` |
| `mise use node 20` | Missing `@` | `mise use node@20` |

## Verification

```bash
# Check what mise.toml has
cat mise.toml

# List installed tools
mise ls

# Check tool path
mise where node
mise exec -- which node
```
