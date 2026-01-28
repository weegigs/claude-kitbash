---
name: execute
description: Execute an existing plan aggressively with minimal interruption. Use after /kick-off approval to implement the planned work.
---

# Workflow Execute

Aggressive execution mode. Find plan, work through tasks, minimize interruptions.

## Mode: Ultrawork

- Execute in dependency order, never skip ahead
- Parallelize independent work where possible
- Ask questions only when truly blocked
- Run verification at checkpoints, not after every change
- Code review required before commits

## Guardrails

- **No arbitrary deferrals** — complete all planned work
- **No silent TODOs** — every TODO must be discussed and tracked
- **No scope reduction without approval** — ask before deferring
- **Dual code review required** — Codex + principles agent

## Process

### Phase 1: Locate Plan

1. **Find active plan** (check in order):
   - TodoWrite from `/kick-off`
   - In-progress beads: `bd list --status=in_progress`
   - Recent specs: `ls -t .agent-os/specs/ | head -1`
   - Ready beads: `bd ready` then `bd show <id>`

2. **If no plan found**:
   ```
   No active plan. Options:
   1. Run /kick-off to create a plan
   2. Specify a beads task ID
   3. Point to a spec in .agent-os/specs/
   ```

3. **Load context**:
   - Read TodoWrite for structure
   - `bd show <parent-id>` for plan structure
   - Note parent epic ID — new tasks belong to it

### Phase 2: Assess State

4. **Map execution state**:
   ```
   Plan: [title]

   Completed:  ✓ beads-101, beads-102
   In Progress: → beads-103 (claimed)
   Remaining:  ○ beads-104, beads-105
   Blocked:    ⊘ beads-106 (waiting on 104)
   ```

5. **Inject standards and language skills** (once at start):
   - Read relevant standards from `.agent-os/standards/`
   - Detect primary languages from files to be modified:
     - `.rs` → Load `@rust` (+ `@tokio` if async)
     - `.ts`, `.tsx` → Load `@typescript`
     - `.svelte` → Load `@svelte` + `@typescript`
   - Load `@principles` for quality standards
   - Do not re-inject per task

### Phase 3: Execute

6. **Work loop** — repeat until complete:

   **a. Select next task**
   - Continue in-progress if exists
   - Otherwise pick highest-priority unblocked
   - Claim: `bd update <id> --claim`

   **b. Execute task**
   - Read acceptance criteria
   - Implement without asking for confirmation
   - Make decisions autonomously when reasonable
   - Only ask when genuinely blocked

   **c. Verify task** (lightweight)
   - Run lint, typecheck
   - Check acceptance criteria met
   - Fix issues immediately

   **d. Code review** (required)
   - Run in parallel:
     1. `/codex-review`
     2. Agent with `@principles`
   - Address issues from BOTH before committing

   **e. Complete task**
   - Commit: `jj split -m "description" .`
   - Close: `bd close <id>`
   - Update TodoWrite

   **f. Check for checkpoint**
   - If checkpoint task, run full `/check`
   - Otherwise continue to next

7. **Handle blockers**:
   - Technical → attempt 2x, then ask
   - Missing info → ask concisely, continue other work
   - External dependency → note it, move to next task

8. **Handle discovered work**:
   - Never add TODO without user approval
   - Pause and explain what you found
   - Ask: "Handle now, or create beads task?"
   - If creating: `bd create --title="..." --parent=<epic-id>`

### Phase 4: Completion

9. **Final verification**:
   - Run `/check`
   - Ensure all beads closed including parent
   - Report completion summary

10. **Completion report**:
    ```
    Plan complete: [title]

    Executed: ✓ beads-101, 102, 103, 104, 105

    Commits:
      abc1234 Added user_preferences migration
      def5678 Implemented repository

    All verification passed.
    ```

## Ultrawork Principles

**DO:**
- Make reasonable decisions without asking
- Batch questions if multiple blockers
- Continue other tasks while waiting
- Trust the plan from kick-off

**DON'T:**
- Ask "should I proceed?" — just proceed
- Ask "is this approach okay?" — use judgment
- Stop for minor uncertainties
- Skip tasks or reduce scope without approval
- Add TODOs without discussion

**ASK ONLY WHEN:**
- Requirement genuinely ambiguous
- External resource needed
- Significant deviation required
- Blocked after 2 attempts
- Discovered unplanned work

## TODO Protocol

- Never write TODO without asking first
- If approved, create beads: `bd create --title="TODO: ..." --parent=<epic>`
- Reference in code: `// TODO(beads-XXX): description`
- No orphan TODOs

## Quick Reference

| Command | Purpose |
|---------|---------|
| `bd show <id>` | Task details |
| `bd update <id> --claim` | Start task |
| `bd close <id>` | Complete task |
| `bd create --parent=<epic>` | Add to epic |
| `jj split -m "msg" .` | Commit |
| `/check` | Full verification |
