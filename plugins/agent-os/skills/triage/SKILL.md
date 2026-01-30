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

## Session States

### 1. Discovery Mode (default)

Capture issues quickly without deep analysis:

```
Ready to capture issues. Describe what you see - I'll note it and move on.

Commands:
  "next" / "continue" - done with this issue, ready for next
  "done" / "evaluate" - finish discovery, begin evaluation
```

**For each issue reported:**

1. Capture in TodoWrite with prefix `[TRIAGE]`:
   ```
   [TRIAGE] Brief description of issue
   ```

2. Acknowledge briefly:
   ```
   Noted: [summary]. Next?
   ```

3. Do NOT:
   - Deep-dive into root cause
   - Propose solutions
   - Ask clarifying questions (save for evaluation)

### 2. Evaluation Mode

When user says "done" or "evaluate":

**Step 1: List captured issues**

```
Captured N issues:

1. [TRIAGE] Issue description
2. [TRIAGE] Issue description
...

Beginning evaluation...
```

**Step 2: Assess each issue**

For each issue, determine:

| Factor | Assessment |
|--------|------------|
| **Type** | bug / feature / refactor / chore |
| **Severity** | critical / major / minor / cosmetic |
| **Complexity** | XS / S / M / L / XL |

**Severity criteria:**
- **Critical**: Blocks core functionality, data loss risk
- **Major**: Significantly impacts user experience
- **Minor**: Inconvenient but workaround exists
- **Cosmetic**: Visual/polish issues only

**Complexity criteria (from project standards):**
- **XS**: Trivial change, single location
- **S**: Single module, clear fix
- **M**: Multi-module, some investigation
- **L**: Complex workflows, architectural consideration
- **XL**: System redesign, major refactoring

**Step 3: Present assessment**

```
## Triage Summary

### Critical (do first)
| Issue | Type | Complexity | Recommendation |
|-------|------|------------|----------------|
| ... | bug | S | beads task |

### Major
| Issue | Type | Complexity | Recommendation |
|-------|------|------------|----------------|
| ... | feature | M | /spec |

### Minor
...

### Cosmetic
...
```

**Recommendations:**
- XS/S complexity → Create beads task directly
- M+ complexity → Route to `/spec` for full specification
- Related issues → Group under epic

### 3. Action Mode

After evaluation, offer actions:

```
Actions:
  1. Create beads tasks for XS/S items
  2. Create epic + tasks for related items
  3. Start /spec for complex item
  4. Export summary to file
  5. Done (clear triage items)
```

## Integration

**With beads:**
```bash
# Quick task creation
bd create "[issue]" -t bug -p 2

# For grouped issues
bd create "Epic: [area]" -t epic
bd create "[issue]" -t bug --parent <epic-id>
```

**With agent-os:**
```
# Complex issues route to spec
/spec [issue description]
```

**With ByteRover (if available):**
```bash
# Query for known issues in area
brv query "issues with [area]"
```

## Example Session

```
User: /triage checkout flow

Claude: Ready to capture issues in checkout flow. 
        Describe what you see - I'll note it and move on.

User: The total doesn't update when I change quantity

Claude: Noted: Cart total not updating on quantity change. Next?

User: Also the apply coupon button is misaligned on mobile

Claude: Noted: Coupon button alignment issue on mobile. Next?

User: When I enter an invalid card, the error message is confusing

Claude: Noted: Unclear error message for invalid card. Next?

User: done

Claude: Captured 3 issues:
        1. Cart total not updating on quantity change
        2. Coupon button alignment issue on mobile  
        3. Unclear error message for invalid card

        ## Triage Summary

        ### Major
        | Issue | Type | Complexity | Recommendation |
        |-------|------|------------|----------------|
        | Cart total not updating | bug | S | beads task |
        | Unclear card error | bug | XS | beads task |

        ### Cosmetic
        | Issue | Type | Complexity | Recommendation |
        |-------|------|------------|----------------|
        | Coupon button alignment | chore | XS | beads task |

        Actions:
        1. Create beads tasks for all items
        2. Start /spec for complex item
        3. Export summary
        4. Done
```

## Completion

Clear triage items from TodoWrite when session ends.

## See Also

- `/spec` - Full specification for complex issues
- `@beads` - Task creation and management
- `/kick-off` - Execution planning after triage
