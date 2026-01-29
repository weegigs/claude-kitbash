---
name: kick-off
description: Create an execution plan from a requirement, spec, or task. Use when starting new work that needs structured breakdown into tasks.
---

# Workflow Kick-off

Create a detailed execution plan. Does NOT implement — use `/execute` after approval.

## Prerequisites

### Plan Mode

Kick-off requires plan mode. If not active, use the `EnterPlanMode` tool to switch.

### Task Tracking

Detect availability:
```bash
command -v bd &> /dev/null && echo "beads" || echo "todowrite"
```

- **beads available**: Use `bd` commands for full task management
- **beads unavailable**: Use TodoWrite with naming convention (see references)

### Knowledge Base

Detect ByteRover:
```bash
command -v brv &> /dev/null && [ -d ".brv" ] && echo "byterover" || echo "none"
```

- **byterover available**: Query prior knowledge before planning
- **byterover unavailable**: Skip knowledge queries

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
   - Spec file → read from `.agent-os/specs/`

2. **Query prior knowledge** (if byterover available):
   ```bash
   brv query "What do we know about <topic>?"
   brv query "Any past issues with <area>?"
   ```
   
   Prior knowledge may reveal lessons learned, architectural decisions, or gotchas. Skip if byterover unavailable.

3. **Explore context** — understand:
   - Related existing code and patterns
   - Dependencies and constraints
   - Similar prior implementations

4. **Inject standards** (if agent-os configured):
   ```
   If .agent-os/standards/ exists:
     Invoke /standards-inject (auto-suggest mode)
   ```

5. **Ask clarifying questions** (3-5 non-obvious):
   - Edge cases, error handling, assumptions
   - Performance, security, backwards compatibility
   - Acceptance criteria and verification approach

### Phase 2: Task Planning

6. **Create parent task**:

   **With beads:**
   ```bash
   bd create --title="<requirement summary>" --type=feature|task|bug --priority=2
   ```

   **Without beads:**
   ```
   Add to TodoWrite: "[EPIC-XXX] <requirement summary>"
   ```

7. **Identify logical breakpoints**:
   - Group into phases (data layer, business logic, UI, etc.)
   - Each phase produces a verifiable, working state
   - Mark critical points requiring code review

8. **Break into atomic subtasks**:
   - Each subtask independently verifiable
   - Include acceptance criteria in description
   - Add dependencies (beads: `bd dep add`, TodoWrite: use ordering)
   - Insert checkpoint tasks at phase boundaries
   - Add final task: "Final checkpoint: Full workflow verification"

8. **Generate execution plan**:
   - Ordered subtask list with checkpoints
   - Files likely modified per phase
   - Testing approach
   - Risks or blockers

**Example structure:**
```
Phase 1: Data Layer
  - [EPIC/1] Add migration
  - [EPIC/2] Implement repository
  - [EPIC/✓] Checkpoint: Verify data layer

Phase 2: Business Logic
  - [EPIC/3] Add validation service
  - [EPIC/4] Implement commands
  - [EPIC/✓] Checkpoint: Verify business logic

Phase 3: Integration
  - [EPIC/5] Wire up components
  - [EPIC/✓] Final checkpoint
```

### Phase 3: Handoff

9. **Present plan**:
   - Summary of requirement as understood
   - Task IDs (beads) or TodoWrite items
   - Execution order
   - Remaining uncertainties

10. **Save to TodoWrite**:
    - Full plan for agent continuity
    - Enables `/execute` to find and resume

11. **On approval**, remind user:
    - Run `/execute` to begin
    - Or start manually with first task

## Completion Checklist

- [ ] Parsed input (free-text / document / beads / spec)
- [ ] Queried prior knowledge (if byterover available)
- [ ] Explored codebase context
- [ ] Injected relevant standards (if agent-os configured)
- [ ] Asked 3-5 clarifying questions
- [ ] Created parent task
- [ ] Identified phases and breakpoints
- [ ] Created subtasks with acceptance criteria
- [ ] Added dependencies/ordering
- [ ] Inserted checkpoint tasks
- [ ] Plan summary prepared
- [ ] Saved to TodoWrite

## See Also

- `/execute` — Execute the plan after approval
- `/next` — Find next task when resuming
- `/check` — Verification at checkpoints
- `/standards-inject` — Inject relevant coding standards (agent-os)
