# Tauri Command Patterns

## Command Registration with Specta

Use tauri-specta for automatic TypeScript binding generation:

```rust
// src/lib.rs
pub fn run() {
    let specta_builder = tauri_specta::Builder::<tauri::Wry>::new()
        .commands(tauri_specta::collect_commands![
            get_user,
            create_user,
            update_user,
            delete_user,
        ]);

    // Generate TypeScript bindings in debug mode
    #[cfg(debug_assertions)]
    {
        specta_builder
            .export(
                specta_typescript::Typescript::default(),
                "../src/lib/generated/tauri-api.ts",
            )
            .expect("Failed to export TypeScript bindings");
    }

    tauri::Builder::default()
        .invoke_handler(specta_builder.invoke_handler())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## State Management

```rust
use std::sync::Mutex;
use tauri::Manager;

pub struct AppState {
    pub db: Mutex<Connection>,
    pub config: RwLock<Config>,
}

impl AppState {
    pub fn new() -> Self {
        Self {
            db: Mutex::new(Connection::open_in_memory().unwrap()),
            config: RwLock::new(Config::default()),
        }
    }
}

// Initialize in setup
tauri::Builder::default()
    .setup(|app| {
        app.manage(AppState::new());
        Ok(())
    })

// Access in commands
#[tauri::command]
#[specta::specta]
async fn query(
    state: tauri::State<'_, AppState>,
) -> Result<Vec<Item>, AppError> {
    let db = state.db.lock()
        .map_err(|_| AppError::internal("Lock poisoned"))?;
    // ...
}
```

## Graceful Shutdown

Handle window close events for async resource cleanup:

```rust
.setup(|app| {
    let window = app.get_webview_window("main")
        .expect("failed to get main window");
    let app_handle = app.handle().clone();

    window.on_window_event(move |event| {
        if let tauri::WindowEvent::CloseRequested { api, .. } = event {
            api.prevent_close();

            // Get resources to clean up
            let state: tauri::State<AppState> = app_handle.state();
            let resources = state.take_resources();

            if let Some(w) = app_handle.get_webview_window("main") {
                tauri::async_runtime::spawn(async move {
                    // Async cleanup
                    resources.shutdown().await;
                    let _ = w.destroy();
                });
            }
        }
    });

    Ok(())
})
```

## Event Channels

For streaming data to the frontend:

```rust
use tauri::ipc::Channel;

#[tauri::command]
#[specta::specta]
async fn subscribe_updates(
    channel: Channel<Update>,
) -> Result<(), AppError> {
    // Spawn task to send updates
    tauri::async_runtime::spawn(async move {
        loop {
            let update = get_next_update().await;
            if channel.send(update).is_err() {
                break; // Channel closed
            }
        }
    });
    Ok(())
}
```

## Frontend Usage

```typescript
import { commands } from "$lib/generated/tauri-api";

// Type-safe command invocation
const user = await commands.getUser({ id: "usr_123" });

// With channel subscription
await commands.subscribeUpdates((update) => {
    console.log("Received:", update);
});
```
