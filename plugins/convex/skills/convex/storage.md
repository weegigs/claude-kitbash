---
name: convex-storage
description: Convex file storage - uploads, serving files, and storage patterns.
---

# Convex File Storage

## Upload Workflow

### Step 1: Generate Upload URL

```typescript
// convex/files.ts
import { mutation } from "./_generated/server";
import { v } from "convex/values";

export const generateUploadUrl = mutation({
  args: {},
  returns: v.string(),
  handler: async (ctx) => {
    return await ctx.storage.generateUploadUrl();
  },
});
```

### Step 2: Client Upload

```typescript
// Client-side (React example)
const generateUploadUrl = useMutation(api.files.generateUploadUrl);
const saveFile = useMutation(api.files.saveFile);

async function uploadFile(file: File) {
  // Get upload URL
  const uploadUrl = await generateUploadUrl();

  // Upload file directly to storage
  const response = await fetch(uploadUrl, {
    method: "POST",
    headers: { "Content-Type": file.type },
    body: file,
  });

  const { storageId } = await response.json();

  // Save reference to database
  await saveFile({ storageId, filename: file.name });
}
```

### Step 3: Save Storage Reference

```typescript
// convex/files.ts
export const saveFile = mutation({
  args: {
    storageId: v.id("_storage"),
    filename: v.string(),
  },
  returns: v.id("files"),
  handler: async (ctx, args) => {
    return await ctx.db.insert("files", {
      storageId: args.storageId,
      filename: args.filename,
      uploadedAt: Date.now(),
    });
  },
});
```

## Serving Files

### Get File URL

```typescript
export const getFileUrl = query({
  args: { storageId: v.id("_storage") },
  returns: v.union(v.string(), v.null()),
  handler: async (ctx, args) => {
    return await ctx.storage.getUrl(args.storageId);
  },
});
```

### Get URL with Document Lookup

```typescript
export const getFile = query({
  args: { fileId: v.id("files") },
  returns: v.union(
    v.object({
      filename: v.string(),
      url: v.union(v.string(), v.null()),
    }),
    v.null()
  ),
  handler: async (ctx, args) => {
    const file = await ctx.db.get(args.fileId);
    if (!file) return null;

    const url = await ctx.storage.getUrl(file.storageId);
    return {
      filename: file.filename,
      url,
    };
  },
});
```

## Storage Metadata

### Query Storage Table

The `_storage` system table contains file metadata:

```typescript
export const getStorageMetadata = query({
  args: { storageId: v.id("_storage") },
  returns: v.union(
    v.object({
      _id: v.id("_storage"),
      _creationTime: v.number(),
      sha256: v.string(),
      size: v.number(),
      contentType: v.optional(v.string()),
    }),
    v.null()
  ),
  handler: async (ctx, args) => {
    return await ctx.db
      .system
      .get(args.storageId);
  },
});
```

### List All Stored Files

```typescript
export const listStoredFiles = query({
  args: {},
  returns: v.array(v.object({
    _id: v.id("_storage"),
    size: v.number(),
    contentType: v.optional(v.string()),
  })),
  handler: async (ctx) => {
    return await ctx.db
      .system
      .query("_storage")
      .collect();
  },
});
```

## Delete Files

```typescript
export const deleteFile = mutation({
  args: { fileId: v.id("files") },
  returns: v.null(),
  handler: async (ctx, args) => {
    const file = await ctx.db.get(args.fileId);
    if (!file) return null;

    // Delete from storage
    await ctx.storage.delete(file.storageId);

    // Delete database record
    await ctx.db.delete(args.fileId);

    return null;
  },
});
```

## HTTP Upload Endpoint

For external uploads (webhooks, APIs):

```typescript
// convex/http.ts
import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { api } from "./_generated/api";

const http = httpRouter();

http.route({
  path: "/upload",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    // Get file from request body
    const blob = await request.blob();

    // Store file
    const storageId = await ctx.storage.store(blob);

    // Optionally save to database
    const filename = request.headers.get("X-Filename") ?? "unnamed";
    const fileId = await ctx.runMutation(api.files.saveFile, {
      storageId,
      filename,
    });

    return new Response(JSON.stringify({ fileId, storageId }), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

export default http;
```

## Schema for Files

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  files: defineTable({
    storageId: v.id("_storage"),
    filename: v.string(),
    uploadedAt: v.number(),
    uploadedBy: v.optional(v.id("users")),
    mimeType: v.optional(v.string()),
  })
    .index("by_uploadedBy", ["uploadedBy"])
    .index("by_storageId", ["storageId"]),
});
```

## Image Processing Pattern

```typescript
// convex/images.ts
export const uploadImage = mutation({
  args: {
    storageId: v.id("_storage"),
    altText: v.optional(v.string()),
  },
  returns: v.id("images"),
  handler: async (ctx, args) => {
    // Get metadata from storage
    const metadata = await ctx.db.system.get(args.storageId);

    // Validate it's an image
    if (!metadata?.contentType?.startsWith("image/")) {
      throw new Error("File must be an image");
    }

    return await ctx.db.insert("images", {
      storageId: args.storageId,
      altText: args.altText ?? "",
      size: metadata.size,
      contentType: metadata.contentType,
    });
  },
});
```

## Storage API Reference

| Method | Context | Purpose |
|--------|---------|---------|
| `ctx.storage.generateUploadUrl()` | Mutation | Create short-lived upload URL |
| `ctx.storage.getUrl(storageId)` | Query, Mutation, Action | Get serving URL |
| `ctx.storage.store(blob)` | Action, HTTP Action | Store blob directly |
| `ctx.storage.delete(storageId)` | Mutation | Delete stored file |
| `ctx.db.system.get(storageId)` | Query, Mutation | Get storage metadata |
| `ctx.db.system.query("_storage")` | Query, Mutation | Query storage table |
