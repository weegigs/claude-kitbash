---
name: check
description: Verify workflow completion before ending a session. Use when finishing implementation work to ensure commits, reviews, and task tracking are complete.
---

# Workflow Check

Verification checklist before completing a coding session. Skip if no code changes were made (research/planning only).

## Prerequisites

This project uses **jj** (Jujutsu), not git:
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
1. `/codex-review` — if Codex CLI available
2. `@reviewer` agent — always (uses `@principles` + language skills)

Both must pass. If Codex unavailable, `@reviewer` agent alone is sufficient.

Address all issues before proceeding.

### 3. Commits

- [ ] All changes committed: `jj split -m "description" .`
- [ ] Messages describe **what changed**, not process
  - Good: "Added validation for roster names"
  - Good: "Fixed cost calculation overflow"
  - Bad: "Completed phase 2"
  - Bad: "Implemented per spec"

### 4. Task Management

- [ ] TodoWrite items completed or removed
- [ ] Tasks closed (beads: `bd close <id>`, or mark completed)
- [ ] If closing last subtask, close parent too

### 5. Cop-Out Scan (MANDATORY)

This check cannot be skipped. Any finding is a blocker.

See [../execute/references/cop-outs.md](../execute/references/cop-outs.md) for complete patterns.

**Quick scans on modified files:**

```bash
# Get modified files
FILES=$(jj diff --stat | awk '{print $1}')

# Deferred work markers
echo "$FILES" | xargs rg -n "TODO|FIXME|XXX|HACK|PLACEHOLDER|STUB" 2>/dev/null

# Lint suppressions
echo "$FILES" | xargs rg -n "#\[allow|eslint-disable|@ts-ignore|noqa|type:\s*ignore" 2>/dev/null

# Type bypasses
echo "$FILES" | xargs rg -n "as any|as unknown as" 2>/dev/null

# Error swallowing
echo "$FILES" | xargs rg -n "catch\s*\{\s*\}|catch\s*\(_\)" 2>/dev/null

# Skipped tests
echo "$FILES" | xargs rg -n "\.skip\(|#\[ignore\]|@pytest\.mark\.skip|xit\(|xdescribe\(" 2>/dev/null
```

**Evaluation:**

| Finding | Verdict |
|---------|---------|
| TODO with task ref + user approval | PASS |
| TODO with task ref, no approval | **FAIL** |
| TODO without task ref | **FAIL** |
| Explanatory comment | PASS |
| Any lint suppression without approval | **FAIL** |
| Any type bypass | **FAIL** |
| Any empty catch | **FAIL** |
| Any skipped test | **FAIL** |

**Key principle:** Even tracked deferrals require explicit user approval in the conversation.

## Quick Reference

| Check | Command |
|-------|---------|
| View changes | `jj diff --git` |
| Commit | `jj split -m "msg" .` |
| Close task | `bd close <id>` or mark completed |

## See Also

- `@principles` — Quality standards for code review
- `/codex-review` — Independent code review via Codex
- `@reviewer` — Code review agent (code-quality plugin)
