---
name: illegal-states
description: Make illegal states unrepresentable via type design.
---

# Make Illegal States Unrepresentable

Design types so invalid states cannot exist at compile time. Use discriminated unions instead of boolean flags or optional fields that interact.

## TypeScript

### ❌ Don't: Allow invalid state combinations

```typescript
type UserState = {
  loading: boolean;
  data?: User;
  error?: Error;
};

// Problem: These states are all representable but invalid:
// { loading: true, data: someUser, error: someError }
// { loading: false, data: undefined, error: undefined }
// { loading: true, error: someError }

function UserProfile({ state }: { state: UserState }) {
  // Defensive checks everywhere because types don't help
  if (state.loading) {
    return <Spinner />;
  }
  if (state.error) {
    return <Error message={state.error.message} />;
  }
  if (state.data) {
    return <Profile user={state.data} />;
  }
  return <Empty />; // What state is this? Bug waiting to happen
}
```

### ✅ Do: Use discriminated unions

```typescript
type UserState =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: User }
  | { status: "error"; error: Error };

function UserProfile({ state }: { state: UserState }) {
  switch (state.status) {
    case "idle":
      return <Empty />;
    case "loading":
      return <Spinner />;
    case "success":
      return <Profile user={state.data} />; // data guaranteed present
    case "error":
      return <Error message={state.error.message} />; // error guaranteed present
  }
}
```

## Rust

### ❌ Don't: Use Option fields that interact

```rust
struct Connection {
    is_connected: bool,
    socket: Option<TcpStream>,
    error: Option<ConnectionError>,
}

// Problem: Invalid states are representable:
// is_connected: true, socket: None (connected but no socket?)
// is_connected: false, socket: Some(...) (not connected but has socket?)
// socket: Some(...), error: Some(...) (has both socket and error?)

fn handle_connection(conn: &Connection) {
    if conn.is_connected {
        if let Some(socket) = &conn.socket {
            // use socket
        } else {
            // Bug: connected but no socket?
        }
    }
}
```

### ✅ Do: Use enums to represent valid states only

```rust
enum Connection {
    Disconnected,
    Connecting,
    Connected { socket: TcpStream },
    Failed { error: ConnectionError },
}

fn handle_connection(conn: &Connection) {
    match conn {
        Connection::Disconnected => {
            println!("Not connected");
        }
        Connection::Connecting => {
            println!("Connection in progress...");
        }
        Connection::Connected { socket } => {
            // socket is guaranteed to exist here
            socket.write_all(b"hello")?;
        }
        Connection::Failed { error } => {
            // error is guaranteed to exist here
            eprintln!("Connection failed: {}", error);
        }
    }
}
```

## When to Apply

Look for these patterns that indicate illegal states are possible:

- Boolean flags that interact (`isLoading && hasError`)
- Optional fields that depend on each other
- String literals that should be unions
- Multiple booleans where only certain combinations are valid
- `null` or `undefined` checks scattered throughout code
