---
name: spec-research
description: Research specification workflow. Structures investigation questions and findings format.
---

# Research Specification Workflow

## Questions to Ask

```
Research: "[description]"

1. What are you trying to discover?
2. What decisions need to be made based on findings?
3. Any constraints or areas to focus on?
4. What's the desired output format?
```

## Requirements Format

```markdown
## 1. Requirements ✓

### Requirement 1: Investigate [Topic]

**User Story:** As a [role], I want to understand [topic], so that [decision can be made].

#### Acceptance Criteria
1. WHEN investigation complete THE FINDINGS SHALL [answer key questions]
2. WHEN options identified THE ANALYSIS SHALL [include trade-offs]
3. WHEN recommendation made THE REASONING SHALL [be documented]
```

## Analysis Section

```markdown
## 2. Research Scope ✓

**Questions to Answer**:
1. [Key question 1]
2. [Key question 2]
3. [Key question 3]

**Areas to Investigate**:
- [Area 1]
- [Area 2]

**Decision Context**: 
[What decision this research informs]

**Constraints**:
[Time, resources, technology limits]
```

## Scope Section

```markdown
## 3. Scope ✓

**In Scope**:
- [Specific topics to research]
- [Sources to consult]

**Out of Scope**:
- [Related but separate topics]
- [Implementation details]

**Complexity**: [simple/moderate/complex]
```

## Success Criteria

```markdown
## 4. Success Criteria ✓

- [ ] All key questions answered
- [ ] Trade-offs documented
- [ ] Recommendation provided (if applicable)
- [ ] Findings actionable for next steps
```

## Output Format

Research specs may output findings document instead of implementation-ready spec:

```markdown
## Findings

### [Question 1]
[Answer with supporting evidence]

### [Question 2]
[Answer with supporting evidence]

## Options Analysis

| Option | Pros | Cons |
|--------|------|------|
| A | ... | ... |
| B | ... | ... |

## Recommendation
[Recommended approach with reasoning]

## Next Steps
[What to do with these findings]
```
