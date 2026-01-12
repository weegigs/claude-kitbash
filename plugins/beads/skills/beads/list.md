---
name: bd-list
description: List beads issues with filters.
---

# bd list

List issues with various filters and sorting options.

## Usage

```bash
bd list [flags]
```

## Common Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--status` | `-s` | Filter: open, in_progress, blocked, deferred, closed |
| `--type` | `-t` | Filter: task, bug, feature, epic, chore |
| `--priority` | `-p` | Filter by priority (0-4 or P0-P4) |
| `--assignee` | `-a` | Filter by assignee |
| `--label` | `-l` | Filter by labels (AND - must have ALL) |
| `--label-any` | | Filter by labels (OR - must have at least one) |
| `--limit` | `-n` | Max results (default 50, 0=unlimited) |
| `--all` | | Include closed issues |
| `--sort` | | Sort by: priority, created, updated, status, id, title |
| `--reverse` | `-r` | Reverse sort order |
| `--pretty` | | Tree format with symbols |
| `--long` | | Detailed multi-line output |
| `--watch` | `-w` | Live updates (implies --pretty) |
| `--parent` | | Filter to children of epic |
| `--pinned` | | Show only pinned issues |
| `--no-pinned` | | Exclude pinned issues |

## Date Filters

| Flag | Description |
|------|-------------|
| `--created-after` | Created after date (YYYY-MM-DD) |
| `--created-before` | Created before date |
| `--updated-after` | Updated after date |
| `--closed-after` | Closed after date |
| `--overdue` | Due date in the past |

## Examples

```bash
# All open issues
bd list -s open

# In-progress bugs
bd list -s in_progress -t bug

# High priority (P0-P1)
bd list -p 0
bd list -p 1

# By assignee
bd list -a kevin

# With label
bd list -l frontend

# Recently updated
bd list --sort updated -r

# Detailed view
bd list --long

# Pretty tree view
bd list --pretty
```
