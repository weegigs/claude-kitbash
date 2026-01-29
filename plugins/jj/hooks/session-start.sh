#!/usr/bin/env bash
# kitbash-jj session-start.sh
# Validates jj environment and provides minimal context (skills have the details)

set -euo pipefail

ISSUES=()

# Check jj CLI
if command -v jj &> /dev/null; then
  JJ_VERSION=$(jj --version 2>/dev/null | head -1 || echo "unknown")
  JJ_STATUS="jj installed ($JJ_VERSION)"
else
  JJ_STATUS="jj not installed"
  ISSUES+=("Install jj: https://martinvonz.github.io/jj/latest/install-and-setup/")
fi

# Check jj repository
if [ -d ".jj" ] || jj root &> /dev/null 2>&1; then
  JJ_REPO="in jj repository"
else
  JJ_REPO="not a jj repository"
  ISSUES+=("Initialize: jj git init --colocate")
fi

# Build minimal context - skills have the full documentation
CONTEXT="**jj**: $JJ_STATUS, $JJ_REPO. Load \`/jj\` skill for version control operations."

# Add issues if any
if [ ${#ISSUES[@]} -gt 0 ]; then
  CONTEXT+="\n\n**Setup required:**"
  for issue in "${ISSUES[@]}"; do
    CONTEXT+="\n- $issue"
  done
fi

# Output JSON
ESCAPED_CONTEXT=$(echo -e "$CONTEXT" | jq -Rs .)

cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ESCAPED_CONTEXT
  }
}
EOF

exit 0
