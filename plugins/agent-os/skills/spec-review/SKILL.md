---
name: spec-review
description: Review methodology for implementation plans. Used by spec-reviewer agent and Codex.
---

# Spec Review

Methodology for reviewing implementation plans created by `/spec`.

## Review Dimensions

### 1. Completeness

Check that the plan addresses:

- [ ] All stated user requirements
- [ ] Error handling and edge cases
- [ ] Dependencies between tasks
- [ ] Integration points with existing code

**Red flags:**
- Vague tasks like "handle errors appropriately"
- Missing tasks for obvious requirements
- No mention of testing or verification

### 2. Coherence

Check that tasks:

- [ ] Flow logically from one to the next
- [ ] Have clear boundaries (no overlapping scope)
- [ ] Are ordered correctly (dependencies before dependents)
- [ ] Don't have gaps (nothing falls through the cracks)

**Red flags:**
- Task 3 depends on output from Task 5
- Two tasks that both "set up the database schema"
- Jump from "create API" to "deploy to production"

### 3. Standards Alignment

Check against `.agent-os/standards/`:

- [ ] Relevant standards are identified
- [ ] Planned approaches match documented patterns
- [ ] No conflicts with existing conventions

**Red flags:**
- Plan ignores applicable standards
- Approach contradicts documented patterns
- Standards referenced but not followed

### 4. Feasibility

Check that:

- [ ] Tasks are appropriately sized (not too big, not trivial)
- [ ] Hidden complexity is surfaced
- [ ] Scope is realistic for the stated goal

**Red flags:**
- "Implement authentication" as a single task
- Underestimating integration complexity
- Scope creep beyond original request

## Review Process

1. **Read the full plan** — Understand intent before critiquing
2. **Check each dimension** — Use checklists above
3. **Identify findings** — Categorize as ✓ (good), ⚠ (suggestion), ✗ (issue)
4. **Provide verdict** — APPROVE, APPROVE_WITH_NOTES, or REQUEST_CHANGES

## Output Format

```markdown
## Review Summary

**Overall:** [APPROVE | APPROVE_WITH_NOTES | REQUEST_CHANGES]

### Findings

✓ Requirements clearly mapped to tasks
✓ Standards properly referenced

⚠ Consider splitting Task 4 into smaller pieces

✗ Missing error handling for API failures
✗ Task 2 depends on Task 5 (ordering issue)

### Recommendations

[If REQUEST_CHANGES:]
1. Add error handling task after Task 3
2. Reorder: move Task 5 before Task 2
```

## Verdict Criteria

| Verdict | When to Use |
|---------|-------------|
| **APPROVE** | No issues, plan is ready to execute |
| **APPROVE_WITH_NOTES** | Minor suggestions, but safe to proceed |
| **REQUEST_CHANGES** | Issues that would cause problems if not addressed |

## Principles

- **Constructive over critical** — Suggest improvements, don't just point out flaws
- **Significant over pedantic** — Focus on things that matter
- **Concise over verbose** — One-line findings preferred
- **Respect intent** — Work within the plan author's goals
