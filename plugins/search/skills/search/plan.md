---
name: plan
description: Research planning before execution. Use before starting complex research when scope is unclear, for multi-session research efforts, or research supporting important decisions.
---

# Research Planning

Structured approach for complex research tasks before execution.

## When to Use

- Before starting complex research
- When scope is unclear
- Multi-session research efforts
- Research supporting important decisions

## Complexity Assessment

Before planning, assess research complexity:

| Signal | Complexity | Planning Needed? |
|--------|------------|------------------|
| Single factual question | Low | No — just search |
| 2-3 related questions | Medium | Light planning |
| Multi-faceted comparison | High | Full planning |
| Architecture decision | High | Full planning + stakeholder input |

**Quick complexity check**:
```
Questions: How many distinct questions?
Sources: How many source types needed?
Dependencies: Do questions depend on each other?
Stakes: What decision does this support?

If (questions > 3 OR sources > 2 OR high stakes) → Plan first
```

## Planning Template

Before diving into searches, answer these questions:

1. **Goal**: What decision/output does this research support?
2. **Questions**: Break into 3-5 specific queries
3. **Sources**: Which tools/domains for each question?
4. **Agents**: Which threads can run in parallel?
5. **Criteria**: How to know when done?

## Agent Planning

Map research threads to parallel execution:

```python
# Map questions to tools based on their strengths
Question_1 = "How does X work?"        # → Explore agent + Context7
Question_2 = "What are alternatives?"  # → Perplexity (synthesis)
Question_3 = "Real-world experiences?" # → Explore agent (forums, issues)

# Q1 and Q3 can run in parallel (independent)
# Q2 may depend on Q1 results
```

Independent questions can run in parallel; dependent questions run sequentially.

## Query Construction Strategy

### Iteration Approach
Plan for 2-3 search iterations per question:

1. **Broad** - Understand the landscape
2. **Specific** - Drill into relevant areas
3. **Targeted** - Fill remaining gaps

### Query Patterns

```
# Discovery phase
"[topic] overview guide"
"[topic] introduction tutorial"

# Comparison phase
"[option A] vs [option B] [use case]"
"[topic] alternatives comparison"

# Implementation phase
"[topic] [framework] example"
"[topic] [language] best practices"

# Troubleshooting phase
"[topic] [error message]"
"[topic] common issues"
```

### Include Context

Add relevant context to queries:
- Current year for recency (date-guard enforced)
- Framework/language versions
- Specific use case constraints

## Source Type Selection

Match source types to question types:

| Question Type | Best Sources |
|---------------|--------------|
| How-to | Official docs, tutorials |
| Why/rationale | RFCs, design docs, blog posts |
| Comparison | Benchmark articles, Perplexity synthesis |
| Community experience | GitHub issues, forums, Stack Overflow |
| Current state | Recent articles, release notes |

## Completion Criteria

Research is "done enough" when:

- [ ] Core question answered with evidence
- [ ] No major conflicting information unresolved
- [ ] Implementation path is clear
- [ ] Known unknowns are documented
- [ ] Confidence level is appropriate for the decision

## Structured Findings Format

Organize research output for clarity:

```markdown
## Research: [Topic]

### Summary
[1-2 sentence answer to core question]

### Key Findings
1. [Finding with citation]
2. [Finding with citation]
3. [Finding with citation]

### Open Questions
- [Question that couldn't be answered]
- [Area needing further investigation]

### Recommendation
[Action based on findings]

### Sources
1. [Source name] - [URL]
2. [Source name] - [URL]
```

## Example Research Plan

**Goal**: Choose state management approach for Svelte 5 app

**Questions** (include current year via `date +%Y` for recency):
1. What are the built-in options? (Context7 — version-aware)
2. When are external libraries needed? (Perplexity — synthesis)
3. What does the community prefer? (Explore agent — forums, issues)
4. Performance considerations? (WebSearch — benchmarks `<current-year>`)

**Parallel execution**:
- Q1 + Q3 in parallel (independent)
- Q2 after Q1 (depends on understanding built-in)
- Q4 after Q2 (depends on knowing alternatives)

**Done when**:
- Understand runes vs stores tradeoffs
- Know when zustand/nanostores are warranted
- Have example patterns for chosen approach

## Avoiding Over-Research

Signs to stop and proceed:

- Same information appearing in multiple sources
- Marginal returns on additional searches
- "Good enough" answer for the decision at hand
- Diminishing relevance of new results
- User is waiting and question is answered

## Integration with Other Skills

| Phase | Skill | Purpose |
|-------|-------|---------|
| Planning | `search:plan` | (this skill) |
| Execution | `search:deep-research` | Run the research |
| Validation | `search:verify` | Verify critical findings |
| Reference | `search:patterns` | Query construction |

## Plan Template (Quick Copy)

```markdown
## Research Plan: [Topic]

**Goal**: [Decision this supports]

**Questions**:
1. [Question] → [Tool]
2. [Question] → [Tool]
3. [Question] → [Tool]

**Execution**:
- Parallel: Q1 + Q3 (independent)
- Sequential: Q2 after Q1 (dependent)

**Done when**:
- [ ] Core question answered
- [ ] No unresolved conflicts
- [ ] Clear recommendation possible

**Estimated level**: 1-4 (see patterns.md)
```
