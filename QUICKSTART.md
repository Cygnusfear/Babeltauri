# 🚀 Quick Start - Babelfish Tauri

## First Time Setup

```bash
# 1. Enter Nix environment
nix develop

# 2. Install frontend dependencies
cd src-ui && npm install && cd ..

# 3. Build frontend
cd src-ui && npm run build && cd ..

# 4. Create .env file
cp .env.example .env
# Edit .env and add your OPENROUTER_API_KEY=sk-or-...
```

## Run the App

### Production Mode (Recommended)
```bash
# Make sure frontend is built first
cd src-ui && npm run build && cd ..

# Run the app
cargo run
```

### Development Mode (Hot Reload)
```bash
# Terminal 1: Start Vite dev server
cd src-ui && npm run dev

# Terminal 2: Run Tauri (will connect to dev server)
cargo run
```

## What You Should See

1. A desktop window opens (1000x700px)
2. Title: "Babelfish" with 🐠 icon
3. Language tabs at top: ES ↔ EN, PT ↔ EN
4. If no API key in .env: Settings modal appears
5. Chat area in the middle
6. Input box at bottom

## Testing the App

1. Enter your OpenRouter API key in settings (if not in .env)
2. Type some Spanish text in the input box
3. Press Enter
4. You should see:
   - Your input on the right (blue bubble)
   - Loading indicator (3 bouncing dots)
   - Translation on the left (gray bubble)
5. Click any translation to copy to clipboard
6. "Copied!" notification appears

## Troubleshooting

### Window doesn't open
```bash
# Check logs
RUST_BACKTRACE=1 cargo run
```

### "API key not set" error
- Open Settings (button top-right)
- Enter your OpenRouter API key
- Or add to .env file: `OPENROUTER_API_KEY=sk-or-...`

### Frontend not loading
```bash
# Rebuild frontend
cd src-ui && npm run build && cd ..
```

### "Failed to load prompts"
- Check that `prompts/es-en.md` and `prompts/pt-en.md` exist
- They're embedded at compile time

## Keyboard Shortcuts

- **Enter**: Send translation (Shift+Enter for new line)
- **Clear button**: Clear chat history
- **Settings button**: Configure API key
- **Click message**: Copy to clipboard

## Next Steps

- Test translations in both language pairs
- Try clicking translations to copy
- Test the settings modal
- Clear chat and start over

## Known Issues

- API key doesn't persist (only in-memory, resets on restart)
  - Workaround: Keep it in .env file
- First translation may be slow (cold start)
- Warnings about unused `Model` struct (from old TUI code, safe to ignore)

## Development Commands

```bash
# Build production binary
cargo build --release
./target/release/babeltauri

# Watch mode (restart on Rust changes)
cargo watch -x run

# Frontend dev server (hot reload)
cd src-ui && npm run dev

# Lint Rust code
cargo clippy
```

## Success Criteria

✅ Window opens
✅ Settings modal works
✅ Language tabs switch
✅ Translations work
✅ Click-to-copy works
✅ Loading indicator shows
✅ Error messages display

Ready to fly! 🐠
