---
name: spec
description: Shape and plan significant work with optional review. Usage: /spec add login screen OR /spec add login screen with no review
---

# Spec

Gather context and structure planning for significant work.

## Usage

```
/spec <description>                    # With review (default)
/spec <description> with no review     # Skip review step
```

**Examples:**
```
/spec add user comment system
/spec implement OAuth login with no review
/spec refactor payment processing
```

## Important Guidelines

- **Always use AskUserQuestion tool** when asking the user anything
- **Offer suggestions** — Present options the user can confirm, adjust, or correct
- **Keep it lightweight** — This is shaping, not exhaustive documentation

## Review Mode

By default, the completed plan is sent for independent review before execution.

**To skip review**, include "with no review" at the end of the command.

Review uses:
1. **Codex MCP** (if available) — Independent AI review via Codex
2. **spec-reviewer agent** (fallback) — Dedicated review agent

## Beads Integration

This skill integrates with beads issue tracking when available.

**At start**, check if beads is available:
```bash
command -v bd &>/dev/null
```

**If beads is NOT available**, ask the user:
```
Beads issue tracking is not installed. Would you like to:

1. Continue without issue tracking (simpler workflow)
2. Install beads first: `brew install steveyegge/beads/bd`

(Choose 1 or 2)
```

If they choose 1, proceed without beads (skip bead-related steps).

## Process

### Step 1: Parse Command

Extract the feature description from the command arguments.

Check if "with no review" is present at the end — if so, set `skipReview = true`.

### Step 2: Clarify What We're Building

Use AskUserQuestion to understand the scope:

```
What are we building? You said: "[description from command]"

(Add more detail if needed, or say "that's it" to proceed)
```

Based on their response, ask 1-2 clarifying questions if scope is unclear:
- "Is this a new feature or a change to existing functionality?"
- "What's the expected outcome when this is done?"
- "Are there any constraints or requirements I should know about?"

### Step 3: Gather Visuals

Use AskUserQuestion:

```
Do you have any visuals to reference?

- Mockups or wireframes
- Screenshots of similar features
- Examples from other apps

(Paste images, share file paths, or say "none")
```

### Step 4: Identify Reference Implementations

Use AskUserQuestion:

```
Is there similar code in this codebase I should reference?

Examples:
- "The comments feature is similar to what we're building"
- "Look at how src/features/notifications/ handles real-time updates"
- "No existing references"
```

If references are provided, read and analyze them.

### Step 5: Check Product Context

Check if `.agent-os/product/` exists.

If it exists, read key files and use AskUserQuestion:

```
I found product context in .agent-os/product/. Should this feature align with any specific product goals?

Key points from your product docs:
- [summarize relevant points]

(Confirm alignment or note any adjustments)
```

### Step 6: Surface Relevant Standards

Read `.agent-os/standards/index.yml` to identify relevant standards.

Use AskUserQuestion to confirm:

```
Based on what we're building, these standards may apply:

1. **api/response-format** — API response envelope structure
2. **api/error-handling** — Error codes and exception handling
3. **database/migrations** — Migration patterns

Should I include these in the spec? (yes / adjust: remove 3, add frontend/forms)
```

Read confirmed standards files.

### Step 7: Generate Spec Folder Name

Create folder name:
```
YYYY-MM-DD-HHMM-{feature-slug}/
```

Where:
- Date/time is current timestamp
- Feature slug is derived from description (lowercase, hyphens, max 40 chars)

Example: `2026-01-15-1430-user-comment-system/`

### Step 8: Structure the Plan

Build the plan with **Task 1 always being "Save spec documentation"**:

```
Here's the plan structure. Task 1 saves all our shaping work before implementation begins.

---

## Task 1: Save Spec Documentation

Create `.agent-os/specs/{folder-name}/` with:

- **plan.md** — This full plan
- **shape.md** — Shaping notes (scope, decisions, context)
- **standards.md** — Relevant standards that apply
- **references.md** — Pointers to reference implementations
- **visuals/** — Any mockups or screenshots provided

## Task 2: [First implementation task]

[Description based on the feature]

## Task 3: [Next task]

...

---

Does this plan structure look right?
```

### Step 9: Complete the Plan

After Task 1 is confirmed, build remaining implementation tasks based on:
- Feature scope from Step 2
- Patterns from references (Step 4)
- Constraints from standards (Step 6)

Each task should be specific and actionable.

### Step 10: Review Plan (unless skipped)

**If `skipReview` is false:**

Check if Codex MCP is available. If so, submit plan for review:

```
Submitting plan for independent review...
```

Use Codex or spawn `spec-reviewer` agent with the full plan. See `@spec-review` skill for methodology.

Present review findings:

```
Review complete. Findings:

✓ All requirements addressed
⚠ Consider: [suggestion from review]
✗ Missing: [issue identified]

Address these before proceeding? (yes / proceed anyway / adjust plan)
```

**If `skipReview` is true:**
```
Skipping review as requested.
```

### Step 11: Create Beads (if available)

If beads is available, offer to create tracking issues:

```
Create beads to track this work?

- Epic: "{Feature Name}"
  - Task 1: Save spec documentation
  - Task 2: [implementation task]
  - Task 3: [implementation task]
  ...

Create these beads? (yes / no)
```

If yes:
```bash
bd create "{Feature Name}" -t epic
# Note the epic ID, then:
bd create "Save spec documentation" -t task --parent <epic-id>
bd create "[implementation task]" -t task --parent <epic-id>
# ... for each task
```

### Step 12: Ready for Execution

```
Plan complete. When you approve and execute:

1. Task 1 will save all spec documentation first
2. Then implementation tasks will proceed

Ready to start? (approve / adjust)
```

## Output Structure

```
.agent-os/specs/{YYYY-MM-DD-HHMM-feature-slug}/
├── plan.md           # The full plan
├── shape.md          # Shaping decisions and context
├── standards.md      # Which standards apply and key points
├── references.md     # Pointers to similar code
└── visuals/          # Mockups, screenshots (if any)
```

## File Contents

### shape.md

```markdown
# {Feature Name} — Shaping Notes

## Scope

[What we're building]

## Decisions

- [Key decisions made during shaping]
- [Constraints or requirements noted]

## Context

- **Visuals:** [List or "None"]
- **References:** [Code references studied]
- **Product alignment:** [Notes or "N/A"]

## Standards Applied

- api/response-format — [why it applies]
- api/error-handling — [why it applies]
```

### standards.md

```markdown
# Standards for {Feature Name}

The following standards apply to this work.

---

## api/response-format

[Full content of the standard file]

---

## api/error-handling

[Full content of the standard file]
```

### references.md

```markdown
# References for {Feature Name}

## Similar Implementations

### {Reference 1 name}

- **Location:** `src/features/comments/`
- **Relevance:** [Why this is relevant]
- **Key patterns:** [What to borrow]
```

## Tips

- **Keep shaping fast** — Capture enough to start, refine as you build
- **Visuals are optional** — Not every feature needs mockups
- **Standards guide, not dictate** — They inform but aren't mandatory
- **Specs are discoverable** — Future developers can understand what was built and why
