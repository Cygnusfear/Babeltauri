default:
  @just --list

dev:
  cargo run

watch:
  cargo watch -x run

build:
  nix develop -c cargo tauri build

build-cargo:
  #!/usr/bin/env bash
  echo "🔨 Building with Cargo Tauri (requires nix develop shell)..."
  cargo tauri build
  echo "✅ Build complete!"
  echo "Binary location: target/release/babeltauri"

ui-dev:
  cd src-ui && npm run dev

ui-build:
  cd src-ui && npm run build

tauri-build:
  cargo tauri build

test:
  cargo test

lint:
  cargo clippy

clean:
  cargo clean
  rm -rf src-ui/dist
