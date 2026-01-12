#!/usr/bin/env bash
# kitbash-beads session-start.sh
# Validates beads environment and injects workflow context

set -euo pipefail

ISSUES=()

# Check bd CLI
if command -v bd &> /dev/null; then
  BD_VERSION=$(bd --version 2>/dev/null | head -1 || echo "unknown")
  BD_STATUS="✓ bd installed ($BD_VERSION)"
else
  BD_STATUS="✗ bd not installed"
  # Platform-native first, then fallbacks
  if [[ "$OSTYPE" == "darwin"* ]]; then
    ISSUES+=("Install beads via Homebrew: brew install steveyegge/beads/bd")
    ISSUES+=("  Or via npm: npm install -g @beads/bd")
    ISSUES+=("  Or via Go: go install github.com/steveyegge/beads/cmd/bd@latest")
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ISSUES+=("Install beads via Homebrew: brew install steveyegge/beads/bd")
    ISSUES+=("  Or via npm: npm install -g @beads/bd")
    ISSUES+=("  Or via Go: go install github.com/steveyegge/beads/cmd/bd@latest")
  else
    ISSUES+=("Install beads: npm install -g @beads/bd")
    ISSUES+=("  Or via Go: go install github.com/steveyegge/beads/cmd/bd@latest")
  fi
fi

# Check beads initialized in project
if [ -d ".beads" ]; then
  BEADS_STATUS="✓ Beads initialized in project"
else
  BEADS_STATUS="○ Beads not initialized (run: bd init)"
fi

# Build context
CONTEXT="# Beads Issue Tracking

$BD_STATUS
$BEADS_STATUS

## Quick Reference

| Operation | Command |
|-----------|---------|
| Find ready work | \`bd ready\` |
| View issue | \`bd show <id>\` |
| Claim task | \`bd update <id> --claim\` |
| Create issue | \`bd create \"<title>\"\` |
| Complete work | \`bd close <id>\` |
| Sync from main | \`bd sync --from-main\` |

## Priority Scale
0/P0 = Critical, 1/P1 = High, 2/P2 = Medium, 3/P3 = Low, 4/P4 = Backlog

## Session Workflow
1. \`bd ready\` → find unblocked work
2. \`bd update <id> --claim\` → claim task
3. Work on task
4. \`bd sync --from-main\` → sync beads
5. \`bd close <id>\` → complete work"

# Add issues if any
if [ ${#ISSUES[@]} -gt 0 ]; then
  CONTEXT+="\n\n## Setup Required\n"
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
