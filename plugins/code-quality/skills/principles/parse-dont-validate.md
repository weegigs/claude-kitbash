---
name: parse-dont-validate
description: Validated types at boundaries.
---

# Parse, Don't Validate

Transform unvalidated data into validated types at system boundaries. Once parsed, the type guarantees validity throughout the codebase.

## TypeScript

### ❌ Don't: Validate and return the same loose type

```typescript
function processEmail(input: string): string {
  if (!input.includes("@")) {
    throw new Error("Invalid email");
  }
  return input; // Still just a string—could be anything
}

function sendWelcome(email: string) {
  // Do we need to validate again? Who knows!
  // The type doesn't tell us if it's been validated
  sendEmail(email, "Welcome!");
}

// Later, someone calls sendWelcome with unvalidated input
sendWelcome(userInput); // Bug: might not be a valid email
```

### ✅ Do: Parse into a validated type

```typescript
// Branded type guarantees validation happened
type Email = string & { readonly __brand: "Email" };

function parseEmail(input: string): Email {
  const trimmed = input.trim().toLowerCase();
  if (!trimmed.includes("@") || !trimmed.includes(".")) {
    throw new Error(`Invalid email: ${input}`);
  }
  return trimmed as Email;
}

function sendWelcome(email: Email) {
  // No validation needed—the type guarantees it's valid
  sendEmail(email, "Welcome!");
}

// Compiler enforces validation at the boundary
const email = parseEmail(userInput); // Parse once at boundary
sendWelcome(email); // Type-safe usage throughout
```

### ✅ Do: Parse complex structures

```typescript
// Raw input type
interface CreateUserInput {
  email: string;
  age: string;
  role: string;
}

// Validated domain type
interface User {
  email: Email;
  age: PositiveInt;
  role: "admin" | "user" | "guest";
}

function parseUser(input: CreateUserInput): User {
  const role = parseRole(input.role);
  return {
    email: parseEmail(input.email),
    age: parsePositiveInt(input.age),
    role,
  };
}

// All functions downstream receive validated User
function createUser(user: User): void {
  // No defensive checks needed—types guarantee validity
  db.users.create(user);
}
```

## Rust

### ❌ Don't: Return the same type after validation

```rust
fn process_user_id(input: &str) -> Result<String> {
    if input.len() != 36 {
        return Err(anyhow!("Invalid UUID length"));
    }
    // Still just a String—no compile-time guarantee it's valid
    Ok(input.to_string())
}

fn get_user(id: String) -> Result<User> {
    // Should we validate again? The type doesn't say
    db.find_user(&id)
}
```

### ✅ Do: Use newtypes to encode validation

```rust
// Newtype guarantees validation
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct UserId(String);

impl UserId {
    fn parse(input: &str) -> Result<Self> {
        let trimmed = input.trim();
        // Validate UUID format
        uuid::Uuid::parse_str(trimmed)?;
        Ok(UserId(trimmed.to_string()))
    }

    fn as_str(&self) -> &str {
        &self.0
    }
}

fn get_user(id: UserId) -> Result<User> {
    // No validation needed—UserId guarantees validity
    db.find_user(id.as_str())
}

// Parse at the boundary
fn handle_request(raw_id: &str) -> Result<User> {
    let id = UserId::parse(raw_id)?; // Validation happens once
    get_user(id) // Type-safe usage
}
```

### ✅ Do: Parse complex structures

```rust
// Raw input
struct CreateUserRequest {
    email: String,
    age: String,
    role: String,
}

// Validated domain types
struct Email(String);
struct Age(u8);

enum Role {
    Admin,
    User,
    Guest,
}

struct ValidUser {
    email: Email,
    age: Age,
    role: Role,
}

impl ValidUser {
    fn parse(input: CreateUserRequest) -> Result<Self> {
        Ok(ValidUser {
            email: Email::parse(&input.email)?,
            age: Age::parse(&input.age)?,
            role: Role::parse(&input.role)?,
        })
    }
}

// All functions receive validated ValidUser
fn create_user(user: ValidUser) -> Result<()> {
    // No defensive checks—types guarantee validity
    db.insert_user(user)
}
```

## When to Apply

Look for these patterns that indicate validation without parsing:

- Functions that validate but return the same type (`String` → `String`)
- Repeated validation of the same data in multiple functions
- Stringly-typed identifiers (`user_id: String` instead of `UserId`)
- Defensive checks deep in the codebase for data that should already be valid
- Comments like "// already validated" or "// assume valid"
