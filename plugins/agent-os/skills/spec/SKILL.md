---
name: spec
description: Prepare any work for execution planning. Routes to work-type specific workflow.
---

# Spec

Universal work preparation. Detects work type, routes to appropriate workflow.

## Usage

```
/spec <description>
```

## Process

### Step 1: Identify Work Type

Analyze the request to determine work type, then confirm with user:

| Type | Indicators | Examples |
|------|------------|----------|
| **Bug** | Something broken, wrong behavior, error occurring, users affected | "fix apple login", "users can't checkout", "error when saving" |
| **Feature** | New capability, add functionality, implement something new | "implement user reviews", "add dark mode toggle", "create admin dashboard" |
| **Refactor** | Improve structure, clean up, reorganize without behavior change | "refactor payment service", "clean up auth module", "split monolith" |
| **Research** | Understand options, investigate approach, compare alternatives | "investigate caching options", "explore auth providers", "analyze performance" |

Present your assessment:

```
I'll prepare a specification for: "[description]"

This looks like a **[detected type]** — [one sentence why].

Correct? (yes / actually it's a [type])
```

### Step 2: Load Work-Type Workflow

Based on confirmed type, load the appropriate skill:

| Type | Skill | Focus |
|------|-------|-------|
| Bug | `@spec-bug` | Root cause, fix requirements, regression prevention |
| Feature | `@spec-feature` | User stories, acceptance criteria, integration points |
| Refactor | `@spec-refactor` | Current state, target state, compatibility constraints |
| Research | `@spec-research` | Questions to answer, options analysis, recommendations |

### Step 3: Generate Output

All workflows produce:

```markdown
# [Title] - Specification

## 1. Requirements ✓
## 2. Analysis ✓
## 3. Scope ✓
## 4. Success Criteria ✓

---
**Status**: Ready for /kick-off
```

Save to `.agent-os/specs/{YYYY-MM-DD-HHMM-slug}/`

## Next Step

After spec complete: `/kick-off` creates execution plan
