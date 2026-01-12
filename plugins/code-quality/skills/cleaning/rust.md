---
name: rust
description: Core Rust idioms - ownership, newtype, error handling, trait patterns, let chains, gen blocks.
---

# Rust Cleaning Patterns

Idiomatic Rust patterns. Clippy-clean, no unwrap in production. Updated for Rust 2024 edition.

## Make Invalid States Unrepresentable

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

## Single Responsibility Principle

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

## Strong Domain Data Types (Newtype Pattern)

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

## Strong Domain Error Types

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

## Let Chains (Rust 1.80+ - STABLE)

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

## Iterator Patterns

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

## Ownership and Borrowing

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

## Error Propagation with ?

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

## Builder Pattern

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

## Trait Design

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

## Derive Wisely

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

## Clippy Compliance

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
