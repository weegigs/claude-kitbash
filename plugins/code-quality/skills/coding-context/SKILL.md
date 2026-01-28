---
name: coding-context
description: Detect languages in target files and inject appropriate language skills. Use before implementing code to ensure language-specific patterns are loaded.
---

# Coding Context

Detect languages in target files and inject appropriate skills before implementing code.

## Usage

### Auto-Detect Mode (recommended)
```
/coding-context
```
Analyzes the current task context to determine which files will be modified and loads appropriate skills.

### Explicit Mode
```
/coding-context src/lib.rs src/main.rs
/coding-context src/components/
```
Detects languages from specified files/directories and loads skills.

## Process

### Step 1: Identify Target Files

**If no arguments provided:**
1. Check current task context (TodoWrite, beads task, conversation)
2. Look for mentioned file paths
3. If still unclear, scan working directory for common patterns

**If arguments provided:**
- Use specified files/directories directly

### Step 2: Detect Languages

Scan target files and map extensions to skills:

| Extension | Language | Primary Skill | Additional |
|-----------|----------|---------------|------------|
| `.rs` | Rust | `@rust` | `@tokio` if async |
| `.ts`, `.tsx` | TypeScript | `@typescript` | — |
| `.svelte` | Svelte | `@svelte` | `@typescript` |
| `.py` | Python | *(no skill yet)* | — |
| `.go` | Go | *(no skill yet)* | — |

**Async Rust detection:**
```bash
# Check for tokio usage
grep -r "use tokio" --include="*.rs" <target> 2>/dev/null
grep -r "#\[tokio::main\]" --include="*.rs" <target> 2>/dev/null
```

### Step 3: Load Skills

For each detected language, load the skill into context:

```
Detected: Rust with async (tokio)

Loading skills:
- @rust — Rust idioms, ownership, Option combinators, error handling
- @tokio — Async patterns, channels, structured concurrency
- @principles — Universal quality standards

Key patterns to apply:
- Flatten nested if-let with and_then + ?
- Use let chains for multi-condition branching
- Domain-specific error types over Box<dyn Error>
- Prefer borrowing over cloning
```

### Step 4: Summarize Context

Output a brief summary:

```
## Coding Context Loaded

**Languages:** Rust (async)
**Skills:** @rust, @tokio, @principles

**Key idioms for this session:**
- Option combinators over nested if-let
- ? operator for error propagation
- Structured concurrency with tokio::select!

Ready to implement.
```

## When to Use

| Scenario | Action |
|----------|--------|
| Starting implementation | Run `/coding-context` first |
| Switching to different file type | Run `/coding-context <new-files>` |
| Reviewing code | Run to ensure reviewer has language context |
| Unsure which patterns apply | Run to get key idioms summary |

## Integration with Workflow

### With `/execute`
The `/execute` skill calls this automatically at start. No need to invoke separately.

### With `/kick-off`
Planning phase doesn't need language skills. Skip until implementation.

### With code review
Run before `/codex-review` to include language-specific patterns in review criteria.

## Key Idioms by Language

### Rust (`@rust`)
- Flatten nested `if let` with `and_then` + `?` in closures
- Use `bool.then(|| value)` to convert conditions to `Option`
- Newtype pattern for domain types
- Domain error enums over `Box<dyn Error>`
- Property-based testing for pure functions

### TypeScript (`@typescript`)
- Discriminated unions over type guards
- Branded types for domain primitives
- `Result<T, E>` pattern for error handling
- Composition over inheritance

### Svelte (`@svelte`)
- `$derived` over `$effect` for computed values
- Runes for reactivity (`$state`, `$derived`, `$effect`)
- Load functions for server data
- Form actions for mutations

## See Also

- `@rust`, `@typescript`, `@svelte` — Full language skill references
- `@principles` — Universal quality standards
- `/execute` — Auto-injects coding context at start
