---
name: Workflow: Check
description: Verify workflow completion before ending session.
category: Workflow
tags: [workflow, verification, beads, jj]
---

Before completing, verify you followed the development workflow.

**If no code changes were made** (research, exploration, or planning session), you may complete without these steps.

---

## Version Control: jj (NOT git)

This project uses **jj (Jujutsu)**, not git. All VCS operations must use jj:
- `jj status` (not `git status`)
- `jj diff --git` (not `git diff`)
- `jj split -m "message" .` (not `git add` + `git commit`)

## Code Quality

Reference `@principles` for complete standards. Key principles:
- **Architecture**: Imperative shell, functional core (pure functions + thin I/O layer)
- **Design**: Illegal states unrepresentable, single responsibility, open-closed, parse don't validate, composition over inheritance, explicit dependencies, fail fast, domain errors, immutability, no stringly-typed, happy path left
- **Standards**: Clarity over brevity, no lint suppressions, no workarounds

1. **Quality checks** - Did you run quality checks (linting, type checking, tests)?
2. **Code review** - Request independent reviews (run in parallel):
   - **Codex review**: Use `/codex-review` or MCP codex tool with `jj diff --git` output
   - **cleaner review**: Use `@cleaner` agent to review changes
   - Both reviewers use `@principles` as their quality standard
   - Address any issues identified before proceeding
   - Self-review via `jj diff --git` alone does NOT satisfy this requirement
3. **Commits** - Did you use `jj split -m "description" .` to commit all modified files?
   - Messages must describe **what changed**, not process steps
   - Good: "Added validation for roster names", "Fixed cost calculation overflow"
   - Bad: "Completed phase 2", "Finished AM-123", "Implemented per spec"

## Task Management

4. **TodoWrite cleared** - Are all TodoWrite items completed or removed? No pending todos should remain.
5. **Beads closed** - Have you closed (`bd close`) any beads tasks that were completed? If closing the last subtask of a parent task, close the parent too.

## Deferred Work

6. **Code markers scanned** - Scan all files you created or modified for work markers (use `rg`, don't rely on memory):
   - Search patterns: `TODO`, `FIXME`, `NOTE`, `Note:`, `XXX`, `HACK`
   - **Assess each marker's content** to determine if it indicates:
     - Deferred work or future improvements → requires tracking in Beads
     - Workarounds or technical debt → requires tracking in Beads
     - Legitimate explanatory notes → no action needed
   - For markers indicating deferred work:
     - Resolve it now if possible
     - If not, create a Beads task to track the work
     - Explain to the user why it cannot be completed now and get their agreement
7. **Other deferred work** - If any other work is being deferred:
   - Is it truly not achievable now (not just skipped for convenience)?
   - Has the deferred work been tracked in detail in Beads?
   - Has the user explicitly agreed to the deferment?

---

If you made code changes, please complete these steps before finishing.
If you don't feel a step is necessary, explain why to the user.
