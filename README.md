# 🐠 Babelfish

A blazing-fast TUI translator powered by Gemini Flash 2.5 via OpenRouter, built with Rust and Ratatui.

Full rewrite from Go/Bubbletea to pure Rust with async, proper error handling, and improved performance.

## Quick Start

```bash
# Enter dev environment
nix develop

# Create .env file
cp .env.example .env
# Edit .env and add your OPENROUTER_API_KEY

# Run
cargo run

# Run with hot reload
cargo watch -x run

# Build release binary
cargo build --release
./target/release/babelfish
```

## Features

- **Blazing fast**: Native Rust performance with async I/O
- **Clean async**: Tokio-based event loop with proper error handling
- **Markdown prompts**: Load translation rules from `prompts/*.md` files
- **Beautiful UI**: Tab-based language pair selection, scrollable chat
- **Keyboard shortcuts**: Enter to translate, Tab to switch pairs, Ctrl+L to clear
- **Single binary**: No runtime dependencies, just compile and run

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Enter | Submit translation |
| Tab | Switch language pair |
| Ctrl+C | Clear input (or quit if empty) |
| Esc | Clear input |
| Ctrl+L | Clear chat history |
| Up/Down | Scroll chat |
| PageUp/PageDown | Scroll chat (fast) |

## Project Structure

```
.
├── src/
│   ├── main.rs        # Entry point, event loop
│   ├── model.rs       # Application state
│   ├── update.rs      # Message types
│   ├── ui.rs          # Rendering logic
│   ├── translator.rs  # OpenRouter API client
│   └── prompts.rs     # Prompt loader
├── prompts/
│   ├── es-en.md       # Spanish ↔ English
│   └── pt-en.md       # Portuguese ↔ English
├── Cargo.toml         # Rust dependencies
├── flake.nix          # Nix dev environment
└── .env               # API keys (gitignored)
```

## Architecture

Event-driven async TUI:
- **Model**: Application state (language pair, messages, scroll position)
- **Event Loop**: tokio::select! handling keyboard and async messages
- **UI Rendering**: Ratatui rendering from state
- **Async Tasks**: tokio::spawn for API calls with mpsc channel communication

## Dependencies

- **ratatui**: Terminal UI framework
- **crossterm**: Cross-platform terminal manipulation
- **tokio**: Async runtime
- **reqwest**: HTTP client
- **serde**: Serialization
- **dotenvy**: Environment variables
- **anyhow**: Error handling
