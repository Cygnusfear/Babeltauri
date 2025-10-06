# Package Versions

## Tauri Stack
- **Tauri**: 2.8.5 (Latest stable - Sept 1, 2025)
- **Tauri Build**: 2.4.1

## Frontend
- **React**: 18.3.1
- **TypeScript**: 5.5.3
- **Vite**: 5.4.1
- **TailwindCSS**: 3.4.1
- **@tauri-apps/api**: 2.0.0

## Backend
- **Rust**: 1.90.0 (via Nix flake)
- **tokio**: 1.x (async runtime)
- **reqwest**: 0.12 (HTTP client)
- **serde**: 1.x (JSON serialization)
- **anyhow**: 1.x (error handling)

## System Dependencies (Nix)
- **gtk3**: For Linux UI
- **webkitgtk_4_1**: WebView engine
- **libsoup_3**: HTTP library
- **glib**: Core library
- **glib-networking**: Network support
- **nodejs**: 22.19.0 (for frontend build)

## Build Status
✅ Compiles successfully on Linux (NixOS)
✅ Uses latest stable Tauri (2.8.5)
⚠️  Windows/macOS builds untested

## Update History
- 2025-10-06: Initial Tauri migration from TUI version
- 2025-10-06: Confirmed using latest Tauri 2.8.5
