---
name: next
description: Review tasks and recommend the next action. Use when starting a session or after completing work to identify highest-impact next steps.
---

# Workflow Next

Analyze task state and recommend the best next action. Does NOT implement — only recommends.

## Task Tracking

Detect at start:
```bash
command -v bd &> /dev/null && echo "beads" || echo "todowrite"
```

## Process

### Step 1: Check Session State

Before looking at tasks, check for incomplete prior work:

```bash
# Uncommitted changes?
jj status

# In-progress TodoWrite items?
# (Check TodoWrite for in_progress status)
```

**If uncommitted changes exist:**
```
⚠️  Uncommitted changes detected.

Recommendation: Run /check before starting new work.
```

### Step 2: Gather Task State

**With beads:**
```bash
bd list --status=in_progress   # Active work
bd ready                       # Unblocked tasks
bd blocked                     # Blocked tasks
bd stats                       # Overall health
```

**Without beads:**
- Read TodoWrite
- Filter by status (pending, in_progress, completed)

### Step 3: Analyze

**In-progress work exists?**
- Recommend continuing or closing before starting new
- Note stale items (started but not touched recently)

**Blocked count high?**
- Focus on tasks that unblock others
- Check for dependency chains nearing completion

**Session continuity?**
- If prior session left work incomplete, recommend resuming
- If starting fresh, prefer highest-impact ready task

### Step 4: Recommend

**With beads:**
```
Recommendation: beads-XXX — [title]

Rationale: [Why this over others — priority, unblocking potential, urgency]

Alternatives:
1. beads-YYY — [reason this could be valid too]
2. beads-ZZZ — [another option]

To start: bd update beads-XXX --claim
```

**Without beads:**
```
Recommendation: [EPIC/N] — [title]

Rationale: [Why this over others]

To start: Mark as in_progress in TodoWrite
```

**If no actionable work:**
- Review and close completed tasks
- Create new work from backlog/roadmap
- Run `/check` to ensure prior work is closed

## Decision Criteria

Priority order:
1. Complete in-progress work before starting new
2. Address uncommitted changes first
3. P0/P1 bugs and blockers take precedence
4. Tasks that unblock others provide higher leverage
5. Higher priority (lower number) before lower
6. Older tasks before newer at same priority

## Quick Reference

| Operation | With beads | Without beads |
|-----------|------------|---------------|
| Show task | `bd show <id>` | Read TodoWrite |
| Find ready | `bd ready` | Filter pending todos |
| Filter by priority | `bd list --priority=0` | N/A |
| Start task | `bd update --claim` | Mark in_progress |
| Check changes | `jj status` | Same |
