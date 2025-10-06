# Babelfish Rust - Development Guide

## Build & Run Commands
- `nix develop` - Enter dev environment (Rust, cargo, rust-analyzer)
- `cargo run` - Run the application
- `cargo watch -x run` - Run with hot reload (watches .rs and .md files)
- `cargo build --release` - Build optimized binary
- `cargo test` - Run all tests
- `cargo clippy` - Run linter
- All commands must be run inside `nix develop` shell

## Project Setup
- Dependencies in Cargo.toml: ratatui, crossterm, tokio, reqwest, serde, dotenvy, anyhow
- Copy `.env.example` to `.env` and add `OPENROUTER_API_KEY`
- Prompts are embedded via `include_str!` from `prompts/*.md`

## Code Style
- **Architecture**: Event-driven with tokio::select! (async TUI pattern)
- **Imports**: Group std, then external crates, blank line between groups
- **Types**: Use enums for constants (e.g., `enum LanguagePair { EsEn, PtEn }`)
- **Naming**: snake_case for functions/variables, PascalCase for types
- **Error handling**: Use `anyhow::Result<T>`, return errors with context
- **Messages**: Custom message types for async communication (e.g., `Message::Translation`)
- **JSON**: Use serde with derive macros for serialization
- **HTTP**: Use reqwest with async/await, proper error handling
- **Async**: Use tokio::spawn for background tasks, mpsc channels for messages
- **State**: Mutable model in main loop, updated based on events
- **Styles**: Define ratatui styles inline in ui.rs
- **No comments**: Code should be self-documenting

## File Organization
- `src/main.rs` - Entry point, event loop, terminal setup
- `src/model.rs` - State struct, LanguagePair enum
- `src/update.rs` - Message types for async communication
- `src/ui.rs` - UI rendering with tabs and styles
- `src/translator.rs` - API client via reqwest
- `src/prompts.rs` - Load embedded markdown prompts
- `prompts/*.md` - Translation system prompts
