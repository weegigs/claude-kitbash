---
name: spec-review
description: Review methodology for specifications. Used by spec-reviewer agent and Codex.
---

# Spec Review

Methodology for reviewing specifications created by `/spec`. Validates requirements, analysis, and readiness for `/kick-off` execution planning.

## Specification Structure

All specs follow this universal structure:

```markdown
# [Work Title] - Specification

## 1. Requirements ✓
[EARS notation requirements with acceptance criteria]

## 2. Analysis ✓
[Work-type specific: bug analysis, feature analysis, refactor analysis, or research scope]

## 3. Scope ✓
[In/out scope, complexity assessment]

## 4. Success Criteria ✓
[Definition of done, testable outcomes]

---
**Status**: Ready for /kick-off
**Work Type**: [bug/feature/refactor/research]
**Complexity**: [simple/moderate/complex]
```

## Review Dimensions

### 1. Requirements Quality (Critical)

Requirements use **EARS notation**: `WHEN [condition] THE SYSTEM SHALL [behavior]`

**Check that requirements are:**

- [ ] **Specific** — Clear condition and behavior, no ambiguity
- [ ] **Testable** — Can be verified with a test case
- [ ] **Complete** — Cover happy path, error cases, edge cases
- [ ] **Traceable** — Each has user story context

**Red flags:**
- Vague: "THE SYSTEM SHALL handle errors appropriately"
- Untestable: "THE SYSTEM SHALL be fast"
- Incomplete: Only happy path, no error handling
- Missing user story context

**Review by Work Type:**

| Work Type | Requirements Focus |
|-----------|-------------------|
| **Bug** | Fix behavior + no regression + error handling |
| **Feature** | User stories + all acceptance criteria + error cases |
| **Refactor** | Compatibility + behavior preservation + new patterns |
| **Research** | Questions answered + trade-offs documented |

### 2. Analysis Completeness

**For Bugs:**
- [ ] Symptom clearly described
- [ ] Root cause identified (or noted as unknown)
- [ ] Impact assessed
- [ ] Regression risks noted

**For Features:**
- [ ] Problem statement clear
- [ ] Users identified
- [ ] Integration points mapped
- [ ] Dependencies listed

**For Refactors:**
- [ ] Current state documented
- [ ] Pain points articulated
- [ ] Target state defined
- [ ] Compatibility constraints explicit

**For Research:**
- [ ] Questions to answer listed
- [ ] Investigation areas defined
- [ ] Decision context provided

### 3. Scope Clarity

- [ ] In-scope items explicit
- [ ] Out-of-scope items explicit
- [ ] Complexity assessment reasonable
- [ ] Dependencies identified

**Red flags:**
- Unbounded scope ("improve performance")
- Missing complexity assessment
- Hidden dependencies

### 4. Success Criteria

- [ ] Definition of done is clear
- [ ] Criteria are measurable/testable
- [ ] Maps back to requirements
- [ ] Includes verification approach

**Red flags:**
- Vague: "Users are happy"
- Unmeasurable: "System is better"
- Missing test strategy

### 5. Standards Alignment

Check against `.agent-os/standards/`:

- [ ] Relevant standards identified
- [ ] No conflicts with existing patterns
- [ ] Standards content included in spec

### 6. Readiness for /kick-off

- [ ] All sections complete (Requirements, Analysis, Scope, Success Criteria)
- [ ] Work type and complexity correctly assessed
- [ ] Sufficient detail for task generation
- [ ] No blocking questions remain

## Review Process

1. **Identify work type** — Bug, feature, refactor, or research
2. **Validate requirements** — EARS notation, testability, completeness
3. **Check analysis** — Work-type appropriate depth
4. **Verify scope** — Clear boundaries
5. **Confirm success criteria** — Measurable outcomes
6. **Assess readiness** — Ready for /kick-off?

## Output Format

```markdown
## Spec Review Summary

**Work Type:** [bug/feature/refactor/research]
**Overall:** [APPROVE | APPROVE_WITH_NOTES | REQUEST_CHANGES]

### Requirements Review

✓ X requirements with Y acceptance criteria
✓ EARS notation correctly applied
⚠ Requirement 3 acceptance criteria could be more specific
✗ Missing error handling requirement for [scenario]

### Analysis Review

✓ [Work-type] analysis complete
⚠ Consider adding [missing element]

### Scope Review

✓ Clear boundaries
✓ Complexity assessment reasonable

### Success Criteria Review

✓ Measurable outcomes defined
⚠ Add specific metric for [criteria]

### Readiness Assessment

[Ready for /kick-off | Needs revision]

### Recommendations

[If REQUEST_CHANGES:]
1. Add requirement for [missing scenario]
2. Clarify acceptance criteria for Requirement 3
3. Add error handling to success criteria
```

## Verdict Criteria

| Verdict | When to Use |
|---------|-------------|
| **APPROVE** | Spec is complete and ready for /kick-off |
| **APPROVE_WITH_NOTES** | Minor suggestions, safe to proceed |
| **REQUEST_CHANGES** | Issues that would cause problems in execution |

## Test Compliance Check

**Critical for execution phase**: Each acceptance criteria should map to a test:

```markdown
### Test Mapping Preview

| Requirement | Acceptance Criteria | Test Type |
|-------------|--------------------|-----------| 
| R1 | WHEN user logs in... | Integration |
| R1 | WHEN credentials invalid... | Unit |
| R2 | WHEN session expires... | Integration |
```

If acceptance criteria cannot be tested, flag for revision.

## Principles

- **Requirements-first** — Validate requirements before anything else
- **Testability matters** — Every acceptance criteria must be verifiable
- **Constructive** — Suggest improvements, don't just critique
- **Work-type aware** — Apply appropriate standards per type
- **Execution-focused** — Spec must be actionable for /kick-off
