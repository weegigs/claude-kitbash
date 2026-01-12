---
name: bd-sync
description: Synchronize beads issues with jj/git.
---

# bd sync

Synchronize issues with the version control repository.

## IMPORTANT: jj Workflow

This project uses **jj** (Jujutsu), not git directly. Branches are ephemeral and don't have upstream remotes.

**Always use:**
```bash
bd sync --from-main
```

**Never use** plain `bd sync` - it assumes a git remote exists.

## Usage

```bash
bd sync --from-main [flags]
```

## Flags

| Flag | Description |
|------|-------------|
| `--from-main` | **Required for jj**: Pull from main branch |
| `--import-only` | Only import JSONL (skip git ops) |
| `--flush-only` | Only export to JSONL (skip git ops) |
| `--status` | Show diff between sync branch and main |
| `--dry-run` | Preview without making changes |
| `--squash` | Accumulate changes without committing |

## Common Commands

```bash
# Sync from main (standard for ephemeral branches)
bd sync --from-main

# Just import after jj operations
bd sync --import-only

# Check sync status
bd sync --status

# Preview what would happen
bd sync --from-main --dry-run
```

## Session End Protocol

```bash
# 1. Check what changed
jj status

# 2. Pull latest beads from main
bd sync --from-main

# 3. Commit code changes
jj split <files> -m "Description"

# 4. Close completed work
bd close <id> -r "Done"
```

## When to Sync

| Situation | Command |
|-----------|---------|
| End of session | `bd sync --from-main` |
| After jj merge/rebase | `bd sync --import-only` |
| Before starting work | `bd sync --from-main` (optional) |
| Check for updates | `bd sync --status` |

## Troubleshooting

If sync fails:
```bash
# Check status first
bd sync --status

# Try import only
bd sync --import-only

# Check for conflicts in .beads/issues.jsonl
jj diff .beads/
```
