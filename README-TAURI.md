# 🐠 Babelfish - Tauri Desktop App

Cross-platform desktop translator app built with Tauri + React + Rust, powered by Gemini Flash 2.5 via OpenRouter.

## Quick Start

### Development

```bash
# Enter Nix development environment
nix develop

# Install frontend dependencies (first time only)
cd src-ui && npm install && cd ..

# Run the app (development mode)
cargo run
```

The app will automatically start the Vite dev server and open the Tauri window.

### Production Build

```bash
# Build optimized binary
cargo build --release

# The binary will be at:
./target/release/babeltauri
```

## Features

- **Cross-platform**: Works on Linux, macOS, and Windows
- **Modern UI**: React with TailwindCSS for a clean, responsive interface
- **Fast translations**: Async Rust backend with tokio
- **Multiple language pairs**: ES↔EN, PT↔EN (easily extensible)
- **Click to copy**: Click any translation to copy to clipboard
- **Settings**: Configure API key in-app
- **Lightweight**: Small binary size, low memory footprint

## Project Structure

```
babeltauri/
├── src/                    # Rust backend (Tauri)
│   ├── main.rs            # Entry point
│   ├── lib.rs             # Tauri app setup
│   ├── commands.rs        # Tauri commands (IPC)
│   ├── translator.rs      # OpenRouter API client
│   ├── prompts.rs         # Prompt loader
│   └── model.rs           # Data models
├── src-ui/                # React frontend
│   ├── src/
│   │   ├── App.tsx        # Main component
│   │   └── components/    # UI components
│   └── dist/              # Built frontend (gitignored)
├── prompts/               # Translation prompts
│   ├── es-en.md
│   └── pt-en.md
├── icons/                 # App icons
├── tauri.conf.json        # Tauri configuration
├── Cargo.toml             # Rust dependencies
└── flake.nix              # Nix dev environment
```

## Configuration

### API Key

On first launch, the app will prompt you to enter your OpenRouter API key. Alternatively, create a `.env` file:

```bash
cp .env.example .env
# Edit .env and add your OPENROUTER_API_KEY
```

### Adding Language Pairs

1. Create a new prompt file in `prompts/`, e.g., `fr-en.md`
2. The app will automatically detect and load it on next start
3. The tab label is generated from the filename (e.g., `fr-en` → `FR ↔ EN`)

## Development

### Frontend Development

```bash
cd src-ui
npm run dev
```

The frontend runs on http://localhost:5173 and hot-reloads on changes.

### Backend Development

```bash
# Watch mode (restarts on file changes)
cargo watch -x run

# Manual run
cargo run
```

### Building for Distribution

```bash
# Linux
cargo build --release

# Windows (cross-compile from Linux)
cargo build --release --target x86_64-pc-windows-gnu

# macOS (requires macOS or cross-compilation setup)
cargo build --release --target x86_64-apple-darwin
```

## Keyboard Shortcuts

- **Enter**: Send translation
- **Shift+Enter**: New line in input
- **Click message**: Copy to clipboard

## Tech Stack

### Frontend
- **React 18**: UI framework
- **TypeScript**: Type safety
- **TailwindCSS**: Styling
- **Vite**: Build tool
- **@tauri-apps/api**: Tauri bindings

### Backend
- **Tauri 2.x**: Desktop app framework
- **Rust**: System programming language
- **tokio**: Async runtime
- **reqwest**: HTTP client
- **serde**: Serialization

## Comparison with TUI Version

| Feature | TUI (ratatui) | GUI (Tauri) |
|---------|---------------|-------------|
| Platform | Linux/macOS/Windows | Linux/macOS/Windows |
| Interface | Terminal | Native window |
| Installation | Single binary | Single binary + webview |
| Mouse support | Limited | Full |
| Copy/paste | wl-copy/pbcopy | Native clipboard |
| Settings | .env file only | In-app UI |
| Binary size | ~5MB | ~15MB |
| Memory | ~10MB | ~50MB |

## Troubleshooting

### Linux: Missing dependencies

```bash
# Debian/Ubuntu
sudo apt install libwebkit2gtk-4.1-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev

# Fedora
sudo dnf install webkit2gtk4.1-devel gtk3-devel libappindicator-gtk3-devel librsvg2-devel

# Arch
sudo pacman -S webkit2gtk-4.1 gtk3 librsvg
```

### Windows: Building fails

Make sure you have:
- Microsoft C++ Build Tools
- WebView2 Runtime (usually pre-installed on Windows 10/11)

### API Key not persisting

The API key is stored in memory only during runtime. To persist across sessions, set it in `.env`.

## License

Same as the TUI version.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on your platform
5. Submit a pull request

## Roadmap

- [ ] Persistent API key storage (encrypted)
- [ ] Translation history
- [ ] Export translations
- [ ] Custom prompts via UI
- [ ] Dark/light theme toggle
- [ ] Auto-updater
- [ ] Hotkey for global translation
- [ ] Tray icon support
