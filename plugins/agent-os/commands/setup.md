---
name: setup
description: Initialize or refresh agent-os configuration. Auto-detects project state and offers appropriate actions.
---

# /setup

Initialize or refresh agent-os configuration for a project.

## Usage

```
/setup              # Auto-detect mode and offer actions
/setup init         # Force initialization flow
/setup refresh      # Force refresh flow
/setup audit        # Report-only, no changes
```

## Implementation

This command delegates to the `@setup` skill. Load and follow the skill instructions:

**Invoke**: `@setup`

The skill handles:
- Project state detection (new vs configured)
- Init flow (audit docs, detect stack, suggest profile, create structure)
- Refresh flow (detect drift in README, dependencies, baseline, patterns)
- Audit mode (report-only)
- Delegation to `/plan-product`, `/standards init`, `/standards update`, `/standards discover`
