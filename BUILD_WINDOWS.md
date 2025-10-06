# Building for Windows

## From Linux (Cross-compilation)

Cross-compiling Tauri apps from Linux to Windows is complex due to WebView2 dependencies. 

**Recommended approach: Build on Windows directly**

### Option 1: Build on Windows Machine

1. Install prerequisites on Windows:
   ```powershell
   # Install Rust
   winget install Rustlang.Rustup
   
   # Install Node.js
   winget install OpenJS.NodeJS
   
   # Install WebView2 (usually pre-installed on Windows 10/11)
   # If needed: https://developer.microsoft.com/en-us/microsoft-edge/webview2/
   ```

2. Clone the repo and build:
   ```powershell
   git clone <your-repo>
   cd Babeltauri
   
   # Install frontend deps
   cd src-ui
   npm install
   npm run build
   cd ..
   
   # Build Tauri app
   cargo build --release
   ```

3. The executable will be at: `target/release/babeltauri.exe`

### Option 2: GitHub Actions (Automated)

Create `.github/workflows/build.yml`:

```yaml
name: Build Windows

on:
  push:
    tags:
      - 'v*'

jobs:
  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 22
      
      - name: Setup Rust
        uses: dtolnay/rust-toolchain@stable
      
      - name: Install frontend dependencies
        run: |
          cd src-ui
          npm install
          npm run build
      
      - name: Build Tauri app
        run: cargo build --release
      
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: babeltauri-windows
          path: target/release/babeltauri.exe
```

### Option 3: Docker with Wine (Advanced, Not Recommended)

This is very complex and unreliable for Tauri apps due to GUI dependencies.

## Creating Installer

Once you have the `.exe`, you can create an installer:

### Using Tauri's Built-in Bundler

On Windows, run:
```powershell
cargo install tauri-cli
cargo tauri build
```

This creates:
- `target/release/bundle/msi/Babeltauri_1.0.0_x64_en-US.msi` (MSI installer)
- `target/release/bundle/nsis/Babeltauri_1.0.0_x64-setup.exe` (NSIS installer)

### Installer Features

Configure in `tauri.conf.json`:

```json
{
  "bundle": {
    "active": true,
    "targets": ["msi", "nsis"],
    "identifier": "com.babelfish.app",
    "icon": ["icons/icon.ico"],
    "windows": {
      "certificateThumbprint": null,
      "digestAlgorithm": "sha256",
      "timestampUrl": ""
    }
  }
}
```

## Distribution

### Single EXE (No Installer)

The `babeltauri.exe` from `cargo build --release` is self-contained and can be distributed directly.

**Size**: ~15-20 MB (includes WebView2 bootstrap)

**Requirements**: 
- Windows 10/11 (WebView2 is pre-installed)
- Windows 7/8: Users need to install WebView2 Runtime

### MSI Installer (Enterprise)

- Best for corporate environments
- Can be deployed via Group Policy
- Size: ~20-25 MB

### NSIS Installer (User-friendly)

- Best for individual users
- Custom branding and install wizard
- Can bundle WebView2 Runtime
- Size: ~25-30 MB (with WebView2 bundled)

## Testing Without Windows

You can test the build process with:

```bash
# On Linux, check if the project is ready for Windows
cargo check --target x86_64-pc-windows-gnu
```

But for actual Windows builds, you need Windows or GitHub Actions.

## Current Status

✅ Frontend built and ready (`src-ui/dist/`)
✅ Prompts embedded in binary
✅ Tauri configured for Windows
⚠️ Need Windows machine or GitHub Actions to build

## Next Steps

1. Push code to GitHub
2. Set up GitHub Actions workflow
3. Create a release tag: `git tag v1.0.0 && git push --tags`
4. GitHub will build Windows installer automatically
5. Download from GitHub Releases
