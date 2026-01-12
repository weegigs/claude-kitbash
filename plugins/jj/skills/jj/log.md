---
name: jj-log
description: View jj commit history.
---

# jj log

View commit history.

## Usage

```bash
jj log [options]
```

## Common Patterns

```bash
# Full log (default view)
jj log

# Recent commits
jj log --limit 5
jj log -n 5

# Just parent and working copy
jj log -r @-..@

# Commits since main
jj log -r main..@

# Show a specific revision
jj show <rev>

# Oneline format
jj log --no-graph -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'
```

## Flags

| Flag | Description |
|------|-------------|
| `-r <revset>` | Filter revisions |
| `-n <N>`, `--limit <N>` | Limit number of commits |
| `--no-graph` | Don't show graph structure |
| `-T <template>` | Custom output template |
| `-p`, `--patch` | Show diff with each commit |

## Understanding the Log

```
@  abcd1234 user@email 2025-01-10 (no description set)
│  Working copy
○  efgh5678 user@email 2025-01-10 Added validation
│  Previous commit
○  ijkl9012 user@email 2025-01-09 Fixed calculation
```

| Symbol | Meaning |
|--------|---------|
| `@` | Working copy (current) |
| `○` | Regular commit |
| `│` | Linear history |
| `├─┬─` | Merge point |

## Revset Examples

| Revset | Meaning |
|--------|---------|
| `@` | Working copy |
| `@-` | Parent |
| `@--` | Grandparent |
| `main` | Main bookmark |
| `all()` | All revisions |
| `heads()` | All heads |
| `ancestors(@)` | All ancestors of working copy |
