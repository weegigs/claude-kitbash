---
name: setup
description: Initialize or refresh agent-os configuration. Auto-detects project state and offers appropriate actions.
---

# Setup

One-shot skill for agent-os initialization and maintenance. Automatically detects whether a project needs initial setup or a refresh.

## Usage

```
/setup              # Auto-detect mode and offer actions
/setup init         # Force initialization flow
/setup refresh      # Force refresh flow
/setup audit        # Report-only, no changes
```

## Process (no args)

### Step 1: Detect Project State

```bash
# Check for existing agent-os setup
ls .agent-os/ 2>/dev/null

# Check for existing documentation
ls README.md docs/ 2>/dev/null

# Check for project manifests
ls package.json Cargo.toml pyproject.toml go.mod 2>/dev/null
```

### Step 2: Classify State

| State | Signals | Action |
|-------|---------|--------|
| **New** | No `.agent-os/`, may have README/manifests | Init flow |
| **Configured** | `.agent-os/` exists with content | Refresh flow |
| **Partial** | `.agent-os/` exists but incomplete | Offer init or refresh |

### Step 3: Branch by State

**New Project (no `.agent-os/`):**

```
No agent-os configuration found.

Detected project signals:
- README.md: [exists/missing]
- package.json: [exists/missing] → [detected stack info]
- Cargo.toml: [exists/missing] → [detected stack info]
- docs/: [exists/missing]

Would you like to initialize agent-os for this project? (yes / no)
```

If yes → proceed to Init Flow

**Configured Project (`.agent-os/` exists):**

```
Agent-os configuration found.

Current state:
- Product docs: [count] files in .agent-os/product/
- Standards baseline: [profile@version or "none"]
- Project standards: [count] files
- Specs: [count] files in .agent-os/specs/

Checking for drift...
```

Then proceed to Refresh Flow

---

## Init Flow

### Step 1: Audit Existing Documentation

Scan for existing project documentation:

```bash
# Check common doc locations
cat README.md 2>/dev/null | head -100
ls docs/*.md 2>/dev/null
cat CONTRIBUTING.md 2>/dev/null | head -50
```

Report findings:

```
Found existing documentation:
- README.md (X lines) — [brief summary of content]
- docs/architecture.md — [brief summary]
- CONTRIBUTING.md — [brief summary]

This information will help bootstrap your product docs.
```

### Step 2: Detect Stack

Analyze project to detect technologies:

```bash
# Node/JS/TS
cat package.json 2>/dev/null | jq -r '.dependencies, .devDependencies | keys[]' 2>/dev/null

# Rust
cat Cargo.toml 2>/dev/null

# Python
cat pyproject.toml requirements.txt 2>/dev/null

# Go
cat go.mod 2>/dev/null
```

Map findings to profile suggestions:

| Detected | Suggested Profile |
|----------|-------------------|
| Svelte + Tauri + Rust | tauri-svelte |
| React + Node | (future: react-node) |
| Other | No profile, manual standards |

### Step 3: Suggest Profile

```
Based on your project, I recommend:

Profile: tauri-svelte
- Svelte 5 + SvelteKit 2
- Tauri v2
- Rust 2024 Edition
- Convex backend

Use this profile? (yes / different / none)
```

If "different" → list available profiles
If "none" → skip standards baseline, user will add manually

### Step 4: Create Structure

```bash
mkdir -p .agent-os/product
mkdir -p .agent-os/specs
mkdir -p .agent-os/standards/project
```

### Step 5: Hand Off to Product Planning

```
Agent-os structure created.

Next: Let's establish your product documentation.
```

Delegate to `/plan-product` to create:
- `.agent-os/product/mission.md`
- `.agent-os/product/roadmap.md`
- `.agent-os/product/tech-stack.md`

### Step 6: Initialize Standards

After product planning completes:

```
Product docs created. Now let's set up standards.
```

If profile was selected → delegate to `/standards init`
If no profile → show manual setup instructions:

```
No profile selected. To add standards manually:

1. Create standards in .agent-os/standards/project/
2. Use /standards discover to extract patterns from code
3. Use /standards-inject to apply them to conversations
```

### Step 7: Confirm Completion

```
Setup complete.

Created:
  .agent-os/product/mission.md
  .agent-os/product/roadmap.md
  .agent-os/product/tech-stack.md
  .agent-os/standards/baseline/ (if profile selected)

Next steps:
- Review product docs and refine as needed
- Add project-specific standards with /standards discover
- Create specs for features with /spec
```

---

## Refresh Flow

### Step 1: Check for Drift

Analyze multiple drift signals:

#### README Drift
```bash
# Compare README mod time to product docs
stat -f %m README.md 2>/dev/null
stat -f %m .agent-os/product/mission.md 2>/dev/null
```

If README is newer than product docs:

```
README.md was modified after product docs were created.
The product documentation may be out of sync.
```

#### Dependency Drift
```bash
# Check for new dependencies not in tech-stack.md
diff <(cat package.json | jq -r '.dependencies | keys[]' | sort) \
     <(grep -E '^\s*-' .agent-os/product/tech-stack.md | sed 's/.*- //' | sort) 2>/dev/null
```

If new dependencies found:

```
New dependencies detected not in tech-stack.md:
- @tanstack/svelte-query (added)
- zod (added)
```

#### Baseline Drift
```bash
# Read current baseline version
cat .agent-os/standards/baseline/manifest.yml 2>/dev/null
```

Compare to profile source version. If outdated:

```
Standards baseline is outdated.

Current: tauri-svelte@1.0.0
Latest:  tauri-svelte@1.1.0

Changes in 1.1.0:
- Updated Svelte 5 patterns
- Added new error handling standard
```

#### Pattern Drift
```bash
# Check for undocumented patterns in code
# Look for common patterns not in standards
grep -r "createQuery\|createMutation" src/ 2>/dev/null | head -5
```

If significant patterns found without standards:

```
Detected patterns in code without matching standards:
- TanStack Query usage (found in 8 files)
- Zod schemas (found in 12 files)

Consider documenting these with /standards discover
```

### Step 2: Present Drift Report

```
Refresh Analysis
================

README drift: [yes/no]
  README.md modified [date], product docs from [date]

Dependency drift: [yes/no]
  [N] new dependencies not in tech-stack.md

Baseline drift: [yes/no]
  Current: [version], Latest: [version]

Pattern drift: [yes/no]
  [N] undocumented patterns detected

Actions available:
1. Update product docs from README
2. Sync tech-stack with dependencies
3. Update standards baseline
4. Discover new standards from code
5. Apply all updates
6. Skip (no changes)

(Choose options, e.g., "1,3" or "5" for all)
```

### Step 3: Apply Selected Updates

For each selected action:

| Action | Delegation |
|--------|------------|
| Update product docs | `/plan-product` (update mode) |
| Sync tech-stack | Direct edit with user confirmation |
| Update baseline | `/standards update` |
| Discover standards | `/standards discover` |

### Step 4: Confirm Changes

```
Refresh complete.

Applied:
- [list of changes made]

Skipped:
- [list of available but not selected updates]

Run /setup refresh again to check for additional drift.
```

---

## Audit Mode

Report-only mode that shows what would be done without making changes.

```
/setup audit
```

Runs the same drift detection as Refresh Flow but outputs:

```
Audit Report (no changes made)
==============================

Project State:
- Agent-os configured: yes
- Product docs: 3 files
- Standards baseline: tauri-svelte@1.0.0
- Project standards: 2 files
- Specs: 5 files

Drift Detected:
- README modified after product docs (would update mission.md)
- 2 new dependencies (would update tech-stack.md)
- Baseline outdated by 1 version (would update to 1.1.0)
- 3 undocumented code patterns (would suggest standards)

Run /setup refresh to apply updates.
```

---

## Subcommand Delegation

| Subcommand | Delegates To |
|------------|--------------|
| Product docs creation | `/plan-product` |
| Standards init | `/standards init` |
| Standards update | `/standards update` |
| Standards discovery | `/standards discover` |

## Directory Structure Created

```
.agent-os/
├── product/
│   ├── mission.md
│   ├── roadmap.md
│   └── tech-stack.md
├── specs/
│   └── (feature specs created by /spec)
└── standards/
    ├── baseline/
    │   └── (from profile, managed by /standards)
    └── project/
        └── (user standards, managed manually or by /standards discover)
```

## Tips

- Run `/setup` on any new project to bootstrap agent-os quickly
- Run `/setup refresh` periodically to catch drift
- Run `/setup audit` before major releases to check documentation health
- The setup command is non-destructive — it always asks before overwriting
