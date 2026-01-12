# Claude Kitbash

Shareable Claude Code plugins for **beads** issue tracking and **jj** (Jujutsu) version control workflows.

## Plugins

| Plugin | Description | Dependencies |
|--------|-------------|--------------|
| `beads@kitbash` | Beads issue tracking skills | None |
| `jj@kitbash` | Jujutsu version control skills | None |
| `workflow@kitbash` | Workflow commands (/kick-off, /next, /check) | beads, jj |

## Installation

```bash
# Add the marketplace
/plugin marketplace add weegigs/claude-kitbash

# Install what you need
/plugin install beads@kitbash    # Issue tracking only
/plugin install jj@kitbash       # Version control only
/plugin install workflow@kitbash # All three (includes dependencies)
```

### Team Setup

Add to your project's `.claude/settings.json` for auto-install:

```json
{
  "marketplaces": [
    {
      "name": "kitbash",
      "source": "github.com/weegigs/claude-kitbash"
    }
  ],
  "plugins": [
    "workflow@kitbash"
  ]
}
```

## Requirements

### beads

```bash
# macOS/Linux (recommended)
brew install steveyegge/beads/bd

# Or via npm
npm install -g @beads/bd

# Or via Go
go install github.com/steveyegge/beads/cmd/bd@latest
```

### jj

```bash
# macOS
brew install jj

# Linux
cargo install --locked jj-cli
```

See: https://martinvonz.github.io/jj/latest/install-and-setup/

## What's Included

### beads Plugin

Skills for the [beads](https://github.com/steveyegge/beads) issue tracker:

- Session workflow: `bd ready` → `bd update --claim` → work → `bd close`
- Priority scale: P0 (critical) to P4 (backlog)
- Dependency tracking: `bd dep add`, `bd blocked`
- jj-aware sync: `bd sync --from-main`

### jj Plugin

Skills for [Jujutsu](https://martinvonz.github.io/jj/) version control:

- git-to-jj command mapping
- Commit workflow: `jj split . -m "message"`
- LLM-friendly diffs: `jj diff --git`
- Working copy always has `(no description set)`

### workflow Plugin

| Command | Purpose |
|---------|---------|
| `/kick-off` | Create execution plan from requirements |
| `/next` | Recommend next task based on beads state |
| `/check` | Verify workflow completion before ending |

## Session Hooks

Both beads and jj plugins include session start hooks that validate tools are installed and inject quick reference context.

## License

MIT License - Wee Gigs Pty Ltd
