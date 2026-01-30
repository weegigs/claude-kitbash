#!/usr/bin/env bash
# Agent-OS session-start.sh
# Detects agent-os state and suggests CLAUDE.md updates if needed
# Output: JSON for Claude only - nothing visible to user terminal

set -euo pipefail

# Check for .agent-os directory
AGENT_OS_INITIALIZED=false
if [ -d ".agent-os" ]; then
  AGENT_OS_INITIALIZED=true
fi

# Check CLAUDE.md for agent-os mention
CLAUDE_MD_EXISTS=false
CLAUDE_MD_HAS_AGENT_OS=false
if [ -f "CLAUDE.md" ]; then
  CLAUDE_MD_EXISTS=true
  if grep -qi "agent-os\|/spec\|/standards\|/triage\|/kick-off" CLAUDE.md 2>/dev/null; then
    CLAUDE_MD_HAS_AGENT_OS=true
  fi
fi

# Build context message
CONTEXT=""

if [ "$AGENT_OS_INITIALIZED" = true ]; then
  # Fully initialized - brief reminder
  CONTEXT="**Agent-OS**: Standards in \`.agent-os/\`. Skills: \`/spec\`, \`/triage\`, \`/standards\`, \`/kick-off\`"

  if [ "$CLAUDE_MD_HAS_AGENT_OS" = false ]; then
    CONTEXT="$CONTEXT | Consider adding agent-os guidance to CLAUDE.md"
  fi
else
  # Not initialized - suggest setup
  CONTEXT="**Agent-OS**: Not initialized. Run \`/setup\` to configure standards and specs."

  if [ "$CLAUDE_MD_EXISTS" = true ] && [ "$CLAUDE_MD_HAS_AGENT_OS" = false ]; then
    CONTEXT="$CONTEXT | CLAUDE.md exists but lacks agent-os guidance - consider updating after setup."
  fi
fi

jq -n --arg ctx "$CONTEXT" '{
  "suppressOutput": true,
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'

exit 0
