---
name: convex-functions
description: Convex function types - queries, mutations, actions, HTTP endpoints, and internal functions.
---

# Convex Functions

## Query Functions

Queries read data from the database. They must be deterministic (no random values, no Date.now()).

```typescript
import { query } from "./_generated/server";
import { v } from "convex/values";

export const get = query({
  args: { id: v.id("tasks") },
  returns: v.union(
    v.object({
      _id: v.id("tasks"),
      _creationTime: v.number(),
      text: v.string(),
      completed: v.boolean(),
    }),
    v.null()
  ),
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

export const listByStatus = query({
  args: { completed: v.boolean() },
  returns: v.array(v.object({
    _id: v.id("tasks"),
    text: v.string(),
    completed: v.boolean(),
  })),
  handler: async (ctx, args) => {
    // Always use withIndex, not filter
    return await ctx.db
      .query("tasks")
      .withIndex("by_completed", (q) => q.eq("completed", args.completed))
      .collect();
  },
});
```

## Mutation Functions

Mutations read and write data. Also deterministic.

```typescript
import { mutation } from "./_generated/server";
import { v } from "convex/values";

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

export const update = mutation({
  args: {
    id: v.id("tasks"),
    text: v.optional(v.string()),
    completed: v.optional(v.boolean()),
  },
  returns: v.null(),
  handler: async (ctx, args) => {
    const { id, ...fields } = args;
    // patch() merges, replace() overwrites entire document
    await ctx.db.patch(id, fields);
    return null;
  },
});

export const remove = mutation({
  args: { id: v.id("tasks") },
  returns: v.null(),
  handler: async (ctx, args) => {
    await ctx.db.delete(args.id);
    return null;
  },
});
```

### Patch vs Replace

| Method | Behavior |
|--------|----------|
| `ctx.db.patch(id, fields)` | Merge fields into existing document |
| `ctx.db.replace(id, document)` | Replace entire document (must include all required fields) |

## Action Functions

Actions can perform side effects: external API calls, non-deterministic operations, Node.js APIs.

```typescript
import { action } from "./_generated/server";
import { v } from "convex/values";
import { api } from "./_generated/api";

export const sendNotification = action({
  args: { taskId: v.id("tasks"), message: v.string() },
  returns: v.boolean(),
  handler: async (ctx, args) => {
    // Read from database via runQuery
    const task = await ctx.runQuery(api.tasks.get, { id: args.taskId });
    if (!task) return false;

    // External API call (only in actions)
    const response = await fetch("https://api.example.com/notify", {
      method: "POST",
      body: JSON.stringify({ text: args.message }),
    });

    // Write to database via runMutation
    if (response.ok) {
      await ctx.runMutation(api.tasks.update, {
        id: args.taskId,
        notified: true,
      });
    }

    return response.ok;
  },
});
```

### Using Node.js APIs

Add `"use node"` directive at the top of the file:

```typescript
"use node";

import { action } from "./_generated/server";
import { v } from "convex/values";
import crypto from "crypto";

export const generateHash = action({
  args: { data: v.string() },
  returns: v.string(),
  handler: async (ctx, args) => {
    return crypto.createHash("sha256").update(args.data).digest("hex");
  },
});
```

## HTTP Endpoints

Define HTTP endpoints in `convex/http.ts`:

```typescript
import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { api } from "./_generated/api";

const http = httpRouter();

http.route({
  path: "/tasks",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    const tasks = await ctx.runQuery(api.tasks.list, {});
    return new Response(JSON.stringify(tasks), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

http.route({
  path: "/tasks",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const body = await request.json();
    const id = await ctx.runMutation(api.tasks.create, { text: body.text });
    return new Response(JSON.stringify({ id }), {
      status: 201,
      headers: { "Content-Type": "application/json" },
    });
  }),
});

http.route({
  pathPrefix: "/webhooks/",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const path = new URL(request.url).pathname;
    // Handle webhook based on path
    return new Response("OK");
  }),
});

export default http;
```

### HTTP Request Object

```typescript
handler: httpAction(async (ctx, request) => {
  // URL and method
  const url = new URL(request.url);
  const method = request.method;

  // Query parameters
  const limit = url.searchParams.get("limit");

  // Headers
  const auth = request.headers.get("Authorization");

  // Body (various formats)
  const json = await request.json();
  const text = await request.text();
  const formData = await request.formData();
  const blob = await request.blob();
})
```

## Internal Functions

Internal functions are only callable from other Convex functions, not from clients.

```typescript
import { internalQuery, internalMutation, internalAction } from "./_generated/server";
import { v } from "convex/values";

// Only callable from other Convex functions
export const getInternal = internalQuery({
  args: { id: v.id("tasks") },
  returns: v.union(v.object({...}), v.null()),
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

export const processInternal = internalMutation({
  args: { id: v.id("tasks") },
  returns: v.null(),
  handler: async (ctx, args) => {
    // Internal processing logic
    return null;
  },
});
```

### Calling Internal Functions

```typescript
import { internal } from "./_generated/api";

// From an action
export const process = action({
  args: { id: v.id("tasks") },
  returns: v.null(),
  handler: async (ctx, args) => {
    // Use `internal` object, not `api`
    const task = await ctx.runQuery(internal.tasks.getInternal, { id: args.id });
    await ctx.runMutation(internal.tasks.processInternal, { id: args.id });
    return null;
  },
});
```

## Function References

| Object | Purpose | Visibility |
|--------|---------|------------|
| `api` | Public functions | Client-callable |
| `internal` | Internal functions | Server-only |

```typescript
import { api, internal } from "./_generated/api";

// api.moduleName.functionName
api.tasks.list
api.tasks.create

// internal.moduleName.functionName
internal.tasks.getInternal
internal.tasks.processInternal
```

## Calling Functions from Functions

| From | Can Call | Via |
|------|----------|-----|
| Query | Nothing | - |
| Mutation | Nothing | - |
| Action | Query, Mutation, Action | `ctx.runQuery()`, `ctx.runMutation()`, `ctx.runAction()` |
| HTTP Action | Query, Mutation, Action | `ctx.runQuery()`, `ctx.runMutation()`, `ctx.runAction()` |

```typescript
// Action calling other functions
export const orchestrate = action({
  args: { id: v.id("tasks") },
  returns: v.null(),
  handler: async (ctx, args) => {
    // Call a query
    const task = await ctx.runQuery(api.tasks.get, { id: args.id });

    // Call a mutation
    await ctx.runMutation(api.tasks.update, {
      id: args.id,
      processed: true,
    });

    // Call another action
    await ctx.runAction(api.notifications.send, {
      taskId: args.id,
      message: "Processed",
    });

    return null;
  },
});
```
