# Symbols for State Markers

## Problem: null/undefined Ambiguity

```typescript
// ❌ Ambiguous
type UserResult = User | null | undefined;

// Questions this raises:
// - Does null mean "not found"?
// - Does undefined mean "not loaded yet"?
// - How do we distinguish "loading" from "error"?
// - What about "not authorized to view"?
```

## Solution: Explicit Symbol Markers

```typescript
// ✅ Clear, unambiguous state markers
const NOT_FOUND = Symbol("not_found");
const LOADING = Symbol("loading");
const UNAUTHORIZED = Symbol("unauthorized");

type UserResult =
  | User
  | typeof NOT_FOUND
  | typeof LOADING
  | typeof UNAUTHORIZED;
```

## Benefits

1. **Self-documenting**: Symbol names describe the state
2. **Type-safe**: Each symbol is a distinct type
3. **Exhaustive**: TypeScript ensures all cases handled
4. **No collision**: Symbols are globally unique

## Usage Patterns

### Cache Lookups

```typescript
const NOT_CACHED = Symbol("not_cached");
const CACHE_MISS = Symbol("cache_miss");

type CacheResult<T> =
  | { hit: true; value: T }
  | typeof NOT_CACHED
  | typeof CACHE_MISS;

function getFromCache<T>(key: string): CacheResult<T> {
  if (!cache.has(key)) return NOT_CACHED;
  const entry = cache.get(key);
  if (entry.expired) return CACHE_MISS;
  return { hit: true, value: entry.value };
}
```

### Async Data Loading

```typescript
const LOADING = Symbol("loading");
const LOAD_ERROR = Symbol("load_error");

type AsyncData<T> = T | typeof LOADING | typeof LOAD_ERROR;

// In component
let userData = $state<AsyncData<User>>(LOADING);

$effect(() => {
  fetchUser(id)
    .then(user => userData = user)
    .catch(() => userData = LOAD_ERROR);
});
```

### Form Field State

```typescript
const PRISTINE = Symbol("pristine");
const VALIDATING = Symbol("validating");

type FieldState<T> =
  | { status: typeof PRISTINE }
  | { status: typeof VALIDATING }
  | { status: "valid"; value: T }
  | { status: "invalid"; errors: string[] };
```

## Boundary Mapping

Map external nulls to symbols at system boundaries:

```typescript
// Convex API returns null for "not found"
async function getUser(id: string): Promise<User | typeof NOT_FOUND> {
  const result = await ctx.db.get(id); // Returns User | null

  // Map at boundary
  return result ?? NOT_FOUND;
}

// Internal code uses symbols, never null
function processUser(user: User | typeof NOT_FOUND) {
  if (user === NOT_FOUND) {
    // Handle not found case
    return;
  }
  // TypeScript knows: user is User
  console.log(user.email);
}
```

## Pattern Matching

```typescript
function renderUserState(result: UserResult): JSX.Element {
  // TypeScript narrows type at each check
  if (result === LOADING) {
    return <Spinner />;
  }

  if (result === NOT_FOUND) {
    return <NotFoundMessage />;
  }

  if (result === UNAUTHORIZED) {
    return <UnauthorizedMessage />;
  }

  // TypeScript knows: result is User
  return <UserCard user={result} />;
}
```

## When to Use Symbols vs Discriminated Unions

| Use Symbols When | Use Discriminated Unions When |
|------------------|------------------------------|
| Simple presence/absence states | States carry different data |
| Replacing null/undefined | Complex state machines |
| Cache/loading indicators | Form states with error messages |
| Single marker values | Multiple fields per state |

```typescript
// Symbols: simple markers
const LOADING = Symbol("loading");
type Data = User | typeof LOADING;

// Discriminated union: states with data
type FormState =
  | { status: "idle" }
  | { status: "submitting" }
  | { status: "success"; data: Response }
  | { status: "error"; error: Error; retryCount: number };
```

## Exporting Symbols

```typescript
// types.ts
export const NOT_FOUND = Symbol("not_found");
export const LOADING = Symbol("loading");

// Export types for use in signatures
export type NotFound = typeof NOT_FOUND;
export type Loading = typeof LOADING;

// Convenience type combining common states
export type AsyncState<T> = T | NotFound | Loading;
```
