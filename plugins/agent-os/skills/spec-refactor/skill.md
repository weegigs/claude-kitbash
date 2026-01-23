---
name: spec-refactor
description: Refactor specification workflow. Documents current state, target state, and compatibility requirements.
---

# Refactor Specification Workflow

## Questions to Ask

```
Refactor: "[description]"

1. What's the current state/pain point?
2. What's the desired end state?
3. Are there specific areas to focus on?
4. What must NOT change? (compatibility constraints)
```

## Requirements Format

```markdown
## 1. Requirements ✓

### Requirement 1: Refactor [Component]

**User Story:** As a developer, I want [improved structure], so that [benefit].

#### Acceptance Criteria
1. WHEN [operation] THE SYSTEM SHALL [use new pattern]
2. WHEN [existing API called] THE SYSTEM SHALL [maintain compatibility]
3. WHEN refactor complete THE SYSTEM SHALL [pass all existing tests]
```

## Analysis Section

```markdown
## 2. Refactor Analysis ✓

**Current State**: 
[What exists now - structure, patterns, issues]

**Pain Points**: 
[Why refactor is needed]

**Target State**: 
[What it should become]

**Compatibility Constraints**: 
[What must remain unchanged - APIs, behavior, contracts]
```

## Scope Section

```markdown
## 3. Scope ✓

**In Scope**:
- [Specific modules/files to refactor]
- [Patterns to introduce]

**Out of Scope**:
- [Areas to leave alone]
- [Future refactoring]

**Complexity**: [simple/moderate/complex]
```

## Success Criteria

```markdown
## 4. Success Criteria ✓

- [ ] All existing tests pass
- [ ] No breaking changes to public APIs
- [ ] New patterns consistently applied
- [ ] Code review approved
- [ ] [Specific improvements measurable]
```
