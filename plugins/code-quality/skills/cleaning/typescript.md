---
name: typescript
description: Pure functional TypeScript patterns - discriminated unions, branded types, composition, Result/Option, iterator helpers.
---

# TypeScript Cleaning Patterns

Pure functional TypeScript idioms. No React, no classes unless necessary. Updated for TypeScript 5.8+ and ES2025.

## Make Invalid States Unrepresentable

Use the type system to make illegal states impossible to construct.

```typescript
// ❌ Boolean flags create invalid combinations
type FormState = {
  isSubmitting: boolean;
  isSuccess: boolean;
  isError: boolean;
  error?: Error;
  data?: Response;
};
// Can have isSubmitting AND isSuccess both true - invalid!

// ✅ Discriminated union - each state is distinct
type FormState =
  | { status: "idle" }
  | { status: "submitting" }
  | { status: "success"; data: Response }
  | { status: "error"; error: Error };

// ❌ Optional fields that depend on each other
type User = {
  isPremium: boolean;
  subscriptionEnd?: Date;  // Required if isPremium, but type doesn't enforce
};

// ✅ Model the relationship in the type
type User =
  | { type: "free" }
  | { type: "premium"; subscriptionEnd: Date };
```

**Apply when you see**: boolean flags, optional fields that are conditionally required, string literals that should be unions.

## Single Responsibility Principle

Each function, module, and type should have exactly one reason to change.

```typescript
// ❌ Function does too many things
async function handleUserRegistration(form: FormData) {
  const email = form.get("email");
  if (!isValidEmail(email)) throw new Error("Invalid email");
  const user = { email, createdAt: new Date() };
  await db.users.insert(user);
  await sendWelcomeEmail(email);
}

// ✅ Separate concerns
function validateRegistration(form: FormData): Email {
  return parseEmail(form.get("email"));
}

function createUser(email: Email): User {
  return { email, createdAt: new Date() };
}

async function registerUser(email: Email): Promise<User> {
  const user = createUser(email);
  await db.users.insert(user);
  return user;
}
```

**Apply when you see**: functions with "and" in their description, modules mixing I/O with business logic.

## Strong Domain Data Types

Use branded types to prevent mixing up primitives that represent different domain concepts.

```typescript
// ❌ All IDs are interchangeable strings
function getUser(id: string): User { }
function getOrder(id: string): Order { }
getUser(orderId);  // No error, but completely wrong!

// ✅ Branded types prevent mixups at compile time
type UserId = string & { readonly __brand: "UserId" };
type OrderId = string & { readonly __brand: "OrderId" };
type Email = string & { readonly __brand: "Email" };
type Money = number & { readonly __brand: "Money"; readonly currency: "USD" };

// Smart constructors that validate and brand
function userId(id: string): UserId {
  if (!id.startsWith("usr_")) throw new Error("Invalid user ID format");
  return id as UserId;
}

function parseEmail(input: string): Email {
  if (!/.+@.+\..+/.test(input)) throw new Error("Invalid email");
  return input as Email;
}

function usd(cents: number): Money {
  return cents as Money;
}

// Now the compiler catches the bug
function getUser(id: UserId): User { }
function getOrder(id: OrderId): Order { }

getUser(orderId);  // ✅ Type error! OrderId not assignable to UserId

// Domain types carry meaning
type Percentage = number & { readonly __brand: "Percentage" };
type Timestamp = number & { readonly __brand: "Timestamp" };
type Latitude = number & { readonly __brand: "Latitude" };
type Longitude = number & { readonly __brand: "Longitude" };
```

**Apply when you see**: functions taking multiple string/number parameters, IDs passed as plain strings, domain concepts represented as primitives.

## Strong Domain Error Types

Use discriminated unions for errors that callers must handle differently.

```typescript
// ❌ Generic error - caller can't distinguish cases
function createUser(email: string): User {
  throw new Error("Something went wrong");
}

// ✅ Domain-specific error types
type CreateUserError =
  | { type: "invalid_email"; email: string }
  | { type: "duplicate_email"; existingUserId: UserId }
  | { type: "rate_limited"; retryAfter: Date };

type CreateUserResult = Result<User, CreateUserError>;

function createUser(email: string): CreateUserResult {
  if (!isValidEmail(email)) {
    return err({ type: "invalid_email", email });
  }

  const existing = db.findByEmail(email);
  if (existing) {
    return err({ type: "duplicate_email", existingUserId: existing.id });
  }

  return ok(db.insert({ email: parseEmail(email) }));
}

// Caller can handle each case specifically
const result = createUser(input);
if (!result.ok) {
  switch (result.error.type) {
    case "invalid_email":
      return `"${result.error.email}" is not a valid email`;
    case "duplicate_email":
      return `Email already registered`;
    case "rate_limited":
      return `Too many attempts. Try again at ${result.error.retryAfter}`;
  }
}

// Group related errors by domain
type AuthError =
  | { type: "invalid_credentials" }
  | { type: "account_locked"; until: Date }
  | { type: "mfa_required"; challenge: MfaChallenge };

type PaymentError =
  | { type: "insufficient_funds"; required: Money; available: Money }
  | { type: "card_declined"; reason: string }
  | { type: "fraud_detected" };
```

**Apply when you see**: generic Error throws, error messages as the only distinguishing factor, catch blocks that parse error messages.

## Result Type

Explicit success/failure without exceptions.

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

const ok = <T>(value: T): Result<T, never> => ({ ok: true, value });
const err = <E>(error: E): Result<never, E> => ({ ok: false, error });

// Chain operations that might fail
function pipeline(input: string): Result<ProcessedData, PipelineError> {
  const parsed = parseInput(input);
  if (!parsed.ok) return parsed;

  const validated = validateData(parsed.value);
  if (!validated.ok) return validated;

  const transformed = transform(validated.value);
  if (!transformed.ok) return transformed;

  return ok(transformed.value);
}
```

## Iterator Helpers (ES2025 - STABLE)

Use lazy iterator methods for efficient data pipelines. These are now standard in ES2025.

```typescript
// ✅ NEW: Iterator helpers - lazy evaluation, single pass
const result = users
  .values()                           // Get iterator
  .filter(u => u.active)              // Lazy
  .map(u => u.email)                  // Lazy
  .take(10)                           // Lazy - stops after 10
  .toArray();                         // Consume

// ❌ LEGACY: Array methods - eager, creates intermediate arrays
const result = users
  .filter(u => u.active)              // Creates new array
  .map(u => u.email)                  // Creates another array
  .slice(0, 10);                      // Creates third array

// Complex pipeline with iterator helpers
function processLargeDataset(records: Record[]) {
  return records
    .values()
    .filter(r => r.status === "active")
    .flatMap(r => r.items.values())
    .map(item => transformItem(item))
    .filter(item => item.value > threshold)
    .take(1000)
    .reduce((acc, item) => {
      acc.set(item.id, item);
      return acc;
    }, new Map());
}

// Available iterator methods (ES2025):
// .map(fn)      - Transform each element
// .filter(fn)   - Keep matching elements
// .flatMap(fn)  - Map and flatten one level
// .take(n)      - First n elements
// .drop(n)      - Skip first n elements
// .reduce(fn)   - Fold into single value
// .find(fn)     - First match
// .some(fn)     - Any match exists
// .every(fn)    - All match
// .toArray()    - Consume into array
```

**Apply when you see**: chained array methods on large datasets, multiple intermediate arrays being created.

## Using Declarations (ES2025 - STABLE)

Automatic resource cleanup without try/finally.

```typescript
// ✅ NEW: using declarations - automatic cleanup
async function processFile(path: string) {
  await using file = await openFile(path);
  await using connection = await getDbConnection();

  const data = await file.read();
  await connection.insert(data);
  // Both automatically closed when scope exits, even on error
}

// Implement Symbol.dispose for custom resources
class Transaction {
  constructor(private db: Database) {
    this.db.begin();
  }

  [Symbol.dispose]() {
    this.db.rollback();  // Auto-rollback if not committed
  }

  commit() {
    this.db.commit();
  }
}

function updateUser(db: Database, id: UserId, data: UserData) {
  using tx = new Transaction(db);
  db.update("users", id, data);
  tx.commit();
  // Implicit rollback if exception thrown before commit
}

// ❌ LEGACY: Manual try/finally
async function processFileLegacy(path: string) {
  const file = await openFile(path);
  try {
    const connection = await getDbConnection();
    try {
      const data = await file.read();
      await connection.insert(data);
    } finally {
      await connection.close();
    }
  } finally {
    await file.close();
  }
}
```

## Pipe Composition

Until the pipeline operator lands, use explicit pipe functions.

```typescript
// Simple pipe for same-type transformations
const pipe = <T>(...fns: Array<(x: T) => T>) =>
  (initial: T): T => fns.reduce((acc, fn) => fn(acc), initial);

const processString = pipe(
  (s: string) => s.trim(),
  (s: string) => s.toLowerCase(),
  (s: string) => s.replace(/\s+/g, "-")
);

// Flow for different types (more flexible)
function flow<A, B>(f: (a: A) => B): (a: A) => B;
function flow<A, B, C>(f: (a: A) => B, g: (b: B) => C): (a: A) => C;
function flow<A, B, C, D>(f: (a: A) => B, g: (b: B) => C, h: (c: C) => D): (a: A) => D;
function flow(...fns: Function[]) {
  return (x: unknown) => fns.reduce((acc, fn) => fn(acc), x);
}

const processUser = flow(
  (id: UserId) => fetchUser(id),
  (user: User) => enrichUser(user),
  (user: EnrichedUser) => formatForDisplay(user)
);
```

## Const Assertions and Readonly

```typescript
// ✅ Literal types with const assertion
const ROLES = ["admin", "user", "guest"] as const;
type Role = typeof ROLES[number];  // "admin" | "user" | "guest"

const CONFIG = {
  timeout: 5000,
  retries: 3,
  endpoints: {
    users: "/api/users",
    orders: "/api/orders"
  }
} as const;

// ✅ Readonly parameters - prevent mutation
function process(items: readonly string[]): string[] {
  // items.push("x");  // ✅ Type error
  return [...items, "processed"];
}

// Deep readonly for complex objects
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};
```

## Type Narrowing and Guards

```typescript
// Custom type guard
function isUser(value: unknown): value is User {
  return (
    typeof value === "object" &&
    value !== null &&
    "id" in value &&
    "email" in value
  );
}

// Assertion function - throws if invalid
function assertDefined<T>(
  value: T | null | undefined,
  message?: string
): asserts value is T {
  if (value == null) {
    throw new Error(message ?? "Value is null or undefined");
  }
}

// Exhaustiveness checking
function handleState(state: FormState): string {
  switch (state.status) {
    case "idle": return "Ready";
    case "submitting": return "Loading...";
    case "success": return state.data.message;
    case "error": return state.error.message;
    default:
      const _exhaustive: never = state;
      return _exhaustive;
  }
}
```

## Module Organization

```typescript
// Prefer named exports for better refactoring
export function createUser(email: Email): User { }
export function deleteUser(id: UserId): void { }

// Group related types
export type { User, UserId, CreateUserError };

// Barrel exports for public API
// index.ts
export { createUser, deleteUser } from "./user.js";
export type { User, UserId } from "./types.js";
```
