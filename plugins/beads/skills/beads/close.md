---
name: bd-close
description: Close beads issues.
---

# bd close

Close one or more completed issues.

## Usage

```bash
bd close <id> [flags]
bd close <id1> <id2> ... [flags]  # Multiple issues
bd close [flags]                   # Closes last touched issue
```

## Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--reason` | `-r` | Reason for closing |
| `--suggest-next` | | Show newly unblocked issues after closing |
| `--continue` | | Auto-advance to next step (molecules) |
| `--force` | `-f` | Force close pinned issues |

## Examples

```bash
# Close with reason
bd close bd-123 -r "Completed: implemented dark mode"

# Close multiple at once (more efficient)
bd close bd-123 bd-456 bd-789

# Close and see what's unblocked
bd close bd-123 --suggest-next

# Close last touched issue
bd close -r "Done"
```

## Session End Pattern

```bash
# Complete all finished work
bd close bd-123 bd-456 -r "Session complete"

# Sync beads to main
bd sync --from-main

# Commit code changes
jj split <files> -m "Description of changes"
```

## After Closing

Closing an issue may unblock dependent work:

```bash
bd close bd-123 --suggest-next
# Shows any issues that were waiting on bd-123

# Or check manually
bd ready
```
