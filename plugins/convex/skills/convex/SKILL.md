---
name: convex
description: Convex backend development. Use when discussing queries, mutations, actions, schema, or Convex patterns.
---

# Convex Backend Development

Convex is a reactive backend-as-a-service with real-time sync, TypeScript-first schemas, and serverless functions.

## Setup (Bun)

```bash
bun add convex
bunx convex dev    # Development with hot reload
bunx convex deploy # Production deployment
```

## Function Types

| Type | Purpose | Capabilities | Syntax |
|------|---------|--------------|--------|
| `query` | Read data | Database reads, deterministic | `query({ args, returns, handler })` |
| `mutation` | Write data | Database reads/writes, deterministic | `mutation({ args, returns, handler })` |
| `action` | Side effects | External APIs, non-deterministic | `action({ args, returns, handler })` |
| `httpAction` | HTTP endpoints | Request/response handling | `httpAction(async (ctx, request) => {...})` |

## Capability Matrix

| Capability | Query | Mutation | Action |
|------------|-------|----------|--------|
| `ctx.db.get()` | ✓ | ✓ | ✗ |
| `ctx.db.insert()` | ✗ | ✓ | ✗ |
| `ctx.runQuery()` | ✗ | ✗ | ✓ |
| `ctx.runMutation()` | ✗ | ✗ | ✓ |
| `fetch()` / external | ✗ | ✗ | ✓ |
| `ctx.scheduler` | ✗ | ✓ | ✓ |
| `ctx.storage` | ✓ | ✓ | ✓ |

## Essential Validators

| Validator | TypeScript | Example |
|-----------|------------|---------|
| `v.string()` | `string` | `"hello"` |
| `v.number()` | `number` | `42`, `3.14` |
| `v.boolean()` | `boolean` | `true` |
| `v.id("tableName")` | `Id<"tableName">` | Document reference |
| `v.array(v.string())` | `string[]` | `["a", "b"]` |
| `v.object({...})` | `{...}` | Nested structure |
| `v.optional(v.string())` | `string \| undefined` | Optional field |
| `v.union(v.literal("a"), v.literal("b"))` | `"a" \| "b"` | Discriminated union |

## Basic Function Pattern

```typescript
import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

export const list = query({
  args: { limit: v.optional(v.number()) },
  returns: v.array(v.object({
    _id: v.id("tasks"),
    text: v.string(),
    completed: v.boolean(),
  })),
  handler: async (ctx, args) => {
    return await ctx.db
      .query("tasks")
      .order("desc")
      .take(args.limit ?? 10);
  },
});

export const create = mutation({
  args: { text: v.string() },
  returns: v.id("tasks"),
  handler: async (ctx, args) => {
    return await ctx.db.insert("tasks", {
      text: args.text,
      completed: false,
    });
  },
});
```

## Common Gotchas

| Issue | Wrong | Correct |
|-------|-------|---------|
| Filtering | `.filter(q => q.eq(...))` | `.withIndex("by_field", q => q.eq(...))` |
| External calls in mutation | `await fetch(...)` in mutation | Use action, call via `ctx.runMutation` |
| Missing index | Query without index | Define index in schema, use `.withIndex()` |
| Returning undefined | `handler: async () => {}` | Always return a value or use `v.null()` |
| Node.js APIs | Direct `fs`, `crypto` usage | Add `"use node"` directive in actions |

## Detailed Skills

| Skill | Content |
|-------|---------|
| `@convex-functions` | Queries, mutations, actions, HTTP endpoints, internal functions |
| `@convex-schema` | Schema definition, validators, indexes, TypeScript types |
| `@convex-storage` | File uploads, serving files, storage patterns |
| `@convex-scheduling` | Cron jobs, scheduled functions |

## Project Structure

```
convex/
├── _generated/       # Auto-generated types (don't edit)
│   ├── api.d.ts
│   ├── dataModel.d.ts
│   └── server.d.ts
├── schema.ts         # Database schema
├── tasks.ts          # Function modules
├── http.ts           # HTTP endpoints (optional)
└── crons.ts          # Scheduled jobs (optional)
```
