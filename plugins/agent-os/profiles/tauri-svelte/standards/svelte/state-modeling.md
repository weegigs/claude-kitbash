# State Modeling

## Discriminated Unions for Complex State

Model state machines with discriminated unions:

```typescript
// ❌ Boolean flags create invalid states
type FormState = {
  isSubmitting: boolean;
  isSuccess: boolean;
  isError: boolean;
  data?: Response;
  error?: Error;
};
// Can have isSubmitting AND isSuccess both true!

// ✅ Discriminated union - each state is distinct
type FormState =
  | { status: "idle" }
  | { status: "submitting" }
  | { status: "success"; data: Response }
  | { status: "error"; error: Error };
```

## Symbols for State Markers

Use symbols instead of null/undefined for explicit state:

```typescript
// ❌ Ambiguous null/undefined
type UserResult = User | null | undefined;
// Does null mean "not found"? "not loaded"? "error"?

// ✅ Explicit symbols
const NOT_FOUND = Symbol("not_found");
const LOADING = Symbol("loading");

type UserResult = User | typeof NOT_FOUND | typeof LOADING;

// Usage with exhaustive checking
function renderUser(result: UserResult) {
  if (result === LOADING) {
    return <Spinner />;
  }
  if (result === NOT_FOUND) {
    return <NotFound />;
  }
  // TypeScript knows: result is User
  return <UserCard user={result} />;
}
```

## Boundary Mapping

Map external null values to symbols at boundaries:

```typescript
// Convex returns null for "not found"
const convexResult: User | null = await ctx.db.get(id);

// Map at boundary, propagate symbol internally
const result: User | typeof NOT_FOUND = convexResult ?? NOT_FOUND;
```

## Stores vs Runes Boundary

**Problem**: Tauri Channel callbacks execute outside Svelte's reactive context. Rune updates from callbacks won't trigger reactivity.

**Solution**: Use Svelte stores for state updated from external callbacks:

```typescript
// PitwallState.svelte.ts
import { writable, type Writable } from "svelte/store";
import type { PitwallState } from "$lib/types";

class PitwallStateManager {
  // Store for external updates (Tauri callbacks)
  state: Writable<PitwallState>;

  constructor() {
    this.state = writable({ status: "disconnected" });
  }

  async start(): Promise<void> {
    await startPitwall(
      // Callback from Tauri Channel - NOT reactive context
      (sessionInfo) => {
        // Store update is safe from any context
        this.state.set({
          status: "connected",
          session: extractSession(sessionInfo),
          drivers: extractDrivers(sessionInfo),
        });
      }
    );
  }
}

// Singleton export
export const pitwallState = new PitwallStateManager();
```

**In components, use store subscription**:

```svelte
<script lang="ts">
  import { pitwallState } from "$lib/pitwall";

  const state = pitwallState.state;
</script>

{#if $state.status === "connected"}
  <DriversPanel drivers={$state.drivers} />
{:else}
  <ConnectionStatus />
{/if}
```

## When to Use Each Pattern

| Context | Use |
|---------|-----|
| Component-local state | `$state()` rune |
| Computed values | `$derived()` rune |
| Side effects | `$effect()` rune |
| Tauri Channel callbacks | Svelte store |
| External library callbacks | Svelte store |
| Shared state across components | Store or context |
