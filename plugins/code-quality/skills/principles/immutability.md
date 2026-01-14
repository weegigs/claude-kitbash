---
name: immutability
description: Const/readonly by default.
---

# Prefer Immutability

Default to `const` and readonly. Mutate only when there's a clear performance or API requirement.

## TypeScript

### ❌ Don't: Mutate objects and arrays in place

```typescript
function addItem(cart: Cart, item: Item): void {
  cart.items.push(item); // Mutates original cart
  cart.total += item.price;
}

function applyDiscount(cart: Cart, discount: number): void {
  cart.total *= (1 - discount); // More mutation
}

// Caller's data is modified unexpectedly
const myCart = { items: [], total: 0 };
addItem(myCart, item1);
addItem(myCart, item2);
applyDiscount(myCart, 0.1);
// myCart has been mutated 3 times - hard to track state

// Array mutation surprises
function removeInactive(users: User[]): User[] {
  for (let i = users.length - 1; i >= 0; i--) {
    if (!users[i].active) {
      users.splice(i, 1); // Mutates original array!
    }
  }
  return users;
}
```

### ✅ Do: Return new objects

```typescript
function addItem(cart: Cart, item: Item): Cart {
  return {
    ...cart,
    items: [...cart.items, item],
    total: cart.total + item.price,
  };
}

function applyDiscount(cart: Cart, discount: number): Cart {
  return {
    ...cart,
    total: cart.total * (1 - discount),
  };
}

// Clear data flow - each step produces new state
const cart1 = { items: [], total: 0 };
const cart2 = addItem(cart1, item1);
const cart3 = addItem(cart2, item2);
const cart4 = applyDiscount(cart3, 0.1);
// cart1 through cart4 all exist and are unchanged

// Immutable array operations
function removeInactive(users: readonly User[]): User[] {
  return users.filter(user => user.active);
}
```

### ✅ Do: Use readonly types

```typescript
// Readonly properties
interface Config {
  readonly apiUrl: string;
  readonly timeout: number;
  readonly retries: number;
}

// Readonly arrays
function processItems(items: readonly Item[]): number {
  // items.push(x); // Compile error!
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Deep readonly
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K];
};

function freezeConfig(config: Config): DeepReadonly<Config> {
  return Object.freeze(config);
}
```

## Rust

### ❌ Don't: Unnecessary mutable references

```rust
fn add_item(cart: &mut Cart, item: Item) {
    cart.items.push(item);
    cart.total += item.price;
}

fn apply_discount(cart: &mut Cart, discount: f64) {
    cart.total *= 1.0 - discount;
}

// Mutation through mutable references
let mut cart = Cart::new();
add_item(&mut cart, item1);
add_item(&mut cart, item2);
apply_discount(&mut cart, 0.1);
// cart has been mutated - state changes are implicit

// Mutation hiding in loops
fn sum_and_clear(values: &mut Vec<i32>) -> i32 {
    let sum = values.iter().sum();
    values.clear(); // Surprise side effect!
    sum
}
```

### ✅ Do: Return new values

```rust
fn add_item(cart: Cart, item: Item) -> Cart {
    Cart {
        items: cart.items.into_iter().chain(std::iter::once(item)).collect(),
        total: cart.total + item.price,
    }
}

fn apply_discount(cart: Cart, discount: f64) -> Cart {
    Cart {
        total: cart.total * (1.0 - discount),
        ..cart
    }
}

// Clear data flow with ownership
let cart = Cart::new();
let cart = add_item(cart, item1);
let cart = add_item(cart, item2);
let cart = apply_discount(cart, 0.1);

// No hidden mutation
fn sum(values: &[i32]) -> i32 {
    values.iter().sum()
}
```

### ✅ Do: Use owned types for transforms

```rust
// Transform with ownership - clear data flow
fn process_users(users: Vec<User>) -> Vec<ProcessedUser> {
    users.into_iter()
        .filter(|u| u.active)
        .map(|u| ProcessedUser::from(u))
        .collect()
}

// Builder pattern for complex construction
struct ConfigBuilder {
    api_url: Option<String>,
    timeout: Option<Duration>,
}

impl ConfigBuilder {
    fn new() -> Self {
        Self { api_url: None, timeout: None }
    }

    fn api_url(mut self, url: String) -> Self {
        self.api_url = Some(url);
        self // Returns self for chaining
    }

    fn timeout(mut self, timeout: Duration) -> Self {
        self.timeout = Some(timeout);
        self
    }

    fn build(self) -> Result<Config, ConfigError> {
        Ok(Config {
            api_url: self.api_url.ok_or(ConfigError::MissingApiUrl)?,
            timeout: self.timeout.unwrap_or(Duration::from_secs(30)),
        })
    }
}
```

## When to Apply

Look for these patterns that indicate problematic mutation:

- Functions with `void` return that modify parameters
- `&mut` references where `&` would suffice
- In-place array/object modifications
- Shared mutable state between functions
- "Spooky action at a distance" bugs
- Difficulty reasoning about state at any point in time
