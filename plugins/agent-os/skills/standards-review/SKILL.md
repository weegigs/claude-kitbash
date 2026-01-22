---
name: standards-review
description: Review methodology for discovered standards. Used by standards-reviewer agent and Codex.
---

# Standards Review

Methodology for reviewing standards created by `/discover-standards`.

## Review Dimensions

### 1. Accuracy

Check that:

- [ ] Standard reflects actual codebase behavior
- [ ] Code examples are correct and work if copy-pasted
- [ ] No factual errors or misinterpretations

**Red flags:**
- Example code that wouldn't compile/run
- Description contradicts what the code does
- Outdated patterns from old code

### 2. Clarity

Check that:

- [ ] A developer can understand in under 30 seconds
- [ ] The "what to do" is unambiguous
- [ ] Examples are concrete and actionable

**Red flags:**
- Vague language: "generally", "usually", "consider"
- Missing examples for complex patterns
- Ambiguous instructions with multiple interpretations

### 3. Conciseness

Check that:

- [ ] Every word earns its place
- [ ] No redundant explanations
- [ ] Bullet points over paragraphs

**Red flags:**
- Paragraphs where bullets would work
- Repeating the same point in different words
- Explaining obvious things

### 4. Usefulness

Check that:

- [ ] Captures non-obvious tribal knowledge
- [ ] Would help an AI agent or new developer
- [ ] Not duplicating framework documentation

**Red flags:**
- Documenting default framework behavior
- Patterns that are industry-standard (not project-specific)
- Too obvious to be worth writing down

## Review Process

1. **Read the standard** — Understand what it's trying to communicate
2. **Check each dimension** — Use checklists above
3. **Identify findings** — Categorize as ✓ (good), ⚠ (suggestion), ✗ (issue)
4. **Provide specific edits** — Show exact replacement text for issues

## Output Format

```markdown
## Review Summary

**Overall:** [APPROVE | APPROVE_WITH_NOTES | REQUEST_CHANGES]

**File:** api/response-format.md

### Findings

✓ Clear envelope structure with good examples
✓ Captures non-obvious error code convention

⚠ Could trim the "why" section — it's longer than needed

✗ Example shows `error: null` but text says "omit error field"

### Specific Edits

**Line 15:** Replace
```json
{ "success": true, "data": {...}, "error": null }
```
with
```json
{ "success": true, "data": {...} }
```
```

## Verdict Criteria

| Verdict | When to Use |
|---------|-------------|
| **APPROVE** | Standard is accurate, clear, and useful |
| **APPROVE_WITH_NOTES** | Minor improvements possible, but usable as-is |
| **REQUEST_CHANGES** | Errors or issues that would mislead readers |

## Principles

- **Brevity is a feature** — Standards should be scannable, not readable
- **Tribal over obvious** — If it's in the docs, it doesn't belong here
- **Accurate over polished** — Correctness matters more than prose quality
- **Actionable over descriptive** — Tell them what to do, not what exists
