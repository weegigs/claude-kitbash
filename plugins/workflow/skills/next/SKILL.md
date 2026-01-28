---
name: next
description: Review beads tasks and recommend the next action. Use when starting a session or after completing work to identify highest-impact next steps.
---

# Workflow Next

Analyze beads state and recommend the best next action. Does NOT implement — only recommends.

## Process

### Step 1: Gather State

```bash
# Check active work
bd list --status=in_progress

# Find ready work (unblocked)
bd ready

# Understand blockers
bd blocked

# Overall health
bd stats
```

### Step 2: Analyze

**In-progress work exists?**
- Recommend continuing or closing before starting new work
- Note stale items (started but not touched recently)

**Blocked count high?**
- Focus on tasks that unblock others
- Check for dependency chains nearing completion

**Session continuity?**
- If prior session left work incomplete, recommend resuming
- If starting fresh, prefer highest-impact ready task

### Step 3: Recommend

Present:

```
**Recommendation**: beads-XXX — [title]

**Rationale**: [Why this over others — priority, unblocking potential, urgency]

**Alternatives**:
1. beads-YYY — [reason this could be valid too]
2. beads-ZZZ — [another option]

**To start**: bd update beads-XXX --claim
```

**If no actionable work:**
- Review and close completed tasks
- Create new work from backlog/roadmap
- Run `/check` to ensure prior work is closed

## Decision Criteria

Priority order:
1. Complete in-progress work before starting new
2. P0/P1 bugs and blockers take precedence
3. Tasks that unblock others provide higher leverage
4. Higher priority (lower number) before lower
5. Older tasks before newer at same priority

## Quick Reference

| Command | Purpose |
|---------|---------|
| `bd show <id>` | Inspect task details |
| `bd ready --labels=<label>` | Filter by area |
| `bd list --status=open --priority=0` | Find critical items |
| `bd update <id> --claim` | Start working |
