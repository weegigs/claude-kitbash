---
name: byterover
description: |
  This skill should be used when the user asks to "query project knowledge",
  "curate learnings", "record architectural decisions", "document bug investigations",
  "check brv status", or mentions ByteRover, brv, or project knowledge base.
---

# ByteRover CLI

Project knowledge base for domain knowledge, format specs, and lessons learned.

**Query first** when lacking context about a topic.

## Commands

| Command | Purpose |
|---------|---------|
| `brv query "question"` | Query project knowledge |
| `brv curate "context"` | Record knowledge |
| `brv status` | Check project status |

## Query (Read)

Query before starting unfamiliar work. The knowledge base contains:
- Domain knowledge not in general programming knowledge
- Document format specifications
- Lessons from past investigations
- Architectural decisions and rationale

```bash
brv query "How is authentication implemented?"
brv query "What bugs have been found in the converter?"
```

## Curate (Write)

Record discoveries worth preserving. Include: what, why, where.

```bash
# Basic
brv curate "Auth uses JWT with 24h expiry in httpOnly cookies"

# With file reference (max 5)
brv curate "Rate limiting uses token bucket with Redis backend" -f src/middleware/rate_limit.rs
```

### What to Curate

| Type | Examples |
|------|----------|
| Domain knowledge | Project-specific concepts |
| Format specs | Data structures, schemas |
| Lessons learned | Bug root causes, gotchas |
| Decisions | Why things are designed a certain way |
| Integration points | How systems connect |

### What NOT to Curate

- Trivial/obvious from code
- General programming knowledge
- Temporary debugging
- Self-documenting changes

### Format

```
Good: "PDF export bug: images missing when nested in groups.
       Fix requires recursive extraction in crates/export/src/pdf.rs:127-145"

Bad:  "Found a bug" (no context)
Bad:  "Authentication" (not actionable)
```

## Reference

For detailed examples: [references/examples.md](references/examples.md)
