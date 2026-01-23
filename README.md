# Claude Kitbash

Shareable Claude Code plugins for **beads** issue tracking, **jj** (Jujutsu) version control, **Convex** backend development, **agent-os** standards/specs, and code quality workflows.

## Plugins

| Plugin | Description | Contents |
|--------|-------------|----------|
| `beads@kitbash` | Beads issue tracking | Skills, SessionStart hook |
| `jj@kitbash` | Jujutsu version control | Skills (jj, jj-workspace, spawn-worker), SessionStart hook |
| `workflow@kitbash` | Workflow commands | /kick-off, /next, /check |
| `code-quality@kitbash` | Code quality tools | cleaner agent, codex-review command, principles + cleaning skills |
| `convex@kitbash` | Convex backend development | Skills for functions, schema, storage, scheduling |
| `agent-os@kitbash` | Standards & specs | Standards discovery, spec planning, product docs |

## Installation

```bash
# Add the marketplace
/plugin marketplace add weegigs/claude-kitbash

# Install what you need
/plugin install beads@kitbash       # Issue tracking
/plugin install jj@kitbash          # Version control + workspace management
/plugin install workflow@kitbash    # Workflow commands
/plugin install code-quality@kitbash # Code cleaning agent
/plugin install convex@kitbash      # Convex backend development
/plugin install agent-os@kitbash    # Standards discovery & spec planning
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

| Skill | Purpose |
|-------|---------|
| `ready` | Find available work |
| `show` | View issue details |
| `create` | Create new issues |
| `update` | Update issue status |
| `close` | Complete issues |
| `list` | List issues by filter |
| `dep` | Manage dependencies |
| `sync` | Sync with jj branches |
| `utilities` | Stats, doctor, blocked |

**SessionStart hook**: Validates `bd` is installed, injects workflow context.

### jj Plugin

Skills for [Jujutsu](https://martinvonz.github.io/jj/) version control:

| Skill | Purpose |
|-------|---------|
| `jj` | Core jj commands and git-to-jj mapping |
| `split` | Commit workflow: `jj split . -m "message"` |
| `diff` | LLM-friendly diffs: `jj diff --git` |
| `status` | Working copy status |
| `log` | View commit history |
| `jj-workspace` | Manage isolated workspaces in `~/.jj-workspaces` |
| `spawn-worker` | Spawn headless Claude agents in jj workspaces |

**SessionStart hook**: Validates `jj` is installed.

### workflow Plugin (v1.4.0)

| Command | Purpose |
|---------|---------|
| `/kick-off` | Create execution plan from requirements |
| `/execute` | Execute plan in ultrawork mode |
| `/next` | Recommend next task based on beads state |
| `/check` | Verify workflow completion before ending |

**`/kick-off` features:**
- Requires plan mode (verifies and stops if not in plan mode)
- Injects relevant standards from `.agent-os/standards/`
- Saves plan to TodoWrite for agent continuity
- Creates beads tasks with dependencies and checkpoints

**`/execute` features:**
- Finds plan from TodoWrite, beads, or specs
- Dual parallel code review: `/codex-review` + `@principles` agent
- No arbitrary deferrals — completes all planned work
- No silent TODOs — every TODO requires user approval → beads task
- No scope reduction without explicit approval

### code-quality Plugin (v1.2.0)

| Component | Purpose |
|-----------|---------|
| `cleaner` agent | Automated code cleanup using @cleaner and @principles skills |
| `/codex-review` command | Independent code review via Codex |

**Skills:**

| Skill | Purpose |
|-------|---------|
| `@cleaner` | Code cleaning methodology |
| `@codex-review` | Codex review process |
| `@principles` | 12 design principles with Rust/TypeScript examples |
| `@cleaning` | Language-specific patterns (TypeScript, Rust, Tokio, Svelte) |

### convex Plugin (v1.0.0)

Skills for [Convex](https://convex.dev) backend development (adapted for Bun runtime):

| Skill | Purpose |
|-------|---------|
| `@convex` | Quick reference - function types, validators, gotchas |
| `@convex-functions` | Queries, mutations, actions, HTTP endpoints, internal functions |
| `@convex-schema` | Schema definition, validators, indexes, TypeScript types |
| `@convex-storage` | File uploads, serving files, storage patterns |
| `@convex-scheduling` | Cron jobs, scheduled functions |

### agent-os Plugin (v1.2.0)

Standards discovery, spec planning, and product documentation for AI-assisted development.

**Main Commands:**

| Command | Purpose |
|---------|---------|
| `/setup` | Initialize or refresh agent-os configuration (auto-detects mode) |
| `/setup init` | Force initialization flow |
| `/setup refresh` | Force refresh flow (detect drift) |
| `/setup audit` | Report-only, no changes |
| `/standards` | One-shot standards management (auto-detects state, offers actions) |
| `/standards init` | Initialize baseline from a profile |
| `/standards update` | Update baseline to latest profile version |
| `/standards discover` | Discover project-specific standards |
| `/spec` | Shape and plan significant work with optional review |
| `/plan-product` | Create product documentation structure |

**`/setup` features:**
- Smart mode auto-detects if project needs init or refresh
- Init flow: audits existing docs, detects stack, suggests profile
- Refresh flow: detects drift (README changes, new dependencies, baseline updates)
- Audit mode: report-only drift detection without making changes
- Integrates with `/plan-product` and `/standards` for complete setup

**Supporting Skills:**

| Skill | Purpose |
|-------|---------|
| `/standards-inject` | Inject relevant standards into AI context |
| `/standards-index` | Build/update project standards index |
| `@spec-review` | Review methodology for implementation plans |
| `@standards-review` | Review methodology for discovered standards |

**Agents:**

| Agent | Purpose |
|-------|---------|
| `spec-reviewer` | Reviews implementation plans for completeness and coherence |
| `standards-reviewer` | Validates discovered standards for accuracy and usefulness |

**Profiles:**

| Profile | Stack |
|---------|-------|
| `tauri-svelte` | Svelte 5 + SvelteKit 2 + Tauri v2 + Rust 2024 + Convex (optional) |

**Directory Structure:**
```
.agent-os/
├── standards/
│   ├── baseline/      # Profile-managed (via /standards init & update)
│   └── project/       # User-managed (via /standards discover)
├── specs/             # Feature specs and implementation plans
└── product/           # Product documentation
```

Project standards shadow baseline at the same path. Use `@baseline(path)` to reference baseline content from overrides.

## Session Hooks

Both beads and jj plugins include session start hooks that:
- Validate tools are installed
- Inject quick reference context
- Set up workflow state

## License

MIT License - Wee Gigs Pty Ltd
