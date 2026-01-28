#!/bin/bash
# Date Guard Hook: Blocks searches with outdated years
# Usage: Called by Claude Code PreToolUse hook for WebSearch/Perplexity
# Input: JSON via stdin (not env vars!)

# Read JSON from stdin
INPUT=$(cat)

# Extract tool name and query from stdin JSON
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

case "$TOOL_NAME" in
  WebSearch)
    QUERY=$(echo "$INPUT" | jq -r '.tool_input.query // empty')
    ;;
  mcp__perplexity__perplexity_ask)
    QUERY=$(echo "$INPUT" | jq -r '.tool_input.messages[].content // empty')
    ;;
  *)
    exit 0
    ;;
esac

# Opt-out: allow historical queries
if echo "$QUERY" | grep -qiE '(historical|archive|history of|in the past)'; then
  exit 0
fi

CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%B)

# Find years in query (2000-2029 range)
FOUND_YEARS=$(echo "$QUERY" | grep -oE '\b20[0-2][0-9]\b' | sort -u)

# Check if any year is stale
for year in $FOUND_YEARS; do
  if [ "$year" -lt "$CURRENT_YEAR" ]; then
    echo "BLOCKED: Query contains outdated year '$year' but TODAY is $CURRENT_MONTH $CURRENT_YEAR." >&2
    echo "Retry with '$CURRENT_YEAR' instead of '$year' for current information." >&2
    echo "(Add 'historical' to query if you intentionally need past data)" >&2
    exit 2
  fi
done

exit 0
