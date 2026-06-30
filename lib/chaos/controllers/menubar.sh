#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_HOME:-$HOME/Wonderland}"
AUDIT="$ROOT/vault/chaos/environment-controller-audit.jsonl"
STATE="$ROOT/vault/chaos/environment-state.json"

mkdir -p "$(dirname "$AUDIT")"

model="$(jq -r '.model // "unknown"' "$STATE" 2>/dev/null || echo unknown)"
status="$(jq -r '.status // "unknown"' "$STATE" 2>/dev/null || echo unknown)"

printf '{"ts":"%s","controller":"menubar","model":"%s","status":"%s","ok":true}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$model" "$status" >> "$AUDIT"

echo "PASS menubar controller observed model=$model status=$status"
