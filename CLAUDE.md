# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Claude Kitbash is a marketplace of shareable Claude Code plugins. Each plugin in `plugins/` provides skills, hooks, agents, and/or commands for Claude Code.

## Architecture

```
.claude-plugin/marketplace.json    # Marketplace index (source of truth for versions)
plugins/
  {plugin}/
    .claude-plugin/plugin.json     # Plugin manifest (version must match marketplace.json)
    skills/{skill}/SKILL.md        # Skill definitions
    skills/{skill}/references/     # Progressive disclosure - detailed docs
    hooks/hooks.json               # Hook configuration
    hooks/*.sh                     # Hook scripts
    agents/*.md                    # Agent definitions
    commands/*.md                  # Command definitions
```

## Plugin Development

### Creating a Plugin

1. Create directory structure: `plugins/{name}/.claude-plugin/plugin.json`
2. Add skills in `plugins/{name}/skills/{skill}/SKILL.md`
3. Register in `.claude-plugin/marketplace.json`

### Skill Best Practices

- **Progressive disclosure**: Keep SKILL.md lean (~1500 words), detailed content in `references/`
- **Third-person descriptions**: "This skill should be used when..." not "Use this skill when..."
- **Imperative form**: "Query before starting work" not "You should query..."
- **Tables over prose**: More scannable, lower token count

### Hook Scripts

SessionStart hooks should output JSON with `suppressOutput: true`:

```bash
jq -n '{
  "suppressOutput": true,
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Brief context here"
  }
}'
```

## Version Management

**Both files must stay in sync:**
- `.claude-plugin/marketplace.json` - marketplace version + all plugin versions
- `plugins/{name}/.claude-plugin/plugin.json` - individual plugin version

Use `/release` skill to manage versions and changelog.

### Semantic Versioning

| Change | Bump |
|--------|------|
| Breaking change | Major |
| New skill/command/agent | Minor |
| Bug fix, doc update | Patch |

## Local Development

Test plugins locally:
```bash
claude --plugin-dir /path/to/claude-kitbash/plugins/{plugin}
```

## Version Control

This project uses **jj** (Jujutsu), not git. Commits use past tense.

```bash
jj status                    # View changes
jj diff --git                # View diff
jj split . -m "Added feature"  # Create commit (always include fileset)
```
