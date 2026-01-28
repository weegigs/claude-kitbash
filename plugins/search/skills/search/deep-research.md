---
name: deep-research
description: Multi-step investigation workflow. Use for complex questions requiring synthesis across multiple sources, comparative analysis, or technical deep-dives.
---

# Deep Research: Multi-Step Investigation

Multi-step research methodology for complex questions requiring synthesis across multiple sources.

## When to Use

- Complex questions requiring multiple sources
- Comparative analysis (X vs Y)
- Technical deep-dives
- Market/competitive research

## User Clarification (Complexity-Based)

Only interview user when complexity warrants it:

| Complexity | Clarification Needed? |
|------------|----------------------|
| Simple lookup | No - just search |
| Moderate (2-3 sources) | No - proceed |
| Complex (multi-faceted) | Yes - confirm scope |
| Ambiguous | Yes - clarify intent |
| High-stakes | Yes - confirm direction |

**When to ask:**
- Research direction is genuinely ambiguous
- Multiple valid interpretations exist
- About to invest significant effort (parallel agents)

**Don't ask:**
- Obvious next steps
- Standard research patterns
- User already provided clear context

## Progressive Enhancement

See `search:patterns` for the full escalation model. Key points for deep research:

- **Start at Level 1** (WebSearch) even for complex questions
- **Escalate based on results**, not assumptions about complexity
- **User approval required** before Level 3+ (parallel agents)

**Escalation prompts** (ask user before spawning agents):
- "Initial search shows conflicting info. Should I dig deeper with parallel research?"
- "This requires comparing multiple approaches. Proceed with deep analysis?"

## Multi-Tool Strategy

Combine tools for comprehensive coverage:

| Tool | Role | Strength |
|------|------|----------|
| Perplexity | Lead researcher | Synthesized answers with citations |
| Explore agents | Parallel threads | Codebase + web in parallel |
| Context7 | API specifics | Current library documentation |
| WebSearch | Gap filler | Quick targeted lookups |

## Parallel Execution Pattern

Launch Perplexity AND agents simultaneously:
```python
# In parallel (single message, multiple tool calls):
Task(subagent_type="Explore", prompt="Research Tauri v2 IPC patterns in docs and community")
perplexity_reason("Compare Tauri IPC approaches: commands vs events vs channels")
```

Perplexity provides synthesized analysis while agents gather raw sources.

## Workflow

1. **Clarify**: User interview if scope unclear
2. **Start Light**: Quick search first
3. **Evaluate**: Is this sufficient? Escalate if needed
4. **Launch**: Perplexity + Explore agents in parallel (with approval)
5. **Collect**: Gather all findings
6. **Cross-reference**: Verify claims across sources
7. **Checkpoint**: Report findings, confirm direction with user
8. **Gap Fill**: WebSearch for remaining questions
9. **Compile**: Format with citations from all sources

## Tool Dependencies

See main skill (`search:`) for full MCP availability check. Key tools for deep research:

| Tool | Role | Fallback |
|------|------|----------|
| `perplexity_reason` | Complex analysis, synthesis | Multiple WebSearch + manual synthesis |
| `perplexity_ask` | Factual queries | WebSearch |
| `Task(Explore)` | Parallel research threads | Sequential searches |
| `AskUserQuestion` | Checkpoints | — (always available) |

## Citation Tracking

Maintain a citations list as research progresses:

```
## Sources
1. [Official Docs] https://...
2. [Stack Overflow] https://...
3. [Blog - Author] https://...
```

Include citation numbers in findings: "Tauri v2 uses a new IPC model [1] that differs from v1 [3]."

## Checkpointing Long Research

For extended research (level 3+), pause and report:

```markdown
## Research Progress

**Status**: 3 of 5 questions answered

| Question | Status | Confidence |
|----------|--------|------------|
| Core functionality | ✓ Done | High |
| Performance tradeoffs | ✓ Done | Medium |
| Edge case X | ? Conflicting | Low |
| Alternative Y | ○ Pending | — |
| Integration approach | ○ Pending | — |

**Blocking issue**: Conflicting info on edge case X

Continue investigating, or sufficient for decision?
```

## Output Format

Present findings in structured format for actionability:

```markdown
## Research: [Topic]

### TL;DR
[1-2 sentence answer with confidence level]

### Key Findings
1. **[Finding]** — [Source] (High confidence)
2. **[Finding]** — [Sources] (Medium confidence)
3. **[Finding]** — [Source] (Needs verification)

### Recommendations
- **Primary**: [Action based on high-confidence findings]
- **Alternative**: [If primary doesn't apply]

### Caveats
- [Limitation or uncertainty]
- [Context where findings may not apply]

### Sources
1. [Official] [Title](URL)
2. [Community] [Title](URL)
```

## Integration with Other Skills

| Phase | Skill | Purpose |
|-------|-------|---------|
| Before | `search:plan` | Structure the research |
| During | `search:patterns` | Query construction |
| After | `search:verify` | Validate critical claims |
