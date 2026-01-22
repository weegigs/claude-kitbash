---
name: standards-inject
description: Inject relevant standards into the current context. Resolves project > baseline. Supports auto-suggest and explicit modes.
---

# Standards Inject

Inject relevant standards into the current context, formatted appropriately for the situation.

## Usage Modes

### Auto-Suggest Mode (no arguments)
```
/standards-inject
```
Analyzes context and suggests relevant standards.

### Explicit Mode (with arguments)
```
/standards-inject api                           # All standards in api/
/standards-inject api/response-format           # Single file
/standards-inject api/response-format api/auth  # Multiple files
```
Directly injects specified standards without suggestions.

## Resolution Order

Standards are resolved in this order:
1. Check `.agent-os/standards/project/{path}` — if exists, use it
2. Fall back to `.agent-os/standards/baseline/{path}`

Project files shadow baseline files at the same path. This allows projects to override profile defaults.

## @baseline Reference

Project standards can reference baseline content:

```markdown
# Error Handling (Project Override)

@baseline(rust/error-handling)

## Project Additions

Our additional error variants...
```

When injecting, expand `@baseline(path)` by reading the baseline file.

## Process

### Step 1: Detect Context Scenario

Before injecting standards, determine which scenario we're in:

**Three scenarios:**

1. **Conversation** — Regular chat, implementing code, answering questions
2. **Creating a Skill** — Building a skill file
3. **Shaping/Planning** — In plan mode, building a spec, running `/spec`

**Detection logic:**

- If currently in plan mode OR conversation clearly mentions "spec", "plan", "shape" → **Shaping/Planning**
- If conversation clearly mentions creating a skill → **Creating a Skill**
- Otherwise → **Ask to confirm**

**If neither skill nor plan is clearly detected**, use AskUserQuestion:

```
I'll inject the relevant standards. How should I format them?

1. **Conversation** — Read standards into our chat (for implementation work)
2. **Skill** — Output file references to include in a skill you're building
3. **Plan** — Output file references to include in a plan/spec

Which scenario? (1, 2, or 3)
```

### Step 2: Read the Index (Auto-Suggest Mode)

Read `.agent-os/standards/index.yml` to get available standards and their descriptions.

If no standards found:
```
No standards found. Options:
- Run /standards init to set up baseline from a profile
- Run /standards discover to document project-specific patterns
```

### Step 3: Analyze Work Context

Look at the current conversation to understand:
- What type of work? (API, database, UI, etc.)
- What technologies mentioned?
- What's the goal?

### Step 4: Match and Suggest

Match index descriptions against the context. Use AskUserQuestion:

```
Based on your task, these standards may be relevant:

1. **api/response-format** — API response envelope structure, status codes
2. **api/error-handling** — Error codes, exception handling, error responses
3. **global/naming** — File naming, variable naming conventions

Inject these standards? (yes / just 1 and 3 / add: database/migrations / none)
```

Keep suggestions focused — typically 2-5 standards.

### Step 5: Inject Based on Scenario

#### Scenario: Conversation

Read the standards and announce them:

```
I've read the following standards as they are relevant to what we're working on:

--- Standard: api/response-format ---

[full content of the standard file]

--- End Standard ---

**Key points:**
- All API responses use { success, data, error } envelope
- Error codes follow AUTH_xxx, DB_xxx pattern
```

#### Scenario: Creating a Skill

Ask how to include:

```
How should these standards be included in your skill?

1. **References** — Add @ file paths (keeps skill lightweight, stays in sync)
2. **Copy content** — Paste full content (self-contained)

Which approach? (1 or 2)
```

**If References:**
```
Include references to these standards files in your skill:

@.agent-os/standards/api/response-format.md
@.agent-os/standards/api/error-handling.md
```

**If Copy content:**
Output the full content of each standard.

#### Scenario: Shaping/Planning

Same options as Creating a Skill, but framed for plan inclusion.

### Step 6: Surface Related Skills (Conversation only)

Check if related skills exist:

```
Related Skills you might want to use:
- create-api-endpoint — Scaffolds new API endpoints following these standards
```

## Explicit Mode

When arguments are provided, skip suggestions but still detect scenario.

### Parse Arguments

- **Folder name** — `api` → inject all `.md` files in `api/` (resolved from project then baseline)
- **Folder/file** — `api/response-format` → inject `api/response-format.md` (resolved from project then baseline)

### Resolution

For each requested path:
1. Check `project/{path}.md` — use if exists
2. Check `baseline/{path}.md` — use if exists
3. Not found → report error

### Validate

If specified files/folders don't exist:

```
Standard not found: api/nonexistent

Available standards:
  baseline/api/: response-format, error-handling
  project/api/:  custom-auth

Did you mean one of these?
```

## Tips

- **Run early** — Inject standards at the start of a task, before implementation
- **Be specific** — If you know which standards apply, use explicit mode
- **Project wins** — If you've overridden a baseline standard, your version is used
- **Use @baseline** — Reference baseline content from project overrides to stay in sync
