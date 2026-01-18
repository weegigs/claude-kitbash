---
name: convex-scheduling
description: Convex cron jobs and scheduled functions.
---

# Convex Scheduling

## Cron Jobs

Define recurring jobs in `convex/crons.ts`:

```typescript
import { cronJobs } from "convex/server";
import { internal } from "./_generated/api";

const crons = cronJobs();

// Run every hour
crons.interval(
  "cleanup old sessions",
  { hours: 1 },
  internal.maintenance.cleanupSessions
);

// Run every 5 minutes
crons.interval(
  "sync external data",
  { minutes: 5 },
  internal.sync.fetchUpdates
);

// Run daily at midnight UTC
crons.cron(
  "daily report",
  "0 0 * * *",
  internal.reports.generateDaily
);

// Run every Monday at 9am UTC
crons.cron(
  "weekly digest",
  "0 9 * * 1",
  internal.notifications.sendWeeklyDigest
);

export default crons;
```

### Interval Syntax

```typescript
crons.interval(
  "job name",           // Unique identifier
  { hours: 1 },         // Interval duration
  functionReference     // Must be internal mutation or action
);

// Duration options
{ seconds: 30 }
{ minutes: 5 }
{ hours: 1 }
{ days: 1 }

// Combined
{ hours: 1, minutes: 30 }  // Every 1.5 hours
```

### Cron Expression Syntax

```typescript
crons.cron(
  "job name",
  "* * * * *",          // Standard cron expression
  functionReference
);

// Format: minute hour day-of-month month day-of-week
//         0-59   0-23 1-31         1-12  0-6 (0=Sunday)

// Examples:
"0 * * * *"     // Every hour at minute 0
"*/15 * * * *"  // Every 15 minutes
"0 0 * * *"     // Daily at midnight
"0 9 * * 1-5"   // Weekdays at 9am
"0 0 1 * *"     // First of each month at midnight
```

### Cron Job Functions

Cron functions must be internal (not client-callable):

```typescript
// convex/maintenance.ts
import { internalMutation } from "./_generated/server";
import { v } from "convex/values";

export const cleanupSessions = internalMutation({
  args: {},
  returns: v.null(),
  handler: async (ctx) => {
    const cutoff = Date.now() - 24 * 60 * 60 * 1000; // 24 hours ago

    const oldSessions = await ctx.db
      .query("sessions")
      .withIndex("by_lastActive", (q) => q.lt("lastActive", cutoff))
      .collect();

    for (const session of oldSessions) {
      await ctx.db.delete(session._id);
    }

    return null;
  },
});
```

## Scheduled Functions

Schedule one-off function executions from mutations or actions.

### Schedule from Mutation

```typescript
import { mutation } from "./_generated/server";
import { internal } from "./_generated/api";
import { v } from "convex/values";

export const createTask = mutation({
  args: { text: v.string(), remindInMinutes: v.optional(v.number()) },
  returns: v.id("tasks"),
  handler: async (ctx, args) => {
    const taskId = await ctx.db.insert("tasks", {
      text: args.text,
      completed: false,
    });

    // Schedule reminder
    if (args.remindInMinutes) {
      await ctx.scheduler.runAfter(
        args.remindInMinutes * 60 * 1000, // milliseconds
        internal.notifications.sendReminder,
        { taskId }
      );
    }

    return taskId;
  },
});
```

### Schedule at Specific Time

```typescript
export const scheduleReport = mutation({
  args: { timestamp: v.number() },
  returns: v.id("_scheduled_functions"),
  handler: async (ctx, args) => {
    // Schedule at specific Unix timestamp (ms)
    const scheduledId = await ctx.scheduler.runAt(
      args.timestamp,
      internal.reports.generate,
      {}
    );

    return scheduledId;
  },
});
```

### Schedule from Action

```typescript
import { action } from "./_generated/server";
import { internal } from "./_generated/api";
import { v } from "convex/values";

export const processWebhook = action({
  args: { data: v.any() },
  returns: v.null(),
  handler: async (ctx, args) => {
    // Process immediately
    await ctx.runMutation(internal.webhooks.saveData, { data: args.data });

    // Schedule follow-up in 5 minutes
    await ctx.scheduler.runAfter(
      5 * 60 * 1000,
      internal.webhooks.verifyProcessing,
      { data: args.data }
    );

    return null;
  },
});
```

## Canceling Scheduled Functions

```typescript
export const cancelScheduled = mutation({
  args: { scheduledId: v.id("_scheduled_functions") },
  returns: v.null(),
  handler: async (ctx, args) => {
    await ctx.scheduler.cancel(args.scheduledId);
    return null;
  },
});
```

## Query Scheduled Functions

```typescript
export const listPendingJobs = query({
  args: {},
  returns: v.array(v.object({
    _id: v.id("_scheduled_functions"),
    scheduledTime: v.number(),
    state: v.object({
      kind: v.string(),
    }),
  })),
  handler: async (ctx) => {
    return await ctx.db
      .system
      .query("_scheduled_functions")
      .collect();
  },
});
```

## Function References

Scheduled functions must use function references:

```typescript
import { internal, api } from "./_generated/api";

// For internal functions (recommended for scheduled jobs)
internal.moduleName.functionName

// For public functions (if needed)
api.moduleName.functionName
```

## Scheduling Patterns

### Delayed Processing

```typescript
export const submitOrder = mutation({
  args: { items: v.array(v.id("products")) },
  returns: v.id("orders"),
  handler: async (ctx, args) => {
    const orderId = await ctx.db.insert("orders", {
      items: args.items,
      status: "pending",
    });

    // Process payment after 100ms (let transaction commit)
    await ctx.scheduler.runAfter(
      100,
      internal.payments.processOrder,
      { orderId }
    );

    return orderId;
  },
});
```

### Retry with Backoff

```typescript
export const processWithRetry = internalMutation({
  args: {
    taskId: v.id("tasks"),
    attempt: v.optional(v.number()),
  },
  returns: v.null(),
  handler: async (ctx, args) => {
    const attempt = args.attempt ?? 1;
    const task = await ctx.db.get(args.taskId);

    if (!task) return null;

    try {
      // Process task...
      await ctx.db.patch(args.taskId, { status: "completed" });
    } catch (error) {
      if (attempt < 3) {
        // Exponential backoff: 1s, 4s, 9s
        const delay = attempt * attempt * 1000;
        await ctx.scheduler.runAfter(
          delay,
          internal.tasks.processWithRetry,
          { taskId: args.taskId, attempt: attempt + 1 }
        );
      } else {
        await ctx.db.patch(args.taskId, { status: "failed" });
      }
    }

    return null;
  },
});
```

### Scheduled Expiration

```typescript
export const createSession = mutation({
  args: { userId: v.id("users") },
  returns: v.id("sessions"),
  handler: async (ctx, args) => {
    const sessionId = await ctx.db.insert("sessions", {
      userId: args.userId,
      createdAt: Date.now(),
    });

    // Auto-expire in 24 hours
    await ctx.scheduler.runAfter(
      24 * 60 * 60 * 1000,
      internal.sessions.expire,
      { sessionId }
    );

    return sessionId;
  },
});

export const expire = internalMutation({
  args: { sessionId: v.id("sessions") },
  returns: v.null(),
  handler: async (ctx, args) => {
    const session = await ctx.db.get(args.sessionId);
    if (session) {
      await ctx.db.delete(args.sessionId);
    }
    return null;
  },
});
```

## Scheduler API Reference

| Method | Context | Purpose |
|--------|---------|---------|
| `ctx.scheduler.runAfter(delay, fn, args)` | Mutation, Action | Schedule after delay (ms) |
| `ctx.scheduler.runAt(timestamp, fn, args)` | Mutation, Action | Schedule at Unix time (ms) |
| `ctx.scheduler.cancel(scheduledId)` | Mutation | Cancel scheduled function |

| Cron Method | Purpose |
|-------------|---------|
| `crons.interval(name, duration, fn)` | Recurring at fixed interval |
| `crons.cron(name, expression, fn)` | Recurring via cron expression |
