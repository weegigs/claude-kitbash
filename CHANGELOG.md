# Changelog

All notable changes to Claude Kitbash are documented in this file.

## [1.10.0] - 2026-01-28

### code-quality v1.5.0
- Added `@cop-out-detector` agent for detecting deferred work and workarounds
- Enhanced `@reviewer` agent with mandatory cop-out pattern checklist
- Added Stop hook to verify genuine completion before allowing "done"
- Added SubagentStop hook to catch incomplete subagent work
- Cop-out patterns: TODO/FIXME, lint suppressions, type bypasses, empty catches, skipped tests

### workflow v1.6.0
- Added cop-out scan section to `/check` skill with grep commands
- Enhanced `/execute` skill with "Hard-Nosed Perfectionist" mindset
- Added discovered work protocol: STOP → ASSESS → ASK → WAIT → ACT
- Enforces: tracked deferrals require explicit user approval, not just beads reference

### search v1.1.1
- Added YAML frontmatter with name+description to all skill files
- No functional changes, metadata compliance fix

## [1.9.0] - 2026-01-28

### search v1.1.0
- Added `/deep-research` skill for multi-step investigation workflows
- Added `/verify` skill for source verification and fact-checking
- Added `/plan` skill for research planning before execution
- Added `@patterns` sub-skill documenting search hierarchy and best practices
- Added `@context7` sub-skill for library documentation via MCP
- Added `@perplexity` sub-skill for deep research with citations
- Progressive disclosure: main skill → sub-skills for detailed guidance

## [1.8.0] - 2026-01-28

### mise v1.0.0 (NEW PLUGIN)
- New plugin for mise development environment management
- SessionStart hook validates mise installation and shows current tools
- Skill index with sub-skills: `@exec`, `@run`, `@tools`, `@env`, `@use`
- Critical pattern: all CLI commands must use `mise exec -- <command>`

### code-quality v1.4.0
- Added SessionStart hook for automatic language detection
- Added `/coding-context` skill for on-demand language skill injection
- Added `@implementer` agent with language-aware quality standards
- Added `@addresser` agent for fixing review findings with idiom awareness
- Added `@reviewer` agent with language-specific pattern checking
- Enhanced `@cleaner` agent with explicit language detection instructions
- Added Option Combinators section to `@rust` skill (flatten nested if-let)
- Restructured `@rust` skill with 3-level hierarchy and table of contents
- Updated `/execute` to inject language skills at start of implementation
- Language skill auto-injection: `.rs` → `@rust`, `.ts/.tsx` → `@typescript`, `.svelte` → `@svelte`

## [1.7.0] - 2026-01-28

### code-quality v1.3.0
- Added `@codex` skill as neutral Codex CLI base (jj-native patterns)
- Added `@codex-review` skill with multi-agent support (scales by complexity: 1-3 agents)
- Added `@codex-spec-review` skill for independent spec validation via Codex
- Removed commands/ directory—skills are the clean interface
- Multi-agent reviews run in parallel for diverse perspectives (design, safety, quality)

### workflow v1.5.0
- Migrated all commands to skills: `/check`, `/execute`, `/kick-off`, `/next`
- Removed commands/ directory—skills are the clean interface
- Updated all skills to be jj-native (no git references)
- Improved skill descriptions with "Use when" triggers per agentskills.io spec
- Added cross-references between skills (`@codex-review`, `@principles`, etc.)

### agent-os v1.4.0
- Standardized file naming: all `skill.md` files renamed to `SKILL.md`
- Updated 10 skill descriptions with "Use when" trigger conditions
- Split `/setup` skill into references/ (init-flow, refresh-flow, audit-flow)
- Split `/plan-product` skill templates into references/
- Consolidated resolution order documentation into shared reference
- Extracted writing conciseness guidelines into shared reference
- Removed redundant `commands/setup.md`—skill already exists

### Documentation
- Updated code-quality README with new Codex skills and multi-agent patterns
- Updated main README with workflow skills (not commands) and code-quality v1.3.0
- All documentation now references skills as the primary interface

## [1.6.0] - 2026-01-23

### agent-os v1.3.0
- Refactored `/spec` as universal work preparation command with progressive disclosure
- Added work-type detection: bug, feature, refactor, research
- Added work-type specific sub-skills: `@spec-bug`, `@spec-feature`, `@spec-refactor`, `@spec-research`
- Implemented EARS notation for requirements (kiro.dev methodology)
- Updated `@spec-review` to validate new specification structure with test compliance mapping
- Spec output now ready for `/kick-off` execution planning phase

### Documentation
- Updated README with v1.3.0 /spec workflow documentation

## [1.5.0] - 2026-01-23

### agent-os v1.2.0
- Added `/setup` skill for project initialization and refresh workflows
- Smart mode auto-detects if project needs init or refresh
- Init flow: audits existing docs, detects stack, suggests profile, hands off to `/plan-product` and `/standards`
- Refresh flow: detects drift (README changes, new dependencies, baseline updates, undocumented patterns)
- Audit mode for report-only drift detection without making changes

### Infrastructure
- Added `/release` skill for marketplace release management
- Release skill identifies changes, suggests version bumps, updates changelog and version files

### Documentation
- Updated README with /setup documentation

## [1.4.0] - 2026-01-23

### workflow v1.4.0
- Added plan mode verification to `/kick-off` - stops and instructs user if not in plan mode
- Added dual parallel code review requirement: `/codex-review` + `@principles` agent
- Updated workflow commands to use `.agent-os/specs/` instead of openspec

### Documentation
- Updated README with workflow v1.4.0 features

## [1.3.0] - 2026-01-23

### workflow v1.3.0
- Added `/execute` command for ultrawork plan execution
- Integrated standards injection into `/kick-off`
- Added plan mode instructions (`--permission-mode plan`, `/plan`, `Shift+Tab`)
- Refined kick-off and execute: TodoWrite continuity, no arbitrary deferrals, TODO tracking via beads
- Added mandatory code review step before commits

### agent-os v1.1.0 (New Plugin)
- Added standards management with baseline/project architecture
- Added `/standards` one-shot orchestrator command
- Added `/standards-init`, `/standards-update`, `/standards-discover` skills
- Added `/standards-inject`, `/standards-index` supporting skills
- Added `/spec` for shaping and planning work
- Added `/plan-product` for product documentation
- Added `spec-reviewer` and `standards-reviewer` agents
- Added `tauri-svelte` profile with 10 standards (Svelte 5, Tauri v2, Rust, TypeScript, Convex)

### Documentation
- Updated README with agent-os plugin documentation
- Added baseline/project standards architecture documentation

## [1.2.0] - 2026-01-23

### workflow v1.2.0
- Integrated `/standards-inject` into `/kick-off` command

### agent-os v1.0.0 (New Plugin)
- Initial release of agent-os plugin
- Standards discovery and spec planning capabilities

## [1.1.0] - 2026-01-15

### code-quality v1.2.0
- Extracted cleaner and codex-review into separate skills
- Added `@principles` skill with 12 design principles
- Added `/codex-review` command for independent code review

### code-quality v1.1.0
- Added principles skill with design principles and Codex review command

### workflow v1.1.0
- Minor improvements and bug fixes

## [1.0.0] - 2026-01-12

### Initial Release

#### beads v1.0.0
- Skills for beads issue tracking: ready, show, create, update, close, list, dep, sync, utilities
- SessionStart hook for validation and context injection

#### jj v1.0.0
- Skills for Jujutsu version control: jj, split, diff, status, log
- Added jj-workspace skill for managing isolated workspaces
- Added spawn-worker skill for headless Claude agents
- SessionStart hook for jj validation

#### workflow v1.0.0
- `/kick-off` command for creating execution plans
- `/next` command for task recommendations
- `/check` command for workflow verification

#### code-quality v1.0.0
- `cleaner` agent for automated code cleanup
- Cleaning skills for TypeScript, Rust, Tokio, Svelte
- Imperative shell/functional core patterns
- Property-based and snapshot testing patterns

### Infrastructure
- Plugin marketplace structure
- Plugin configuration matching Claude Code format
