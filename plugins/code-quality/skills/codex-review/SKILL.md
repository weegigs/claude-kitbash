---
name: codex-review
description: Code review via Codex CLI using quality principles. Use when seeking independent validation of code changes. Supports multi-agent review for complex changes.
---

# Codex Code Review

Independent code review using Codex CLI with quality principles. Built on `@codex`. Supports multi-agent review for larger changesets.

## Process

### Step 1: Determine Scope

Ask user or infer from context:

```
What should I review?

1. Working copy changes (jj diff @)
2. Last commit (jj diff @-)
3. Changes since main (jj diff main..@)
4. Specific revision: [specify]
```

### Step 2: Assess Complexity

Determine review depth based on diff characteristics:

```bash
# Check diff size
jj diff --git | wc -l

# Check files changed
jj diff --stat | tail -1
```

| Signal | Complexity | Agents |
|--------|------------|--------|
| < 100 lines, 1-3 files | Simple | 1 |
| 100-500 lines, 4-10 files | Medium | 2 |
| > 500 lines, 10+ files, cross-cutting | Complex | 3 |

### Step 3: Deploy Review Agents

#### Simple Review (1 agent)

Single comprehensive review with all principles:

```bash
jj diff --git | codex exec - -o /tmp/code-review.md << 'PROMPT'
Review this diff against quality principles.

## Principles

**Architecture:** Imperative shell, functional core

**Design:**
- Make illegal states unrepresentable
- Single responsibility
- Parse, don't validate
- Prefer composition
- Explicit dependencies
- Fail fast with context
- Domain errors (identifiable for action)
- Prefer immutability
- Avoid stringly-typed code
- Left-hand side is happy path

**Standards:**
- Clarity over brevity
- No lint suppressions without approval
- No workarounds—fix root causes

## Output

For each issue:
- file:line — quoted code
- Principle violated
- Specific fix

If clean: "No issues found."
PROMPT
```

#### Medium Review (2 agents)

Two perspectives — design principles and code standards:

**Agent 1: Architecture & Design**
```bash
jj diff --git | codex exec - -o /tmp/review-design.md << 'PROMPT'
Review this diff focusing on ARCHITECTURE AND DESIGN.

Check:
- Functional core / imperative shell separation
- Illegal states unrepresentable (no boolean flag soup)
- Single responsibility
- Explicit dependencies (no hidden globals)
- Composition over inheritance
- Immutability by default

Report as: file:line — principle — fix
PROMPT
```

**Agent 2: Error Handling & Standards**
```bash
jj diff --git | codex exec - -o /tmp/review-standards.md << 'PROMPT'
Review this diff focusing on ERROR HANDLING AND STANDARDS.

Check:
- Fail fast with context
- Domain errors (identifiable, actionable)
- Parse don't validate (boundaries)
- No lint suppressions
- No workarounds
- Clarity over brevity

Report as: file:line — issue — fix
PROMPT
```

#### Complex Review (3 agents)

Three perspectives — design, safety, and quality:

**Agent 1: Architecture & Design** (as above)

**Agent 2: Safety & Error Handling**
```bash
jj diff --git | codex exec - -o /tmp/review-safety.md << 'PROMPT'
Review this diff focusing on SAFETY AND ERROR HANDLING.

Check:
- Error cases handled
- Fail fast with context
- No swallowed errors
- Resource cleanup (files, connections)
- Input validation at boundaries
- No panics/crashes from bad input

Report as: file:line — safety issue — fix
PROMPT
```

**Agent 3: Code Quality & Maintainability**
```bash
jj diff --git | codex exec - -o /tmp/review-quality.md << 'PROMPT'
Review this diff focusing on CODE QUALITY.

Check:
- Clarity over brevity
- No magic strings (use types/enums)
- Happy path on left (early returns)
- No lint suppressions
- Dead code removed
- Names are intention-revealing

Report as: file:line — quality issue — fix
PROMPT
```

### Step 4: Synthesize Results

Combine agent outputs into unified report:

```markdown
## Code Review: [scope description]

### Agent Perspectives

**Architecture & Design:**
[Agent 1 findings]

**Error Handling & Standards:** (if medium+)
[Agent 2 findings]

**Safety:** (if complex)
[Agent 2 findings]

**Code Quality:** (if complex)
[Agent 3 findings]

### Consensus

| Dimension | Issues |
|-----------|--------|
| Design | N issues |
| Safety | N issues |
| Quality | N issues |

### All Issues (deduplicated)

1. `src/foo.rs:42` — Single responsibility — Extract into separate function
2. `src/bar.ts:15` — Lint suppression — Fix the underlying type error

### Overall: CLEAN / HAS_ISSUES
```

### Step 5: Present to User

```
Codex Code Review Complete
==========================

[Synthesized report]

---
Address findings? (yes / skip / discuss specific issue)
```

## Running Agents in Parallel

For efficiency with larger diffs:

```bash
# Capture diff once
jj diff --git > /tmp/diff.patch

# Run agents in parallel
cat /tmp/diff.patch | codex exec "Design focus..." -o /tmp/r1.md &
cat /tmp/diff.patch | codex exec "Safety focus..." -o /tmp/r2.md &
cat /tmp/diff.patch | codex exec "Quality focus..." -o /tmp/r3.md &

wait

# Synthesize
cat /tmp/r1.md /tmp/r2.md /tmp/r3.md
```

## Optional Focus Areas

Add to any review prompt:

```bash
# Security focus
"...Also check: injection, auth bypass, secrets in code, path traversal"

# Performance focus
"...Also check: N+1 queries, unnecessary allocations, blocking I/O"

# API focus
"...Also check: breaking changes, missing validation, error responses"
```

## Language-Specific Patterns

Before running review, identify the primary language and include relevant idioms:

| Extension | Language | Skill | Key Patterns to Check |
|-----------|----------|-------|----------------------|
| `.rs` | Rust | `@rust` | Ownership/borrowing, Option combinators vs nested if-let, error propagation with ?, newtype pattern |
| `.ts`, `.tsx` | TypeScript | `@typescript` | Discriminated unions, branded types, Result/Option patterns, composition |
| `.svelte` | Svelte | `@svelte` | Runes ($state, $derived, $effect), load functions, form actions |

**Enhanced review prompt for Rust:**
```bash
jj diff --git | codex exec - -o /tmp/code-review.md << 'PROMPT'
Review this Rust diff against quality principles AND Rust idioms.

## Quality Principles
[standard principles from above]

## Rust Idioms
- Flatten nested if-let with Option combinators (and_then, ?)
- Use let chains for multi-condition branching
- Prefer borrowing over cloning
- Use newtype pattern for domain types
- Domain-specific error enums over Box<dyn Error>
- Property-based testing for pure functions

Report violations of both principles AND idioms.
PROMPT
```

**Load the full language skill** (`@rust`, `@typescript`, etc.) when you need the complete pattern reference.

## See Also

- `@codex` — Base Codex CLI patterns
- `@principles` — Full quality principles reference
- `@codex-spec-review` — Spec review via Codex
- `@rust`, `@typescript`, `@svelte` — Language-specific cleaning patterns
