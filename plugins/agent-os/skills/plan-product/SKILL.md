---
name: plan-product
description: Establish foundational product documentation through interactive conversation. Creates files in .agent-os/product/
---

# Plan Product

Establish foundational product documentation through an interactive conversation. Creates mission, roadmap, and tech stack files.

## Important Guidelines

- **Always use AskUserQuestion tool** when asking the user anything
- **Keep it lightweight** — gather enough to create useful docs without over-documenting
- **One question at a time** — don't overwhelm with multiple questions

## Beads Integration

This skill integrates with beads issue tracking when available.

**At start**, check if beads is available:
```bash
command -v bd &>/dev/null
```

If beads is available and roadmap items are created, offer to create tracking epics.

## Process

### Step 1: Check for Existing Product Docs

Check if `.agent-os/product/` exists and contains any of:
- `mission.md`
- `roadmap.md`
- `tech-stack.md`

**If any files exist**, use AskUserQuestion:

```
I found existing product documentation:
- mission.md: [exists/missing]
- roadmap.md: [exists/missing]
- tech-stack.md: [exists/missing]

Would you like to:
1. Start fresh (replace all)
2. Update specific files
3. Cancel

(Choose 1, 2, or 3)
```

If option 2, ask which files to update.
If option 3, stop here.

**If no files exist**, proceed to Step 2.

### Step 2: Gather Product Vision (for mission.md)

Use AskUserQuestion:

```
Let's define your product's mission.

**What problem does this product solve?**

(Describe the core problem or pain point you're addressing)
```

After they respond:

```
**Who is this product for?**

(Describe your target users or audience)
```

After they respond:

```
**What makes your solution unique?**

(What's the key differentiator or approach?)
```

### Step 3: Gather Roadmap (for roadmap.md)

Use AskUserQuestion:

```
Now let's outline your development roadmap.

**What are the must-have features for launch (MVP)?**

(List the core features needed for the first usable version)
```

After they respond:

```
**What features are planned for after launch?**

(List features you'd like to add in future phases, or say "none yet")
```

### Step 4: Establish Tech Stack (for tech-stack.md)

First, check if `.agent-os/standards/global/tech-stack.md` exists.

**If tech-stack standard exists**, read it and use AskUserQuestion:

```
I found a tech stack standard in your standards:

[Summarize key technologies]

Does this project use the same tech stack, or does it differ?

1. Same as standard (use as-is)
2. Different (I'll specify)

(Choose 1 or 2)
```

If option 1, use the standard's content.
If option 2, ask them to specify.

**If no tech-stack standard exists** (or they chose option 2):

```
**What technologies does this project use?**

Please describe your tech stack:
- Frontend: (e.g., React, Vue, vanilla JS, or N/A)
- Backend: (e.g., Rails, Node, Django, or N/A)
- Database: (e.g., PostgreSQL, MongoDB, or N/A)
- Other: (hosting, APIs, tools, etc.)
```

### Step 5: Generate Files

Create `.agent-os/product/` if it doesn't exist.

#### mission.md

```markdown
# Product Mission

## Problem

[What problem this product solves]

## Target Users

[Who this product is for]

## Solution

[What makes the solution unique]
```

#### roadmap.md

```markdown
# Product Roadmap

## Phase 1: MVP

[Must-have features for launch]

## Phase 2: Post-Launch

[Planned future features, or "To be determined"]
```

#### tech-stack.md

```markdown
# Tech Stack

## Frontend

[Frontend technologies, or "N/A"]

## Backend

[Backend technologies, or "N/A"]

## Database

[Database choice, or "N/A"]

## Other

[Other tools, hosting, services]
```

### Step 6: Create Roadmap Beads (if available)

If beads is available and roadmap phases were defined:

```
Create beads to track roadmap phases?

- Epic: "Phase 1: MVP"
- Epic: "Phase 2: Post-Launch"

Create these epics? (yes / no)
```

If yes:
```bash
bd create "Phase 1: MVP" -t epic -p 1
bd create "Phase 2: Post-Launch" -t epic -p 2
```

### Step 7: Confirm Completion

```
✓ Product documentation created:

  .agent-os/product/mission.md
  .agent-os/product/roadmap.md
  .agent-os/product/tech-stack.md

Review these files to ensure they accurately capture your product vision.
You can edit them directly or run /plan-product again to update.
```

## Tips

- If the user provides brief answers, that's fine — docs can be expanded later
- If they want to skip a section, create the file with "To be defined"
- The `/spec` command reads these files when planning features
