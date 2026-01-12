---
name: beads
description: Issue tracking with beads (bd CLI). Use when discussing tasks, issues, work tracking, or project management.
---

# Beads Issue Tracking

This project uses `bd` CLI for issue tracking. Use direct CLI commands, NOT MCP tools.

## Quick Reference

| Command | Purpose |
|---------|---------|
| `bd ready` | Find unblocked tasks |
| `bd show <id>` | View issue details |
| `bd list` | List issues with filters |
| `bd create "<title>"` | Create new issue |
| `bd update <id>` | Update issue |
| `bd close <id>` | Close issue |
| `bd blocked` | Show blocked issues |
| `bd stats` | Project statistics |
| `bd dep` | Manage dependencies |
| `bd sync --from-main` | Sync from main branch |
| `bd q "<title>"` | Quick capture (outputs ID only) |
| `bd defer <id>` | Postpone issue |
| `bd stale` | Find forgotten issues |
| `bd doctor` | Health check |

## Priority Scale

| Value | Meaning |
|-------|---------|
| `0` / `P0` | Critical (drop everything) |
| `1` / `P1` | High (do soon) |
| `2` / `P2` | Medium (default) |
| `3` / `P3` | Low (when time permits) |
| `4` / `P4` | Backlog (someday/maybe) |

**Never use** `high`, `medium`, `low` - only numeric `0-4` or `P0-P4`.

## Issue Types

`task`, `bug`, `feature`, `epic`, `chore`

## Status Values

`open`, `in_progress`, `blocked`, `deferred`, `closed`

## Session Workflow

### Start of Session
```bash
bd ready                    # Find unblocked work
bd show <id>                # Review details
bd update <id> --claim      # Claim atomically (sets assignee + in_progress)
```

### During Work
```bash
bd create "<title>" -t task  # Track discovered work
bd dep add <new> <current>   # Link as discovered-from
```

### End of Session
```bash
jj status                   # Check changes
bd sync --from-main         # Pull beads updates (NOT bd sync alone)
jj split <files> -m "..."   # Commit changes
bd close <id> -r "Done"     # Close completed work
```

## Common Mistakes

| Wrong | Correct | Why |
|-------|---------|-----|
| `bd show --brief` | `bd show --short` | `--brief` doesn't exist |
| `bd update -s in_progress` | `bd update --claim` | `--claim` also sets assignee |
| `bd sync` | `bd sync --from-main` | Ephemeral branches have no upstream |
| `--priority high` | `-p 1` or `-p P1` | Only numeric priorities |
| MCP tools | `bd` CLI | Token efficiency |

## See Also

Individual command skills for detailed flag reference:
- `ready.md`, `show.md`, `list.md`, `create.md`
- `update.md`, `close.md`, `dep.md`, `sync.md`
- `utilities.md` - `bd q`, `bd stale`, `bd doctor`, `bd defer`, search, comments, epic management
