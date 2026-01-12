---
name: bd-ready
description: Find unblocked beads tasks ready to work on.
---

# bd ready

Show tasks with no blockers that are `open` or `in_progress`.

## Usage

```bash
bd ready [flags]
```

## Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--limit` | `-n` | Maximum issues (default 10) |
| `--priority` | `-p` | Filter by priority (0-4) |
| `--assignee` | `-a` | Filter by assignee |
| `--unassigned` | `-u` | Show only unassigned |
| `--label` | `-l` | Filter by labels (AND) |
| `--label-any` | | Filter by labels (OR) |
| `--type` | `-t` | Filter by type (task, bug, feature, etc.) |
| `--sort` | `-s` | Sort: hybrid (default), priority, oldest |
| `--parent` | | Filter to descendants of epic |
| `--include-deferred` | | Include deferred issues past their defer_until |
| `--pretty` | | Tree format with symbols |
| `--json` | | JSON output |

## Examples

```bash
# Find ready work
bd ready

# Top 5 high priority
bd ready -n 5 -p 1

# Unassigned bugs
bd ready -u -t bug

# With specific label
bd ready -l frontend
```

## After Finding Work

```bash
bd show <id>           # Review details
bd update <id> --claim # Claim it (sets assignee + in_progress)
```
