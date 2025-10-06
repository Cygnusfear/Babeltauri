#!/usr/bin/env bash
echo "🐠 Starting Babelfish Tauri App..."
echo ""
nix develop --command bash -c 'cargo run'
