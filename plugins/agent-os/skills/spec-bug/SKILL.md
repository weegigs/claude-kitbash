---
name: spec-bug
description: Bug fix specification workflow. Use when specifying bug fixes to generate root cause analysis and acceptance criteria.
---

# Bug Specification Workflow

## Questions to Ask

```
Bug: "[description]"

1. What specific behavior or error occurs?
2. Steps to reproduce?
3. What's the expected behavior?
4. Impact? (blocking/degraded/minor)
```

## Requirements Format

```markdown
## 1. Requirements ✓

### Requirement 1: Fix [Bug Description]

**User Story:** As a [affected user], I want [correct behavior], so that [benefit].

#### Acceptance Criteria
1. WHEN [trigger condition] THE SYSTEM SHALL [correct behavior]
2. WHEN [error condition] THE SYSTEM SHALL [graceful handling]
3. WHEN fix is applied THE SYSTEM SHALL [no regression]
```

## Analysis Section

```markdown
## 2. Bug Analysis ✓

**Symptom**: [What user sees]
**Root Cause**: [Technical cause - if known, or "To investigate"]
**Impact**: [Who/what is affected]
**Regression Risk**: [What might break]
```

## Scope Section

```markdown
## 3. Scope ✓

**In Scope**:
- [Fix specific behavior]
- [Add error handling]

**Out of Scope**:
- [Related but separate issues]

**Complexity**: [simple/moderate/complex]
```

## Success Criteria

```markdown
## 4. Success Criteria ✓

- [ ] Bug no longer reproducible
- [ ] No regressions in related functionality
- [ ] Error handling covers edge cases
- [ ] [Specific metric if applicable]
```
