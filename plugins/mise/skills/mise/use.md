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
# Bun
mise use bun@latest
mise use bun@1.1

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
| Exact | `bun@1.1.0` | Specific version |
| Major | `bun@1` | Latest 1.x |
| Prefix | `bun@1.1` | Latest 1.1.x |
| Latest | `bun` | Latest stable |

## Scope Flags

| Flag | Description |
|------|-------------|
| (none) | Write to `mise.toml` in current directory |
| `--global` | Write to `~/.config/mise/config.toml` |
| `--pin` | Pin to exact version |

## Examples

```bash
# Set bun for this project
mise use bun@latest

# Pin exact version
mise use --pin bun@1.1.0

# Set global default
mise use --global python@3.12

# Multiple tools at once
mise use bun@latest python@3.12 rust@stable
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
mise ls-remote bun

# Latest version
mise latest bun

# Search for tools
mise search biome
```

## After Adding Tools

```bash
# Install the tools (usually automatic)
mise install

# Verify installation
mise ls
mise where bun
```

## Anti-Patterns

| Wrong | Why | Correct |
|-------|-----|---------|
| `brew install bun` | Bypasses mise | `mise use bun@latest` |
| `pyenv install 3.12` | Bypasses mise | `mise use python@3.12` |
| `rustup default stable` | Bypasses mise | `mise use rust@stable` |
| `mise use bun latest` | Missing `@` | `mise use bun@latest` |

## Verification

```bash
# Check what mise.toml has
cat mise.toml

# List installed tools
mise ls

# Check tool path
mise where bun
mise exec -- which bun
```
