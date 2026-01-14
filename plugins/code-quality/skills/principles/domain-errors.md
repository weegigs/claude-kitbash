---
name: domain-errors
description: Errors should be identifiable to allow action to be taken on them.
---

# Domain Errors

Errors should be typed and identifiable so callers can take appropriate action. String errors and generic exceptions prevent programmatic error handling.

## TypeScript

### ❌ Don't: String errors or generic Error

```typescript
function createUser(input: CreateUserInput): User {
  if (!input.email) {
    throw new Error("Email is required");
  }
  if (!input.email.includes("@")) {
    throw new Error("Invalid email format");
  }
  if (await emailExists(input.email)) {
    throw new Error("Email already exists");
  }
  // ...
}

// Caller can't distinguish error types
try {
  await createUser(input);
} catch (error) {
  // String matching is fragile and untyped
  if (error.message.includes("already exists")) {
    // What if message text changes?
  }
}
```

### ✅ Do: Typed domain errors

```typescript
// Define error types for the domain
type CreateUserError =
  | { type: "VALIDATION"; field: string; message: string }
  | { type: "EMAIL_EXISTS"; email: string }
  | { type: "RATE_LIMITED"; retryAfter: number }
  | { type: "SERVICE_UNAVAILABLE" };

type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };

function createUser(input: CreateUserInput): Result<User, CreateUserError> {
  if (!input.email) {
    return { ok: false, error: { type: "VALIDATION", field: "email", message: "required" } };
  }
  if (!input.email.includes("@")) {
    return { ok: false, error: { type: "VALIDATION", field: "email", message: "invalid format" } };
  }
  if (await emailExists(input.email)) {
    return { ok: false, error: { type: "EMAIL_EXISTS", email: input.email } };
  }
  // ...
  return { ok: true, value: user };
}

// Caller can take specific action per error type
const result = await createUser(input);
if (!result.ok) {
  switch (result.error.type) {
    case "VALIDATION":
      showFieldError(result.error.field, result.error.message);
      break;
    case "EMAIL_EXISTS":
      offerPasswordReset(result.error.email);
      break;
    case "RATE_LIMITED":
      showRetryMessage(result.error.retryAfter);
      break;
    case "SERVICE_UNAVAILABLE":
      showMaintenanceMessage();
      break;
  }
}
```

### ✅ Do: Error classes with discrimination

```typescript
// Base class for domain errors
abstract class DomainError extends Error {
  abstract readonly type: string;
}

class ValidationError extends DomainError {
  readonly type = "VALIDATION" as const;
  constructor(readonly field: string, message: string) {
    super(message);
  }
}

class EmailExistsError extends DomainError {
  readonly type = "EMAIL_EXISTS" as const;
  constructor(readonly email: string) {
    super(`Email already exists: ${email}`);
  }
}

class RateLimitedError extends DomainError {
  readonly type = "RATE_LIMITED" as const;
  constructor(readonly retryAfter: number) {
    super(`Rate limited, retry after ${retryAfter}s`);
  }
}

// Type guard for exhaustive handling
function isDomainError(error: unknown): error is DomainError {
  return error instanceof DomainError;
}

// Caller can match on type
try {
  await createUser(input);
} catch (error) {
  if (!isDomainError(error)) throw error; // Re-throw unexpected errors

  switch (error.type) {
    case "VALIDATION":
      showFieldError(error.field, error.message);
      break;
    case "EMAIL_EXISTS":
      offerPasswordReset(error.email);
      break;
    case "RATE_LIMITED":
      showRetryMessage(error.retryAfter);
      break;
  }
}
```

## Rust

### ❌ Don't: String errors or anyhow everywhere

```rust
use anyhow::Result;

fn create_user(input: CreateUserInput) -> Result<User> {
    if input.email.is_empty() {
        return Err(anyhow::anyhow!("Email is required"));
    }
    if !input.email.contains('@') {
        return Err(anyhow::anyhow!("Invalid email format"));
    }
    if email_exists(&input.email).await? {
        return Err(anyhow::anyhow!("Email already exists"));
    }
    // ...
}

// Caller can't distinguish error types
match create_user(input).await {
    Ok(user) => { /* ... */ }
    Err(e) => {
        // String matching is fragile
        if e.to_string().contains("already exists") {
            // What if message changes?
        }
    }
}
```

### ✅ Do: Typed domain errors with thiserror

```rust
use thiserror::Error;

#[derive(Error, Debug)]
enum CreateUserError {
    #[error("Validation error: {field} - {message}")]
    Validation { field: String, message: String },

    #[error("Email already exists: {0}")]
    EmailExists(String),

    #[error("Rate limited, retry after {retry_after}s")]
    RateLimited { retry_after: u64 },

    #[error("Service unavailable")]
    ServiceUnavailable,

    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),
}

fn create_user(input: CreateUserInput) -> Result<User, CreateUserError> {
    if input.email.is_empty() {
        return Err(CreateUserError::Validation {
            field: "email".into(),
            message: "required".into(),
        });
    }
    if !input.email.contains('@') {
        return Err(CreateUserError::Validation {
            field: "email".into(),
            message: "invalid format".into(),
        });
    }
    if email_exists(&input.email).await? {
        return Err(CreateUserError::EmailExists(input.email));
    }
    // ...
    Ok(user)
}

// Caller can take specific action per error type
match create_user(input).await {
    Ok(user) => handle_success(user),
    Err(CreateUserError::Validation { field, message }) => {
        show_field_error(&field, &message);
    }
    Err(CreateUserError::EmailExists(email)) => {
        offer_password_reset(&email);
    }
    Err(CreateUserError::RateLimited { retry_after }) => {
        show_retry_message(retry_after);
    }
    Err(CreateUserError::ServiceUnavailable) => {
        show_maintenance_message();
    }
    Err(CreateUserError::Database(e)) => {
        log::error!("Database error: {}", e);
        show_generic_error();
    }
}
```

### ✅ Do: Layer errors appropriately

```rust
// Low-level repository errors
#[derive(Error, Debug)]
enum RepositoryError {
    #[error("Not found: {0}")]
    NotFound(String),

    #[error("Conflict: {0}")]
    Conflict(String),

    #[error("Connection error: {0}")]
    Connection(#[from] sqlx::Error),
}

// High-level service errors (what callers care about)
#[derive(Error, Debug)]
enum UserServiceError {
    #[error("User not found: {0}")]
    UserNotFound(UserId),

    #[error("Email already registered: {0}")]
    EmailTaken(String),

    #[error("Invalid input: {0}")]
    InvalidInput(String),

    #[error("Service temporarily unavailable")]
    Unavailable,
}

impl UserService {
    async fn create(&self, input: CreateUserInput) -> Result<User, UserServiceError> {
        // Translate low-level errors to domain errors
        match self.repo.insert(user).await {
            Ok(user) => Ok(user),
            Err(RepositoryError::Conflict(msg)) => {
                Err(UserServiceError::EmailTaken(input.email))
            }
            Err(RepositoryError::Connection(_)) => {
                Err(UserServiceError::Unavailable)
            }
            Err(e) => {
                log::error!("Unexpected repository error: {}", e);
                Err(UserServiceError::Unavailable)
            }
        }
    }
}
```

### ✅ Do: Include actionable context

```rust
#[derive(Error, Debug)]
enum PaymentError {
    #[error("Insufficient funds: need {required}, have {available}")]
    InsufficientFunds {
        required: Money,
        available: Money,
    },

    #[error("Card declined: {reason}")]
    CardDeclined {
        reason: String,
        #[source]
        provider_error: Option<ProviderError>,
    },

    #[error("Payment requires authentication")]
    AuthenticationRequired {
        redirect_url: String,
    },

    #[error("Currency not supported: {currency}")]
    UnsupportedCurrency {
        currency: String,
        supported: Vec<String>,
    },
}

// Caller can take informed action
match process_payment(order).await {
    Err(PaymentError::InsufficientFunds { required, available }) => {
        let shortfall = required - available;
        prompt_add_funds(shortfall);
    }
    Err(PaymentError::AuthenticationRequired { redirect_url }) => {
        redirect_to_3ds(&redirect_url);
    }
    Err(PaymentError::UnsupportedCurrency { currency, supported }) => {
        offer_currency_conversion(&currency, &supported);
    }
    // ...
}
```

## When to Apply

Look for these patterns that indicate errors aren't actionable:

- `throw new Error("...")` with string messages
- `anyhow!()` used throughout application code (fine for CLI tools, not for libraries)
- String matching on error messages
- Generic catch blocks that can't distinguish error types
- Callers that log and ignore because they can't identify the error
- Error messages designed for humans but not for code

## Guidelines

1. **Domain errors for business logic** — Use typed errors for expected failure modes
2. **anyhow/generic for unexpected errors** — Infrastructure failures can use generic errors
3. **Include context for action** — If retry is possible, include `retry_after`. If redirect needed, include URL
4. **Layer appropriately** — Repository errors shouldn't leak to HTTP handlers; translate at boundaries
5. **Exhaustive matching** — Discriminated unions/enums force handling of all cases
