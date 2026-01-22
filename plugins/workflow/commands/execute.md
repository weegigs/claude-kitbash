---
name: Workflow: Execute
description: Execute the current plan aggressively. Find plan state, work through tasks, minimize interruptions.
category: Workflow
tags: [workflow, execution, beads, ultrawork]
---

**Mode**: Ultrawork — aggressive execution with minimal interruption. Ask questions only when blocked.

**Guardrails**
- Execute tasks in dependency order. Never skip ahead.
- Parallelize independent work where possible.
- Ask questions only when truly blocked, not for confirmation.
- Run verification at checkpoints, not after every change.
- Inject relevant standards once at start, reference throughout.

---

## Phase 1: Locate Plan

1. **Find active plan** by checking in order:
   - In-progress beads: `bd list --status=in_progress`
   - Recent specs: `ls -t .agent-os/specs/ | head -1`
   - Ready beads with subtasks: `bd ready` then `bd show <id>` for structure

2. **If no plan found**:
   ```
   No active plan found. Options:
   1. Run /kick-off to create a plan
   2. Specify a beads task ID to execute
   3. Point me to a spec directory
   ```
   Wait for user input.

3. **Load plan context**:
   - Read spec files if in `.agent-os/specs/`
   - Run `bd show <parent-id>` for beads plan structure
   - Identify all subtasks and their dependencies

## Phase 2: Assess State

4. **Map execution state**:
   ```
   Plan: [title]
   
   Completed:
     ✓ beads-101: Add migration
     ✓ beads-102: Implement repository
   
   In Progress:
     → beads-103: Add validation service (claimed)
   
   Remaining:
     ○ beads-104: Wire up commands
     ○ beads-105: Final checkpoint
   
   Blocked:
     ⊘ beads-106: Integration tests (waiting on beads-104)
   ```

5. **Inject standards** (once, at start):
   - Check `.agent-os/standards/` exists
   - Identify standards relevant to remaining work
   - Read and internalize — do not re-inject per task

## Phase 3: Execute

6. **Work loop** — repeat until plan complete:

   a. **Select next task**:
      - Continue in-progress task if exists
      - Otherwise, pick highest-priority unblocked task
      - Claim it: `bd update <id> --claim`

   b. **Execute task**:
      - Read task acceptance criteria
      - Implement without asking for confirmation
      - Use standards as reference (already injected)
      - Make decisions autonomously when reasonable
      - Only ask when genuinely blocked (missing info, ambiguous requirement, external dependency)

   c. **Verify task** (lightweight):
      - Run relevant quality checks (lint, typecheck)
      - Check acceptance criteria met
      - If issues found, fix immediately

   d. **Complete task**:
      - Commit changes: `jj split -m "description" .`
      - Close task: `bd close <id>`
      - Update TodoWrite if tracking

   e. **Check for checkpoint**:
      - If task was a checkpoint task, run full `/check` verification
      - Otherwise, continue to next task

7. **Handle blockers**:
   - Technical blocker → attempt to resolve, ask only if stuck after 2 attempts
   - Missing information → ask concise question, continue other work while waiting
   - External dependency → note it, move to next unblocked task

## Phase 4: Completion

8. **Final verification** when all tasks done:
   - Run `/check` for full workflow verification
   - Ensure all beads closed including parent
   - Report completion summary

9. **Completion report**:
   ```
   Plan complete: [title]
   
   Executed:
     ✓ beads-101: Add migration
     ✓ beads-102: Implement repository
     ✓ beads-103: Add validation service
     ✓ beads-104: Wire up commands
     ✓ beads-105: Final checkpoint
   
   Commits:
     abc1234 Added user_preferences migration
     def5678 Implemented UserPreferences repository
     ...
   
   All verification passed. Parent task closed.
   ```

---

## Ultrawork Principles

**DO**:
- Make reasonable decisions without asking
- Batch related questions if multiple blockers arise
- Continue with other tasks while waiting for answers
- Trust the plan structure from kick-off
- Use standards as guardrails, not checklists

**DON'T**:
- Ask "should I proceed?" — just proceed
- Ask "is this approach okay?" — use your judgment
- Stop for minor uncertainties — make a call, note if needed
- Re-verify after every small change — batch at checkpoints
- Explain what you're about to do — just do it

**ASK ONLY WHEN**:
- Requirement is genuinely ambiguous (multiple valid interpretations with different outcomes)
- External resource needed (API key, access, third-party decision)
- Significant deviation from plan required
- Blocker after 2 resolution attempts

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `bd show <id>` | Task details and acceptance criteria |
| `bd update <id> --claim` | Start working on task |
| `bd close <id>` | Complete task |
| `bd blocked` | See dependency chains |
| `jj split -m "msg" .` | Commit changes |
| `/check` | Full verification at checkpoints |
