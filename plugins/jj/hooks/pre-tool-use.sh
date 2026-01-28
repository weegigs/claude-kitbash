#!/usr/bin/env bash
# kitbash-jj pre-tool-use.sh
# Catches common jj anti-patterns before they execute

set -euo pipefail

# Read the tool input from stdin
INPUT=$(cat)

# Extract the command from the JSON input
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# If no command (not a Bash tool call), allow
if [ -z "$COMMAND" ]; then
  echo '{"ok": true}'
  exit 0
fi

# Check for jj describe without -r flag (setting description on working copy)
# Pattern: "jj describe" followed by -m but NOT preceded by -r
if echo "$COMMAND" | grep -qE 'jj\s+describe\s+(-m|--message)' && \
   ! echo "$COMMAND" | grep -qE 'jj\s+describe\s+(-r|--revision)'; then
  cat << 'EOF'
{
  "ok": false,
  "reason": "STOP: `jj describe -m` sets description on working copy (@), which should ALWAYS be `(no description set)`. Use `jj split . -m \"message\"` to create commits. Use `jj describe -r <rev> -m \"msg\"` only to edit historical commit messages."
}
EOF
  exit 0
fi

# Check for jj split without fileset (will open interactive editor)
if echo "$COMMAND" | grep -qE 'jj\s+split\s+-m' && \
   ! echo "$COMMAND" | grep -qE 'jj\s+split\s+\S+\s+-m'; then
  cat << 'EOF'
{
  "ok": false,
  "reason": "STOP: `jj split -m` without a fileset opens an interactive editor (fails in non-TTY). Use `jj split . -m \"message\"` to commit all changes, or `jj split <file> -m \"msg\"` for specific files."
}
EOF
  exit 0
fi

# All checks passed
echo '{"ok": true}'
exit 0
