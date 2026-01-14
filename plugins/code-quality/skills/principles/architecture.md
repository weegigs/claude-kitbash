---
name: architecture
description: Imperative shell, functional core—separate pure logic from I/O.
---

# Imperative Shell, Functional Core

Separate code into two distinct layers:

- **Functional Core**: Pure functions with no side effects—deterministic, easily testable
- **Imperative Shell**: Thin layer handling I/O that coordinates the core

This separation enables effective testing via property-based tests and snapshots.

## TypeScript

### ❌ Don't: Mix I/O with business logic

```typescript
async function processOrder(orderId: string): Promise<void> {
  const order = await db.orders.findById(orderId);
  const user = await db.users.findById(order.userId);

  let discount = 0;
  if (user.membershipLevel === "gold") {
    discount = order.total * 0.1;
  } else if (user.membershipLevel === "silver") {
    discount = order.total * 0.05;
  }

  const finalTotal = order.total - discount;
  await db.orders.update(orderId, { finalTotal, discount });
  await emailService.send(user.email, `Order total: $${finalTotal}`);
}
```

### ✅ Do: Separate pure calculation from I/O orchestration

```typescript
// Functional core: pure, testable
function calculateDiscount(membershipLevel: string, total: number): number {
  switch (membershipLevel) {
    case "gold": return total * 0.1;
    case "silver": return total * 0.05;
    default: return 0;
  }
}

function computeOrderTotal(order: Order, user: User): OrderResult {
  const discount = calculateDiscount(user.membershipLevel, order.total);
  return {
    finalTotal: order.total - discount,
    discount,
  };
}

// Imperative shell: thin I/O coordination
async function processOrder(orderId: string): Promise<void> {
  const order = await db.orders.findById(orderId);
  const user = await db.users.findById(order.userId);

  const result = computeOrderTotal(order, user);

  await db.orders.update(orderId, result);
  await emailService.send(user.email, `Order total: $${result.finalTotal}`);
}
```

## Rust

### ❌ Don't: Mix I/O with business logic

```rust
async fn process_order(order_id: &str, pool: &PgPool) -> Result<()> {
    let order = sqlx::query_as!(Order, "SELECT * FROM orders WHERE id = $1", order_id)
        .fetch_one(pool)
        .await?;

    let user = sqlx::query_as!(User, "SELECT * FROM users WHERE id = $1", order.user_id)
        .fetch_one(pool)
        .await?;

    let discount = match user.membership_level.as_str() {
        "gold" => order.total * 0.1,
        "silver" => order.total * 0.05,
        _ => 0.0,
    };

    let final_total = order.total - discount;

    sqlx::query!("UPDATE orders SET final_total = $1 WHERE id = $2", final_total, order_id)
        .execute(pool)
        .await?;

    send_email(&user.email, &format!("Order total: ${}", final_total)).await?;
    Ok(())
}
```

### ✅ Do: Separate pure calculation from I/O orchestration

```rust
// Functional core: pure, testable
fn calculate_discount(membership_level: &str, total: f64) -> f64 {
    match membership_level {
        "gold" => total * 0.1,
        "silver" => total * 0.05,
        _ => 0.0,
    }
}

struct OrderResult {
    final_total: f64,
    discount: f64,
}

fn compute_order_total(order: &Order, user: &User) -> OrderResult {
    let discount = calculate_discount(&user.membership_level, order.total);
    OrderResult {
        final_total: order.total - discount,
        discount,
    }
}

// Imperative shell: thin I/O coordination
async fn process_order(order_id: &str, pool: &PgPool) -> Result<()> {
    let order = sqlx::query_as!(Order, "SELECT * FROM orders WHERE id = $1", order_id)
        .fetch_one(pool)
        .await?;

    let user = sqlx::query_as!(User, "SELECT * FROM users WHERE id = $1", order.user_id)
        .fetch_one(pool)
        .await?;

    let result = compute_order_total(&order, &user);

    sqlx::query!("UPDATE orders SET final_total = $1 WHERE id = $2", result.final_total, order_id)
        .execute(pool)
        .await?;

    send_email(&user.email, &format!("Order total: ${}", result.final_total)).await?;
    Ok(())
}
```

## Why This Matters

- **Testability**: Pure functions can be tested with property-based testing across thousands of inputs
- **Predictability**: No hidden state means functions always produce the same output for the same input
- **Debuggability**: When something fails, you know it's either in I/O (shell) or logic (core)
- **Reusability**: Pure functions can be reused in different contexts without dragging along I/O dependencies
