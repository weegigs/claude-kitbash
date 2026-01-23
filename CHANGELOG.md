# Changelog

All notable changes to Claude Kitbash are documented in this file.

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
