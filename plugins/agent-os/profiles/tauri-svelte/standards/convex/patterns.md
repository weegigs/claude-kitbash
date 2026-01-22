# Convex Patterns

## Query Pattern

```typescript
import { query } from "./_generated/server";
import { v } from "convex/values";

export const getUser = query({
  args: { id: v.id("users") },
  handler: async (ctx, { id }) => {
    return await ctx.db.get(id);
  },
});

// With filtering
export const listActiveUsers = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db
      .query("users")
      .filter((q) => q.eq(q.field("status"), "active"))
      .collect();
  },
});

// Using index
export const getUserByEmail = query({
  args: { email: v.string() },
  handler: async (ctx, { email }) => {
    return await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", email))
      .first();
  },
});
```

## Mutation Pattern

```typescript
import { mutation } from "./_generated/server";
import { v } from "convex/values";

export const createUser = mutation({
  args: {
    email: v.string(),
    name: v.string(),
  },
  handler: async (ctx, { email, name }) => {
    // Check for duplicates
    const existing = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", email))
      .first();

    if (existing) {
      throw new Error("Email already registered");
    }

    return await ctx.db.insert("users", {
      email,
      name,
      createdAt: Date.now(),
    });
  },
});

export const updateUser = mutation({
  args: {
    id: v.id("users"),
    name: v.optional(v.string()),
    email: v.optional(v.string()),
  },
  handler: async (ctx, { id, ...updates }) => {
    const existing = await ctx.db.get(id);
    if (!existing) {
      throw new Error("User not found");
    }

    await ctx.db.patch(id, updates);
  },
});
```

## Schema Definition

```typescript
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  users: defineTable({
    email: v.string(),
    name: v.string(),
    status: v.union(v.literal("active"), v.literal("inactive")),
    createdAt: v.number(),
  })
    .index("by_email", ["email"])
    .index("by_status", ["status"]),

  sessions: defineTable({
    userId: v.id("users"),
    title: v.string(),
    startedAt: v.number(),
    endedAt: v.optional(v.number()),
  })
    .index("by_user", ["userId"])
    .index("by_user_and_time", ["userId", "startedAt"]),
});
```

## Svelte Integration

```svelte
<script lang="ts">
  import { useQuery, useMutation } from "convex-svelte";
  import { api } from "$lib/convex/_generated/api";

  // Reactive query
  const users = useQuery(api.users.listActiveUsers, {});

  // Mutation
  const createUser = useMutation(api.users.createUser);

  let email = $state("");
  let name = $state("");

  async function handleSubmit() {
    try {
      await createUser({ email, name });
      email = "";
      name = "";
    } catch (error) {
      console.error("Failed to create user:", error);
    }
  }
</script>

{#if $users.isLoading}
  <p>Loading...</p>
{:else if $users.error}
  <p>Error: {$users.error.message}</p>
{:else if $users.data}
  <ul>
    {#each $users.data as user}
      <li>{user.name} ({user.email})</li>
    {/each}
  </ul>
{/if}

<form onsubmit|preventDefault={handleSubmit}>
  <input bind:value={email} placeholder="Email" />
  <input bind:value={name} placeholder="Name" />
  <button type="submit">Create User</button>
</form>
```

## Internal Functions

For server-side only logic:

```typescript
import { internalMutation, internalQuery } from "./_generated/server";

// Only callable from other Convex functions
export const processUserInternal = internalMutation({
  args: { userId: v.id("users") },
  handler: async (ctx, { userId }) => {
    // Internal processing
  },
});

// Call from another function
import { internal } from "./_generated/api";

export const publicMutation = mutation({
  handler: async (ctx) => {
    await ctx.runMutation(internal.users.processUserInternal, {
      userId: someId,
    });
  },
});
```

## HTTP Endpoints

```typescript
import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";

const http = httpRouter();

http.route({
  path: "/webhook",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const body = await request.json();

    // Process webhook
    await ctx.runMutation(internal.webhooks.process, { data: body });

    return new Response("OK", { status: 200 });
  }),
});

export default http;
```

## Boundary Mapping with Symbols

Map Convex nulls to symbols at the boundary:

```typescript
// In your Svelte code
import { NOT_FOUND, LOADING } from "$lib/types";

const userQuery = useQuery(api.users.getUser, { id });

// Map to symbol-based state
let user = $derived.by(() => {
  if ($userQuery.isLoading) return LOADING;
  if ($userQuery.data === null) return NOT_FOUND;
  return $userQuery.data;
});
```
