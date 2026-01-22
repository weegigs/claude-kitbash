# Rust Error Handling

## Domain Error Types

Use `thiserror` with serde-tagged variants for Tauri IPC compatibility:

```rust
#[derive(Debug, Clone, thiserror::Error, serde::Serialize)]
#[serde(tag = "code", rename_all = "SCREAMING_SNAKE_CASE")]
pub enum AppError {
    #[error("Not found: {entity} '{id}'")]
    NotFound { entity: String, id: String },

    #[error("Validation failed: {message}")]
    Validation {
        message: String,
        path: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        context: Option<String>,
    },

    #[error("Internal error: {0}")]
    Internal(String),
}
```

## Constructor Pattern

Provide ergonomic constructors for each variant:

```rust
impl AppError {
    pub fn not_found(entity: impl Into<String>, id: impl Into<String>) -> Self {
        Self::NotFound {
            entity: entity.into(),
            id: id.into(),
        }
    }

    pub fn validation(path: impl Into<String>, message: impl Into<String>) -> Self {
        Self::Validation {
            message: message.into(),
            path: path.into(),
            context: None,
        }
    }

    pub fn validation_with_context(
        path: impl Into<String>,
        message: impl Into<String>,
        context: impl Into<String>,
    ) -> Self {
        Self::Validation {
            message: message.into(),
            path: path.into(),
            context: Some(context.into()),
        }
    }

    pub fn internal(message: impl Into<String>) -> Self {
        Self::Internal(message.into())
    }
}
```

## Tauri Command Returns

All Tauri commands return `Result<T, AppError>`:

```rust
#[tauri::command]
#[specta::specta]
pub async fn get_user(id: UserId) -> Result<User, AppError> {
    db.find_user(&id)
        .await?
        .ok_or_else(|| AppError::not_found("User", id.as_str()))
}
```

## Batch Validation

For operations validating multiple items, collect errors:

```rust
#[derive(Debug, Default, serde::Serialize)]
pub struct ValidationReport {
    pub errors: Vec<ValidationError>,
    pub warnings: Vec<ValidationWarning>,
}

impl ValidationReport {
    pub fn add_error(&mut self, path: impl Into<String>, message: impl Into<String>) {
        self.errors.push(ValidationError {
            path: path.into(),
            message: message.into(),
        });
    }

    pub fn is_valid(&self) -> bool {
        self.errors.is_empty()
    }
}
```

## Banned Patterns

| Pattern | Reason | Alternative |
|---------|--------|-------------|
| `.unwrap()` | Panics in production | `?` or `.ok_or()` |
| `.expect()` | Panics in production | `?` or `.ok_or()` |
| `panic!` | Crashes the app | Return `Result` |
| `Box<dyn Error>` | Caller can't match | Domain error enum |

## Clippy Configuration

In `Cargo.toml` or `.cargo/config.toml`:

```toml
[lints.clippy]
unwrap_used = "deny"
expect_used = "deny"
panic = "deny"
```
