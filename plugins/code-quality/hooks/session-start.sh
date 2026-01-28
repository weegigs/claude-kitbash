#!/usr/bin/env bash
# Language detection and skill injection guidance for Claude Code sessions

set -euo pipefail

# Count files by extension in common source directories
count_files() {
    local ext="$1"
    find . -type f -name "*.$ext" \
        -not -path "*/node_modules/*" \
        -not -path "*/target/*" \
        -not -path "*/.git/*" \
        -not -path "*/dist/*" \
        -not -path "*/build/*" \
        -not -path "*/.jj/*" \
        2>/dev/null | wc -l | tr -d ' '
}

# Detect languages present in the codebase
rust_count=$(count_files "rs")
ts_count=$(count_files "ts")
tsx_count=$(count_files "tsx")
svelte_count=$(count_files "svelte")
python_count=$(count_files "py")
go_count=$(count_files "go")

# Calculate totals
typescript_total=$((ts_count + tsx_count))

# Check if any supported languages are present
has_supported_lang=false
if [[ "$rust_count" -gt 0 ]] || [[ "$typescript_total" -gt 0 ]] || [[ "$svelte_count" -gt 0 ]]; then
    has_supported_lang=true
fi

# Exit silently if no supported languages detected
if [[ "$has_supported_lang" != "true" ]]; then
    exit 0
fi

# Build context message
cat << 'HEADER'
# Code Quality: Language Skills

When implementing or reviewing code, load the appropriate language skill BEFORE writing code.

HEADER

echo "## Detected Languages"
echo ""
echo "| Language | Files | Skill to Load |"
echo "|----------|-------|---------------|"

if [[ "$rust_count" -gt 0 ]]; then
    echo "| Rust | $rust_count | \`@rust\` |"
fi

if [[ "$typescript_total" -gt 0 ]]; then
    echo "| TypeScript | $typescript_total | \`@typescript\` |"
fi

if [[ "$svelte_count" -gt 0 ]]; then
    echo "| Svelte | $svelte_count | \`@svelte\` + \`@typescript\` |"
fi

# Note unsupported but present languages
if [[ "$python_count" -gt 0 ]] || [[ "$go_count" -gt 0 ]]; then
    echo ""
    echo "**Also present** (no skill yet):"
    [[ "$python_count" -gt 0 ]] && echo "- Python ($python_count files)"
    [[ "$go_count" -gt 0 ]] && echo "- Go ($go_count files)"
fi

cat << 'FOOTER'

## When to Load

- **Before implementing**: Load skill for target file type
- **Before reviewing**: Load skill to catch language-specific anti-patterns
- **Once per task**: No need to reload for each file

## Quick Reference

| Extension | Load |
|-----------|------|
| `.rs` | `@rust` (+ `@tokio` if async) |
| `.ts`, `.tsx` | `@typescript` |
| `.svelte` | `@svelte` + `@typescript` |

Always load `@principles` for universal quality standards.

FOOTER
