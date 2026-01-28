---
name: release
description: Prepare and execute marketplace releases. Use when releasing new versions: identifies changes since last release, suggests semantic version bumps, and updates changelog and version files.
---

# Release

Manage releases for the Claude Kitbash marketplace. Identifies changes since last release, suggests version bumps, and updates all version files.

## Usage

```
/release              # Interactive release flow
/release check        # Check what would be released (dry run)
/release bump <ver>   # Bump marketplace version directly
```

## Process (no args)

### Step 1: Identify Changes Since Last Release

```bash
# Get the last release tag/commit
jj log -r 'tags()' --limit 1 2>/dev/null || echo "no tags"

# Get commits since last release (or all if no tags)
jj log -r 'ancestors(@) ~ ancestors(tags())' --no-graph
```

If no tags exist, use first commit as baseline.

### Step 2: Analyze Changed Plugins

For each plugin directory, check for modifications:

```bash
# Check each plugin for changes
for plugin in plugins/*/; do
  jj diff -r 'ancestors(@) ~ ancestors(tags())' --summary "$plugin"
done
```

Build a change report:

| Plugin | Changed Files | Change Type |
|--------|---------------|-------------|
| agent-os | 3 files | New skill added |
| workflow | 0 files | No changes |
| code-quality | 1 file | Bug fix |

### Step 3: Check Current Versions

Read current versions from each plugin:

```bash
# For each plugin
cat plugins/*/\.claude-plugin/plugin.json | jq -r '.name + "@" + .version'
```

Compare to changelog to detect version mismatches.

### Step 4: Suggest Version Bumps

Apply semantic versioning rules:

| Change Type | Version Bump | Examples |
|-------------|--------------|----------|
| Breaking changes | Major (X.0.0) | Removed skill, renamed command, changed behavior |
| New features | Minor (x.Y.0) | New skill, new command, new agent |
| Bug fixes | Patch (x.y.Z) | Fix in existing skill, documentation fix |

Present suggestions:

```
Release Analysis
================

Plugins with changes:
  agent-os: 1.1.0 → 1.2.0 (new skill: /setup)
  code-quality: 1.2.0 (no changes)
  workflow: 1.4.0 (no changes)
  beads: 1.0.0 (no changes)
  jj: 1.0.0 (no changes)
  convex: 1.0.0 (no changes)

Marketplace: 1.4.0 → 1.5.0

Proceed with these versions? (yes / edit / cancel)
```

If "edit" → allow user to override version numbers.

### Step 5: Update Version Files

Update ALL version files for consistency:

1. **Marketplace file** (source of truth):
   ```bash
   # File: .claude-plugin/marketplace.json
   # Update top-level "version" for marketplace version
   # Update plugins[].version for each changed plugin
   ```

2. **Individual plugin files**:
   ```bash
   # File: plugins/{plugin}/.claude-plugin/plugin.json
   # Update "version" field to match marketplace.json
   ```

Both files must be updated to maintain consistency.

### Step 6: Update CHANGELOG.md

Generate changelog entry from commits:

```bash
# Get commit messages for changelog
jj log -r 'ancestors(@) ~ ancestors(tags())' --no-graph -T 'description'
```

Create new section at top of CHANGELOG.md:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### {plugin} vX.Y.Z
- {change description from commits}
- {another change}

### Documentation
- {any README changes}
```

### Step 7: Hygiene Checks

Before finalizing:

```bash
# Validate all JSON files
for f in plugins/*/.claude-plugin/plugin.json; do
  jq empty "$f" || echo "Invalid JSON: $f"
done

# Check version consistency
# Ensure CHANGELOG versions match plugin.json versions

# Check for uncommitted changes (should only be release changes)
jj status
```

### Step 8: Create Release Commit

```bash
# Stage and commit
jj split . -m "Released v{marketplace_version}: {summary}"
```

### Step 9: Tag Release (optional)

```bash
# Create tag for the release
jj tag create "v{marketplace_version}"
```

---

## Check Mode (`/release check`)

Dry-run that shows what would be released without making changes:

```
Release Check (dry run)
=======================

Changes since last release (v1.4.0):

agent-os:
  + plugins/agent-os/skills/setup/SKILL.md (new file)
  
Suggested version bumps:
  agent-os: 1.1.0 → 1.2.0
  marketplace: 1.4.0 → 1.5.0

Run /release to apply these changes.
```

---

## Bump Mode (`/release bump <version>`)

Directly bump marketplace version without analysis:

```bash
/release bump 2.0.0
```

This:
1. Updates marketplace version in relevant files
2. Prompts for changelog entry
3. Creates commit

Use for manual version control when automated analysis isn't needed.

---

## Version Tracking

### Files to Update

| File | Field |
|------|-------|
| `.claude-plugin/marketplace.json` | `version` (marketplace) and plugin `version` entries |
| `plugins/{name}/.claude-plugin/plugin.json` | `version` |
| `CHANGELOG.md` | New section header |
| `README.md` | Version badges (if any) |

**CRITICAL**: The `.claude-plugin/marketplace.json` file is the source of truth for:
1. Marketplace version (top-level `version` field)
2. Plugin versions (in the `plugins` array)

Both must be updated when releasing. The individual `plugins/{name}/.claude-plugin/plugin.json` files should match the versions in `marketplace.json`.

### Version Sources

- Marketplace version: `.claude-plugin/marketplace.json` → `version`
- Plugin versions: `.claude-plugin/marketplace.json` → `plugins[].version`
- Plugin versions (backup): `plugins/{name}/.claude-plugin/plugin.json`
- Release history: `jj log` / `jj tags`

---

## Changelog Format

Follow Keep a Changelog format:

```markdown
## [1.5.0] - 2026-01-24

### agent-os v1.2.0
- Added `/setup` skill for initialization and refresh workflows
- Smart mode detects if project needs init or refresh
- Audit mode for report-only drift detection

### Documentation
- Updated README with /setup documentation
```

### Change Categories

- **Added** - New features
- **Changed** - Changes to existing functionality
- **Deprecated** - Features to be removed
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Security fixes

---

## Tips

- Run `/release check` first to see what would be released
- Commits should be atomic and well-described for good changelog generation
- Use conventional commit messages for easier categorization
- Tag releases for easy reference: `jj tag create "v1.5.0"`
