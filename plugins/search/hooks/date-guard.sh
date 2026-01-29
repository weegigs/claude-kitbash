#!/bin/bash
# Date Guard Hook: Blocks searches with outdated years
# Usage: Called by Claude Code PreToolUse hook for WebSearch/Perplexity tools
# Input: JSON via stdin
# Output: JSON for quiet, controlled UX

set -euo pipefail

# Read JSON from stdin
INPUT=$(cat)

# Extract tool name from stdin JSON
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Extract query based on tool type
# All current tools use tool_input.query
case "$TOOL_NAME" in
  WebSearch|mcp__perplexity__*)
    QUERY=$(echo "$INPUT" | jq -r '.tool_input.query // empty')
    ;;
  *)
    # Unknown tool - allow silently
    echo '{"suppressOutput":true}'
    exit 0
    ;;
esac

# Empty query - allow silently
if [ -z "$QUERY" ]; then
  echo '{"suppressOutput":true}'
  exit 0
fi

# Opt-out: allow historical queries
if echo "$QUERY" | grep -qiE '(historical|archive|history of|in the past)'; then
  echo '{"suppressOutput":true}'
  exit 0
fi

CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%B)

# Find years in query (2000-2029 range)
FOUND_YEARS=$(echo "$QUERY" | grep -oE '\b20[0-2][0-9]\b' | sort -u)

# Check if any year is stale
for year in $FOUND_YEARS; do
  if [ "$year" -lt "$CURRENT_YEAR" ]; then
    # Block with JSON output for clean UX
    REASON="Query contains outdated year '$year'. Current date is $CURRENT_MONTH $CURRENT_YEAR. Retry with '$CURRENT_YEAR' for current information. (Add 'historical' to query for past data)"

    # Output JSON with deny decision
    jq -n \
      --arg reason "$REASON" \
      '{
        "hookSpecificOutput": {
          "hookEventName": "PreToolUse",
          "permissionDecision": "deny",
          "permissionDecisionReason": $reason
        }
      }'
    exit 0
  fi
done

# Allow - suppress output for quiet experience
echo '{"suppressOutput":true}'
exit 0
