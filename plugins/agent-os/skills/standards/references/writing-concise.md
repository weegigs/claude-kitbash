# Writing Concise Standards

Standards will be injected into AI context windows. Every word costs tokens.

## Principles

- **Lead with the rule** — State what to do first, explain why second (if needed)
- **Use code examples** — Show, don't tell
- **Skip the obvious** — Don't document what the code already makes clear
- **One standard per concept** — Don't combine unrelated patterns
- **Bullet points over paragraphs** — Scannable beats readable

## Good vs Bad Examples

### Bad (verbose)

```markdown
When creating API endpoints, you should always return responses
in a consistent format. This helps ensure that clients can
reliably parse responses. The format we use includes a success
boolean, a data field for the payload, and an error field when
something goes wrong.
```

### Good (concise)

```markdown
# API Response Format

All responses use this envelope:
\`\`\`json
{ "success": true, "data": {...} }
{ "success": false, "error": { "code": "...", "message": "..." } }
\`\`\`

- Never return raw data without envelope
- Error responses require code + message
```

## Token Impact

| Style | Approximate Tokens |
|-------|-------------------|
| Verbose paragraph | 80-100 |
| Concise bullets + example | 30-40 |

Standards are loaded frequently. A 50% token reduction across 10 standards saves significant context space.

## Review Checklist

When writing or reviewing standards:

- [ ] Does it start with the rule, not background?
- [ ] Are there code examples?
- [ ] Can any words be removed without losing meaning?
- [ ] Is each bullet point actionable?
- [ ] Is it documenting tribal knowledge (not framework defaults)?
