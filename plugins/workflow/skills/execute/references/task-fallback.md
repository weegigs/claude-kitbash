# Task Management Fallback

When beads (`bd` CLI) is unavailable, use TodoWrite with naming conventions for hierarchy.

## Detection

```bash
command -v bd &> /dev/null && echo "beads" || echo "todowrite"
```

## Naming Convention

Use prefixes to create pseudo-hierarchy in flat TodoWrite:

```
[EPIC-001] Parent task title
[EPIC-001/1] First subtask
[EPIC-001/2] Second subtask  
[EPIC-001/✓] Checkpoint: Verify phase complete
```

## Command Mapping

| With beads | Without beads (TodoWrite) |
|------------|---------------------------|
| `bd create --title="X"` | Add `[EPIC/n] X` to TodoWrite |
| `bd update <id> --claim` | Mark todo `in_progress` |
| `bd close <id>` | Mark todo `completed` |
| `bd ready` | Read TodoWrite, filter `pending` |
| `bd show <id>` | Read specific todo content |
| `bd list --status=in_progress` | Filter TodoWrite by `in_progress` |
| `bd dep add <a> <b>` | Use ordering in TodoWrite list |

## Epic ID Generation

Generate a short epic ID for grouping:

```
EPIC-{3 random chars}
```

Example: `EPIC-A7K`, `EPIC-B2M`

## Checkpoint Tasks

Mark checkpoints with `✓` symbol:

```
[EPIC-A7K/✓] Checkpoint: Verify data layer complete
```

## Status Display

When presenting status:

**With beads:**
```
Completed:  ✓ beads-101, beads-102
In Progress: → beads-103
Remaining:  ○ beads-104, beads-105
```

**With TodoWrite:**
```
Completed:  ✓ [EPIC-A7K/1], [EPIC-A7K/2]
In Progress: → [EPIC-A7K/3]
Remaining:  ○ [EPIC-A7K/4], [EPIC-A7K/5]
```

## Limitations

TodoWrite fallback lacks:
- Persistent storage across sessions
- Dependencies beyond ordering
- Priority levels
- Labels/tags

For complex multi-session work, recommend installing beads.
