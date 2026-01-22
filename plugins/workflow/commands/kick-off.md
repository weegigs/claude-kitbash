---
name: Workflow: Kick-off
description: Create a detailed execution plan from a requirement, document, or beads task.
category: Workflow
tags: [workflow, planning, beads]
---

**Guardrails**
- Favor straightforward, minimal implementations first and add complexity only when it is requested or clearly required.
- Keep execution plans tightly scoped to the requested outcome.
- Identify any vague or ambiguous details and ask necessary follow-up questions before creating tasks.
- Do not begin implementation during kick-off. Only create the plan and beads tasks. Implementation happens after approval.
- All subtasks must be small enough to complete in a single session and independently verifiable.

**Steps**

## Phase 1: Requirement Analysis

1. **Parse the input** to identify the source type:
   - Free-text description - analyze directly
   - Document reference (e.g., `docs/...`, `openspec/...`) - read and extract requirements
   - Beads task reference (e.g., `beads-123`) - run `bd show <id>` to retrieve details

2. **Explore context** using file reads and search to understand:
   - Related existing code and patterns
   - Dependencies and constraints
   - Similar prior implementations

3. **Inject relevant standards** (if `.agent-os/standards/` exists):
   - Check for standards directory: `ls .agent-os/standards/`
   - If exists, analyze the requirement to identify relevant standards
   - Inject applicable standards using `/standards-inject` or read directly
   - Standards inform implementation patterns and constraints for the plan

4. **Ask clarifying questions** using `AskUserQuestion` with 3-5 non-obvious questions:
   - Focus on edge cases, error handling, and implicit assumptions
   - Probe constraints not stated in the requirement (performance, security, backwards compatibility)
   - Clarify acceptance criteria and verification approach
   - Avoid questions the requirement already answers

## Phase 2: Task Planning

5. **Create or extend the parent beads task**:
   - If input was a beads task - extend it with subtasks
   - Otherwise - run `bd create --title="<requirement summary>" --type=feature|task|bug --priority=2`

6. **Identify logical breakpoints** in the implementation:
   - Group related subtasks into phases (e.g., "data layer", "business logic", "UI", "integration")
   - Each phase should produce a verifiable, working state
   - Small plans (1-3 tasks) need only a final checkpoint
   - Larger plans should have checkpoints after each logical phase
   - Identify **critical points** requiring code review (e.g., security-sensitive code, complex algorithms, API boundaries)

7. **Break down into atomic subtasks** using `bd create`:
   - Each subtask should be independently verifiable
   - Include clear acceptance criteria in the description
   - Sequence with dependencies using `bd dep add <subtask> <depends-on>`
   - **Insert verification checkpoint tasks** at each logical breakpoint:
     - After each phase, add a task: "Checkpoint: Run workflow verification for [phase name]"
     - Checkpoint tasks must include these verification steps from `/workflow:check`:
       1. Run quality checks
       2. Review changes with `jj diff --git`
       3. Commit completed work with `jj split -m "description" .`
       4. Scan for TODO/FIXME comments in modified files
       5. Close completed beads tasks with `bd close`
   - Add a final subtask: "Final checkpoint: Run full workflow completion checks"

8. **Generate the execution plan** with:
   - Ordered list of subtasks with verification steps
   - **Explicit checkpoint tasks** at each breakpoint (not just implied)
   - Files likely to be created or modified per phase
   - Testing approach for each subtask
   - Risks or blockers identified during analysis

**Example plan structure for a multi-phase feature:**
```
Phase 1: Data Layer
  - beads-101: Add migration for user_preferences table
  - beads-102: Implement UserPreferences repository
  - beads-103: Checkpoint: Verify data layer (quality check, jj diff, jj split, bd close)

Phase 2: Business Logic
  - beads-104: Add preference validation service
  - beads-105: Implement preference update commands
  - beads-106: Checkpoint: Verify business logic

Phase 3: UI Integration
  - beads-107: Create preferences form component
  - beads-108: Wire up to commands
  - beads-109: Final checkpoint: Full workflow completion checks
```

## Phase 3: Handoff

9. **Present the plan** to the user including:
   - Summary of the requirement as understood
   - Parent beads task ID and subtask IDs
   - Recommended execution order
   - Any remaining uncertainties or decisions needed

10. **On approval**, remind the user:
   - Start with `bd update <first-subtask> --claim`
   - Complete with `/workflow:check` to verify all steps

**Reference**
- Use `bd ready` to see unblocked tasks
- Use `bd show <id>` to inspect task details
- Use `bd blocked` to see dependency chains
- Run `/workflow:check` before marking work complete

---

## Kick-off Completion Checklist

**Before presenting the plan to the user, verify all steps are complete:**

### Phase 1: Requirement Analysis
- [ ] Parsed input and identified source type (free-text / document / beads task)
- [ ] Explored codebase context (related code, dependencies, prior implementations)
- [ ] Checked for standards and injected relevant ones (if `.agent-os/standards/` exists)
- [ ] Asked 3-5 clarifying questions and received answers

### Phase 2: Task Planning
- [ ] Created or extended parent beads task
- [ ] Identified logical breakpoints and grouped subtasks into phases
- [ ] Created all atomic subtasks with acceptance criteria
- [ ] Added dependencies between subtasks using `bd dep add`
- [ ] Inserted verification checkpoint tasks at each phase boundary
- [ ] Added final checkpoint task for workflow completion

### Phase 3: Handoff Ready
- [ ] Plan summary prepared
- [ ] All beads task IDs documented
- [ ] Execution order clearly stated
- [ ] Remaining uncertainties listed (if any)

**Present this checklist to the user along with the plan.**
