---
name: standards-discover
description: Extract tribal knowledge from your codebase into documented standards. Creates files in .agent-os/standards/project/
---

# Standards Discover

Extract tribal knowledge from your codebase into concise, documented standards.

## Important Guidelines

- **Always use AskUserQuestion tool** when asking the user anything
- **Write concise standards** — Use minimal words. Standards must be scannable by AI agents without bloating context windows.
- **Offer suggestions** — Present options the user can confirm, choose between, or correct.

## Beads Integration

This skill integrates with beads issue tracking when available.

**At start of session**, check if beads is available:
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

If they choose 1, proceed without beads integration (skip all bead-related steps below).

## Process

### Step 1: Determine Focus Area

Check if the user specified an area when running this command. If they did, skip to Step 2.

If no area was specified:

1. Analyze the codebase structure (folders, file types, patterns)
2. Identify 3-5 major areas. Examples:
   - **Frontend areas:** UI components, styling/CSS, state management, forms, routing
   - **Backend areas:** API routes, database/models, authentication, background jobs
   - **Cross-cutting:** Error handling, validation, testing, naming conventions, file structure
3. Use AskUserQuestion to present the areas:

```
I've identified these areas in your codebase:

1. **API Routes** (src/api/) — Request handling, response formats
2. **Database** (src/models/, src/db/) — Models, queries, migrations
3. **React Components** (src/components/) — UI patterns, props, state
4. **Authentication** (src/auth/) — Login, sessions, permissions

Which area should we focus on for discovering standards? (Pick one, or suggest a different area)
```

Wait for user response before proceeding.

### Step 2: Analyze & Present Findings

Once an area is determined:

1. Read key files in that area (5-10 representative files)
2. Look for patterns that are:
   - **Unusual or unconventional** — Not standard framework/library patterns
   - **Opinionated** — Specific choices that could have gone differently
   - **Tribal** — Things a new developer wouldn't know without being told
   - **Consistent** — Patterns repeated across multiple files

3. Use AskUserQuestion to present findings and let user select:

```
I analyzed [area] and found these potential standards worth documenting:

1. **API Response Envelope** — All responses use { success, data, error } structure
2. **Error Codes** — Custom error codes like AUTH_001, DB_002 with specific meanings
3. **Pagination Pattern** — Cursor-based pagination with consistent param names

Which would you like to document?

Options:
- "Yes, all of them"
- "Just 1 and 3"
- "Add: [your suggestion]"
- "Skip this area"
```

Wait for user selection before proceeding.

### Step 3: Ask Why, Then Draft Each Standard

**IMPORTANT:** For each selected standard, complete this full loop before moving to the next:

1. **Ask 1-2 clarifying questions** about the "why" behind the pattern
2. **Wait for user response**
3. **Draft the standard** incorporating their answer
4. **Confirm with user** before creating the file
5. **Create the file** if approved

Example questions:
- "What problem does this pattern solve? Why not use the default/common approach?"
- "Are there exceptions where this pattern shouldn't be used?"
- "What's the most common mistake a developer or agent makes with this?"

**Do NOT batch all questions upfront.** Process one standard at a time.

### Step 4: Create the Standard File

For each standard (after completing Step 3's Q&A):

1. Determine the appropriate folder (create if needed):
   - `api/`, `database/`, `javascript/`, `css/`, `backend/`, `testing/`, `global/`

2. Check if a related standard file already exists — append to it if so

3. Draft the content and use AskUserQuestion to confirm:

```
Here's the draft for api/response-format.md:

---
# API Response Format

All API responses use this envelope:

\`\`\`json
{ "success": true, "data": { ... } }
{ "success": false, "error": { "code": "...", "message": "..." } }
\`\`\`

- Never return raw data without the envelope
- Error responses must include both code and message
- Success responses omit the error field entirely
---

Create this file? (yes / edit: [your changes] / skip)
```

4. Create or update the file in `.agent-os/standards/project/[folder]/`

### Step 5: Update the Index

After all standards are created:

1. Scan `.agent-os/standards/project/` for all `.md` files
2. For each new file without an index entry, use AskUserQuestion:

```
New standard needs an index entry:
  File: api/response-format.md

Suggested description: "API response envelope structure and error format"

Accept this description? (yes / or type a better one)
```

3. Update `.agent-os/standards/project/index.yml`

### Step 6: Create Beads for Follow-up (if beads available)

If patterns were identified but not documented (user said "skip" or "later"), offer to create tracking beads:

```
I identified patterns that weren't documented yet. Create tracking issues?

1. Document API versioning pattern
2. Document request validation pattern

Create beads for these? (yes / no / select: 1)
```

If yes, create beads:
```bash
bd create "Document API versioning pattern in standards" -t chore -p 3
bd create "Document request validation pattern in standards" -t chore -p 3
```

### Step 7: Offer to Continue

Use AskUserQuestion:

```
Standards created for [area]:
- api/response-format.md
- api/error-codes.md

Would you like to discover standards in another area, or are we done?
```

## Output Location

All discovered standards: `.agent-os/standards/project/[folder]/[standard].md`
Project index file: `.agent-os/standards/project/index.yml`

Note: Discovered standards go to `project/`, not `baseline/`. The baseline is managed by `/standards init` and `/standards update`.

## Writing Concise Standards

Standards will be injected into AI context windows. Every word costs tokens:

- **Lead with the rule** — State what to do first, explain why second (if needed)
- **Use code examples** — Show, don't tell
- **Skip the obvious** — Don't document what the code already makes clear
- **One standard per concept** — Don't combine unrelated patterns
- **Bullet points over paragraphs** — Scannable beats readable
