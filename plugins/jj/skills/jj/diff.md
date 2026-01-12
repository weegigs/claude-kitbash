---
name: jj-diff
description: View jj diffs and compare revisions.
---

# jj diff

Show differences between revisions or in working copy.

## Usage

```bash
jj diff [options] [paths...]
```

## LLM/Tooling Best Practice

**Always use `--git` flag** for diffs that will be reviewed by LLMs or processed by tools:

```bash
# Standard format for LLM code review
jj diff --git

# With extra context for better LLM understanding
jj diff --git --context 5

# Review a specific revision
jj diff --git -r @-
```

The `--git` flag produces standard unified diff format that is:
- Universally parseable by LLMs and code review tools
- Compatible with CI systems and patch workflows
- Shows file renames and mode changes properly

## Common Patterns

```bash
# Working copy changes (all files)
jj diff --git

# Specific file
jj diff --git path/to/file.rs

# Specific directory
jj diff --git apps/desktop/

# Previous commit's changes
jj diff --git -r @-

# Between two revisions
jj diff --git -r <from>..<to>

# Changes since main
jj diff --git -r main..@

# Stat summary (insertions/deletions)
jj diff --stat
```

## Flags

| Flag | Description |
|------|-------------|
| `--git` | **Recommended.** Standard unified diff format for tooling |
| `--context <N>` | Number of context lines (default 3, use 5+ for LLMs) |
| `-r <revset>` | Revision(s) to diff |
| `--stat` | Show summary stats |
| `--summary` | Show only changed file names |
| `--color-words` | Word-level diff coloring |
| `--name-only` | Show only file paths |

## Revset Syntax

| Revset | Meaning |
|--------|---------|
| `@` | Working copy |
| `@-` | Parent of working copy |
| `@--` | Grandparent |
| `main` | The main bookmark |
| `<rev>..<rev>` | Range between revisions |

## Examples

```bash
# What changed in parent commit (for LLM review)
jj diff --git -r @-

# What changed between main and now
jj diff --git -r main..@

# Summary of current changes
jj diff --summary

# Diff for code review (specific files)
jj diff --git apps/desktop/src-tauri/src/services/*.rs

# Full context for complex changes
jj diff --git --context 10 -r @-
```
