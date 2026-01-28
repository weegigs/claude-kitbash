---
name: check
description: Verify workflow completion before ending a session. Use when finishing implementation work to ensure commits, reviews, and task tracking are complete.
---

# Workflow Check

Verification checklist before completing a coding session. Skip if no code changes were made (research/planning only).

## Prerequisites

This project uses **jj (Jujutsu)**, not git:
- `jj status` (not `git status`)
- `jj diff --git` (not `git diff`)
- `jj split -m "message" .` (not `git add` + `git commit`)

## Checklist

### 1. Quality Checks

- [ ] Ran linting and type checking
- [ ] Tests pass (if applicable)

### 2. Code Review

Independent review required — self-review alone is insufficient.

Run reviews in parallel:
- **Codex review**: `/codex-review` (uses `@principles`)
- **Cleaner review**: `@cleaner` agent

Address all issues before proceeding.

### 3. Commits

- [ ] All changes committed: `jj split -m "description" .`
- [ ] Messages describe **what changed**, not process
  - ✓ "Added validation for roster names"
  - ✓ "Fixed cost calculation overflow"
  - ✗ "Completed phase 2"
  - ✗ "Implemented per spec"

### 4. Task Management

- [ ] TodoWrite items completed or removed
- [ ] Beads tasks closed: `bd close <id>`
- [ ] If closing last subtask, close parent too

### 5. Deferred Work

Scan modified files for work markers:

```bash
jj diff --stat | awk '{print $1}' | xargs rg -n "TODO|FIXME|XXX|HACK" 2>/dev/null
```

For each marker:
- **Explanatory note** → No action needed
- **Deferred work** → Create beads task or resolve now

No orphan TODOs — every deferral needs:
- User agreement
- Beads task for tracking
- Clear reason why it can't be done now

## Quick Reference

| Check | Command |
|-------|---------|
| View changes | `jj diff --git` |
| Commit | `jj split -m "msg" .` |
| Close task | `bd close <id>` |
| Scan markers | `rg "TODO\|FIXME" <files>` |

## See Also

- `@principles` — Quality standards for code review
- `@codex-review` — Independent code review via Codex
