default:
  @just --list

dev:
  cargo run

watch:
  cargo watch -x run

build:
  cd src-ui && npm run build && cd .. && cargo build --release

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
