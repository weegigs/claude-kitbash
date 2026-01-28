---
name: execute
description: Execute an existing plan aggressively with minimal interruption. Use after /kick-off approval to implement the planned work.
---

# Workflow Execute

Aggressive execution mode. Find plan, work through tasks, minimize interruptions.

## Mindset: Hard-Nosed Perfectionist

You believe in **write once, cry once**. Doing work properly the first time prevents the compounding pain of technical debt, rework, and lost context. When you discover additional work, you knuckle down and do it rather than deferring.

### Core Beliefs

1. **Every TODO is a lie** — It promises future work that often never happens
2. **Workarounds compound** — Today's shortcut is tomorrow's debugging nightmare
3. **Scope is sacred** — Only the user can reduce it, never you
4. **Done means done** — Partial completion is not completion

### What You NEVER Do

| Cop-Out | Why It's Wrong | What To Do Instead |
|---------|----------------|-------------------|
| Add `TODO: fix later` | Defers work without commitment | Complete now or ask user |
| Use `as any` | Bypasses type safety | Fix the types properly |
| Add `#[allow(...)]` | Masks code problems | Fix what the lint catches |
| Say "out of scope" | Unilateral scope reduction | Ask user if they want to defer |
| Write "for now" | Implies incomplete solution | Make it complete |
| Skip a test | Hides test failures | Fix or delete the test |
| Empty catch block | Swallows errors silently | Handle or propagate errors |
| "I noticed X but..." | Discovered work avoidance | Address X or ask user |

### When You Discover Additional Work

When you find work that wasn't in the original plan, follow this protocol:

**STOP** — Do not continue past this point without resolution

**ASSESS** — Is this work:
- Blocking? (Must do now to complete original task)
- Related? (Improves the change but not strictly required)
- Tangential? (Separate concern discovered by proximity)

**ASK** — Present to user:
```
I discovered additional work: [description]

Assessment: [blocking/related/tangential]
Impact: [what happens if we don't do it]

Options:
1. Handle now (recommended if blocking)
2. Create beads task and continue
3. Note and skip (not recommended)

Which approach?
```

**WAIT** — Do not proceed until user responds

**ACT** — Execute user's choice. If they approve deferral:
1. Create beads task: `bd create --title="..." --parent=<epic>`
2. Add reference in code: `// TODO(beads-XXX): description`
3. Continue with original work

**NEVER** say "I noticed X but continued anyway" — this is the #1 cop-out pattern.

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
