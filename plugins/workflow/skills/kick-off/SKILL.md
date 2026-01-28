---
name: kick-off
description: Create an execution plan from a requirement, spec, or beads task. Use when starting new work that needs structured breakdown into tasks.
---

# Workflow Kick-off

Create a detailed execution plan. Does NOT implement — use `/execute` after approval.

## Plan Mode Required

Kick-off requires plan mode to prevent accidental implementation.

**If not in plan mode:**
```
⚠️  Kick-off requires Plan Mode.

Switch to plan mode:
- Press Shift+Tab until "Plan Mode" shown
- Or type /plan
- Or restart with: claude --permission-mode plan

Then run /kick-off again.
```

## Guardrails

- Favor straightforward implementations; add complexity only when required
- Keep plans tightly scoped to requested outcome
- Ask clarifying questions before creating tasks
- All subtasks must be completable in a single session
- Do NOT implement during kick-off

## Process

### Phase 1: Requirement Analysis

1. **Parse input** — identify source type:
   - Free-text description → analyze directly
   - Document reference → read and extract
   - Beads task → `bd show <id>`

2. **Explore context** — understand:
   - Related existing code and patterns
   - Dependencies and constraints
   - Similar prior implementations

3. **Inject standards** (if `.agent-os/standards/` exists):
   - Identify relevant standards
   - Read via `/standards-inject` or directly
   - Standards inform implementation patterns

4. **Ask clarifying questions** (3-5 non-obvious):
   - Edge cases, error handling, assumptions
   - Performance, security, backwards compatibility
   - Acceptance criteria and verification approach

### Phase 2: Task Planning

5. **Create parent task**:
   ```bash
   bd create --title="<requirement summary>" --type=feature|task|bug --priority=2
   ```

6. **Identify logical breakpoints**:
   - Group into phases (data layer, business logic, UI, etc.)
   - Each phase produces a verifiable, working state
   - Mark critical points requiring code review

7. **Break into atomic subtasks**:
   - Each subtask independently verifiable
   - Include acceptance criteria in description
   - Add dependencies: `bd dep add <subtask> <depends-on>`
   - Insert checkpoint tasks at phase boundaries:
     - "Checkpoint: Verify [phase] — quality check, commit, close tasks"
   - Add final task: "Final checkpoint: Full workflow verification"

8. **Generate execution plan**:
   - Ordered subtask list with checkpoints
   - Files likely modified per phase
   - Testing approach
   - Risks or blockers

**Example structure:**
```
Phase 1: Data Layer
  - beads-101: Add migration
  - beads-102: Implement repository
  - beads-103: Checkpoint: Verify data layer

Phase 2: Business Logic
  - beads-104: Add validation service
  - beads-105: Implement commands
  - beads-106: Checkpoint: Verify business logic

Phase 3: Integration
  - beads-107: Wire up components
  - beads-108: Final checkpoint
```

### Phase 3: Handoff

9. **Present plan**:
   - Summary of requirement as understood
   - Parent and subtask IDs
   - Execution order
   - Remaining uncertainties

10. **Save to TodoWrite**:
    - Full plan for agent continuity
    - Enables `/execute` to find and resume

11. **On approval**, remind user:
    - Run `/execute` to begin
    - Or start manually: `bd update <first-subtask> --claim`

## Completion Checklist

Before presenting plan:

**Phase 1: Requirement Analysis**
- [ ] Parsed input (free-text / document / beads)
- [ ] Explored codebase context
- [ ] Checked and injected relevant standards
- [ ] Asked 3-5 clarifying questions

**Phase 2: Task Planning**
- [ ] Created parent beads task
- [ ] Identified phases and breakpoints
- [ ] Created subtasks with acceptance criteria
- [ ] Added dependencies via `bd dep add`
- [ ] Inserted checkpoint tasks
- [ ] Added final checkpoint

**Phase 3: Handoff**
- [ ] Plan summary prepared
- [ ] All task IDs documented
- [ ] Execution order clear
- [ ] Saved to TodoWrite

## See Also

- `/execute` — Execute the plan after approval
- `/next` — Find next task when resuming
- `/check` — Verification at checkpoints
