---
name: spec-feature
description: Feature specification workflow. Use when specifying new features to generate user stories with EARS acceptance criteria.
---

# Feature Specification Workflow

## Questions to Ask

```
Feature: "[description]"

1. What problem does this solve?
2. Who are the primary users?
3. What's the expected outcome when complete?
4. Any constraints or existing patterns to follow?
```

## Requirements Format

```markdown
## 1. Requirements ✓

### Introduction
[Brief description of what this feature does and why]

### Glossary
- **Term_One**: Definition
- **Term_Two**: Definition

### Requirement 1

**User Story:** As a [role], I want [action], so that [benefit].

#### Acceptance Criteria
1. WHEN [condition] THE [System_Name] SHALL [behavior]
2. WHEN [condition] THE [System_Name] SHALL [behavior]
3. WHEN [error condition] THE [System_Name] SHALL [error handling]

### Requirement 2
[Additional requirements as needed]
```

## Analysis Section

```markdown
## 2. Feature Analysis ✓

**Problem Statement**: [What problem this solves]
**Users**: [Who benefits]
**Integration Points**: [What existing systems are affected]
**Dependencies**: [External dependencies]
```

## Scope Section

```markdown
## 3. Scope ✓

**In Scope**:
- [Core feature functionality]
- [Error handling]
- [Basic UI/UX]

**Out of Scope**:
- [Future enhancements]
- [Edge cases for later]

**Complexity**: [simple/moderate/complex]
```

## Success Criteria

```markdown
## 4. Success Criteria ✓

- [ ] All acceptance criteria met
- [ ] Integration points working
- [ ] Error cases handled
- [ ] [Specific metrics if applicable]
```

## Standards Check

Read `.agent-os/standards/index.yml` and confirm applicable standards:

```
These standards may apply:
1. **[standard-path]** — [why]

Include these? (yes / adjust)
```
