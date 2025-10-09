#!/usr/bin/env bash
echo "🐠 Starting Babelfish Tauri App..."
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Shutting down..."
    kill $VITE_PID 2>/dev/null
    wait $VITE_PID 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start Vite dev server in background
echo "Starting Vite dev server..."
nix develop --command bash -c 'cd src-ui && npm run dev' &
VITE_PID=$!

# Wait for Vite to be ready
echo "Waiting for Vite dev server to be ready..."
until curl -s http://localhost:5173 > /dev/null 2>&1; do
    sleep 0.5
done
echo "Vite dev server is ready!"

# Start Tauri app
echo "Starting Tauri app..."
nix develop --command bash -c 'cargo run'

# Cleanup when cargo run exits
cleanup
