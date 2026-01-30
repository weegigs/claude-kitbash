# Triage Session Examples

## UI Walkthrough

Interactive review of user interface flows.

```
User: /triage checkout flow

Claude: Ready to capture issues in checkout flow. Describe what you see.

User: The total doesn't update when I change quantity

Claude: Noted: Cart total not updating on quantity change. Next?

User: Apply coupon button is misaligned on mobile

Claude: Noted: Coupon button alignment on mobile. Next?

User: Invalid card error message just says "Error" - not helpful

Claude: Noted: Unclear error message for invalid card. Next?

User: done

Claude: 
## Triage Summary

### Major
| Issue | Type | Complexity | Action |
|-------|------|------------|--------|
| Cart total not updating | bug | S | beads |

### Minor
| Issue | Type | Complexity | Action |
|-------|------|------------|--------|
| Unclear card error | bug | XS | beads |

### Cosmetic
| Issue | Type | Complexity | Action |
|-------|------|------------|--------|
| Coupon button alignment | chore | XS | beads |
```

## API Testing Session

Testing API endpoints and responses.

```
User: /triage user API

Claude: Ready to capture issues in user API. Describe what you see.

User: GET /users returns 500 when user has no profile

Claude: Noted: 500 error for users without profile. Next?

User: PATCH /users doesn't validate email format

Claude: Noted: Missing email validation on PATCH. Next?

User: Response doesn't include updated_at timestamp

Claude: Noted: Missing updated_at in response. Next?

User: Rate limiting seems too aggressive - getting 429 after 5 requests

Claude: Noted: Rate limit threshold too low (5 requests). Next?

User: done

Claude:
## Triage Summary

### Critical
| Issue | Type | Complexity | Action |
|-------|------|------------|--------|
| 500 for profileless users | bug | S | beads |

### Major
| Issue | Type | Complexity | Action |
|-------|------|------------|--------|
| Missing email validation | bug | S | beads |
| Rate limit too aggressive | bug | M | beads |

### Minor
| Issue | Type | Complexity | Action |
|-------|------|------------|--------|
| Missing updated_at | feature | XS | beads |
```

## Performance Review

Identifying performance bottlenecks.

```
User: /triage dashboard performance

Claude: Ready to capture issues in dashboard performance. Describe what you see.

User: Initial load takes 8 seconds

Claude: Noted: 8s initial load time. Next?

User: Switching tabs re-fetches all data

Claude: Noted: Tab switch causes full data refetch. Next?

User: Chart rendering blocks the UI

Claude: Noted: Chart rendering blocks UI thread. Next?

User: done

Claude:
## Triage Summary

### Major
| Issue | Type | Complexity | Action |
|-------|------|------------|--------|
| 8s initial load | bug | L | /spec |
| Tab switch refetches all | bug | M | beads |
| Chart blocks UI | bug | M | beads |

Note: Initial load issue routed to /spec due to L complexity - likely requires 
investigation into data fetching, caching, and bundle optimization.
```

## Code Review Findings

Capturing issues found during code review.

```
User: /triage auth module review

Claude: Ready to capture issues in auth module. Describe what you see.

User: Password hashing uses MD5

Claude: Noted: MD5 password hashing (security). Next?

User: No rate limiting on login attempts

Claude: Noted: Missing login rate limiting. Next?

User: Token expiry is hardcoded to 1 year

Claude: Noted: Hardcoded 1-year token expiry. Next?

User: Duplicate session handling logic in 3 places

Claude: Noted: Duplicated session logic (3 locations). Next?

User: done

Claude:
## Triage Summary

### Critical
| Issue | Type | Complexity | Action |
|-------|------|------------|--------|
| MD5 password hashing | bug | M | /spec |
| Missing login rate limit | bug | M | beads |

### Major
| Issue | Type | Complexity | Action |
|-------|------|------------|--------|
| 1-year token expiry | bug | S | beads |
| Duplicated session logic | refactor | M | beads |

Note: MD5 issue routed to /spec - requires migration strategy for existing passwords.
```

## Mobile Testing Session

```
User: /triage mobile app

Claude: Ready to capture issues in mobile app. Describe what you see.

User: Keyboard covers input fields

Claude: Noted: Keyboard obscures inputs. Next?

User: Back gesture closes modal without confirmation

Claude: Noted: Back gesture skips modal confirmation. Next?

User: Images don't load on slow connection

Claude: Noted: Images fail on slow network. Next?

User: Pull to refresh doesn't work on empty state

Claude: Noted: Pull-to-refresh broken on empty state. Next?

User: done

Claude:
## Triage Summary

### Major
| Issue | Type | Complexity | Action |
|-------|------|------------|--------|
| Keyboard covers inputs | bug | M | beads |
| Back skips confirmation | bug | S | beads |

### Minor
| Issue | Type | Complexity | Action |
|-------|------|------------|--------|
| Images fail on slow network | bug | M | beads |
| Pull-refresh on empty | bug | S | beads |
```

## Multi-Area Triage

When issues span multiple areas, group into epic:

```
User: done

Claude:
## Triage Summary

Found issues across 3 areas - recommend grouping:

### Epic: Checkout Flow Improvements
- Cart total not updating (bug, S)
- Coupon alignment (chore, XS)
- Error messages (bug, XS)

### Epic: Auth Hardening
- Rate limiting (bug, M)
- Token expiry (bug, S)

### Standalone
- Dashboard performance (bug, L) → /spec

Actions:
1. Create "Checkout Flow" epic with 3 subtasks
2. Create "Auth Hardening" epic with 2 subtasks
3. Start /spec for dashboard performance
```
