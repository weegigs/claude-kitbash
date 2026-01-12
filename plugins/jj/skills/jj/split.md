---
name: jj-split
description: Create commits from working copy changes (the jj way).
---

# jj split

Create commits by splitting changes from the working copy.

This is the **primary way to create commits** in jj. Unlike git's `add` + `commit`,
jj split selects which changes become a new commit.

> **Critical for Agents/Scripts:** Always provide a fileset (`.` or specific paths).
> Without a fileset, jj opens an interactive diff editor that fails in non-TTY environments
> with "Device not configured" errors and corrupts terminal state.

## Usage

```bash
jj split <fileset> -m "description"
```

Where `<fileset>` is:
- `.` - All changes (most common)
- `path/to/file.rs` - Specific file
- `apps/desktop/` - Directory
- Multiple paths - `file1.rs file2.rs`

## Common Patterns

```bash
# Commit all working copy changes
jj split . -m "Added user authentication"

# Commit specific files
jj split path/to/file.rs -m "Fixed null pointer bug"

# Commit a directory
jj split apps/desktop/ -m "Refactored desktop app"

# Commit multiple specific files
jj split file1.rs file2.rs -m "Updated models"
```

## How It Works

1. Working copy contains all your changes
2. `jj split` takes specified files (or all if none specified)
3. Creates a new commit with those changes
4. Remaining changes stay in working copy
5. Working copy keeps `(no description set)`

## Commit Message Guidelines

**Use past tense** (describes what was done):
- "Added validation for roster names"
- "Fixed cost calculation overflow"
- "Refactored authentication module"

**Never use:**
- "Add validation" (imperative)
- "Completed phase 2" (process, not content)
- "Finished AM-123" (ticket reference only)

## Flags

| Flag | Description |
|------|-------------|
| `-m <msg>` | Commit message |
| `-r <rev>` | Split a different revision (advanced) |

## Examples

```bash
# After making changes to multiple areas
jj status
# M apps/api/auth.rs
# M apps/api/users.rs
# A docs/auth.md

# Commit all changes at once
jj split . -m "Added JWT auth and user profile"

# OR commit auth changes together, leave users for later
jj split apps/api/auth.rs docs/auth.md -m "Added JWT authentication"

# Then commit users separately
jj split apps/api/users.rs -m "Added user profile endpoint"
```

## Anti-Patterns

| Wrong | Why | Correct |
|-------|-----|---------|
| `jj split -m "msg"` | Opens interactive editor (fails in agents) | `jj split . -m "msg"` |
| `jj commit -m "msg"` | Creates empty commit | `jj split . -m "msg"` |
| `jj new -m "msg"` | Creates new empty change | `jj split . -m "msg"` |

**Note:** Use `jj describe -r <rev> -m "msg"` to edit historical commit messages.

## Verification

After splitting, verify with:
```bash
jj log --limit 3     # See new commit
jj status            # Remaining changes (if any)
```
