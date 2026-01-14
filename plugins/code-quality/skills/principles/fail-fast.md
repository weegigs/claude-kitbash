---
name: fail-fast
description: Surface errors immediately with context.
---

# Fail Fast and Loudly

Surface errors immediately at the point of failure rather than silently propagating invalid state.

## TypeScript

### ❌ Don't: Silent failures that propagate

```typescript
function getUser(id: string): User | undefined {
  const user = users.get(id);
  return user; // Caller might not check, NPE later
}

function processUser(id: string): void {
  const user = getUser(id);
  // 10 lines later...
  console.log(user.name); // TypeError: Cannot read property 'name' of undefined
  // Stack trace points here, but the bug is the missing user lookup
}

// Swallowed exceptions
async function fetchData(): Promise<Data | null> {
  try {
    const response = await fetch("/api/data");
    return await response.json();
  } catch (error) {
    console.error(error); // Logged but caller doesn't know
    return null; // Silent failure
  }
}
```

### ✅ Do: Fail immediately with context

```typescript
function getUser(id: string): User {
  const user = users.get(id);
  if (!user) {
    throw new Error(`User not found: ${id}`);
  }
  return user;
}

function processUser(id: string): void {
  const user = getUser(id); // Fails here with clear message
  console.log(user.name); // Type-safe: user is definitely User
}

// Propagate errors with context
async function fetchData(): Promise<Data> {
  const response = await fetch("/api/data");
  if (!response.ok) {
    throw new Error(`API error: ${response.status} ${response.statusText}`);
  }
  return await response.json();
}

// Or use Result type for expected failures
type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };

function parseConfig(input: string): Result<Config, string> {
  try {
    const parsed = JSON.parse(input);
    if (!isValidConfig(parsed)) {
      return { ok: false, error: "Invalid config structure" };
    }
    return { ok: true, value: parsed };
  } catch (e) {
    return { ok: false, error: `JSON parse error: ${e.message}` };
  }
}
```

### ✅ Do: Validate at boundaries

```typescript
// Validate inputs at function entry
function processOrder(order: unknown): OrderResult {
  // Fail fast at the boundary
  if (!isValidOrder(order)) {
    throw new ValidationError("Invalid order", { received: order });
  }

  // After validation, types are guaranteed
  const validOrder = order as Order;
  return calculateTotal(validOrder);
}

// Assert invariants
function withdraw(account: Account, amount: number): Account {
  if (amount <= 0) {
    throw new Error(`Invalid withdrawal amount: ${amount}`);
  }
  if (amount > account.balance) {
    throw new Error(`Insufficient funds: ${amount} > ${account.balance}`);
  }

  return { ...account, balance: account.balance - amount };
}
```

## Rust

### ❌ Don't: Silent Option returns

```rust
fn get_user(id: &str) -> Option<User> {
    users.get(id).cloned() // Caller might unwrap without checking
}

fn process_user(id: &str) {
    let user = get_user(id);
    // 10 lines later...
    println!("{}", user.unwrap().name); // Panic with no context
}

// Swallowed errors
fn read_config() -> Config {
    match std::fs::read_to_string("config.toml") {
        Ok(content) => toml::from_str(&content).unwrap_or_default(),
        Err(_) => Config::default(), // Silent fallback hides problems
    }
}
```

### ✅ Do: Fail with context using Result

```rust
use thiserror::Error;

#[derive(Error, Debug)]
enum UserError {
    #[error("User not found: {0}")]
    NotFound(String),
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),
}

fn get_user(id: &str) -> Result<User, UserError> {
    users.get(id)
        .cloned()
        .ok_or_else(|| UserError::NotFound(id.to_string()))
}

fn process_user(id: &str) -> Result<(), UserError> {
    let user = get_user(id)?; // Propagates with context
    println!("{}", user.name);
    Ok(())
}

// Explicit error handling with context
fn read_config(path: &Path) -> Result<Config, ConfigError> {
    let content = std::fs::read_to_string(path)
        .map_err(|e| ConfigError::ReadFailed { path: path.to_owned(), source: e })?;

    toml::from_str(&content)
        .map_err(|e| ConfigError::ParseFailed { path: path.to_owned(), source: e })
}
```

### ✅ Do: Use expect() with context

```rust
// When you're certain something should exist
fn get_required_env(key: &str) -> String {
    std::env::var(key)
        .expect(&format!("Required environment variable {} not set", key))
}

// Assert invariants
fn withdraw(account: &mut Account, amount: u64) -> Result<(), WithdrawError> {
    if amount == 0 {
        return Err(WithdrawError::ZeroAmount);
    }
    if amount > account.balance {
        return Err(WithdrawError::InsufficientFunds {
            requested: amount,
            available: account.balance,
        });
    }

    account.balance -= amount;
    Ok(())
}
```

## When to Apply

Look for these patterns that indicate silent failures:

- Functions returning `Option`/`undefined` for unexpected failures
- `catch` blocks that log and continue
- Default values hiding configuration errors
- `unwrap()` without context
- Errors surfacing far from their source
- "Why is this null?" debugging sessions
