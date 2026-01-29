#!/usr/bin/env bash
# Mise context injection for Claude Code sessions
# Output: JSON for Claude only - nothing visible to user terminal

set -euo pipefail

# Check for mise configuration files
has_mise_config() {
    [[ -f "mise.toml" ]] || \
    [[ -f ".mise.toml" ]] || \
    [[ -f "mise.local.toml" ]] || \
    [[ -f ".tool-versions" ]] || \
    [[ -d ".mise" ]]
}

# Exit silently if not a mise project
if ! has_mise_config; then
    echo '{"suppressOutput":true}'
    exit 0
fi

# Build minimal context - skills have the full documentation
CONTEXT="**mise**: project uses mise for environment management. Load \`/mise\` skill before running CLI commands."

# Output JSON with suppressOutput to keep terminal clean
jq -n --arg ctx "$CONTEXT" '{
  "suppressOutput": true,
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'

exit 0
