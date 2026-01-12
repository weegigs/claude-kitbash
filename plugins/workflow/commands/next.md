---
name: Workflow: Next
description: Review beads tasks and recommend the next action to take.
category: Workflow
tags: [workflow, planning, beads]
---

**Guardrails**
- Base recommendations on objective criteria (priority, dependencies, in-progress state), not assumptions.
- If multiple valid options exist, present them ranked with clear reasoning.
- Do not begin implementation. Only recommend the next action.

**Steps**

## Phase 1: Gather State

1. **Check current work** - run `bd list --status=in_progress` to see active tasks:
   - If work is in progress, recommend continuing or closing it before starting new work
   - Note any stale in-progress items (started but not touched recently)

2. **Find ready work** - run `bd ready` to see unblocked tasks:
   - Note priority levels (P0 = critical, P4 = backlog)
   - Identify any urgent items (bugs, blockers)

3. **Check blocked work** - run `bd blocked` to understand the dependency landscape:
   - Identify tasks that would unblock the most other work
   - Note any dependency chains nearing completion

## Phase 2: Analyze Context

4. **Review project health** - run `bd stats` to understand overall state:
   - High blocked count suggests focusing on unblocking work
   - High open count suggests triage or prioritization review

5. **Consider session continuity**:
   - If prior session left work partially complete, recommend resuming
   - If starting fresh, prefer highest-impact ready task

## Phase 3: Recommend

6. **Present recommendation** with:
   - **Primary recommendation**: The single best next action with task ID
   - **Rationale**: Why this task over others (priority, unblocking potential, urgency)
   - **Alternatives**: 1-2 other valid options if the primary doesn't fit the user's current focus
   - **Command to start**: `bd update <id> --claim`

7. **If no actionable work exists**, suggest:
   - Reviewing and closing completed tasks
   - Creating new work from backlog or roadmap
   - Running `/workflow:check` to ensure prior work is properly closed

**Decision Criteria (in priority order)**
1. Complete in-progress work before starting new work
2. P0/P1 bugs and blockers take precedence
3. Tasks that unblock other work provide higher leverage
4. Higher priority (lower number) before lower priority
5. Older tasks before newer tasks at same priority

**Reference**
- `bd show <id>` - inspect task details before starting
- `bd ready --labels=<label>` - filter by area of focus
- `bd list --status=open --priority=0` - find critical items
