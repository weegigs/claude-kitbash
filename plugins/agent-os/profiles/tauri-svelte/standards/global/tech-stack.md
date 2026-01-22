# Tech Stack

## Frontend

- **Svelte 5** with runes (`$state`, `$derived`, `$effect`, `$props`)
- **SvelteKit 2** for routing and SSR
- **Tailwind CSS v4** for styling
- **Vite** for build tooling

## Desktop

- **Tauri v2** (Rust backend)
- **tauri-specta** for TypeScript binding generation from Rust types

## Backend (optional)

- **Convex.dev** for real-time sync
- OR **libSQL/SQLite** for local-first architecture

## Tooling

| Tool | Purpose |
|------|---------|
| Bun | Package manager and runtime |
| Biome | Linting and formatting (TypeScript) |
| Cargo fmt + Clippy | Linting and formatting (Rust) |
| jj (Jujutsu) | Version control |
| beads (bd) | Issue tracking |

## Architecture Principles

1. **Imperative Shell, Functional Core** - Pure business logic, thin I/O layer
2. **Rust is Source of Truth** - Types generated from Rust via specta
3. **Invalid States Unrepresentable** - Discriminated unions over boolean flags
4. **No Workarounds** - Fix root causes, never suppress lints

## Development Commands

```bash
# Development
bun dev                   # Vite dev server (web only)
bun tauri dev             # Tauri desktop app with hot reload

# Build
bun build                 # Build SvelteKit frontend
bun tauri build           # Build desktop application

# Quality
bun check                 # Run svelte-check
bun lint                  # Run Biome linter
cargo clippy              # Rust lints
cargo fmt --check         # Rust formatting
```
