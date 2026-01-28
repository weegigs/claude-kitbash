---
name: codex-spec-review
description: Spec review via Codex CLI for independent validation. Use when seeking external validation of specifications before implementation.
---

# Codex Spec Review

Independent specification review using Codex CLI. Built on `@codex`. Supports multi-agent review for complex specs.

## Process

### Step 1: Identify Spec

```bash
# List available specs
ls .agent-os/specs/*.md 2>/dev/null

# Or accept spec path from user
```

### Step 2: Assess Complexity

Determine review depth based on spec characteristics:

| Signal | Complexity | Agents |
|--------|------------|--------|
| < 100 lines, 1-2 requirements | Simple | 1 |
| 100-300 lines, 3-5 requirements | Medium | 2 |
| > 300 lines, 6+ requirements, dependencies | Complex | 3 |

```bash
# Quick size check
wc -l .agent-os/specs/feature.md

# Count requirements
grep -c "^### Requirement" .agent-os/specs/feature.md
```

### Step 3: Deploy Review Agents

#### Simple Review (1 agent)

Single comprehensive review:

```bash
cat .agent-os/specs/feature.md | codex exec - -o /tmp/spec-review.md << 'PROMPT'
Review this specification for implementation readiness.

## Criteria

### Requirements Quality
- EARS notation: WHEN [condition] THE SYSTEM SHALL [behavior]
- Each requirement is specific, testable, complete
- Happy path, error cases, and edge cases covered

### Analysis Completeness
- Problem/context clearly stated
- Dependencies identified
- Integration points mapped

### Scope Clarity
- In-scope items explicit
- Out-of-scope items explicit
- Complexity assessment reasonable

### Success Criteria
- Definition of done is measurable
- Maps back to requirements
- Test approach identified

## Output Format

For each dimension, provide:
- ✓ What's good
- ⚠ Suggestions
- ✗ Issues that block implementation

End with: READY / NEEDS_REVISION
PROMPT
```

#### Medium Review (2 agents)

Two perspectives — requirements focus and execution focus:

**Agent 1: Requirements & Completeness**
```bash
cat .agent-os/specs/feature.md | codex exec - -o /tmp/spec-review-reqs.md << 'PROMPT'
Review this specification focusing on REQUIREMENTS QUALITY.

Check:
- EARS notation properly applied
- All requirements testable
- Error cases covered
- No ambiguous language ("appropriate", "should", "might")
- User stories have clear benefit

Report issues as: [Requirement N]: issue
PROMPT
```

**Agent 2: Execution Readiness**
```bash
cat .agent-os/specs/feature.md | codex exec - -o /tmp/spec-review-exec.md << 'PROMPT'
Review this specification focusing on EXECUTION READINESS.

Check:
- Scope boundaries clear (can start without questions)
- Dependencies identified and available
- Success criteria measurable
- Complexity assessment matches actual scope
- No hidden assumptions

Report issues as: [Section]: issue
PROMPT
```

#### Complex Review (3 agents)

Three perspectives — requirements, risk, and testability:

**Agent 1: Requirements Quality** (as above)

**Agent 2: Risk & Dependencies**
```bash
cat .agent-os/specs/feature.md | codex exec - -o /tmp/spec-review-risk.md << 'PROMPT'
Review this specification focusing on RISK AND DEPENDENCIES.

Check:
- External dependencies identified
- Integration risks noted
- Breaking change potential assessed
- Rollback/mitigation considered
- Complexity realistically assessed

Report risks as: [RISK]: description and mitigation
PROMPT
```

**Agent 3: Testability**
```bash
cat .agent-os/specs/feature.md | codex exec - -o /tmp/spec-review-test.md << 'PROMPT'
Review this specification focusing on TESTABILITY.

Check:
- Each acceptance criteria maps to a test
- Test types identified (unit/integration/e2e)
- Edge cases enumerable
- Success criteria verifiable
- No untestable requirements ("fast", "user-friendly")

Report issues as: [Requirement N]: cannot test because...
PROMPT
```

### Step 4: Synthesize Results

Combine agent outputs into unified report:

```markdown
## Spec Review: [Name]

### Agent Perspectives

**Requirements Quality:**
[Agent 1 findings]

**Execution Readiness:** (if medium+)
[Agent 2 findings]

**Risk & Dependencies:** (if complex)
[Agent 2/3 findings]

**Testability:** (if complex)
[Agent 3 findings]

### Consensus

| Dimension | Verdict |
|-----------|---------|
| Requirements | ✓/⚠/✗ |
| Execution | ✓/⚠/✗ |
| Risk | ✓/⚠/✗ |
| Testability | ✓/⚠/✗ |

### Overall: READY / NEEDS_REVISION

### Action Items
1. [Specific issue to address]
2. [Another issue]
```

### Step 5: Present to User

```
Codex Spec Review Complete
==========================

[Synthesized report]

---
Proceed to /kick-off? (yes / address issues first / discuss)
```

## Running Agents in Parallel

For efficiency, run agents concurrently:

```bash
# Start all agents in background
cat spec.md | codex exec "Requirements focus..." -o /tmp/r1.md &
cat spec.md | codex exec "Execution focus..." -o /tmp/r2.md &
cat spec.md | codex exec "Risk focus..." -o /tmp/r3.md &

# Wait for completion
wait

# Combine results
cat /tmp/r1.md /tmp/r2.md /tmp/r3.md
```

## See Also

- `@codex` — Base Codex CLI patterns
- `@spec-review` — Manual spec review methodology (non-Codex)
- `@codex-review` — Code review via Codex
