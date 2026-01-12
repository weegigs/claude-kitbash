---
name: bd-utilities
description: Beads utility commands for maintenance and analysis.
---

# Beads Utility Commands

Less common but useful commands for project health and analysis.

## Quick Capture: `bd q`

Create issue and output only the ID (for scripting):

```bash
ISSUE=$(bd q "Fix bug")           # Capture in variable
bd q "Task" | xargs bd show       # Pipe to other commands
bd q "Bug" -t bug -p 1            # Accepts same flags as create
```

## Defer/Undefer

Postpone issues without blocking:

```bash
bd defer bd-123                   # Defer indefinitely
bd defer bd-123 --until=tomorrow  # Auto-undefer tomorrow
bd defer bd-123 --until="+1w"     # Auto-undefer in 1 week
bd undefer bd-123                 # Restore to ready pool
```

## Find Stale Issues

Issues not updated recently:

```bash
bd stale                          # Default: 30 days
bd stale -d 7                     # Not updated in 7 days
bd stale -s in_progress           # Stale in-progress work
```

## Dependency Graph

Visualize dependencies (ASCII):

```bash
bd graph bd-epic-123              # Show epic's dependency graph
```

Colors: White=open, Yellow=in_progress, Red=blocked, Green=closed

## Comments

Add notes to issues:

```bash
bd comments bd-123                # List comments
bd comments add bd-123 "Note"     # Add comment
bd comments add bd-123 -f file.md # From file
```

## Health Checks

```bash
bd doctor                         # Quick health check
bd doctor --deep                  # Full graph integrity
bd doctor --fix                   # Auto-fix issues
bd orphans                        # Issues in commits but still open
bd duplicates                     # Find duplicate issues
bd lint                           # Check missing template sections
```

## Statistics

```bash
bd stats                          # Project overview
bd count                          # Total issues
bd count --by-status              # Group by status
bd count --by-priority            # Group by priority
bd count --by-assignee            # Group by assignee
```

## Search

Full-text search with filters:

```bash
bd search "authentication"        # Search all fields
bd search "bug" -s open           # Open issues only
bd search "api" --long            # Detailed output
bd search "refactor" --sort priority
```

## Epic Management

```bash
bd epic status bd-epic-123        # Show completion %
bd epic close-eligible            # Close epics with all children done
```

## Labels

```bash
bd label list-all                 # All labels in use
bd label add bd-123 urgent        # Add label
bd label remove bd-123 urgent     # Remove label
```
