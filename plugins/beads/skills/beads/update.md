---
name: bd-update
description: Update beads issues.
---

# bd update

Update one or more issues.

## Usage

```bash
bd update <id> [flags]
bd update <id1> <id2> ... [flags]  # Multiple issues
bd update [flags]                   # Updates last touched issue
```

## Key Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--claim` | | **Recommended**: Sets assignee to you AND status to in_progress |
| `--status` | `-s` | New status: open, in_progress, blocked, deferred, closed |
| `--priority` | `-p` | New priority (0-4 or P0-P4) |
| `--assignee` | `-a` | New assignee |
| `--title` | | New title |
| `--description` | `-d` | New description |
| `--add-label` | | Add labels (repeatable) |
| `--remove-label` | | Remove labels (repeatable) |
| `--set-labels` | | Replace all labels |
| `--parent` | | Reparent to new issue |
| `--due` | | Due date (+6h, tomorrow, 2025-01-15, empty to clear) |
| `--defer` | | Defer until date (empty to clear) |
| `--estimate` | `-e` | Time estimate in minutes |
| `--notes` | | Additional notes |
| `--design` | | Design notes |
| `--acceptance` | | Acceptance criteria |

## IMPORTANT: Use --claim

**Don't do this:**
```bash
bd update bd-123 -s in_progress  # Doesn't set assignee!
```

**Do this instead:**
```bash
bd update bd-123 --claim  # Sets BOTH assignee AND in_progress
```

## Examples

```bash
# Claim a task (recommended way to start work)
bd update bd-123 --claim

# Change priority
bd update bd-123 -p 1

# Add label
bd update bd-123 --add-label urgent

# Change status manually
bd update bd-123 -s blocked

# Update title
bd update bd-123 --title "New title"

# Multiple issues same update
bd update bd-123 bd-456 -p 2

# Update last touched issue
bd update -s blocked

# Set due date
bd update bd-123 --due=tomorrow

# Defer for later
bd update bd-123 --defer="+1w"

# Clear defer (restore to ready pool)
bd update bd-123 --defer=""

# Add notes
bd update bd-123 --notes "Blocked waiting for API access"
```

## Workflow Pattern

```bash
bd ready                    # Find work
bd show bd-123              # Review it
bd update bd-123 --claim    # Start working
# ... do the work ...
bd close bd-123             # Complete it
```
