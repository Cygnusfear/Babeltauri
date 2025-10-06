# Tauri + React Migration Plan

## Overview
Convert the Rust TUI translator into a cross-platform desktop app using Tauri 2.x + React frontend, maintaining the same core translation logic while providing a GUI for Windows users.

## Architecture

### Frontend (React + TypeScript)
- **UI Framework**: React 18 with TypeScript
- **Styling**: TailwindCSS for rapid UI development
- **State Management**: React hooks (useState, useEffect)
- **Tauri Bindings**: @tauri-apps/api for IPC communication

### Backend (Rust - Tauri)
- **Core Logic**: Reuse existing translator.rs, prompts.rs
- **Tauri Commands**: Expose translation API via Tauri commands
- **State**: Tauri State for API key and language pairs
- **Async**: Keep tokio runtime for OpenRouter API calls

## File Structure
```
babeltauri/
├── src/                         # Rust backend
│   ├── main.rs                  # Tauri entry point
│   ├── translator.rs            # Keep existing (reuse)
│   ├── prompts.rs               # Keep existing (reuse)
│   └── commands.rs              # NEW: Tauri command handlers
├── src-ui/                      # React frontend
│   ├── src/
│   │   ├── App.tsx              # Main component
│   │   ├── components/
│   │   │   ├── ChatMessage.tsx  # Message bubble
│   │   │   ├── InputBox.tsx     # Translation input
│   │   │   ├── LanguageTabs.tsx # Language pair selector
│   │   │   └── Header.tsx       # App header
│   │   ├── hooks/
│   │   │   └── useTranslate.ts  # Translation logic hook
│   │   ├── main.tsx             # React entry
│   │   └── styles.css           # Tailwind imports
│   ├── index.html
│   ├── package.json
│   ├── vite.config.ts
│   └── tsconfig.json
├── prompts/                     # Keep existing
│   ├── es-en.md
│   └── pt-en.md
├── src-tauri/
│   ├── Cargo.toml               # Tauri dependencies
│   ├── tauri.conf.json          # Tauri config
│   ├── build.rs
│   └── icons/                   # App icons
├── .env.example
└── README.md
```

## Implementation Steps

### Phase 1: Tauri Setup
1. Install Tauri CLI: `cargo install tauri-cli`
2. Create Tauri project structure:
   ```bash
   cargo tauri init
   ```
3. Configure tauri.conf.json:
   - App name: "Babelfish"
   - Window size: 1000x700
   - Enable dev tools in debug mode
   - Set CSP for API calls to openrouter.ai

### Phase 2: Backend Refactor
1. **Keep Existing Modules**:
   - `translator.rs` - No changes needed
   - `prompts.rs` - Update to use Tauri resource path API
   - Delete: `ui.rs`, `update.rs`, `model.rs` (TUI-specific)

2. **New `commands.rs`**:
   ```rust
   #[tauri::command]
   async fn translate(
       state: State<'_, AppState>,
       pair_name: String,
       text: String
   ) -> Result<String, String>
   
   #[tauri::command]
   fn get_language_pairs(state: State<'_, AppState>) -> Vec<LanguagePair>
   
   #[tauri::command]
   async fn set_api_key(
       state: State<'_, AppState>,
       key: String
   ) -> Result<(), String>
   ```

3. **AppState**:
   ```rust
   struct AppState {
       api_key: RwLock<String>,
       pairs: Vec<LanguagePair>,
   }
   ```

4. **Update main.rs**:
   - Initialize Tauri app builder
   - Load prompts on startup
   - Load API key from .env or prompt user
   - Register commands
   - Manage AppState

### Phase 3: React Frontend
1. **Setup Vite + React + TypeScript**:
   ```bash
   npm create vite@latest src-ui -- --template react-ts
   cd src-ui
   npm install
   npm install -D tailwindcss postcss autoprefixer
   npm install @tauri-apps/api
   npx tailwindcss init -p
   ```

2. **Component Structure**:
   - **App.tsx**: Main layout with tabs, chat area, input
   - **LanguageTabs.tsx**: Tab buttons for language pairs
   - **ChatMessage.tsx**: Message bubble (user/assistant styling)
   - **InputBox.tsx**: Textarea with submit button
   - **Header.tsx**: Title, settings button

3. **Key Features**:
   - Click-to-copy translations (using Clipboard API)
   - Auto-scroll to latest message
   - Loading indicator during translation
   - Error display for API failures
   - Settings modal for API key input

### Phase 4: Styling
1. **TailwindCSS Theme**:
   - Dark mode by default
   - Accent colors for language pairs
   - Smooth transitions for tab switching
   - Message bubbles: user (right/blue), assistant (left/gray)

2. **Layout**:
   - Header: 60px fixed top
   - Tabs: 50px below header
   - Chat area: flex-1 scrollable
   - Input box: 80px fixed bottom

### Phase 5: Integration
1. **IPC Communication**:
   ```typescript
   import { invoke } from '@tauri-apps/api/tauri';
   
   const translation = await invoke<string>('translate', {
     pairName: 'es-en',
     text: inputText
   });
   ```

2. **State Sync**:
   - Load language pairs on mount
   - Store current pair in React state
   - Handle API key missing state

3. **Error Handling**:
   - Network errors
   - API key validation
   - Rate limit handling

### Phase 6: Windows Distribution
1. **Build Configuration**:
   - Update Cargo.toml with Windows-specific deps
   - Generate Windows icons (32x32, 64x64, 128x128, 256x256)
   - Configure installer in tauri.conf.json:
     ```json
     "bundle": {
       "active": true,
       "targets": ["msi", "nsis"],
       "identifier": "com.babelfish.app",
       "icon": ["icons/icon.ico"]
     }
     ```

2. **Build Commands**:
   ```bash
   # Development
   cargo tauri dev
   
   # Production build
   cargo tauri build --target x86_64-pc-windows-msvc
   ```

3. **Installer Options**:
   - NSIS installer for custom branding
   - MSI for enterprise deployment
   - Include VC++ redistributables

### Phase 7: Testing
1. **Unit Tests**:
   - Rust: Keep existing translator tests
   - React: Component tests with Vitest

2. **Integration Tests**:
   - Test Tauri commands
   - Test IPC communication

3. **Manual Testing**:
   - Windows 10/11 compatibility
   - Translation accuracy
   - UI responsiveness
   - Copy-to-clipboard

### Phase 8: Documentation
1. **Update README.md**:
   - Windows installation instructions
   - Download links for installers
   - Screenshots of GUI
   - Building from source

2. **User Guide**:
   - First-time setup (API key)
   - Using language pairs
   - Keyboard shortcuts
   - Settings

## Dependencies

### Rust (Cargo.toml)
```toml
[dependencies]
tauri = { version = "2", features = ["shell-open"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
tokio = { version = "1", features = ["full"] }
reqwest = { version = "0.12", features = ["json"] }
anyhow = "1"
dotenvy = "0.15"
```

### Frontend (package.json)
```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "@tauri-apps/api": "^2.0.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.1",
    "typescript": "^5.5.3",
    "tailwindcss": "^3.4.1",
    "vite": "^5.4.1"
  }
}
```

## Migration Timeline
- **Day 1**: Tauri setup + backend refactor
- **Day 2**: React components + basic UI
- **Day 3**: IPC integration + styling
- **Day 4**: Windows build + testing
- **Day 5**: Polish + documentation

## Key Considerations
- **Maintain Core Logic**: Reuse translator.rs and prompts.rs without changes
- **API Key Storage**: Use Tauri's secure storage or prompt on first launch
- **Bundled Prompts**: Embed prompts/ directory in binary using Tauri resources
- **Auto-updates**: Consider Tauri's updater for future releases
- **Performance**: Async Rust backend ensures no UI blocking during translations
- **Cross-platform**: While targeting Windows, Tauri supports macOS/Linux for free

## Risks & Mitigations
- **Risk**: API key exposure in frontend
  - **Mitigation**: Keep API key in Rust backend, never send to frontend
- **Risk**: Large bundle size
  - **Mitigation**: Use Vite tree-shaking, minimal dependencies
- **Risk**: Windows Defender false positive
  - **Mitigation**: Code sign installer, submit to Microsoft

## Success Metrics
- [ ] Windows installer < 10MB
- [ ] Translation latency < 2s
- [ ] UI responsive (60fps)
- [ ] One-click install on Windows
- [ ] Settings persist across sessions
