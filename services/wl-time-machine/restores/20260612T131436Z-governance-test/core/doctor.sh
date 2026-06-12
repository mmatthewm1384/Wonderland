#!/usr/bin/env bash
set -euo pipefail

ROOT="${WONDERLAND_ROOT:-$HOME/Wonderland}"
FAILURES=0

ok() {
  echo "[OK] $*"
}

warn() {
  echo "[WARN] $*"
}

fail() {
  echo "[FAIL] $*"
  FAILURES=$((FAILURES + 1))
}

echo "=== 🩺 Running Mandatory Wonderland System Doctor Check ==="

for dir in bin core secrets tools logs data intelligence/obsidian; do
  if [ -d "$ROOT/$dir" ]; then
    ok "Found directory: $dir"
  else
    fail "Missing directory: $dir"
  fi
done

if [ -f "$ROOT/intelligence/obsidian/00-Core/Governance.md" ]; then
  ok "Obsidian Source of Truth Connected."
else
  fail "Missing Obsidian Source of Truth: intelligence/obsidian/00-Core/Governance.md"
fi

if find "$ROOT/bin" -maxdepth 1 -type f -name 'wl-*' -perm -111 | grep -q .; then
  ok "Binaries executable."
else
  fail "No executable wl-* binaries found."
fi

echo
echo "=== 🧭 Governance Doctor ==="

if [ -x "$ROOT/bin/wl-governance" ]; then
  if "$ROOT/bin/wl-governance" doctor; then
    ok "Governance doctor passed."
  else
    fail "Governance doctor failed."
  fi
else
  fail "wl-governance not installed or not executable."
fi

echo
echo "=== 🧾 Registry Doctor ==="

if [ -x "$ROOT/bin/wl-registry" ]; then
  if "$ROOT/bin/wl-registry" doctor; then
    ok "Registry doctor passed."
  else
    fail "Registry doctor failed."
  fi
else
  warn "wl-registry not installed or not executable."
fi

echo
if [ "$FAILURES" -eq 0 ]; then
  echo "=== SYSTEM HEALTHY ==="
  exit 0
else
  echo "=== SYSTEM UNHEALTHY: $FAILURES failure(s) ==="
  exit 1
fi
