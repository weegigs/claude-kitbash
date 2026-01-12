---
name: jj-status
description: View jj working copy status.
---

# jj status

Show the current working copy state.

## Usage

```bash
jj status
```

## Output Interpretation

| Prefix | Meaning |
|--------|---------|
| `A` | Added (new file) |
| `M` | Modified |
| `D` | Deleted |
| `R` | Renamed |
| `C` | Copied |

## Example Output

```
Working copy changes:
A .claude/skills/jj/SKILL.md
M apps/desktop/src-tauri/src/services/roster.rs

Working copy  (@) : abcd1234 (no description set)
Parent commit (@-): efgh5678 Added validation for roster names
```

## Key Points

- Working copy should always show `(no description set)`
- `@` represents the working copy
- `@-` represents the parent commit
- No staging area - all tracked changes are visible
