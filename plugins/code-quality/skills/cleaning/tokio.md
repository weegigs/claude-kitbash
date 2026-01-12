---
name: tokio
description: Tokio async patterns - spawning, channels, select!, graceful shutdown, structured concurrency.
---

# Tokio Cleaning Patterns

Async Rust with Tokio. Structured concurrency, proper cancellation, clean shutdown.

## Spawn vs spawn_blocking

```rust
// ❌ Blocking the async runtime
async fn process() {
    let result = expensive_cpu_work(); // Blocks the executor!
    use_result(result).await;
}

// ✅ Use spawn_blocking for CPU-bound work
async fn process() {
    let result = tokio::task::spawn_blocking(|| {
        expensive_cpu_work()
    }).await?;
    use_result(result).await;
}

// ❌ Spawning blocking I/O on async runtime
async fn read_file() {
    let content = std::fs::read_to_string("file.txt")?; // Blocking!
}

// ✅ Use tokio's async I/O
async fn read_file() {
    let content = tokio::fs::read_to_string("file.txt").await?;
}
```

## Channel Patterns

```rust
// mpsc - Multiple producers, single consumer
use tokio::sync::mpsc;

async fn worker_pool() {
    let (tx, mut rx) = mpsc::channel::<Task>(100);

    // Spawn workers
    for _ in 0..4 {
        let tx = tx.clone();
        tokio::spawn(async move {
            while let Some(task) = get_task().await {
                let result = process(task).await;
                tx.send(result).await.ok();
            }
        });
    }

    // Collect results
    drop(tx); // Close sender when done
    while let Some(result) = rx.recv().await {
        handle_result(result);
    }
}

// broadcast - Multiple consumers, each gets all messages
use tokio::sync::broadcast;

async fn event_bus() {
    let (tx, _) = broadcast::channel::<Event>(100);

    // Each subscriber gets their own receiver
    let mut rx1 = tx.subscribe();
    let mut rx2 = tx.subscribe();

    tokio::spawn(async move {
        while let Ok(event) = rx1.recv().await {
            handle_event_type_a(event);
        }
    });
}

// watch - Single value, latest wins
use tokio::sync::watch;

async fn config_reload() {
    let (tx, rx) = watch::channel(Config::default());

    // Updater
    tokio::spawn(async move {
        loop {
            let new_config = load_config().await;
            tx.send(new_config).ok();
            tokio::time::sleep(Duration::from_secs(60)).await;
        }
    });

    // Reader always gets latest
    let config = rx.borrow().clone();
}
```

## select! Macro

```rust
use tokio::select;

// ❌ Polling in a loop
async fn bad_select() {
    loop {
        if let Ok(msg) = rx.try_recv() {
            handle(msg);
        }
        if shutdown.load(Ordering::Relaxed) {
            break;
        }
        tokio::time::sleep(Duration::from_millis(10)).await;
    }
}

// ✅ Proper select!
async fn good_select(
    mut rx: mpsc::Receiver<Message>,
    mut shutdown: watch::Receiver<bool>,
) {
    loop {
        select! {
            Some(msg) = rx.recv() => {
                handle(msg).await;
            }
            _ = shutdown.changed() => {
                if *shutdown.borrow() {
                    break;
                }
            }
        }
    }
}

// Biased select for priority
select! {
    biased;  // Check in order, not randomly

    _ = shutdown.changed() => break,  // Priority: shutdown first
    Some(msg) = rx.recv() => handle(msg).await,
}
```

## Graceful Shutdown

```rust
use tokio::signal;
use tokio::sync::watch;

async fn run_server() -> Result<()> {
    // Shutdown signal
    let (shutdown_tx, shutdown_rx) = watch::channel(false);

    // Spawn workers with shutdown receiver
    let worker = tokio::spawn(worker_loop(shutdown_rx.clone()));
    let server = tokio::spawn(server_loop(shutdown_rx.clone()));

    // Wait for Ctrl+C
    signal::ctrl_c().await?;
    println!("Shutting down...");

    // Signal shutdown
    shutdown_tx.send(true)?;

    // Wait for graceful completion with timeout
    let timeout = Duration::from_secs(30);
    tokio::time::timeout(timeout, async {
        let _ = tokio::join!(worker, server);
    }).await.ok();

    Ok(())
}

async fn worker_loop(mut shutdown: watch::Receiver<bool>) {
    loop {
        select! {
            _ = do_work() => {}
            _ = shutdown.changed() => {
                if *shutdown.borrow() {
                    // Cleanup before exit
                    cleanup().await;
                    break;
                }
            }
        }
    }
}
```

## Structured Concurrency

```rust
// ❌ Fire and forget spawns
async fn process_items(items: Vec<Item>) {
    for item in items {
        tokio::spawn(async move {
            process(item).await; // No error handling, no backpressure
        });
    }
}

// ✅ JoinSet for structured concurrency
use tokio::task::JoinSet;

async fn process_items(items: Vec<Item>) -> Result<Vec<Output>> {
    let mut set = JoinSet::new();

    for item in items {
        set.spawn(async move {
            process(item).await
        });
    }

    let mut results = Vec::new();
    while let Some(result) = set.join_next().await {
        results.push(result??);
    }

    Ok(results)
}

// With concurrency limit
use futures::stream::{self, StreamExt};

async fn process_with_limit(items: Vec<Item>) -> Vec<Output> {
    stream::iter(items)
        .map(|item| async move { process(item).await })
        .buffer_unordered(10)  // Max 10 concurrent
        .collect()
        .await
}
```

## Timeout and Cancellation

```rust
use tokio::time::{timeout, Duration};

// ❌ No timeout
async fn fetch() {
    let response = client.get(url).send().await?;
}

// ✅ With timeout
async fn fetch() -> Result<Response> {
    timeout(Duration::from_secs(30), async {
        client.get(url).send().await
    })
    .await
    .map_err(|_| Error::Timeout)?
}

// Cancellation-safe code
async fn cancellation_safe(mut rx: mpsc::Receiver<Task>) {
    // ❌ Not cancellation safe - may lose task
    let task = rx.recv().await;
    process(task).await; // If cancelled here, task is lost

    // ✅ Cancellation safe
    loop {
        let task = rx.recv().await;
        if let Some(task) = task {
            // Process to completion or re-queue
            if let Err(e) = process(&task).await {
                requeue(task).await;
            }
        }
    }
}
```

## Async Traits

```rust
// Use async-trait crate for now
use async_trait::async_trait;

#[async_trait]
pub trait Repository {
    async fn get(&self, id: &UserId) -> Result<Option<User>>;
    async fn save(&self, user: &User) -> Result<()>;
}

#[async_trait]
impl Repository for PostgresRepo {
    async fn get(&self, id: &UserId) -> Result<Option<User>> {
        sqlx::query_as("SELECT * FROM users WHERE id = $1")
            .bind(id.as_str())
            .fetch_optional(&self.pool)
            .await
    }

    async fn save(&self, user: &User) -> Result<()> {
        // ...
    }
}
```

## Mutex Patterns

```rust
use tokio::sync::Mutex;

// ❌ Holding mutex across await
async fn bad_mutex(data: Arc<Mutex<Data>>) {
    let mut guard = data.lock().await;
    expensive_async_operation().await; // Holds lock!
    guard.value += 1;
}

// ✅ Minimize lock scope
async fn good_mutex(data: Arc<Mutex<Data>>) {
    let current = {
        let guard = data.lock().await;
        guard.value
    }; // Lock released

    let result = expensive_async_operation(current).await;

    {
        let mut guard = data.lock().await;
        guard.value = result;
    }
}

// For simple atomic operations, prefer atomics
use std::sync::atomic::{AtomicU64, Ordering};

let counter = AtomicU64::new(0);
counter.fetch_add(1, Ordering::Relaxed);
```
