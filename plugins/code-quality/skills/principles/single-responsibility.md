---
name: single-responsibility
description: One reason to change per unit.
---

# Single Responsibility Principle

Each unit (function, class, module) should have exactly one reason to change. Separate fetch, transform, and render concerns.

## TypeScript

### ❌ Don't: Mix fetching, transforming, and rendering

```typescript
function UserCard({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => {
        setUser(data);
        setLoading(false);
      });
  }, [userId]);

  if (loading) return <Spinner />;
  if (!user) return <NotFound />;

  // Transformation mixed with rendering
  const fullName = `${user.firstName} ${user.lastName}`;
  const initials = user.firstName[0] + user.lastName[0];
  const memberSince = new Date(user.createdAt).toLocaleDateString();

  return (
    <div className="card">
      <Avatar initials={initials} />
      <h2>{fullName}</h2>
      <p>Member since {memberSince}</p>
    </div>
  );
}
```

### ✅ Do: Separate data fetching, transformation, and presentation

```typescript
// Data fetching: one reason to change (API changes)
function useUser(userId: string) {
  const [state, setState] = useState<UserState>({ status: "loading" });

  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => setState({ status: "success", data }))
      .catch(error => setState({ status: "error", error }));
  }, [userId]);

  return state;
}

// Transformation: one reason to change (display format changes)
function formatUserDisplay(user: User) {
  return {
    fullName: `${user.firstName} ${user.lastName}`,
    initials: user.firstName[0] + user.lastName[0],
    memberSince: new Date(user.createdAt).toLocaleDateString(),
  };
}

// Presentation: one reason to change (UI changes)
function UserCard({ userId }: { userId: string }) {
  const state = useUser(userId);

  if (state.status === "loading") return <Spinner />;
  if (state.status === "error") return <Error error={state.error} />;

  const display = formatUserDisplay(state.data);

  return (
    <div className="card">
      <Avatar initials={display.initials} />
      <h2>{display.fullName}</h2>
      <p>Member since {display.memberSince}</p>
    </div>
  );
}
```

## Rust

### ❌ Don't: Mix parsing, validation, and business logic

```rust
fn process_order(input: &str) -> Result<String> {
    // Parsing
    let parts: Vec<&str> = input.split(',').collect();
    if parts.len() != 3 {
        return Err(anyhow!("Invalid format"));
    }

    let product_id = parts[0];
    let quantity: i32 = parts[1].parse()?;
    let price: f64 = parts[2].parse()?;

    // Validation
    if quantity <= 0 {
        return Err(anyhow!("Quantity must be positive"));
    }
    if price < 0.0 {
        return Err(anyhow!("Price cannot be negative"));
    }

    // Business logic
    let subtotal = quantity as f64 * price;
    let tax = subtotal * 0.08;
    let total = subtotal + tax;

    // Formatting
    Ok(format!("Order {}: {} x ${:.2} = ${:.2} (tax: ${:.2})",
        product_id, quantity, price, total, tax))
}
```

### ✅ Do: Separate parsing, domain logic, and formatting

```rust
// Parsing: one reason to change (input format changes)
struct OrderInput {
    product_id: String,
    quantity: u32,
    price: f64,
}

fn parse_order(input: &str) -> Result<OrderInput> {
    let parts: Vec<&str> = input.split(',').collect();
    if parts.len() != 3 {
        return Err(anyhow!("Expected format: product_id,quantity,price"));
    }

    Ok(OrderInput {
        product_id: parts[0].to_string(),
        quantity: parts[1].parse()?,
        price: parts[2].parse()?,
    })
}

// Domain logic: one reason to change (business rules change)
struct OrderResult {
    product_id: String,
    quantity: u32,
    price: f64,
    subtotal: f64,
    tax: f64,
    total: f64,
}

fn calculate_order(input: OrderInput) -> OrderResult {
    let subtotal = input.quantity as f64 * input.price;
    let tax = subtotal * 0.08;

    OrderResult {
        product_id: input.product_id,
        quantity: input.quantity,
        price: input.price,
        subtotal,
        tax,
        total: subtotal + tax,
    }
}

// Formatting: one reason to change (output format changes)
fn format_order(result: &OrderResult) -> String {
    format!(
        "Order {}: {} x ${:.2} = ${:.2} (tax: ${:.2})",
        result.product_id, result.quantity, result.price, result.total, result.tax
    )
}

// Composition
fn process_order(input: &str) -> Result<String> {
    let parsed = parse_order(input)?;
    let result = calculate_order(parsed);
    Ok(format_order(&result))
}
```

## When to Apply

Look for these patterns that violate single responsibility:

- Functions doing fetch + transform + render
- Classes with unrelated methods
- Modules mixing I/O, business logic, and formatting
- Functions longer than ~20 lines (often doing multiple things)
- Multiple levels of abstraction in one function
