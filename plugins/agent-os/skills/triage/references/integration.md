# Triage Integration

## With Beads

### Quick Task Creation

```bash
# Single task
bd create "Cart total not updating on quantity change" -t bug -p 2

# With priority based on severity
# Critical → P1, Major → P2, Minor → P3, Cosmetic → P4
bd create "Missing login rate limiting" -t bug -p 1
```

### Epic for Related Issues

```bash
# Create epic
bd create "Checkout Flow Improvements" -t epic -p 2

# Add subtasks
bd create "Fix cart total update" -t bug --parent <epic-id>
bd create "Improve error messages" -t bug --parent <epic-id>
bd create "Fix coupon button alignment" -t chore --parent <epic-id>
```

### Batch Creation

After triage evaluation, create all XS/S items:

```bash
# Create tasks in sequence
bd create "Issue 1" -t bug -p 2
bd create "Issue 2" -t chore -p 3
bd create "Issue 3" -t bug -p 2
```

## With Agent-OS Specs

### Route Complex Issues

For M+ complexity issues, create a spec instead of a task:

```
/spec Fix dashboard performance - 8 second initial load time
```

This triggers the spec workflow:
1. Type detection (bug/feature/refactor)
2. Root cause analysis
3. Acceptance criteria
4. Scope definition

### Spec from Triage Notes

Include triage context when creating spec:

```
/spec Auth module security hardening

Context from triage:
- MD5 password hashing detected
- No login rate limiting
- 1-year token expiry

These are related security issues that should be addressed together.
```

## With ByteRover

### Query Before Triage

```bash
# Check for known issues in area
brv query "known issues with checkout"
brv query "past bugs in auth module"
```

This may reveal:
- Previously fixed issues that regressed
- Known limitations or workarounds
- Related architectural decisions

### Curate After Triage

If triage reveals significant patterns:

```bash
brv curate "Auth module has multiple security issues: MD5 hashing, no rate limiting, long token expiry. Requires comprehensive security review." -f src/auth/
```

## With Workflow

### After Triage → Kick-off

For complex issues routed to `/spec`:

```
1. /triage checkout → identifies performance issue (L complexity)
2. /spec checkout performance → creates specification
3. /kick-off → creates execution plan from spec
4. /execute → implements the plan
```

### For Simple Issues

XS/S issues go directly to beads, bypassing spec:

```
1. /triage checkout → identifies minor issues
2. Create beads tasks directly
3. Work tasks via normal beads workflow
```

## Priority Mapping

| Triage Severity | Beads Priority | Rationale |
|-----------------|----------------|-----------|
| Critical | P0 or P1 | Drop everything / do soon |
| Major | P2 | Standard priority |
| Minor | P3 | When time permits |
| Cosmetic | P4 | Backlog |

Adjust based on:
- User impact scope
- Blocking other work
- Quick wins (XS cosmetic might get P3)
