---
name: jj
description: Jujutsu (jj) version control. Use when jj is mentioned, or when discussing version control, commits, branches, diffs, releases, or comparing changes. CRITICAL for creating commits, releasing versions, saving work, or any git-like operations in jj repositories.
---

# Jujutsu (jj) Version Control

This project uses **jj** (Jujutsu), NOT git. All version control operations must use jj commands.

## Quick Reference

| Operation | jj Command |
|-----------|------------|
| View status | `jj status` |
| View diff | `jj diff --git` |
| View log | `jj log` |
| Create commit | `jj split . -m "message"` |
| View file at revision | `jj file show <rev>:<path>` |
| Compare revisions | `jj diff -r <from>..<to>` |

## Key Differences from Git

| Concept | Git | jj |
|---------|-----|-----|
| Staging area | Required | None (auto-tracks) |
| Committing | `git add` + `git commit` | `jj split . -m "msg"` |
| Working copy | Dirty/clean state | Always a valid revision |
| Branches | Named references | Bookmarks (optional) |
| Stash | `git stash` | Not needed (auto-saved) |

## Critical Rules

1. **Never use git commands** - Hook blocks them, use jj equivalents
2. **Working copy has no description** - Always `(no description set)`
3. **Use `jj split` for commits** - Not `jj describe -m` on working copy
4. **Commits use past tense** - "Added feature" not "Add feature"

## Common Workflows

### View Changes
```bash
jj status              # What files changed
jj diff --git          # All changes
jj diff --git <file>   # Specific file
jj diff --git -r @-    # Previous commit's changes
```

### Create Commits
```bash
jj split . -m "Added validation for names"   # Commit all changes
jj split <file> -m "Fixed bug in parser"     # Commit specific files
jj split <dir>/ -m "Refactored auth module"  # Commit directory
```

**Critical:** Always provide a fileset (`.` for all files, or specific paths). Without it, jj opens an interactive editor that fails in non-TTY environments (agents, scripts).

### View History
```bash
jj log                 # Full log
jj log --limit 5       # Recent commits
jj log -r @-..@        # Just parent and working copy
jj show <rev>          # Details of specific revision
```

### Compare Revisions
```bash
jj diff --git -r <rev1>..<rev2>    # Compare two revisions
jj diff --git -r @-..@             # Changes since parent
jj diff --git -r main..@           # All changes since main
```

## Anti-Patterns

| Wrong | Why | Correct |
|-------|-----|---------|
| `git status` | Blocked by hook | `jj status` |
| `jj describe -m "msg"` | Sets description on working copy (@), violates convention | `jj split . -m "msg"` |
| `jj split -m "msg"` | Opens interactive editor (fails in agents) | `jj split . -m "msg"` |
| `jj commit` | Creates empty commit | `jj split . -m "msg"` |
| `jj new` (for committing) | Wrong mental model | `jj split . -m "msg"` |

**CRITICAL:** Never use `jj describe -m` without `-r <rev>`. This sets a description on the working copy, which should ALWAYS be `(no description set)`. Use `jj split . -m "msg"` to create commits.

**Note:** Use `jj describe -r <rev> -m "msg"` to edit historical commit messages (not working copy).

## See Also

Individual command skills:
- `status.md` - View working copy state
- `diff.md` - Compare changes
- `log.md` - View history
- `split.md` - Create commits (the jj way)
