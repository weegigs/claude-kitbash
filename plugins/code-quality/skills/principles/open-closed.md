---
name: open-closed
description: Open for extension, closed for modification.
---

# Open-Closed Principle

Software entities should be open for extension but closed for modification. Add new behavior by adding new code, not changing existing code.

## TypeScript

### ❌ Don't: Modify existing code to add behavior

```typescript
// Every new payment method requires modifying this function
function processPayment(payment: Payment): Result {
  if (payment.type === "credit_card") {
    return processCreditCard(payment);
  } else if (payment.type === "paypal") {
    return processPaypal(payment);
  } else if (payment.type === "bank_transfer") {
    // Added later - had to modify existing code
    return processBankTransfer(payment);
  } else if (payment.type === "crypto") {
    // Added even later - more modifications
    return processCrypto(payment);
  }
  throw new Error(`Unknown payment type: ${payment.type}`);
}

// Every new discount type requires modifying this
function calculateDiscount(order: Order): number {
  let discount = 0;
  if (order.couponCode) {
    discount += lookupCoupon(order.couponCode);
  }
  if (order.customer.isPremium) {
    discount += order.total * 0.1;
  }
  if (order.items.length > 10) {
    // Added later - bulk discount
    discount += order.total * 0.05;
  }
  return discount;
}
```

### ✅ Do: Extend via abstractions

```typescript
// Define the contract
interface PaymentProcessor {
  readonly type: string;
  process(payment: Payment): Result;
}

// Each implementation is a separate unit
class CreditCardProcessor implements PaymentProcessor {
  readonly type = "credit_card";
  process(payment: Payment): Result {
    // Credit card specific logic
  }
}

class PaypalProcessor implements PaymentProcessor {
  readonly type = "paypal";
  process(payment: Payment): Result {
    // PayPal specific logic
  }
}

// New payment methods don't modify existing code
class CryptoProcessor implements PaymentProcessor {
  readonly type = "crypto";
  process(payment: Payment): Result {
    // Crypto specific logic - new file, no modifications elsewhere
  }
}

// Registry pattern for dispatch
class PaymentService {
  private processors = new Map<string, PaymentProcessor>();

  register(processor: PaymentProcessor) {
    this.processors.set(processor.type, processor);
  }

  process(payment: Payment): Result {
    const processor = this.processors.get(payment.type);
    if (!processor) {
      throw new Error(`No processor for: ${payment.type}`);
    }
    return processor.process(payment);
  }
}
```

### ✅ Do: Strategy pattern for varying behavior

```typescript
// Discount strategy interface
interface DiscountStrategy {
  calculate(order: Order): number;
}

class CouponDiscount implements DiscountStrategy {
  calculate(order: Order): number {
    return order.couponCode ? lookupCoupon(order.couponCode) : 0;
  }
}

class PremiumMemberDiscount implements DiscountStrategy {
  calculate(order: Order): number {
    return order.customer.isPremium ? order.total * 0.1 : 0;
  }
}

class BulkDiscount implements DiscountStrategy {
  calculate(order: Order): number {
    return order.items.length > 10 ? order.total * 0.05 : 0;
  }
}

// Adding new discount = new class, no modification to existing code
class HolidayDiscount implements DiscountStrategy {
  calculate(order: Order): number {
    return isHolidaySeason() ? order.total * 0.15 : 0;
  }
}

// Compose strategies
class DiscountCalculator {
  constructor(private strategies: DiscountStrategy[]) {}

  calculate(order: Order): number {
    return this.strategies.reduce(
      (total, strategy) => total + strategy.calculate(order),
      0
    );
  }
}
```

## Rust

### ❌ Don't: Match statements that grow

```rust
// Every new format requires modifying this function
fn export_report(report: &Report, format: &str) -> Result<Vec<u8>> {
    match format {
        "json" => export_json(report),
        "csv" => export_csv(report),
        "xml" => export_xml(report),  // Added later
        "pdf" => export_pdf(report),  // Added even later
        _ => Err(Error::UnsupportedFormat(format.to_string())),
    }
}

// Every new notification channel requires modifying this
fn send_notification(notif: &Notification) -> Result<()> {
    match notif.channel {
        Channel::Email => send_email(notif),
        Channel::Sms => send_sms(notif),
        Channel::Push => send_push(notif),  // Added later
        Channel::Slack => send_slack(notif), // Added even later
    }
}
```

### ✅ Do: Extend via traits

```rust
// Define the contract
trait ReportExporter: Send + Sync {
    fn format(&self) -> &'static str;
    fn export(&self, report: &Report) -> Result<Vec<u8>>;
}

// Each implementation is independent
struct JsonExporter;
impl ReportExporter for JsonExporter {
    fn format(&self) -> &'static str { "json" }
    fn export(&self, report: &Report) -> Result<Vec<u8>> {
        serde_json::to_vec(report).map_err(Into::into)
    }
}

struct CsvExporter;
impl ReportExporter for CsvExporter {
    fn format(&self) -> &'static str { "csv" }
    fn export(&self, report: &Report) -> Result<Vec<u8>> {
        // CSV export logic
    }
}

// New exporters don't modify existing code
struct PdfExporter;
impl ReportExporter for PdfExporter {
    fn format(&self) -> &'static str { "pdf" }
    fn export(&self, report: &Report) -> Result<Vec<u8>> {
        // PDF export logic - new file, no modifications elsewhere
    }
}

// Registry for dispatch
struct ExportService {
    exporters: HashMap<&'static str, Box<dyn ReportExporter>>,
}

impl ExportService {
    fn register(&mut self, exporter: Box<dyn ReportExporter>) {
        self.exporters.insert(exporter.format(), exporter);
    }

    fn export(&self, report: &Report, format: &str) -> Result<Vec<u8>> {
        self.exporters
            .get(format)
            .ok_or_else(|| Error::UnsupportedFormat(format.to_string()))?
            .export(report)
    }
}
```

### ✅ Do: Use trait objects for pluggable behavior

```rust
// Notification sender trait
trait NotificationSender: Send + Sync {
    fn send(&self, notification: &Notification) -> Result<()>;
}

struct EmailSender { /* config */ }
impl NotificationSender for EmailSender {
    fn send(&self, notification: &Notification) -> Result<()> {
        // Email logic
    }
}

struct SmsSender { /* config */ }
impl NotificationSender for SmsSender {
    fn send(&self, notification: &Notification) -> Result<()> {
        // SMS logic
    }
}

// Adding Slack = new struct + impl, no modification to existing code
struct SlackSender { webhook_url: String }
impl NotificationSender for SlackSender {
    fn send(&self, notification: &Notification) -> Result<()> {
        // Slack webhook logic
    }
}

// Service accepts any sender
struct NotificationService {
    senders: Vec<Box<dyn NotificationSender>>,
}

impl NotificationService {
    fn notify_all(&self, notification: &Notification) -> Result<()> {
        for sender in &self.senders {
            sender.send(notification)?;
        }
        Ok(())
    }
}
```

### ✅ Do: Extension via generics

```rust
// Generic over any validator
trait Validator<T> {
    fn validate(&self, value: &T) -> Result<(), ValidationError>;
}

struct LengthValidator { min: usize, max: usize }
impl Validator<String> for LengthValidator {
    fn validate(&self, value: &String) -> Result<(), ValidationError> {
        if value.len() < self.min || value.len() > self.max {
            return Err(ValidationError::Length { min: self.min, max: self.max });
        }
        Ok(())
    }
}

struct RegexValidator { pattern: Regex }
impl Validator<String> for RegexValidator {
    fn validate(&self, value: &String) -> Result<(), ValidationError> {
        if !self.pattern.is_match(value) {
            return Err(ValidationError::Pattern);
        }
        Ok(())
    }
}

// Compose validators without modifying them
struct CompositeValidator<T> {
    validators: Vec<Box<dyn Validator<T>>>,
}

impl<T> Validator<T> for CompositeValidator<T> {
    fn validate(&self, value: &T) -> Result<(), ValidationError> {
        for validator in &self.validators {
            validator.validate(value)?;
        }
        Ok(())
    }
}
```

## When to Apply

Look for these patterns that violate open-closed:

- Growing `if/else` or `match` chains when adding features
- Modifying existing functions to handle new cases
- Enum variants that keep expanding
- "Shotgun surgery" - one new feature requires changes in many places
- Fear of touching working code to add new behavior

## Guidelines

1. **Identify variation points** — What's likely to change or expand?
2. **Abstract the variation** — Define interfaces/traits for the varying behavior
3. **Depend on abstractions** — Core code depends on interfaces, not implementations
4. **Add by extending** — New behavior = new implementation, not modified code
5. **Use composition** — Combine behaviors via strategy, decorator, or registry patterns
