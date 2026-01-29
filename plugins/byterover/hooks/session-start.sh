#!/usr/bin/env bash
# ByteRover session-start.sh
# Validates brv environment and provides minimal context
# Output: JSON for Claude only - nothing visible to user terminal

set -euo pipefail

# Check brv CLI (try mise exec first, then direct)
BRV_AVAILABLE=false
if command -v mise &> /dev/null && mise exec -- brv --version &> /dev/null 2>&1; then
  BRV_AVAILABLE=true
elif command -v brv &> /dev/null; then
  BRV_AVAILABLE=true
fi

if [ "$BRV_AVAILABLE" = false ]; then
  jq -n '{
    "suppressOutput": true,
    "hookSpecificOutput": {
      "hookEventName": "SessionStart",
      "additionalContext": "**brv**: not installed. Install via mise or check PATH."
    }
  }'
  exit 0
fi

# Check if project has brv initialized
if [ ! -d ".brv" ]; then
  jq -n '{
    "suppressOutput": true,
    "hookSpecificOutput": {
      "hookEventName": "SessionStart",
      "additionalContext": "**brv**: available but not initialized in this project."
    }
  }'
  exit 0
fi

# Project has brv - provide minimal reminder
jq -n '{
  "suppressOutput": true,
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "**ByteRover**: `brv query \"topic\"` before unfamiliar work. Load `/byterover` for full docs."
  }
}'

exit 0
