# Svelte 5 Runes

## State Declaration

```svelte
<script lang="ts">
  // Primitive state
  let count = $state(0);

  // Object state (deeply reactive)
  let user = $state<User>({ name: "", email: "" });

  // Array state
  let items = $state<Item[]>([]);

  // Direct mutation works
  user.name = "Alice";     // Triggers update
  items.push(newItem);     // Triggers update
</script>
```

## Derived Values

Use `$derived` for computed values:

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

## Props

```svelte
<script lang="ts">
  interface Props {
    name: string;
    count?: number;
    disabled?: boolean;
    onchange?: (value: number) => void;
  }

  let {
    name,
    count = 0,
    disabled = false,
    onchange,
  }: Props = $props();
</script>
```

## Bindable Props

For two-way binding:

```svelte
<!-- Parent -->
<Counter bind:count />

<!-- Counter.svelte -->
<script lang="ts">
  let { count = $bindable(0) } = $props();
</script>

<button onclick={() => count++}>
  {count}
</button>
```

## Effects (Side Effects Only)

```svelte
<script lang="ts">
  let query = $state("");

  // ✅ Side effects: DOM synchronization
  $effect(() => {
    document.title = `Search: ${query}`;
  });

  // ✅ Side effects: subscriptions with cleanup
  $effect(() => {
    const unsubscribe = store.subscribe(handler);
    return unsubscribe;
  });

  // ✅ Side effects: logging, analytics
  $effect(() => {
    console.log("Query changed:", query);
  });
</script>
```

## Banned Patterns

| Pattern | Reason | Alternative |
|---------|--------|-------------|
| `export let` | Svelte 4 syntax | `$props()` |
| `$: derived = ...` | Svelte 4 syntax | `$derived()` |
| `$: { ... }` | Svelte 4 syntax | `$effect()` |
| `writable()`/`derived()` stores | Legacy pattern | Runes (see exception below) |

## Exception: Stores for Tauri Callbacks

Use stores when updating state from non-reactive contexts (Tauri Channel callbacks):

```typescript
// State manager with store for external updates
import { writable } from "svelte/store";

class StateManager {
  state = writable<State>({ status: "disconnected" });

  // Called from Tauri Channel - not reactive context
  handleUpdate(data: Data) {
    this.state.set({ status: "connected", data });
  }
}
```

See `state-modeling.md` for the complete pattern.

## Event Handlers

Use `on` prefix matching DOM events:

```svelte
<button onclick={() => count++}>Click</button>
<input oninput={(e) => value = e.currentTarget.value} />
<form onsubmit|preventDefault={handleSubmit}>
```
