---
name: standards
description: Manage project standards. Auto-detects state and offers appropriate actions.
---

# Standards

One-shot command for standards management.

## Usage

```
/standards              # Auto-detect and offer actions
/standards init         # Initialize baseline from profile
/standards update       # Update baseline to latest profile version
/standards discover     # Discover project-specific standards
/standards status       # Show current state
```

## Process (no args)

### Step 1: Check State

```bash
ls .agent-os/standards/baseline/manifest.yml 2>/dev/null
ls .agent-os/standards/project/ 2>/dev/null
```

### Step 2: Branch by State

**No baseline exists:**
```
No standards baseline found.

Would you like to initialize from a profile?

Available profiles:
1. tauri-svelte — Svelte 5 + SvelteKit 2 + Tauri v2 + Rust 2024 + Convex

(Pick a number, or "skip" to set up standards manually)
```

If user selects a profile → delegate to `@standards-init`

**Baseline exists, check version:**
1. Read `.agent-os/standards/baseline/manifest.yml`
2. Compare version to profile source
3. If outdated:

```
Standards baseline is outdated.

Current: tauri-svelte@1.0.0
Latest:  tauri-svelte@1.1.0

Update baseline? (yes / diff / skip)
```

If "yes" → delegate to `@standards-update`
If "diff" → show changed files, then ask again

**Baseline current:**
```
Standards baseline: tauri-svelte@1.0.0 (current)
Project standards:  3 files in .agent-os/standards/project/

Options:
1. Discover more project standards
2. Show status
3. Done

(Pick an option)
```

### Step 3: Status Output

When showing status:

```
Standards Status
================

Baseline: tauri-svelte@1.0.0
  10 standards from profile

Project: 3 standards
  - api/response-format.md
  - api/pagination.md
  - database/migrations.md

Overrides (project shadows baseline):
  - rust/error-handling.md

To inject standards into context: /standards-inject
To discover more standards: /standards discover
To update baseline: /standards update
```

## Subcommand Delegation

| Subcommand | Delegates To |
|------------|--------------|
| `init` | `@standards-init` |
| `update` | `@standards-update` |
| `discover` | `@standards-discover` |
| `status` | (inline, no delegation) |

## Directory Structure

```
.agent-os/standards/
├── baseline/              # Profile-managed, replaced by /standards update
│   ├── manifest.yml       # { profile: tauri-svelte, version: 1.0.0 }
│   ├── rust/
│   │   └── error-handling.md
│   └── ...
└── project/               # User-managed, never touched by plugin
    └── api/
        └── response-format.md
```

## Resolution Order

See [references/resolution-order.md](references/resolution-order.md) for how project and baseline standards are resolved.
