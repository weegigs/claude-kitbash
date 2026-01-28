---
name: rust
description: Core Rust idioms - ownership, newtype, error handling, trait patterns, let chains, gen blocks.
---

# Rust Cleaning Patterns

Idiomatic Rust patterns. Clippy-clean, no unwrap in production. Updated for Rust 2024 edition.

## Table of Contents

1. [Architecture](#architecture)
   - [Imperative Shell, Functional Core](#imperative-shell-functional-core)
   - [Make Invalid States Unrepresentable](#make-invalid-states-unrepresentable)
   - [Single Responsibility Principle](#single-responsibility-principle)
2. [Type System](#type-system)
   - [Strong Domain Data Types (Newtype Pattern)](#strong-domain-data-types-newtype-pattern)
   - [Strong Domain Error Types](#strong-domain-error-types)
3. [Control Flow](#control-flow)
   - [Let Chains](#let-chains-rust-180-stable)
   - [Option Combinators: Flatten Nested if-let](#option-combinators-flatten-nested-if-let)
   - [Error Propagation with ?](#error-propagation-with-)
4. [Collections & Iteration](#collections--iteration)
   - [Iterator Patterns](#iterator-patterns)
5. [Memory & Ownership](#memory--ownership)
   - [Ownership and Borrowing](#ownership-and-borrowing)
6. [API Design](#api-design)
   - [Builder Pattern](#builder-pattern)
   - [Trait Design](#trait-design)
   - [Derive Wisely](#derive-wisely)
7. [Quality](#quality)
   - [Clippy Compliance](#clippy-compliance)
8. [Testing](#testing)
   - [Property-Based Testing](#property-based-testing)
   - [Snapshot Testing](#snapshot-testing)

---

## Architecture

### Imperative Shell, Functional Core

**The most important architectural pattern.** Separate your code into two layers:

- **Functional Core**: Pure functions with no side effects. Given the same input, always returns the same output. No I/O, no randomness, no current time, no network calls.
- **Imperative Shell**: Thin layer that handles all I/O and effects—async operations, file access, network calls—then passes clean data to the core.

This separation enables **property-based testing** of your business logic—far more powerful than static unit tests.

```rust
// ❌ Mixed concerns - hard to test, tightly coupled to I/O
async fn process_order(db: &Db, order_id: OrderId) -> Result<OrderResult, Error> {
    let order = db.get_order(&order_id).await?;           // I/O
    let user = db.get_user(&order.user_id).await?;        // I/O
    let discount = if user.is_premium { 0.1 } else { 0.0 }; // Logic
    let total = order.items.iter()                         // Logic
        .map(|i| i.price.cents() as f64 * (1.0 - discount))
        .sum::<f64>();
    db.update_order_total(&order_id, total).await?;       // I/O
    email_service.send_confirmation(&user.email).await?;  // I/O
    Ok(OrderResult { order_id, total })
}

// ✅ Functional Core - pure business logic, easily testable
#[derive(Debug, Clone)]
pub struct OrderData {
    pub items: Vec<Item>,
    pub is_premium_user: bool,
}

#[derive(Debug, Clone, PartialEq)]
pub struct OrderCalculation {
    pub total: Money,
    pub discount: Percentage,
    pub discount_applied: bool,
}

/// Pure function - no I/O, no async, easily testable
pub fn calculate_order(data: &OrderData) -> OrderCalculation {
    let discount = if data.is_premium_user {
        Percentage::new(10)
    } else {
        Percentage::new(0)
    };

    let total = data.items.iter()
        .map(|item| item.price.apply_discount(discount))
        .fold(Money::zero(), |acc, price| acc + price);

    OrderCalculation {
        total,
        discount,
        discount_applied: discount.value() > 0,
    }
}

// ✅ Imperative Shell - coordinates I/O, calls the core
async fn process_order(
    db: &Db,
    email: &EmailService,
    order_id: OrderId,
) -> Result<OrderResult, ProcessError> {
    // Gather data (I/O)
    let order = db.get_order(&order_id).await?;
    let user = db.get_user(&order.user_id).await?;

    // Pure calculation (no I/O)
    let calculation = calculate_order(&OrderData {
        items: order.items,
        is_premium_user: user.is_premium,
    });

    // Apply effects (I/O)
    db.update_order_total(&order_id, calculation.total).await?;
    email.send_confirmation(&user.email).await?;

    Ok(OrderResult {
        order_id,
        total: calculation.total,
        discount_applied: calculation.discount_applied,
    })
}
```

**Benefits**:
- The functional core can be tested with thousands of generated inputs (property-based testing via `proptest`)
- No mocks needed for the core—it's just data in, data out
- The shell is thin and can be tested with a few integration tests
- Async complexity stays in the shell; the core is sync and simple

**Apply when you see**: `async fn` mixing business logic with `.await` calls, functions that require mocking to test.

### Make Invalid States Unrepresentable

Use enums and the type system to make illegal states impossible to construct.

```rust
// ❌ Struct with invalid state combinations
struct Connection {
    is_connected: bool,
    socket: Option<TcpStream>,  // Should exist iff is_connected
    error: Option<Error>,       // Should exist iff !is_connected && failed
}

// ✅ Enum makes each state explicit
enum Connection {
    Disconnected,
    Connecting,
    Connected { socket: TcpStream },
    Failed { error: Error },
}

// ❌ Optional fields that depend on each other
struct Order {
    status: String,  // "pending", "shipped", "delivered"
    tracking_number: Option<String>,  // Required if shipped
    delivered_at: Option<DateTime>,   // Required if delivered
}

// ✅ Model the state machine in the type
enum OrderStatus {
    Pending,
    Shipped { tracking_number: TrackingNumber },
    Delivered { tracking_number: TrackingNumber, delivered_at: DateTime },
}

struct Order {
    id: OrderId,
    status: OrderStatus,
}
```

**Apply when you see**: boolean flags, `Option` fields that are conditionally required, string-typed status fields.

### Single Responsibility Principle

Each function, struct, and module should have exactly one reason to change.

```rust
// ❌ Function does too many things
async fn process_order(order_id: OrderId) -> Result<()> {
    let order = db.get_order(order_id).await?;
    if order.items.is_empty() {
        return Err(Error::EmptyOrder);
    }
    let total = order.items.iter().map(|i| i.price).sum();
    db.update_order_total(order_id, total).await?;
    email_service.send_confirmation(&order).await?;
    Ok(())
}

// ✅ Separate concerns
fn validate_order(order: &Order) -> Result<(), OrderError> {
    if order.items.is_empty() {
        return Err(OrderError::Empty);
    }
    Ok(())
}

fn calculate_total(items: &[Item]) -> Money {
    items.iter().map(|i| i.price).sum()
}

async fn process_order(order_id: OrderId) -> Result<(), ProcessError> {
    let order = db.get_order(order_id).await?;
    validate_order(&order)?;
    let total = calculate_total(&order.items);
    db.update_order_total(order_id, total).await?;
    email_service.send_confirmation(&order).await?;
    Ok(())
}
```

**Apply when you see**: functions with multiple `await` points doing unrelated work, structs mixing data with behavior.

---

## Type System

### Strong Domain Data Types (Newtype Pattern)

Wrap primitives in newtypes to prevent mixing up domain concepts.

```rust
// ❌ All IDs are interchangeable strings
fn get_user(id: String) -> User { }
fn get_order(id: String) -> Order { }
get_user(order_id);  // Compiles but wrong!

// ✅ Newtype wrappers prevent mixups at compile time
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct UserId(String);

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct OrderId(String);

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub struct Money(i64);  // Cents

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Email(String);

impl UserId {
    pub fn new(id: impl Into<String>) -> Result<Self, IdError> {
        let id = id.into();
        if !id.starts_with("usr_") {
            return Err(IdError::InvalidFormat);
        }
        Ok(Self(id))
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl Email {
    pub fn parse(input: &str) -> Result<Self, EmailError> {
        // Validate email format
        if !input.contains('@') {
            return Err(EmailError::MissingAt);
        }
        Ok(Self(input.to_lowercase()))
    }
}

impl Money {
    pub const fn from_cents(cents: i64) -> Self {
        Self(cents)
    }

    pub fn from_dollars(dollars: f64) -> Self {
        Self((dollars * 100.0).round() as i64)
    }

    pub const fn cents(&self) -> i64 {
        self.0
    }
}

// Now the compiler catches the bug
fn get_user(id: &UserId) -> User { }
fn get_order(id: &OrderId) -> Order { }

get_user(&order_id);  // ✅ Compile error!

// Other domain types
pub struct Latitude(f64);   // -90 to 90
pub struct Longitude(f64);  // -180 to 180
pub struct Percentage(u8);  // 0 to 100
pub struct Timestamp(i64);  // Unix epoch millis
```

**Apply when you see**: functions taking multiple String/i64 parameters, IDs passed as plain strings, domain concepts as primitives.

### Strong Domain Error Types

Use domain-specific error enums that callers can match on exhaustively.

```rust
// ❌ Generic error - caller can't distinguish cases
fn create_user(email: &str) -> Result<User, Box<dyn Error>> {
    Err("Something went wrong".into())
}

// ✅ Domain-specific error types
#[derive(Debug, thiserror::Error)]
pub enum CreateUserError {
    #[error("Invalid email format: {email}")]
    InvalidEmail { email: String },

    #[error("Email already registered")]
    DuplicateEmail { existing_user_id: UserId },

    #[error("Rate limited, retry after {retry_after:?}")]
    RateLimited { retry_after: Duration },

    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),
}

fn create_user(email: &str) -> Result<User, CreateUserError> {
    let email = Email::parse(email)
        .map_err(|_| CreateUserError::InvalidEmail { email: email.to_string() })?;

    if let Some(existing) = db.find_by_email(&email)? {
        return Err(CreateUserError::DuplicateEmail {
            existing_user_id: existing.id,
        });
    }

    Ok(db.insert_user(email)?)
}

// Caller can handle each case specifically
match create_user(input) {
    Ok(user) => println!("Created: {:?}", user),
    Err(CreateUserError::InvalidEmail { email }) => {
        eprintln!("Bad email: {}", email);
    }
    Err(CreateUserError::DuplicateEmail { existing_user_id }) => {
        eprintln!("Already exists: {:?}", existing_user_id);
    }
    Err(CreateUserError::RateLimited { retry_after }) => {
        eprintln!("Try again in {:?}", retry_after);
    }
    Err(CreateUserError::Database(e)) => {
        eprintln!("DB error: {}", e);
    }
}

// Group errors by domain
#[derive(Debug, thiserror::Error)]
pub enum AuthError {
    #[error("Invalid credentials")]
    InvalidCredentials,

    #[error("Account locked until {until}")]
    AccountLocked { until: DateTime<Utc> },

    #[error("MFA required")]
    MfaRequired { challenge: MfaChallenge },
}

#[derive(Debug, thiserror::Error)]
pub enum PaymentError {
    #[error("Insufficient funds: need {required}, have {available}")]
    InsufficientFunds { required: Money, available: Money },

    #[error("Card declined: {reason}")]
    CardDeclined { reason: String },

    #[error("Fraud detected")]
    FraudDetected,
}
```

**Apply when you see**: `Box<dyn Error>`, string error messages, error handling that parses messages.

---

## Control Flow

### Let Chains (Rust 1.80+ - STABLE)

Combine multiple conditions without deep nesting.

```rust
// ✅ NEW: Let chains - clean and readable
fn process_user(maybe_user: Option<User>) -> Result<String, Error> {
    if let Some(user) = maybe_user
        && user.is_active()
        && let Ok(token) = user.generate_token()
    {
        Ok(format!("Token: {}", token))
    } else {
        Err(Error::InvalidUser)
    }
}

// ✅ NEW: Let-else for early returns
fn extract_name(user: &User) -> String {
    let Some(ref name) = user.name else {
        return "Anonymous".to_string();
    };

    let Some(first) = name.split_whitespace().next() else {
        return name.clone();
    };

    first.to_string()
}

// ❌ LEGACY: Nested if-let
fn process_user_legacy(maybe_user: Option<User>) -> Result<String, Error> {
    if let Some(user) = maybe_user {
        if user.is_active() {
            if let Ok(token) = user.generate_token() {
                return Ok(format!("Token: {}", token));
            }
        }
    }
    Err(Error::InvalidUser)
}
```

### Option Combinators: Flatten Nested if-let

Use `and_then` and `?` in closures to avoid the "Pyramid of Doom" when chaining Option operations.

```rust
// ❌ BAD: "Pyramid of Doom" - deep nesting obscures the logic
if let Some(desc) = &upgrade.description {
    if let Some(start) = desc.find('(') {
        if let Some(end) = desc.rfind(')') {
            if start < end {
                let rule = desc[start + 1..end].to_string();
                *counts.entry(rule).or_insert(0) += 1;
            }
        }
    }
}

// ✅ GOOD: Flat structure with combinators
let rule = upgrade.description.as_ref().and_then(|desc| {
    let start = desc.find('(')?;
    let end = desc.rfind(')')?;
    (start < end).then(|| desc[start + 1..end].to_string())
});
if let Some(rule) = rule {
    *counts.entry(rule).or_insert(0) += 1;
}
```

**Why the combinator version is better**:
- Flat structure—logic flows linearly instead of rightward
- `?` operator handles `None` cases implicitly inside the closure
- `bool.then(|| value)` converts a condition to `Option`
- Computation separated from action (extract rule, then use it)

**Key techniques**:

| Technique | Purpose | Example |
|-----------|---------|---------|
| `and_then` | Chain operations returning `Option` | `opt.and_then(\|x\| x.parse().ok())` |
| `?` in closures | Early return `None` if any step fails | `\|x\| { let y = x.get()?; Some(y) }` |
| `bool.then(\|\| v)` | Convert condition to `Option` | `(x > 0).then(\|\| x * 2)` |
| `bool.then_some(v)` | Same, but value is eagerly evaluated | `valid.then_some(result)` |

**When to refactor**: 3+ nested `if let Some(...)` or nested conditions with `if x { if y { if z { ... } } }` where the actual operation is buried 4+ indentation levels deep.

**Contrast with let chains**: Let chains (`if let X && let Y && condition { ... }`) are better when you need branching logic with an else clause. Combinators are better when you're extracting/transforming a value through a pipeline.

### Error Propagation with ?

```rust
// ❌ Verbose match chains
fn read_config(path: &Path) -> Result<Config, Error> {
    let content = match std::fs::read_to_string(path) {
        Ok(c) => c,
        Err(e) => return Err(e.into()),
    };
    let config = match toml::from_str(&content) {
        Ok(c) => c,
        Err(e) => return Err(e.into()),
    };
    Ok(config)
}

// ✅ Clean with ?
fn read_config(path: &Path) -> Result<Config, Error> {
    let content = std::fs::read_to_string(path)?;
    let config = toml::from_str(&content)?;
    Ok(config)
}
```

---

## Collections & Iteration

### Iterator Patterns

Lazy composition compiles to efficient loops.

```rust
// ✅ Iterator chains - lazy, single pass, zero-cost
let result: Vec<_> = users
    .iter()
    .filter(|u| u.is_active())
    .map(|u| u.email.clone())
    .take(10)
    .collect();

// ✅ filter_map for Option-returning transforms
let valid_ids: Vec<UserId> = inputs
    .iter()
    .filter_map(|s| UserId::new(s).ok())
    .collect();

// ✅ flat_map for nested iteration
let all_tags: Vec<&str> = posts
    .iter()
    .flat_map(|post| post.tags.iter().map(|t| t.as_str()))
    .collect();

// ✅ fold for complex accumulation
let stats = events.iter().fold(Stats::default(), |mut acc, event| {
    acc.count += 1;
    acc.total += event.value;
    acc
});

// ✅ partition for splitting
let (active, inactive): (Vec<_>, Vec<_>) = users
    .into_iter()
    .partition(|u| u.is_active());
```

---

## Memory & Ownership

### Ownership and Borrowing

```rust
// ❌ Unnecessary clone
fn process(data: Vec<String>) {
    let copy = data.clone();
    for item in copy { }
}

// ✅ Borrow when you don't need ownership
fn process(data: &[String]) {
    for item in data { }
}

// ❌ Taking ownership unnecessarily
fn format_name(name: String) -> String {
    format!("Hello, {name}")
}

// ✅ Borrow the input
fn format_name(name: &str) -> String {
    format!("Hello, {name}")
}
```

---

## API Design

### Builder Pattern

For structs with many optional fields.

```rust
#[derive(Default)]
pub struct RequestBuilder {
    url: Option<String>,
    timeout: Duration,
    headers: Vec<(String, String)>,
}

impl RequestBuilder {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn url(mut self, url: impl Into<String>) -> Self {
        self.url = Some(url.into());
        self
    }

    pub fn timeout(mut self, timeout: Duration) -> Self {
        self.timeout = timeout;
        self
    }

    pub fn header(mut self, key: impl Into<String>, value: impl Into<String>) -> Self {
        self.headers.push((key.into(), value.into()));
        self
    }

    pub fn build(self) -> Result<Request, BuilderError> {
        let url = self.url.ok_or(BuilderError::MissingUrl)?;
        Ok(Request {
            url,
            timeout: self.timeout,
            headers: self.headers,
        })
    }
}

// Usage
let request = RequestBuilder::new()
    .url("https://api.example.com")
    .timeout(Duration::from_secs(30))
    .header("Authorization", "Bearer token")
    .build()?;
```

### Trait Design

```rust
// ❌ Concrete types in signatures
fn process(input: Vec<String>) -> Vec<String> { }

// ✅ Accept traits, return concrete
fn process(input: impl IntoIterator<Item = String>) -> Vec<String> {
    input.into_iter().map(|s| s.to_uppercase()).collect()
}

// ✅ Return impl Trait for flexibility
fn create_iterator() -> impl Iterator<Item = i32> {
    (0..100).filter(|x| x % 2 == 0)
}

// ✅ Async fn in traits (Rust 1.75+)
trait Repository {
    async fn get(&self, id: &UserId) -> Result<Option<User>, DbError>;
    async fn save(&self, user: &User) -> Result<(), DbError>;
}
```

### Derive Wisely

```rust
// Value types - equality, hashing, cloning
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct UserId(String);

// Data transfer - serialization
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UserDto {
    pub id: String,
    pub email: String,
    #[serde(default)]
    pub active: bool,
}

// Builders and configs - defaults
#[derive(Debug, Default)]
pub struct Config {
    pub timeout: Option<Duration>,
    pub retries: u32,
}
```

---

## Quality

### Clippy Compliance

```rust
#![warn(clippy::pedantic)]
#![allow(clippy::module_name_repetitions)]

// Common fixes:
// - Use `Self` instead of type name in impl blocks
// - Prefer `&str` over `&String`
// - Use `is_empty()` over `len() == 0`
// - Prefer `if let` over `match` for single patterns
// - Use `?` over `match` for error propagation
// - Use `unwrap_or_default()` for Default types
```

---

## Testing

### Property-Based Testing

**Prefer property-based tests over static unit tests.** Static tests check specific examples; property-based tests verify invariants hold across thousands of generated inputs.

The functional core pattern makes this trivial—pure functions are perfect for property testing.

```rust
use proptest::prelude::*;

// ✅ Property: discount is always 0 or 10
proptest! {
    #[test]
    fn discount_is_valid(
        items in prop::collection::vec(item_strategy(), 0..100),
        is_premium in any::<bool>(),
    ) {
        let data = OrderData { items, is_premium_user: is_premium };
        let result = calculate_order(&data);

        prop_assert!(
            result.discount.value() == 0 || result.discount.value() == 10,
            "Discount must be 0 or 10, got {}",
            result.discount.value()
        );
    }
}

// ✅ Property: total is always non-negative
proptest! {
    #[test]
    fn total_is_non_negative(
        items in prop::collection::vec(item_strategy(), 0..100),
        is_premium in any::<bool>(),
    ) {
        let data = OrderData { items, is_premium_user: is_premium };
        let result = calculate_order(&data);

        prop_assert!(result.total.cents() >= 0);
    }
}

// ✅ Property: premium users always get a discount on non-empty orders
proptest! {
    #[test]
    fn premium_gets_discount(
        items in prop::collection::vec(item_strategy(), 1..100),
    ) {
        let data = OrderData {
            items,
            is_premium_user: true,
        };
        let result = calculate_order(&data);

        prop_assert!(result.discount_applied);
    }
}

// ✅ Property: round-trip serialization preserves data
proptest! {
    #[test]
    fn roundtrip_serialization(user in user_strategy()) {
        let serialized = serde_json::to_string(&user).unwrap();
        let deserialized: User = serde_json::from_str(&serialized).unwrap();

        prop_assert_eq!(user, deserialized);
    }
}

// Custom strategies for domain types
fn item_strategy() -> impl Strategy<Value = Item> {
    (1i64..100_000).prop_map(|cents| Item {
        price: Money::from_cents(cents),
    })
}

fn user_id_strategy() -> impl Strategy<Value = UserId> {
    "[a-z0-9]{8}".prop_map(|s| UserId::new(format!("usr_{s}")).unwrap())
}

fn email_strategy() -> impl Strategy<Value = Email> {
    "[a-z]{5,10}@[a-z]{3,8}\\.[a-z]{2,4}"
        .prop_map(|s| Email::parse(&s).unwrap())
}

fn user_strategy() -> impl Strategy<Value = User> {
    (user_id_strategy(), email_strategy(), any::<bool>())
        .prop_map(|(id, email, is_premium)| User {
            id,
            email,
            is_premium,
        })
}
```

**Why property tests beat unit tests**:
- Unit test: "calculate_order with 2 items at $10 returns $20" — tests ONE case
- Property test: "total equals sum of item prices minus discount" — tests THOUSANDS of cases
- Property tests find edge cases you'd never think to write
- When a property test fails, proptest shrinks to the minimal failing case

**Apply when you see**: lots of hand-written example-based tests, test files longer than implementation files.

### Snapshot Testing

**Use `insta` snapshots to catch unintended changes to data structures.** Snapshots are particularly valuable for:
- Complex struct transformations
- Serialization formats (JSON, YAML, TOML)
- Error message formatting
- State machine transitions

```rust
use insta::{assert_snapshot, assert_json_snapshot, assert_debug_snapshot};

// ✅ Snapshot complex transformations
#[test]
fn test_user_transformation() {
    let input = RawUserData {
        id: "usr_123".to_string(),
        email_address: "TEST@Example.COM".to_string(),
        created: "2024-01-15T10:30:00Z".to_string(),
        premium_status: "active".to_string(),
    };

    let result = transform_user(input);

    // Snapshot captures the entire structure
    // Any unexpected change fails the test
    assert_json_snapshot!(result, @r###"
    {
      "id": "usr_123",
      "email": "test@example.com",
      "created_at": "2024-01-15T10:30:00Z",
      "account_type": "premium",
      "subscription_end": "2025-01-15T10:30:00Z"
    }
    "###);
}

// ✅ Snapshot error types
#[test]
fn test_validation_errors() {
    let result = validate_registration(RegistrationInput {
        email: "not-an-email".to_string(),
        password: "123".to_string(),
    });

    assert_debug_snapshot!(result, @r###"
    Err(
        ValidationError {
            fields: {
                "email": "Invalid email format",
                "password": "Password must be at least 8 characters",
            },
        },
    )
    "###);
}

// ✅ Snapshot state transitions
#[test]
fn test_order_state_machine() {
    let order = Order::new();
    let submitted = order.transition(OrderEvent::Submit).unwrap();
    let paid = submitted.transition(OrderEvent::Pay { amount: Money::from_cents(10000) }).unwrap();
    let shipped = paid.transition(OrderEvent::Ship {
        tracking: TrackingNumber::new("ABC123").unwrap()
    }).unwrap();

    assert_snapshot!(format!(
        "{} -> {} -> {} -> {}",
        order.status(),
        submitted.status(),
        paid.status(),
        shipped.status()
    ), @"pending -> submitted -> paid -> shipped");
}

// ✅ Snapshot API responses
#[test]
fn test_api_response_format() {
    let response = create_api_response(user);

    // Inline snapshots are reviewed in the test file
    assert_json_snapshot!(response);

    // Or use file-based snapshots for large structures
    // Creates snapshots/test_api_response_format.snap
}
```

**Workflow with insta**:
1. Write test with `assert_snapshot!`
2. Run `cargo test` — test fails with diff
3. Run `cargo insta review` — interactively accept/reject snapshots
4. Commit the `.snap` files alongside your code

**Combine with property tests**: Use snapshots for specific representative cases, property tests for invariants across all inputs.

**Apply when you see**: complex assertions spread across many `assert_eq!` calls, tests that check only a few fields of a large struct.
