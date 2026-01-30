# Triage Classification

## Type

| Type | Indicators | Examples |
|------|------------|----------|
| **bug** | Something broken, wrong behavior, error | "Button doesn't work", "Crash on submit" |
| **feature** | Missing capability, enhancement | "Need dark mode", "Add export option" |
| **refactor** | Code quality, architecture concern | "This is hard to maintain", "Duplicated logic" |
| **chore** | Polish, cleanup, minor improvement | "Alignment off", "Typo in label" |

## Severity

| Level | Criteria | Examples |
|-------|----------|----------|
| **Critical** | Blocks core functionality, data loss/corruption risk, security issue | Cannot save, payment fails, auth bypass |
| **Major** | Significantly impacts UX, no reasonable workaround | Slow to unusable, key feature broken |
| **Minor** | Inconvenient but workaround exists, affects subset of users | Edge case failure, mobile-only issue |
| **Cosmetic** | Visual/polish only, no functional impact | Misalignment, color inconsistency, typo |

### Severity Edge Cases

**Upgrade to higher severity when:**
- Issue affects high-traffic path
- Issue blocks other work
- Issue has regulatory/compliance implications
- Multiple users reporting same issue

**Downgrade when:**
- Affects admin-only or rarely-used feature
- Clear workaround documented
- Already tracked elsewhere

## Complexity

Uses T-shirt sizing per project standards.

| Size | Scope | Investigation | Examples |
|------|-------|---------------|----------|
| **XS** | Single line/location | None needed | Typo fix, config change, obvious bug |
| **S** | Single module, clear fix | Minimal | Add validation, fix edge case, update style |
| **M** | Multi-module, some unknowns | Moderate | New component, API change, data migration |
| **L** | Complex workflows, architectural | Significant | New feature area, integration, refactor subsystem |
| **XL** | System redesign, major refactor | Extensive | Architecture change, platform migration |

### Complexity Signals

**Indicators of higher complexity:**
- Touches multiple services/modules
- Requires data migration
- Has external dependencies
- Needs backwards compatibility
- Involves security/auth changes
- Unclear root cause

**Indicators of lower complexity:**
- Isolated change
- Clear reproduction steps
- Similar to past fixes
- Well-tested area
- Good documentation exists

## Routing Rules

| Complexity | Severity | Action |
|------------|----------|--------|
| XS/S | Any | Create beads task |
| M | Minor/Cosmetic | Create beads task with notes |
| M | Major/Critical | Route to `/spec` |
| L/XL | Any | Route to `/spec` |

**Group related issues:**
- Same component → epic
- Same root cause → single task with checklist
- Same user flow → epic with ordered subtasks
