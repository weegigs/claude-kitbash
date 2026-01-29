#!/usr/bin/env bash
# Language detection for Claude Code sessions
# Output: JSON for Claude only - nothing visible to user terminal

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

# Calculate totals
typescript_total=$((ts_count + tsx_count))

# Check if any supported languages are present
if [[ "$rust_count" -eq 0 ]] && [[ "$typescript_total" -eq 0 ]] && [[ "$svelte_count" -eq 0 ]]; then
    echo '{"suppressOutput":true}'
    exit 0
fi

# Build minimal context listing detected languages
LANGS=""
[[ "$rust_count" -gt 0 ]] && LANGS+="Rust ($rust_count), "
[[ "$typescript_total" -gt 0 ]] && LANGS+="TypeScript ($typescript_total), "
[[ "$svelte_count" -gt 0 ]] && LANGS+="Svelte ($svelte_count), "
LANGS="${LANGS%, }"  # Remove trailing comma

CONTEXT="**Languages detected**: $LANGS. Load \`/coding-context\` skill before implementing code."

# Output JSON with suppressOutput to keep terminal clean
jq -n --arg ctx "$CONTEXT" '{
  "suppressOutput": true,
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'

exit 0
