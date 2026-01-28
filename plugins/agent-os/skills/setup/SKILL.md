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

## Detailed Workflows

| Workflow | Description | Reference |
|----------|-------------|-----------|
| Init | First-time project setup | [references/init-flow.md](references/init-flow.md) |
| Refresh | Update existing configuration | [references/refresh-flow.md](references/refresh-flow.md) |
| Audit | Read-only validation | [references/audit-flow.md](references/audit-flow.md) |

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
