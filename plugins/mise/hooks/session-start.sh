#!/usr/bin/env bash
# Mise context injection for Claude Code sessions

set -euo pipefail

# Check for mise configuration files
has_mise_config() {
    [[ -f "mise.toml" ]] || \
    [[ -f ".mise.toml" ]] || \
    [[ -f "mise.local.toml" ]] || \
    [[ -f ".tool-versions" ]] || \
    [[ -d ".mise" ]]
}

# Check if mise is installed
has_mise() {
    command -v mise &>/dev/null
}

# Exit silently if not a mise project
if ! has_mise_config; then
    exit 0
fi

# Build context message
cat << 'EOF'
# Mise Environment Active

This project uses **mise** for development environment management.

## Critical: All CLI Commands Must Use Mise

```bash
# CORRECT
mise exec -- npm install
mise exec -- cargo build
mise exec -- pytest

# WRONG (bypasses mise)
npm install
cargo build
pytest
```

## Quick Reference

| Operation | Command |
|-----------|---------|
| Run CLI tool | `mise exec -- <command>` |
| Run project task | `mise run <task>` |
| Install tools | `mise install` |
| List tools | `mise ls` |
| Check setup | `mise doctor` |

## Anti-Patterns

| Wrong | Correct |
|-------|---------|
| `npm install` | `mise exec -- npm install` |
| `cargo build` | `mise exec -- cargo build` |
| `python script.py` | `mise exec -- python script.py` |
| `pnpm dev` | `mise exec -- pnpm dev` |

EOF

# Show current tools if mise is available
if has_mise; then
    echo "## Current Tools"
    echo ""
    echo '```'
    mise ls --current 2>/dev/null || echo "(run 'mise install' to install tools)"
    echo '```'
    echo ""

    # Show available tasks if any
    if mise tasks ls &>/dev/null 2>&1; then
        task_count=$(mise tasks ls 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$task_count" -gt 0 ]]; then
            echo "## Available Tasks"
            echo ""
            echo '```'
            mise tasks ls 2>/dev/null | head -10
            if [[ "$task_count" -gt 10 ]]; then
                echo "... and $((task_count - 10)) more (run 'mise tasks ls')"
            fi
            echo '```'
            echo ""
        fi
    fi
fi
