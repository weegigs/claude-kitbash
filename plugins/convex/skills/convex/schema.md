---
name: convex-schema
description: Convex schema definition, validators, indexes, and TypeScript types.
---

# Convex Schema

## Schema Definition

Define schema in `convex/schema.ts`:

```typescript
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  tasks: defineTable({
    text: v.string(),
    completed: v.boolean(),
    priority: v.optional(v.number()),
    tags: v.array(v.string()),
    assignee: v.optional(v.id("users")),
  })
    .index("by_completed", ["completed"])
    .index("by_assignee", ["assignee"])
    .index("by_completed_priority", ["completed", "priority"]),

  users: defineTable({
    name: v.string(),
    email: v.string(),
  })
    .index("by_email", ["email"]),

  messages: defineTable({
    author: v.id("users"),
    body: v.string(),
    channel: v.string(),
  })
    .index("by_channel", ["channel"]),
});
```

## Validator Reference

### Primitive Validators

| Validator | TypeScript | Example Value |
|-----------|------------|---------------|
| `v.string()` | `string` | `"hello"` |
| `v.number()` | `number` | `42`, `3.14` |
| `v.boolean()` | `boolean` | `true`, `false` |
| `v.bigint()` | `bigint` | `9007199254740993n` |
| `v.bytes()` | `ArrayBuffer` | Binary data |
| `v.null()` | `null` | `null` |

### Reference Validators

| Validator | TypeScript | Purpose |
|-----------|------------|---------|
| `v.id("tableName")` | `Id<"tableName">` | Document reference |

### Composite Validators

| Validator | TypeScript | Example |
|-----------|------------|---------|
| `v.array(v.string())` | `string[]` | `["a", "b", "c"]` |
| `v.object({ name: v.string() })` | `{ name: string }` | `{ name: "Alice" }` |
| `v.record(v.string(), v.number())` | `Record<string, number>` | `{ a: 1, b: 2 }` |

### Optional and Union Validators

| Validator | TypeScript | Purpose |
|-----------|------------|---------|
| `v.optional(v.string())` | `string \| undefined` | Optional field |
| `v.union(v.string(), v.number())` | `string \| number` | Multiple types |
| `v.literal("active")` | `"active"` | Exact value |
| `v.any()` | `any` | Any JSON value |

### Discriminated Unions

```typescript
v.union(
  v.object({
    type: v.literal("text"),
    content: v.string(),
  }),
  v.object({
    type: v.literal("image"),
    url: v.string(),
    width: v.number(),
    height: v.number(),
  })
)
```

## System Fields

Every document automatically has:

| Field | Type | Description |
|-------|------|-------------|
| `_id` | `Id<"tableName">` | Unique document identifier |
| `_creationTime` | `number` | Unix timestamp (ms) when created |

These are automatically added - don't include in schema definition.

## Index Design

### Basic Index

```typescript
defineTable({
  status: v.string(),
  priority: v.number(),
})
  .index("by_status", ["status"])
```

### Compound Index

Field order matters - left-to-right matching:

```typescript
defineTable({
  status: v.string(),
  priority: v.number(),
  createdAt: v.number(),
})
  // Can query: status only, or status + priority, or status + priority + createdAt
  // Cannot query: priority only, or createdAt only
  .index("by_status_priority_created", ["status", "priority", "createdAt"])
```

### Index Usage

```typescript
// Single field equality
ctx.db.query("tasks")
  .withIndex("by_status", (q) => q.eq("status", "active"))

// Compound equality
ctx.db.query("tasks")
  .withIndex("by_status_priority", (q) =>
    q.eq("status", "active").eq("priority", 1)
  )

// Range query (only on last field)
ctx.db.query("tasks")
  .withIndex("by_status_priority", (q) =>
    q.eq("status", "active").gt("priority", 0)
  )
```

### Index Operators

| Operator | Usage |
|----------|-------|
| `q.eq(field, value)` | Exact equality |
| `q.lt(field, value)` | Less than |
| `q.lte(field, value)` | Less than or equal |
| `q.gt(field, value)` | Greater than |
| `q.gte(field, value)` | Greater than or equal |

**Rule**: Use `eq()` for all fields except the last, which can use range operators.

## TypeScript Integration

### Generated Types

```typescript
import { Doc, Id } from "./_generated/dataModel";

// Full document type (includes _id, _creationTime)
type Task = Doc<"tasks">;

// Document ID type
type TaskId = Id<"tasks">;

// Use in function handlers
export const getTask = query({
  args: { id: v.id("tasks") },
  returns: v.union(/* ... */, v.null()),
  handler: async (ctx, args): Promise<Doc<"tasks"> | null> => {
    return await ctx.db.get(args.id);
  },
});
```

### Record Type Pattern

For dynamic keys, use `v.record()`:

```typescript
defineTable({
  metadata: v.record(v.string(), v.string()),
})

// Usage
await ctx.db.insert("documents", {
  metadata: {
    author: "Alice",
    version: "1.0",
    custom_field: "value",
  },
});
```

## Query Patterns

### Always Use Indexes

```typescript
// WRONG - scans entire table
const tasks = await ctx.db
  .query("tasks")
  .filter((q) => q.eq(q.field("status"), "active"))
  .collect();

// CORRECT - uses index
const tasks = await ctx.db
  .query("tasks")
  .withIndex("by_status", (q) => q.eq("status", "active"))
  .collect();
```

### Ordering

```typescript
// Default: ascending by _creationTime
ctx.db.query("tasks").collect()

// Descending order
ctx.db.query("tasks").order("desc").collect()

// Index order
ctx.db.query("tasks")
  .withIndex("by_priority")
  .order("desc")  // By priority descending
  .collect()
```

### Limiting Results

```typescript
// First N results
ctx.db.query("tasks").take(10)

// Single result
ctx.db.query("tasks").first()

// Unique result (throws if multiple)
ctx.db.query("tasks")
  .withIndex("by_email", (q) => q.eq("email", "alice@example.com"))
  .unique()
```

### Pagination

```typescript
import { paginationOptsValidator } from "convex/server";

export const listPaginated = query({
  args: { paginationOpts: paginationOptsValidator },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("tasks")
      .order("desc")
      .paginate(args.paginationOpts);
  },
});

// Returns: { page: Doc[], isDone: boolean, continueCursor: string }
```

## Schema Migrations

Convex supports gradual schema migrations:

```typescript
// Step 1: Add optional field
defineTable({
  text: v.string(),
  newField: v.optional(v.string()), // Optional initially
})

// Step 2: Backfill data via mutation
export const backfillNewField = mutation({
  handler: async (ctx) => {
    const docs = await ctx.db.query("tasks").collect();
    for (const doc of docs) {
      if (doc.newField === undefined) {
        await ctx.db.patch(doc._id, { newField: "default" });
      }
    }
  },
});

// Step 3: Make field required (after backfill)
defineTable({
  text: v.string(),
  newField: v.string(), // Now required
})
```
