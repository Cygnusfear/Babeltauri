default:
  @just --list

dev:
  cargo run

watch:
  cargo watch -x run

build:
  nix build '.#default' --print-build-logs

build-cargo:
  #!/usr/bin/env bash
  echo "🔨 Building with Cargo (requires nix develop shell)..."
  echo "Step 1/2: Building frontend UI..."
  cd src-ui && npm run build
  echo "Step 2/2: Building Tauri application in release mode..."
  cd .. && cargo build --release
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
