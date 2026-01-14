---
name: happy-path
description: Left-hand side is the happy path (Go style early returns).
---

# Left-Hand Side is the Happy Path

Keep the main execution path at the left margin by using early returns for error cases. This Go-style pattern reduces nesting and makes code easier to read.

## TypeScript

### ❌ Don't: Deep nesting with else branches

```typescript
function processOrder(order: Order | null): Result {
  if (order) {
    if (order.items.length > 0) {
      if (order.status === "pending") {
        if (order.total > 0) {
          // Finally, the actual logic buried 4 levels deep
          const tax = calculateTax(order.total);
          const shipping = calculateShipping(order.items);
          return {
            success: true,
            total: order.total + tax + shipping,
          };
        } else {
          return { success: false, error: "Order total must be positive" };
        }
      } else {
        return { success: false, error: "Order must be pending" };
      }
    } else {
      return { success: false, error: "Order must have items" };
    }
  } else {
    return { success: false, error: "Order is required" };
  }
}
```

### ✅ Do: Early returns keep happy path left-aligned

```typescript
function processOrder(order: Order | null): Result {
  // Guard clauses - handle errors first, return early
  if (!order) {
    return { success: false, error: "Order is required" };
  }
  if (order.items.length === 0) {
    return { success: false, error: "Order must have items" };
  }
  if (order.status !== "pending") {
    return { success: false, error: "Order must be pending" };
  }
  if (order.total <= 0) {
    return { success: false, error: "Order total must be positive" };
  }

  // Happy path at the left margin - clear and readable
  const tax = calculateTax(order.total);
  const shipping = calculateShipping(order.items);
  return {
    success: true,
    total: order.total + tax + shipping,
  };
}
```

### ✅ Do: Chain validations clearly

```typescript
function createUser(input: CreateUserInput): User {
  // Each guard clause is one line of validation
  if (!input.email) throw new ValidationError("Email required");
  if (!input.email.includes("@")) throw new ValidationError("Invalid email");
  if (!input.name) throw new ValidationError("Name required");
  if (input.name.length < 2) throw new ValidationError("Name too short");
  if (input.age !== undefined && input.age < 0) throw new ValidationError("Invalid age");

  // Happy path: all validation passed
  return {
    id: generateId(),
    email: input.email.toLowerCase(),
    name: input.name.trim(),
    age: input.age,
    createdAt: new Date(),
  };
}
```

## Rust

### ❌ Don't: Nested match expressions

```rust
fn process_order(order: Option<Order>) -> Result<OrderResult, OrderError> {
    match order {
        Some(o) => {
            if !o.items.is_empty() {
                match o.status {
                    Status::Pending => {
                        if o.total > 0.0 {
                            // Happy path buried deep
                            let tax = calculate_tax(o.total);
                            let shipping = calculate_shipping(&o.items);
                            Ok(OrderResult {
                                total: o.total + tax + shipping,
                            })
                        } else {
                            Err(OrderError::InvalidTotal)
                        }
                    }
                    _ => Err(OrderError::InvalidStatus),
                }
            } else {
                Err(OrderError::NoItems)
            }
        }
        None => Err(OrderError::MissingOrder),
    }
}
```

### ✅ Do: Early returns with ? operator

```rust
fn process_order(order: Option<Order>) -> Result<OrderResult, OrderError> {
    // Guard clauses with early returns
    let order = order.ok_or(OrderError::MissingOrder)?;

    if order.items.is_empty() {
        return Err(OrderError::NoItems);
    }
    if order.status != Status::Pending {
        return Err(OrderError::InvalidStatus);
    }
    if order.total <= 0.0 {
        return Err(OrderError::InvalidTotal);
    }

    // Happy path at the left margin
    let tax = calculate_tax(order.total);
    let shipping = calculate_shipping(&order.items);

    Ok(OrderResult {
        total: order.total + tax + shipping,
    })
}
```

### ✅ Do: Use let-else for cleaner guards

```rust
fn process_order(order: Option<Order>) -> Result<OrderResult, OrderError> {
    // let-else pattern for Option/Result unwrapping
    let Some(order) = order else {
        return Err(OrderError::MissingOrder);
    };

    let Status::Pending = order.status else {
        return Err(OrderError::InvalidStatus);
    };

    if order.items.is_empty() {
        return Err(OrderError::NoItems);
    }
    if order.total <= 0.0 {
        return Err(OrderError::InvalidTotal);
    }

    // Happy path
    let tax = calculate_tax(order.total);
    let shipping = calculate_shipping(&order.items);

    Ok(OrderResult {
        total: order.total + tax + shipping,
    })
}
```

### ✅ Do: Extract validation functions

```rust
impl Order {
    fn validate(&self) -> Result<(), OrderError> {
        if self.items.is_empty() {
            return Err(OrderError::NoItems);
        }
        if self.status != Status::Pending {
            return Err(OrderError::InvalidStatus);
        }
        if self.total <= 0.0 {
            return Err(OrderError::InvalidTotal);
        }
        Ok(())
    }
}

fn process_order(order: Option<Order>) -> Result<OrderResult, OrderError> {
    let order = order.ok_or(OrderError::MissingOrder)?;
    order.validate()?;

    // All validation in one place, happy path clean
    let tax = calculate_tax(order.total);
    let shipping = calculate_shipping(&order.items);

    Ok(OrderResult {
        total: order.total + tax + shipping,
    })
}
```

### ✅ Do: Replace nested ifs with iterator chains

```rust
// ❌ Don't: Nested conditionals in loops
fn get_active_premium_emails(users: &[User]) -> Vec<String> {
    let mut result = Vec::new();
    for user in users {
        if user.active {
            if user.subscription == Subscription::Premium {
                if let Some(email) = &user.email {
                    if email.contains("@") {
                        result.push(email.clone());
                    }
                }
            }
        }
    }
    result
}

// ✅ Do: Flat iterator chain
fn get_active_premium_emails(users: &[User]) -> Vec<String> {
    users.iter()
        .filter(|u| u.active)
        .filter(|u| u.subscription == Subscription::Premium)
        .filter_map(|u| u.email.as_ref())
        .filter(|email| email.contains("@"))
        .cloned()
        .collect()
}

// ❌ Don't: Nested options with if-let chains
fn get_user_city(response: &ApiResponse) -> Option<String> {
    if let Some(data) = &response.data {
        if let Some(user) = &data.user {
            if let Some(address) = &user.address {
                if let Some(city) = &address.city {
                    return Some(city.clone());
                }
            }
        }
    }
    None
}

// ✅ Do: Flat Option chain
fn get_user_city(response: &ApiResponse) -> Option<String> {
    response.data.as_ref()
        .and_then(|d| d.user.as_ref())
        .and_then(|u| u.address.as_ref())
        .and_then(|a| a.city.clone())
}

// ❌ Don't: Nested Result handling
fn process_config(path: &Path) -> Result<Config, Error> {
    match std::fs::read_to_string(path) {
        Ok(content) => {
            match serde_json::from_str::<RawConfig>(&content) {
                Ok(raw) => {
                    match raw.validate() {
                        Ok(()) => Ok(Config::from(raw)),
                        Err(e) => Err(Error::Validation(e)),
                    }
                }
                Err(e) => Err(Error::Parse(e)),
            }
        }
        Err(e) => Err(Error::Read(e)),
    }
}

// ✅ Do: Flat Result chain with ?
fn process_config(path: &Path) -> Result<Config, Error> {
    let content = std::fs::read_to_string(path).map_err(Error::Read)?;
    let raw: RawConfig = serde_json::from_str(&content).map_err(Error::Parse)?;
    raw.validate().map_err(Error::Validation)?;
    Ok(Config::from(raw))
}
```

## Why This Matters

- **Readability**: The main logic stands out at the left margin
- **Cognitive load**: Errors handled and dismissed early; reader can focus on success path
- **Maintenance**: Adding new validation is one line, not restructuring nested blocks
- **Debugging**: Error conditions are explicit and easy to find
- **Go idiom**: This pattern is standard in Go and produces clean, scannable code

## When to Apply

Look for these patterns that violate happy-path-left:

- More than 2 levels of nesting for conditionals
- `else` branches that are longer than the `if` block
- The main logic buried inside multiple conditions
- Difficulty finding "what this function actually does"
- Functions that require horizontal scrolling
