# TypeScript Type Safety

## Banned Patterns

| Pattern | Reason | Alternative |
|---------|--------|-------------|
| `as` type casts | Bypasses type checking | `satisfies`, type guards |
| `any` | Defeats type system | `unknown` + type guards |
| `@ts-ignore` | Hides real issues | Fix the underlying type |
| `@ts-expect-error` | Masks problems | Fix the underlying type |
| `!` non-null assertion | Runtime risk | Explicit null checks |

## Allowed Exceptions

| Pattern | When Allowed |
|---------|--------------|
| `as const` | Safe literal type narrowing |
| `as HTMLInputElement` | DOM events bound to known elements |
| `as` in test mocks | Initializing known valid shapes |

## Type Guards

```typescript
// Custom type guard
function isUser(value: unknown): value is User {
  return (
    typeof value === "object" &&
    value !== null &&
    "id" in value &&
    "email" in value &&
    typeof (value as Record<string, unknown>).id === "string" &&
    typeof (value as Record<string, unknown>).email === "string"
  );
}

// Usage with unknown data
const data: unknown = JSON.parse(input);
if (isUser(data)) {
  console.log(data.email); // Type-safe
}
```

## Satisfies for Validation

```typescript
// ❌ as cast - no validation
const config = { timeout: 5000 } as Config;

// ✅ satisfies - validates shape at compile time
const config = {
  timeout: 5000,
  retries: 3,
} satisfies Config;

// ✅ satisfies with inference
const ROUTES = {
  home: "/",
  users: "/users",
  settings: "/settings",
} satisfies Record<string, string>;

// Type is preserved: { home: "/", users: "/users", settings: "/settings" }
// Not widened to: Record<string, string>
```

## Branded Types

Prevent mixing up primitives:

```typescript
// Define branded types
type UserId = string & { readonly __brand: "UserId" };
type OrderId = string & { readonly __brand: "OrderId" };
type Email = string & { readonly __brand: "Email" };

// Smart constructors with validation
function userId(id: string): UserId {
  if (!id.startsWith("usr_")) {
    throw new Error(`Invalid user ID format: ${id}`);
  }
  return id as UserId;
}

function email(input: string): Email {
  if (!/.+@.+\..+/.test(input)) {
    throw new Error(`Invalid email format: ${input}`);
  }
  return input.toLowerCase() as Email;
}

// Compiler catches mixups
function getUser(id: UserId): User { /* ... */ }
function getOrder(id: OrderId): Order { /* ... */ }

const orderId = "ord_123" as OrderId;
getUser(orderId); // ✅ Type error: OrderId not assignable to UserId
```

## Exhaustiveness Checking

Ensure all union cases are handled:

```typescript
type Status = "idle" | "loading" | "success" | "error";

function getStatusMessage(status: Status): string {
  switch (status) {
    case "idle":
      return "Ready";
    case "loading":
      return "Loading...";
    case "success":
      return "Done!";
    case "error":
      return "Failed";
    default:
      // Exhaustiveness check - compiler error if case missed
      const _exhaustive: never = status;
      return _exhaustive;
  }
}
```

## Strict Null Checks

Always enabled. Handle null/undefined explicitly:

```typescript
// ❌ Assumes value exists
function getName(user: User | null): string {
  return user.name; // Error: user might be null
}

// ✅ Explicit handling
function getName(user: User | null): string {
  if (!user) {
    return "Unknown";
  }
  return user.name;
}

// ✅ Optional chaining with fallback
function getName(user: User | null): string {
  return user?.name ?? "Unknown";
}
```

## JSON.parse Safety

Always validate parsed JSON:

```typescript
// ❌ Unsafe - trusts external data
const data = JSON.parse(input) as User;

// ✅ Safe - validate first
const parsed: unknown = JSON.parse(input);
if (!isUser(parsed)) {
  throw new Error("Invalid user data");
}
const data: User = parsed;
```
