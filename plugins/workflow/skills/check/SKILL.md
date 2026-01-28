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

### 6. Cop-Out Scan

**MANDATORY** — This check cannot be skipped. Any finding is a blocker.

#### Scan for deferred work markers

```bash
jj diff --stat | awk '{print $1}' | xargs rg -n "TODO|FIXME|XXX|HACK|PLACEHOLDER|STUB" 2>/dev/null
```

**Evaluation for each finding:**

| Finding | Verdict | Required Action |
|---------|---------|-----------------|
| TODO with beads reference + user approval | PASS | None |
| TODO with beads reference, no user approval | **FAIL** | Get user approval or complete now |
| TODO without beads reference | **FAIL** | Complete now or get approval + create beads |
| Explanatory comment (not deferred work) | PASS | None |

#### Scan for lint suppressions

```bash
jj diff --stat | awk '{print $1}' | xargs rg -n "#\[allow|eslint-disable|@ts-ignore|noqa|type:\s*ignore" 2>/dev/null
```

**Verdict: FAIL** unless user explicitly approved each suppression in conversation.

The presence of a lint warning means the code should be fixed, not the warning suppressed.

#### Scan for type bypasses

```bash
jj diff --stat | awk '{print $1}' | xargs rg -n "as any|as unknown as" 2>/dev/null
```

**Verdict: FAIL** — Type bypasses are never acceptable. Fix the types properly.

#### Scan for error swallowing

```bash
jj diff --stat | awk '{print $1}' | xargs rg -n "catch\s*\{\s*\}|catch\s*\(_\)" 2>/dev/null
```

**Verdict: FAIL** — Empty catches hide failures. Handle errors or propagate them.

#### Scan for skipped tests

```bash
jj diff --stat | awk '{print $1}' | xargs rg -n "\.skip\(|#\[ignore\]|@pytest\.mark\.skip|xit\(|xdescribe\(" 2>/dev/null
```

**Verdict: FAIL** — Tests exist to run. Fix or remove them, don't skip them.

#### Key Principle

**Even tracked deferrals require explicit user approval.** A beads reference makes work trackable, but the user must explicitly say "yes, defer that" in the conversation. The agent cannot unilaterally decide to defer work.

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
