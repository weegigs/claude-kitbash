#!/usr/bin/env bash
# kitbash-beads session-start.sh
# Validates beads environment and provides minimal context (skills have the details)
# Output: JSON for Claude only - nothing visible to user terminal

set -euo pipefail

ISSUES=()

# Check bd CLI (suppress all output)
if command -v bd &> /dev/null; then
  BD_VERSION=$(bd --version 2>/dev/null | head -1 || echo "unknown")
  BD_STATUS="bd installed ($BD_VERSION)"
else
  BD_STATUS="bd not installed"
  ISSUES+=("Install: brew install steveyegge/beads/bd")
fi

# Check beads initialized in project
if [ -d ".beads" ]; then
  BEADS_REPO="beads initialized"
else
  BEADS_REPO="beads not initialized"
  ISSUES+=("Initialize: bd init")
fi

# Build minimal context - skills have the full documentation
CONTEXT="**beads**: $BD_STATUS, $BEADS_REPO. Load \`/beads\` skill for issue tracking."

# Add issues if any
if [ ${#ISSUES[@]} -gt 0 ]; then
  CONTEXT+="\n\n**Setup required:**"
  for issue in "${ISSUES[@]}"; do
    CONTEXT+="\n- $issue"
  done
fi

# Output JSON with suppressOutput to keep terminal clean
jq -n --arg ctx "$(echo -e "$CONTEXT")" '{
  "suppressOutput": true,
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'

exit 0
