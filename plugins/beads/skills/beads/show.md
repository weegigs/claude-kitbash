---
name: bd-show
description: View beads issue details.
---

# bd show

Display detailed information about one or more issues.

## Usage

```bash
bd show <id> [flags]
bd show <id1> <id2> ...  # Multiple issues
```

## Flags

| Flag | Description |
|------|-------------|
| `--short` | Compact one-line output |
| `--refs` | Show issues that reference this one |
| `--thread` | Show full conversation thread |
| `--json` | JSON output |

## IMPORTANT

**`--brief` does NOT exist.** Use `--short` for compact output.

## Examples

```bash
# Full details
bd show bd-123

# Compact view
bd show bd-123 --short

# Multiple issues, compact
bd show bd-123 bd-456 --short

# What references this issue?
bd show bd-123 --refs

# JSON for scripting
bd show bd-123 --json
```

## Common Pattern

```bash
# Find work, then view details
bd ready
bd show <id-from-ready>
```
