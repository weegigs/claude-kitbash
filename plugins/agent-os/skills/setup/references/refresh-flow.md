# Refresh Flow

Drift detection and updates for configured projects (`.agent-os/` exists).

## Step 1: Check for Drift

Analyze multiple drift signals:

### README Drift
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

### Dependency Drift
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

### Baseline Drift
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

### Pattern Drift
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

## Step 2: Present Drift Report

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

## Step 3: Apply Selected Updates

For each selected action:

| Action | Delegation |
|--------|------------|
| Update product docs | `/plan-product` (update mode) |
| Sync tech-stack | Direct edit with user confirmation |
| Update baseline | `/standards update` |
| Discover standards | `/standards discover` |

## Step 4: Confirm Changes

```
Refresh complete.

Applied:
- [list of changes made]

Skipped:
- [list of available but not selected updates]

Run /setup refresh again to check for additional drift.
```
