---
name: codex
description: Use when the user asks to run Codex CLI (codex exec, codex resume) or references OpenAI Codex for code analysis, refactoring, or automated editing. Uses GPT-5.2 by default.
---

# Codex CLI Integration

Neutral skill for invoking the Codex CLI. Provides the foundation for specialized workflows like code review and spec review.

## Prerequisites

Codex CLI must be installed:
```bash
command -v codex &>/dev/null || echo "Install: brew install openai/codex/codex"
```

## CLI Version

Requires v0.57.0+ for GPT-5.2 support.

## Model Options

| Model | Use Case | Notes |
|-------|----------|-------|
| `gpt-5.2` | Default flagship | 76.3% SWE-bench, 400K input context |
| `gpt-5.2-max` | Ultra-complex reasoning | Use for deep analysis |
| `gpt-5.2-mini` | Cost-efficient | 4x more usage per token |
| `gpt-5.1-thinking` | Adaptive thinking depth | Adjustable reasoning effort |

### Reasoning Effort Levels

For models that support it, set reasoning effort via config:
- `xhigh` - Maximum reasoning depth
- `high` - Deep analysis
- `medium` - Balanced (default)
- `low` - Quick responses

```bash
codex exec --config model_reasoning_effort="high" "Complex analysis task"
```

## Quick Reference

| Use Case | Sandbox Mode | Key Flags |
|----------|--------------|-----------|
| Read-only review | `read-only` | `--sandbox read-only 2>/dev/null` |
| Apply local edits | `workspace-write` | `--full-auto` |
| Network access | `danger-full-access` | `--full-auto` |
| Resume session | Inherited | `echo "..." \| codex exec resume --last` |

## Modes

### Exec Mode (general purpose)

For arbitrary prompts with optional context:

```bash
# Simple prompt
codex exec "Analyze this architecture decision"

# With piped context
jj diff --git | codex exec "Review these changes"

# With file context
codex exec "Review this spec for completeness" < .agent-os/specs/feature.md

# Structured output
codex exec --output-schema schema.json "Extract API endpoints" -o results.json
```

### Review Mode (diff-focused)

Purpose-built for code review with git/jj integration:

```bash
# Review uncommitted changes (works with jj because it wraps git)
codex review --uncommitted "Focus on error handling"

# Review against base branch
codex review --base main "Check for breaking changes"
```

**Note:** `codex review` uses git under the hood. For jj-native workflows, prefer exec mode with `jj diff --git`.

### Resume Session

Continue from a previous Codex session:

```bash
echo "your follow-up prompt here" | codex exec --skip-git-repo-check resume --last 2>/dev/null
```

**Key points:**
- Flags go between `exec` and `resume`
- Session inherits original model, sandbox, and effort settings
- Use `--last` to resume the most recent session

## jj-Native Patterns

### Review Working Copy

```bash
jj diff --git | codex exec "Review this diff. Report issues as file:line format."
```

### Review Specific Revision

```bash
jj diff -r @- --git | codex exec "Review the previous commit"
```

### Review Range

```bash
jj diff -r main..@ --git | codex exec "Review all changes since main"
```

### Include Context Files

```bash
{
  echo "## Diff"
  jj diff --git
  echo "## Related File"
  cat src/lib.rs
} | codex exec "Review with full context"
```

## Options Reference

| Option | Description |
|--------|-------------|
| `-m, --model <MODEL>` | Override model (default: gpt-5.2) |
| `-s, --sandbox <MODE>` | read-only, workspace-write, danger-full-access |
| `-o, --output-last-message <FILE>` | Write final response to file |
| `--output-schema <FILE>` | JSON schema for structured output |
| `--json` | Stream events as JSONL |
| `-C, --cd <DIR>` | Set working directory |
| `--config model_reasoning_effort="<level>"` | Set reasoning effort (xhigh/high/medium/low) |
| `--full-auto` | Enable autonomous edits without prompts |
| `--skip-git-repo-check` | Always use; bypasses git repo validation |

### Stderr Suppression

Append `2>/dev/null` to suppress thinking tokens and progress output:

```bash
jj diff --git | codex exec "Review" 2>/dev/null
```

## Output Handling

### Stream to Terminal (default)

```bash
jj diff --git | codex exec "Review"
```

### Capture to File

```bash
jj diff --git | codex exec "Review" -o /tmp/review.md
cat /tmp/review.md
```

### Structured JSON

```bash
# Create schema
cat > /tmp/schema.json << 'EOF'
{
  "type": "object",
  "properties": {
    "issues": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "file": {"type": "string"},
          "line": {"type": "integer"},
          "severity": {"enum": ["error", "warning", "info"]},
          "message": {"type": "string"}
        }
      }
    },
    "summary": {"type": "string"}
  }
}
EOF

jj diff --git | codex exec --output-schema /tmp/schema.json "Review and report issues"
```

## Building Specialized Skills

This skill is the foundation. Specialized skills should:

1. Load `@codex` for CLI patterns
2. Add domain-specific prompts/criteria
3. Handle their specific input gathering

Example structure for a specialized skill:

```markdown
## Process

1. Gather context (diff, spec file, etc.)
2. Build prompt with domain criteria
3. Invoke codex exec with piped context
4. Parse/present results
```

See `@codex-review` for code quality reviews and `@spec-review` for specification reviews.

## Error Handling

- **Non-zero exits**: Stop and report the error to the user
- **High-impact flags**: Ask permission before using `--full-auto` or `danger-full-access`
- **Partial results**: Summarize warnings and incomplete outputs

## Following Up

After running Codex commands:
- Use `AskUserQuestion` to determine next steps
- Remind about resume capability for follow-up work
- Restate model/sandbox/effort settings when proposing follow-up commands

## Tips

- Use `--sandbox read-only` (default) for review tasks
- Pipe large diffs; don't paste into prompt string
- Use `-o` to capture output for further processing
- Codex runs its own tools; no need to pre-gather all files
- Always use `--skip-git-repo-check` to avoid repo validation issues
