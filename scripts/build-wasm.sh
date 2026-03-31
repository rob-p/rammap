#!/bin/bash
# Build WASM without multithreading (single-threaded, no SharedArrayBuffer needed).
# Works on stable Rust.
#
# Usage: bash scripts/build-wasm.sh

set -euo pipefail

echo "[*] Building WASM (single-threaded + SIMD128)..."

wasm-pack build \
  --target web \
  --release \
  --no-default-features

echo "[*] Done. WASM package in pkg/"
echo "[*] Serve with: python3 -m http.server 8080 (or python3 scripts/serve.py for threads)"
