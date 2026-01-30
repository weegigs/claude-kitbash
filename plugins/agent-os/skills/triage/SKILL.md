---
name: triage
description: Interactive issue discovery session. Use when walking through an application to capture issues, then batch-evaluate severity and complexity.
---

# Triage

Interactive issue discovery with batch evaluation. Walk through an application, capture issues as encountered, then assess and route.

## Usage

```
/triage [area or focus]
```

## Session Flow

### 1. Discovery Mode (default)

```
Ready to capture issues in [area]. Describe what you see.

Commands: "next" (ready for next) | "done" (begin evaluation)
```

**For each issue:**
1. Capture in TodoWrite: `[TRIAGE] Brief description`
2. Acknowledge: `Noted: [summary]. Next?`
3. Do NOT deep-dive or propose solutions

### 2. Evaluation Mode

When user says "done":

1. List all `[TRIAGE]` items
2. Assess each for type, severity, complexity
3. Present summary table grouped by severity

See [references/classification.md](references/classification.md) for assessment criteria.

### 3. Action Mode

```
Actions:
  1. Create beads tasks (XS/S items)
  2. Create epic + tasks (related items)
  3. Start /spec (M+ complexity)
  4. Export summary
  5. Done
```

**Routing:**
- XS/S complexity → beads task
- M+ complexity → `/spec`
- Related issues → group under epic

## Output Format

```
## Triage Summary

### Critical
| Issue | Type | Complexity | Action |
|-------|------|------------|--------|

### Major
...

### Minor / Cosmetic
...
```

## References

- [classification.md](references/classification.md) - Severity and complexity criteria
- [examples.md](references/examples.md) - Session examples by type
- [integration.md](references/integration.md) - Beads, specs, ByteRover patterns

## See Also

- `/spec` - Full specification for complex issues
- `@beads` - Task creation
- `/kick-off` - Execution planning
