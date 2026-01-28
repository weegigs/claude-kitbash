---
name: standards-init
description: Initialize project standards baseline from a profile. Use when setting up a new project with predefined coding standards and conventions.
---

# Standards Init

Initialize project standards from a profile.

## Usage

```
/standards init                    # Interactive profile selection
/standards init tauri-svelte       # Specific profile
```

## Process

### Step 1: Check Existing Baseline

```bash
ls .agent-os/standards/baseline/manifest.yml 2>/dev/null
```

If baseline exists:
```
A baseline already exists: tauri-svelte@1.0.0

Options:
1. Replace with new profile (destructive)
2. Update existing baseline (/standards update)
3. Cancel

(Pick an option)
```

### Step 2: Select Profile (if not specified)

```
Available profiles:

1. tauri-svelte — Svelte 5 + SvelteKit 2 + Tauri v2 + Rust 2024 + Convex

(Pick a number)
```

### Step 3: Copy Profile Standards

1. Create `.agent-os/standards/baseline/` directory
2. Copy all files from profile's `standards/` directory
3. Copy `manifest.yml` from profile

```bash
mkdir -p .agent-os/standards/baseline
cp -r {plugin}/profiles/{profile}/standards/* .agent-os/standards/baseline/
cp {plugin}/profiles/{profile}/manifest.yml .agent-os/standards/baseline/
```

### Step 4: Create Project Directory

```bash
mkdir -p .agent-os/standards/project
```

### Step 5: Confirm

```
Initialized standards baseline from tauri-svelte@1.0.0

Created:
  .agent-os/standards/baseline/     (10 standards)
  .agent-os/standards/project/      (empty, for your additions)

Next steps:
  - Run /standards discover to document project-specific patterns
  - Standards are automatically available via /standards-inject
```

## Profile Location

Profiles are located in the plugin at:
```
plugins/agent-os/profiles/{profile-name}/
├── manifest.yml
└── standards/
    └── ...
```

## Notes

- Baseline is a complete copy, not a reference
- Project directory is created empty for user additions
- Use /standards update to get profile updates later
