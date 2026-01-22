# Component Props Pattern

## Standard Interface Pattern

```svelte
<script lang="ts">
  interface Props {
    // Required props
    id: string;
    name: string;

    // Optional with defaults
    count?: number;
    disabled?: boolean;

    // Callbacks (on prefix)
    onclick?: () => void;
    onchange?: (value: string) => void;

    // Children via Snippet
    children?: Snippet;
  }

  let {
    id,
    name,
    count = 0,
    disabled = false,
    onclick,
    onchange,
    children,
  }: Props = $props();
</script>
```

## Event Handler Naming

- Use `on` prefix: `onclick`, `onchange`, `onsubmit`
- Match DOM event names where applicable
- For custom events: `onitemselect`, `onfilterchange`

```svelte
<!-- Component definition -->
<script lang="ts">
  interface Props {
    onitemselect?: (item: Item) => void;
    onfilterchange?: (filter: string) => void;
  }

  let { onitemselect, onfilterchange }: Props = $props();

  function handleClick(item: Item) {
    onitemselect?.(item);
  }
</script>

<!-- Usage -->
<ItemList
  onitemselect={(item) => selectedItem = item}
  onfilterchange={(f) => filter = f}
/>
```

## Snippets for Composition

Replace slots with snippets:

```svelte
<!-- Card.svelte -->
<script lang="ts">
  import type { Snippet } from "svelte";

  interface Props {
    header?: Snippet;
    footer?: Snippet;
    children: Snippet;
  }

  let { header, footer, children }: Props = $props();
</script>

<div class="card">
  {#if header}
    <header class="card-header">
      {@render header()}
    </header>
  {/if}

  <main class="card-body">
    {@render children()}
  </main>

  {#if footer}
    <footer class="card-footer">
      {@render footer()}
    </footer>
  {/if}
</div>

<!-- Usage -->
<Card>
  {#snippet header()}
    <h2>Card Title</h2>
  {/snippet}

  <p>Card content goes here</p>

  {#snippet footer()}
    <button>Action</button>
  {/snippet}
</Card>
```

## Snippets with Parameters

```svelte
<!-- List.svelte -->
<script lang="ts" generics="T">
  import type { Snippet } from "svelte";

  interface Props {
    items: T[];
    renderItem: Snippet<[T, number]>;
  }

  let { items, renderItem }: Props = $props();
</script>

<ul>
  {#each items as item, index}
    <li>
      {@render renderItem(item, index)}
    </li>
  {/each}
</ul>

<!-- Usage -->
<List items={users}>
  {#snippet renderItem(user, index)}
    <span>{index + 1}. {user.name}</span>
  {/snippet}
</List>
```

## Rest Props

Spread remaining props to underlying element:

```svelte
<script lang="ts">
  import type { HTMLButtonAttributes } from "svelte/elements";

  interface Props extends HTMLButtonAttributes {
    variant?: "primary" | "secondary";
  }

  let { variant = "primary", ...rest }: Props = $props();
</script>

<button
  class="btn btn-{variant}"
  {...rest}
>
  <slot />
</button>
```
