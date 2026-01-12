---
name: bd-create
description: Create new beads issues.
---

# bd create

Create a new issue.

## Usage

```bash
bd create "<title>" [flags]
bd create --title "<title>" [flags]
```

## Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--type` | `-t` | Type: task (default), bug, feature, epic, chore |
| `--priority` | `-p` | Priority: 0-4 or P0-P4 (default: 2) |
| `--description` | `-d` | Issue description |
| `--assignee` | `-a` | Assignee |
| `--labels` | `-l` | Labels (comma-separated) |
| `--parent` | | Parent issue ID (for subtasks) |
| `--deps` | | Dependencies (e.g., `blocks:bd-20,bd-15`) |
| `--design` | | Design notes |
| `--acceptance` | | Acceptance criteria |
| `--notes` | | Additional notes |
| `--due` | | Due date (+6h, +1d, tomorrow, 2025-01-15) |
| `--defer` | | Defer until date (hidden from `bd ready` until then) |
| `--estimate` | `-e` | Time estimate in minutes |
| `--validate` | | Check required sections for issue type |
| `--file` | `-f` | Create multiple issues from markdown file |
| `--silent` | | Output only the issue ID |

## Priority Values

| Value | Meaning |
|-------|---------|
| `0` / `P0` | Critical |
| `1` / `P1` | High |
| `2` / `P2` | Medium (default) |
| `3` / `P3` | Low |
| `4` / `P4` | Backlog |

**Never use** `high`, `medium`, `low` - only numeric values.

## Examples

```bash
# Simple task
bd create "Fix login bug"

# Bug with priority
bd create "Auth token expires too quickly" -t bug -p 1

# Feature with description
bd create "Add dark mode" -t feature -d "Support system preference and manual toggle"

# With labels
bd create "Update docs" -l docs,chore

# Subtask of epic
bd create "Implement API endpoint" --parent bd-epic-123

# With dependency
bd create "Write tests" --deps "blocks:bd-feature-456"

# Get only ID (for scripting)
bd create "Quick fix" --silent

# With due date
bd create "Review PR" --due=tomorrow

# Deferred for later
bd create "Nice to have" --defer="+1w"

# With time estimate (60 minutes)
bd create "Refactor auth" -e 60
```

## Quick Capture: `bd q`

For fast issue creation that outputs only the ID:

```bash
ISSUE=$(bd q "Fix bug")           # Capture ID in variable
bd q "Task" | xargs bd show       # Pipe to other commands
bd q "Bug" -t bug -p 1            # Same flags as create
```

## After Creating

```bash
# Link to current work
bd dep add <new-id> <current-id>  # new depends on current
```
