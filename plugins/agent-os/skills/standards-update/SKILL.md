---
name: standards-update
description: Update standards baseline from latest profile version. Warns about project overrides.
---

# Standards Update

Update baseline standards to latest profile version.

## Usage

```
/standards update           # Update to latest
/standards update --diff    # Show diff first
```

## Process

### Step 1: Check Baseline Exists

```bash
cat .agent-os/standards/baseline/manifest.yml
```

If no baseline:
```
No baseline found. Run /standards init first.
```

### Step 2: Compare Versions

Read current baseline manifest:
```yaml
name: tauri-svelte
version: 1.0.0
```

Compare to profile source version.

If current:
```
Baseline is already at latest version (tauri-svelte@1.0.0)
```

### Step 3: Identify Project Overrides

Scan for files that exist in both baseline and project:

```bash
for f in $(find .agent-os/standards/baseline -name "*.md" -type f); do
  relative=${f#.agent-os/standards/baseline/}
  if [[ -f ".agent-os/standards/project/$relative" ]]; then
    echo "Override: $relative"
  fi
done
```

### Step 4: Show Changes

```
Updating baseline: tauri-svelte 1.0.0 → 1.1.0

Changed files:
  M rust/error-handling.md
  M svelte/runes.md
  A rust/async-patterns.md (new)

You have project overrides for:
  ⚠ rust/error-handling.md — baseline changed, review recommended

Proceed? (yes / diff rust/error-handling.md / cancel)
```

### Step 5: Show Diff (if requested)

For any changed file the user wants to review:

```
Diff: rust/error-handling.md (baseline)

--- baseline (current)
+++ baseline (new)
@@ -45,6 +45,15 @@
 ## Tauri Command Returns
+
+### New in 1.1.0: Async Error Context
+
+Include context for async operations:
+...
```

Ask again after showing diff:
```
Proceed with update? (yes / cancel)
```

### Step 6: Replace Baseline

```bash
rm -rf .agent-os/standards/baseline
cp -r {plugin}/profiles/{profile}/standards .agent-os/standards/baseline
cp {plugin}/profiles/{profile}/manifest.yml .agent-os/standards/baseline/
```

### Step 7: Confirm

```
Updated baseline: tauri-svelte@1.1.0

Changed:
  - rust/error-handling.md (updated)
  - svelte/runes.md (updated)
  - rust/async-patterns.md (added)

Note: Your project override at project/rust/error-handling.md 
is unchanged. Review the baseline changes and update your 
override if needed, or delete it to use the new baseline.
```

## Override Handling

Project overrides are NEVER modified by update. The user owns them.

When baseline changes a file that has a project override:
1. Warn the user before updating
2. After update, remind them to review
3. They can:
   - Update their override to incorporate changes
   - Delete their override to use new baseline
   - Keep their override as-is (intentional divergence)

## Notes

- Update is always a full replacement of baseline/
- Project standards are never touched
- Use `@baseline(path)` in project overrides to reference baseline content
