---
name: no-stringly-typed
description: Unions/enums over magic strings.
---

# Avoid Stringly-Typed Code

Use enums, discriminated unions, and branded types instead of magic strings.

## TypeScript

### ❌ Don't: String parameters with magic values

```typescript
function setStatus(status: string) {
  // What values are valid? "active"? "ACTIVE"? "pending"?
  if (status === "active") {
    // ...
  }
}

function getUser(id: string) {
  // Is this a user ID? tenant ID? any string?
  return users.get(id);
}

// String comparisons everywhere
function handleEvent(event: { type: string; payload: unknown }) {
  if (event.type === "USER_CREATED") {
    // Typo "USER_CRETAED" would fail silently
  } else if (event.type === "USER_UPDATED") {
    // ...
  }
}

// Configuration with string keys
const config = {
  "api.timeout": 5000,
  "api.retries": 3,
  "cache.enabled": true,
};
function getConfig(key: string): unknown {
  return config[key]; // No type safety
}
```

### ✅ Do: Use union types and branded types

```typescript
// Union type for fixed set of values
type Status = "active" | "pending" | "suspended" | "deleted";

function setStatus(status: Status) {
  // TypeScript ensures only valid values
  switch (status) {
    case "active": // ...
    case "pending": // ...
    case "suspended": // ...
    case "deleted": // ...
    // Exhaustiveness check - compiler errors if case missed
  }
}

// Branded types for different string IDs
type UserId = string & { readonly __brand: "UserId" };
type TenantId = string & { readonly __brand: "TenantId" };

function createUserId(id: string): UserId {
  return id as UserId;
}

function getUser(id: UserId) {
  // Can't accidentally pass a TenantId
  return users.get(id);
}

// Discriminated union for events
type AppEvent =
  | { type: "USER_CREATED"; payload: { userId: UserId; email: string } }
  | { type: "USER_UPDATED"; payload: { userId: UserId; changes: Partial<User> } }
  | { type: "USER_DELETED"; payload: { userId: UserId } };

function handleEvent(event: AppEvent) {
  switch (event.type) {
    case "USER_CREATED":
      // event.payload is typed as { userId, email }
      console.log(event.payload.email);
      break;
    case "USER_UPDATED":
      // event.payload is typed as { userId, changes }
      console.log(event.payload.changes);
      break;
  }
}
```

### ✅ Do: Type-safe configuration

```typescript
interface AppConfig {
  api: {
    timeout: number;
    retries: number;
  };
  cache: {
    enabled: boolean;
    ttl: number;
  };
}

const config: AppConfig = {
  api: { timeout: 5000, retries: 3 },
  cache: { enabled: true, ttl: 3600 },
};

// Type-safe access
config.api.timeout; // number
config.cache.enabled; // boolean
```

## Rust

### ❌ Don't: String parameters with conventions

```rust
fn set_status(status: &str) {
    // What's valid? Case sensitive?
    match status {
        "active" => {}
        "pending" => {}
        _ => {} // Silent fallthrough for typos
    }
}

fn get_user(id: &str) -> Option<User> {
    // Is this validated? What format?
    users.get(id)
}

// String-based event handling
fn handle_event(event_type: &str, payload: &str) {
    if event_type == "user.created" {
        // Parsing payload from string
        let user: User = serde_json::from_str(payload).unwrap();
    }
}
```

### ✅ Do: Use enums and newtypes

```rust
// Enum for fixed set of values
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Status {
    Active,
    Pending,
    Suspended,
    Deleted,
}

fn set_status(status: Status) {
    match status {
        Status::Active => {}
        Status::Pending => {}
        Status::Suspended => {}
        Status::Deleted => {}
        // Compiler ensures all cases handled
    }
}

// Newtype for different string IDs
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct UserId(String);

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct TenantId(String);

impl UserId {
    fn new(id: impl Into<String>) -> Self {
        Self(id.into())
    }
}

fn get_user(id: &UserId) -> Option<User> {
    // Can't accidentally pass a TenantId
    users.get(&id.0)
}

// Typed events with enum
enum AppEvent {
    UserCreated { user_id: UserId, email: String },
    UserUpdated { user_id: UserId, changes: UserChanges },
    UserDeleted { user_id: UserId },
}

fn handle_event(event: AppEvent) {
    match event {
        AppEvent::UserCreated { user_id, email } => {
            // Fields are typed and guaranteed present
            println!("User {} created with email {}", user_id.0, email);
        }
        AppEvent::UserUpdated { user_id, changes } => {
            // ...
        }
        AppEvent::UserDeleted { user_id } => {
            // ...
        }
    }
}
```

### ✅ Do: Use serde for serialization

```rust
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
enum Status {
    Active,
    Pending,
    Suspended,
}

// Serializes to/from "active", "pending", "suspended"
// Type-safe in code, string-compatible for APIs
```

## When to Apply

Look for these patterns that indicate stringly-typed code:

- String parameters that only accept certain values
- IDs passed as plain strings (`user_id: String`)
- Switch/match statements on string literals
- Magic strings scattered throughout code
- Comments explaining what string values are valid
- Bugs from typos in string comparisons
