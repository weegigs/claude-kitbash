---
name: explicit-dependencies
description: No hidden globals or implicit state.
---

# Make Dependencies Explicit

Avoid hidden dependencies and global state. Pass what you need, return what you produce.

## TypeScript

### ❌ Don't: Hidden dependencies on globals or context

```typescript
// Global state hidden inside function
let currentUser: User | null = null;

function setCurrentUser(user: User) {
  currentUser = user;
}

function formatWelcome(): string {
  // Where does currentUser come from? Spooky action at a distance
  if (!currentUser) {
    return "Welcome, guest!";
  }
  return `Welcome, ${currentUser.name}!`;
}

// Hidden dependency on global function
function formatDate(date: Date): string {
  // getCurrentLocale() is a hidden dependency
  return date.toLocaleDateString(getCurrentLocale());
}

// Module-level state
const cache = new Map<string, User>();

function getUser(id: string): User | undefined {
  // Caller doesn't know this uses a cache
  return cache.get(id);
}
```

### ✅ Do: Pass dependencies explicitly

```typescript
// Explicit parameter
function formatWelcome(user: User | null): string {
  if (!user) {
    return "Welcome, guest!";
  }
  return `Welcome, ${user.name}!`;
}

// Explicit locale parameter
function formatDate(date: Date, locale: string): string {
  return date.toLocaleDateString(locale);
}

// Explicit cache injection
interface UserCache {
  get(id: string): User | undefined;
  set(id: string, user: User): void;
}

function createUserService(cache: UserCache) {
  return {
    getUser(id: string): User | undefined {
      return cache.get(id);
    },
    setUser(id: string, user: User): void {
      cache.set(id, user);
    },
  };
}
```

### ✅ Do: Use dependency injection

```typescript
// Dependencies as constructor parameters
class OrderService {
  constructor(
    private readonly db: Database,
    private readonly emailService: EmailService,
    private readonly logger: Logger
  ) {}

  async processOrder(orderId: string): Promise<void> {
    // All dependencies are visible and testable
    this.logger.info(`Processing order ${orderId}`);
    const order = await this.db.orders.find(orderId);
    await this.emailService.sendConfirmation(order);
  }
}

// Easy to test with mocks
const service = new OrderService(mockDb, mockEmail, mockLogger);
```

## Rust

### ❌ Don't: Hidden global state

```rust
use std::sync::OnceLock;

// Global configuration hidden from callers
static CONFIG: OnceLock<Config> = OnceLock::new();

fn init_config(config: Config) {
    CONFIG.set(config).unwrap();
}

fn get_timeout() -> Duration {
    // Where does CONFIG come from? Caller doesn't know
    CONFIG.get().unwrap().timeout
}

// Hidden thread-local state
thread_local! {
    static CURRENT_USER: RefCell<Option<User>> = RefCell::new(None);
}

fn get_current_user_name() -> Option<String> {
    // Spooky action at a distance
    CURRENT_USER.with(|u| u.borrow().as_ref().map(|u| u.name.clone()))
}
```

### ✅ Do: Pass dependencies explicitly

```rust
// Explicit parameter
fn get_timeout(config: &Config) -> Duration {
    config.timeout
}

fn format_welcome(user: Option<&User>) -> String {
    match user {
        Some(u) => format!("Welcome, {}!", u.name),
        None => "Welcome, guest!".to_string(),
    }
}

// Dependency as struct field
struct OrderService {
    db: Database,
    email: EmailService,
    logger: Logger,
}

impl OrderService {
    fn new(db: Database, email: EmailService, logger: Logger) -> Self {
        Self { db, email, logger }
    }

    async fn process_order(&self, order_id: &str) -> Result<()> {
        // All dependencies visible
        self.logger.info(&format!("Processing order {}", order_id));
        let order = self.db.orders.find(order_id).await?;
        self.email.send_confirmation(&order).await?;
        Ok(())
    }
}
```

### ✅ Do: Use trait objects for flexibility

```rust
// Define dependencies as traits
trait Database: Send + Sync {
    fn find_order(&self, id: &str) -> Result<Order>;
}

trait EmailService: Send + Sync {
    fn send(&self, to: &str, message: &str) -> Result<()>;
}

// Accept trait objects
struct OrderProcessor {
    db: Box<dyn Database>,
    email: Box<dyn EmailService>,
}

impl OrderProcessor {
    fn new(db: impl Database + 'static, email: impl EmailService + 'static) -> Self {
        Self {
            db: Box::new(db),
            email: Box::new(email),
        }
    }
}

// Easy to test with mock implementations
struct MockDatabase;
impl Database for MockDatabase {
    fn find_order(&self, _id: &str) -> Result<Order> {
        Ok(Order::default())
    }
}
```

## When to Apply

Look for these patterns that indicate hidden dependencies:

- Functions reaching into global state
- Module-level mutable variables
- Implicit context (current user, locale, config)
- "Where does this value come from?" questions
- Hard-to-test code (can't inject mocks)
- Order-dependent initialization
