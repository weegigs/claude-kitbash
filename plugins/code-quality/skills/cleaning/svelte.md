---
name: svelte
description: Svelte 5 runes + SvelteKit 2 - $state, $derived, $effect, load functions, form actions.
---

# Svelte Cleaning Patterns

Svelte 5 with runes, SvelteKit 2. No legacy stores, no Svelte 4 patterns.

## Runes: $state

```svelte
<script lang="ts">
  // ❌ Svelte 4 reactive declarations
  let count = 0;
  $: doubled = count * 2;

  // ✅ Svelte 5 runes
  let count = $state(0);
  let doubled = $derived(count * 2);

  // Objects and arrays are deeply reactive
  let user = $state({ name: "Alice", age: 30 });
  user.age = 31; // Triggers update

  let items = $state<string[]>([]);
  items.push("new"); // Triggers update
</script>

<button onclick={() => count++}>
  {count} (doubled: {doubled})
</button>
```

## Runes: $derived

```svelte
<script lang="ts">
  let items = $state<Item[]>([]);
  let filter = $state("");

  // Simple derived
  let count = $derived(items.length);

  // Complex derived with .by()
  let filtered = $derived.by(() => {
    if (!filter) return items;
    return items.filter(item =>
      item.name.toLowerCase().includes(filter.toLowerCase())
    );
  });

  // Derived from multiple sources
  let summary = $derived(`${filtered.length} of ${count} items`);
</script>
```

## Runes: $effect

```svelte
<script lang="ts">
  let query = $state("");

  // ❌ Using $effect for derived values
  let results = $state<Result[]>([]);
  $effect(() => {
    results = computeResults(query); // Wrong! Use $derived
  });

  // ✅ $effect for side effects only
  $effect(() => {
    // Runs when query changes
    console.log("Query changed:", query);

    // Cleanup function
    return () => {
      console.log("Cleaning up previous effect");
    };
  });

  // ✅ $effect for DOM/external synchronization
  $effect(() => {
    document.title = `Search: ${query}`;
  });

  // ✅ $effect for subscriptions
  $effect(() => {
    const unsubscribe = someStore.subscribe(value => {
      // handle value
    });
    return unsubscribe;
  });
</script>
```

## Runes: $props

```svelte
<!-- ❌ Svelte 4 export let -->
<script lang="ts">
  export let name: string;
  export let count = 0;
</script>

<!-- ✅ Svelte 5 $props -->
<script lang="ts">
  type Props = {
    name: string;
    count?: number;
    onchange?: (value: number) => void;
  };

  let { name, count = 0, onchange }: Props = $props();
</script>

<!-- With rest props -->
<script lang="ts">
  let { name, ...rest }: Props & Record<string, unknown> = $props();
</script>
<div {...rest}>{name}</div>
```

## Runes: $bindable

```svelte
<!-- Parent -->
<Counter bind:count />

<!-- Child: Counter.svelte -->
<script lang="ts">
  let { count = $bindable(0) } = $props();
</script>

<button onclick={() => count++}>
  {count}
</button>
```

## Component Composition

```svelte
<!-- ❌ Slots (legacy) -->
<Card>
  <span slot="header">Title</span>
  Content
</Card>

<!-- ✅ Snippets (Svelte 5) -->
<script lang="ts">
  import type { Snippet } from "svelte";

  type Props = {
    header: Snippet;
    children: Snippet;
  };

  let { header, children }: Props = $props();
</script>

<div class="card">
  <header>{@render header()}</header>
  <main>{@render children()}</main>
</div>

<!-- Usage -->
<Card>
  {#snippet header()}
    <h2>Title</h2>
  {/snippet}

  <p>Card content here</p>
</Card>
```

## SvelteKit: Load Functions

```typescript
// +page.ts - Universal load (runs on server and client)
import type { PageLoad } from "./$types";

export const load: PageLoad = async ({ params, fetch }) => {
  const response = await fetch(`/api/users/${params.id}`);
  const user = await response.json();

  return { user };
};

// +page.server.ts - Server-only load
import type { PageServerLoad } from "./$types";
import { db } from "$lib/server/db";

export const load: PageServerLoad = async ({ params, locals }) => {
  // Access server-only resources
  const user = await db.user.findUnique({
    where: { id: params.id }
  });

  // Check auth
  if (!locals.user) {
    throw redirect(302, "/login");
  }

  return { user };
};
```

## SvelteKit: Form Actions

```typescript
// +page.server.ts
import type { Actions } from "./$types";
import { fail, redirect } from "@sveltejs/kit";

export const actions: Actions = {
  default: async ({ request }) => {
    const data = await request.formData();
    const email = data.get("email");

    if (!email) {
      return fail(400, { email, missing: true });
    }

    try {
      await createUser(email.toString());
    } catch (e) {
      return fail(500, { email, error: "Failed to create user" });
    }

    throw redirect(303, "/success");
  },

  // Named action
  delete: async ({ params }) => {
    await deleteUser(params.id);
    throw redirect(303, "/users");
  }
};
```

```svelte
<!-- +page.svelte -->
<script lang="ts">
  import { enhance } from "$app/forms";

  let { form } = $props();
</script>

<!-- Progressive enhancement -->
<form method="POST" use:enhance>
  <input name="email" value={form?.email ?? ""} />
  {#if form?.missing}
    <p class="error">Email is required</p>
  {/if}
  <button>Submit</button>
</form>

<!-- Named action -->
<form method="POST" action="?/delete" use:enhance>
  <button>Delete</button>
</form>
```

## SvelteKit: Layouts

```typescript
// +layout.ts
import type { LayoutLoad } from "./$types";

export const load: LayoutLoad = async ({ fetch }) => {
  const settings = await fetch("/api/settings").then(r => r.json());
  return { settings };
};
```

```svelte
<!-- +layout.svelte -->
<script lang="ts">
  import type { Snippet } from "svelte";

  type Props = {
    data: { settings: Settings };
    children: Snippet;
  };

  let { data, children }: Props = $props();
</script>

<header>
  <!-- Use layout data -->
  <nav>{data.settings.siteName}</nav>
</header>

<main>
  {@render children()}
</main>
```

## Type-Safe Routing

```typescript
// Use $types for full type safety
import type { PageLoad, PageData } from "./$types";

// Route params are typed
export const load: PageLoad = async ({ params }) => {
  // params.id is typed based on route
  const id: string = params.id;
};

// In component
let { data }: { data: PageData } = $props();
```

## Error Handling

```typescript
// +error.svelte
<script lang="ts">
  import { page } from "$app/stores";

  // Or with runes in +error.svelte
  let { error } = $props();
</script>

<h1>{$page.status}</h1>
<p>{$page.error?.message}</p>

// Throwing errors in load
import { error } from "@sveltejs/kit";

export const load: PageLoad = async ({ params }) => {
  const user = await getUser(params.id);
  if (!user) {
    throw error(404, "User not found");
  }
  return { user };
};
```

## Migration from Stores

```svelte
<script lang="ts">
  // ❌ Svelte 4 stores
  import { writable, derived } from "svelte/store";
  const count = writable(0);
  const doubled = derived(count, $c => $c * 2);
  $count; // Auto-subscription

  // ✅ Svelte 5 runes
  let count = $state(0);
  let doubled = $derived(count * 2);
  // No $ prefix needed, direct access
</script>
```

## Class Directive

```svelte
<!-- ❌ Ternary in class -->
<div class={active ? "card active" : "card"}>

<!-- ✅ Class directive -->
<div class="card" class:active>

<!-- Multiple conditions -->
<div
  class="btn"
  class:primary={type === "primary"}
  class:disabled
  class:loading
>
```
