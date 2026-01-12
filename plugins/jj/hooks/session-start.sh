#!/usr/bin/env bash
# kitbash-jj session-start.sh
# Validates jj environment and injects workflow context

set -euo pipefail

ISSUES=()

# Check jj CLI
if command -v jj &> /dev/null; then
  JJ_VERSION=$(jj --version 2>/dev/null | head -1 || echo "unknown")
  JJ_STATUS="✓ jj installed ($JJ_VERSION)"
else
  JJ_STATUS="✗ jj not installed"
  ISSUES+=("Install jj: https://martinvonz.github.io/jj/latest/install-and-setup/")
  if [[ "$OSTYPE" == "darwin"* ]]; then
    ISSUES+=("  macOS: brew install jj")
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ISSUES+=("  Linux: cargo install --locked jj-cli")
  fi
fi

# Check jj repository
if [ -d ".jj" ] || jj root &> /dev/null 2>&1; then
  JJ_REPO_STATUS="✓ jj repository found"
else
  JJ_REPO_STATUS="○ Not a jj repository"
  ISSUES+=("Initialize: jj git init --colocate (in existing git repo)")
  ISSUES+=("  Or: jj init (new repo)")
fi

# Build context
CONTEXT="# Jujutsu (jj) Version Control

$JJ_STATUS
$JJ_REPO_STATUS

## This project uses jj, NOT git

| git command | jj equivalent |
|-------------|---------------|
| git status | \`jj status\` |
| git diff | \`jj diff --git\` |
| git log | \`jj log\` |
| git add + commit | \`jj split -m \"msg\" <files>\` |
| git branch | \`jj bookmark\` |
| git checkout | \`jj new\` / \`jj edit\` |
| git stash | (not needed, auto-saved) |

## Key Differences
- **No staging area** - jj auto-tracks all changes
- **Working copy** - Always has \`(no description set)\`
- **Commits** - Use \`jj split -m \"message\" .\` (past tense)
- **Diffs** - Use \`--git\` flag for LLM-compatible output

## Common Workflow
\`\`\`bash
jj status              # View changes
jj diff --git          # See diffs
jj split -m \"Added feature\" .  # Commit all
jj split -m \"Fixed bug\" file.rs # Commit specific file
\`\`\`"

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
