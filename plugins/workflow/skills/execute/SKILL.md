---
name: execute
description: Execute an existing plan aggressively with minimal interruption. Use after /kick-off approval to implement the planned work.
---

# Workflow Execute

Aggressive execution mode. Find plan, work through tasks, minimize interruptions.

## Mindset

See [references/mindset.md](references/mindset.md) for the "hard-nosed perfectionist" philosophy.

**Key principles:**
- Every TODO is a lie — complete now or get approval
- Workarounds compound — fix root causes
- Scope is sacred — only user can reduce it
- Done means done — partial completion is not completion

## Mode: Ultrawork

- Execute in dependency order, never skip ahead
- Parallelize independent work where possible
- Ask questions only when truly blocked
- Run verification at checkpoints, not after every change
- Code review required before commits

## Task Tracking

Detect at start:
```bash
command -v bd &> /dev/null && echo "beads" || echo "todowrite"
```

See [references/task-fallback.md](references/task-fallback.md) for TodoWrite fallback patterns.

## Knowledge Base

Detect ByteRover:
```bash
command -v brv &> /dev/null && [ -d ".brv" ] && echo "byterover" || echo "none"
```

- **byterover available**: Curate discoveries after significant work
- **byterover unavailable**: Skip curation steps

## Process

### Phase 1: Locate Plan

1. **Find active plan** (check in order):
   - TodoWrite from `/kick-off`
   - In-progress tasks: `bd list --status=in_progress` (or TodoWrite)
   - Recent specs: `.agent-os/specs/`
   - Ready tasks: `bd ready`

2. **If no plan found** — recommend `/kick-off`

3. **Load context**:
   - Read TodoWrite for structure
   - Note parent epic — new tasks belong to it

### Phase 2: Assess State

4. **Map execution state**:
   ```
   Plan: [title]

   Completed:  ✓ task-1, task-2
   In Progress: → task-3
   Remaining:  ○ task-4, task-5
   Blocked:    ⊘ task-6 (waiting on task-4)
   ```

5. **Inject standards and skills** (once at start):

   **Standards** (if agent-os configured):
   ```
   If .agent-os/standards/ exists:
     Invoke /standards-inject (auto-suggest mode)
   ```

   **Language skills** — detect from files to modify:
   - `.rs` → Load `@rust` (+ `@tokio` if async)
   - `.ts`, `.tsx` → Load `@typescript`
   - `.svelte` → Load `@svelte` + `@typescript`
   
   **Always load `@principles`** for quality standards.

### Phase 3: Execute

6. **Work loop** — repeat until complete:

   **a. Select next task**
   - Continue in-progress if exists
   - Otherwise pick highest-priority unblocked
   - Claim task (beads: `bd update --claim`, TodoWrite: mark in_progress)

   **b. Execute task**
   - Read acceptance criteria
   - Implement without asking for confirmation
   - Make decisions autonomously when reasonable
   - Only ask when genuinely blocked

   **c. Verify task** (lightweight)
   - Run lint, typecheck
   - Check acceptance criteria met
   - Fix issues immediately

   **d. Code review** (required before commit)
   
   Run in parallel:
   1. `/codex-review` — if Codex CLI available
   2. `@reviewer` agent — always (uses `@principles` + language skills)
   
   Both must pass. If Codex unavailable, `@reviewer` agent alone is sufficient.
   
   Address all issues before committing.

   **e. Complete task**
   - Commit: `jj split -m "description" .`
   - Close task (beads: `bd close`, TodoWrite: mark completed)
   - Update TodoWrite

   **f. Check for checkpoint**
   - If checkpoint task, run full `/check`
   - Otherwise continue to next

7. **Handle blockers**:
   - Technical → attempt 2x, then ask
   - Missing info → ask concisely, continue other work
   - External dependency → note it, move to next task

8. **Handle discovered work**:
   - See [references/mindset.md](references/mindset.md) for protocol
   - Never add TODO without user approval
   - Pause and explain what you found
   - If creating task: add to epic

### Phase 4: Completion

9. **Final verification**:
   - Run `/check`
   - Ensure all tasks closed including parent
   - Report completion summary

10. **Curate discoveries** (if byterover available):
    
    If significant discoveries were made during execution:
    ```bash
    brv curate "Discovery context" -f relevant/file.rs
    ```
    
    Worth curating:
    - Bug root causes and non-obvious fixes
    - Architectural decisions and rationale
    - Gotchas that would save future time
    - Domain knowledge not obvious from code
    
    Skip if work was routine implementation.

11. **Completion report**:
    ```
    Plan complete: [title]

    Executed: ✓ all tasks

    Commits:
      abc1234 Added user_preferences migration
      def5678 Implemented repository

    All verification passed.
    ```

## Cop-Out Patterns

See [references/cop-outs.md](references/cop-outs.md) for patterns to avoid.

**Never do:**
- Add TODO without asking
- Use `as any` or lint suppressions
- Say "out of scope" without user approval
- Skip tests or swallow errors

## Quick Reference

| Operation | With beads | Without beads |
|-----------|------------|---------------|
| Show task | `bd show <id>` | Read TodoWrite |
| Start task | `bd update --claim` | Mark in_progress |
| Complete | `bd close <id>` | Mark completed |
| Add task | `bd create --parent=<epic>` | Add to TodoWrite |
| Commit | `jj split -m "msg" .` | Same |
| Full verify | `/check` | Same |
