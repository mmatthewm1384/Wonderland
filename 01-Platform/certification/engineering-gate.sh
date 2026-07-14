#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"
cd "$WL_ROOT"

failures=0

run_gate() {
  local title="$1"
  shift

  echo "== $title =="
  if "$@"; then
    echo "PASS $title"
  else
    echo "FAIL $title"
    failures=$((failures + 1))
  fi
  echo
}

echo "Wonderland Engineering Gate"
echo

run_gate "Registry Service" bin/wl-registry verify
run_gate "Architecture Gate" python3 01-Platform/architecture/engine.py gate --root "$WL_ROOT"
run_gate "Builder Ownership" bin/wl-builder-ownership
run_gate "Manifest Index" bin/wl-manifest-index

if [ "$failures" -eq 0 ]; then
  echo "PASS engineering gate"
  echo "RESULT PASS"
  exit 0
fi

echo "FAIL engineering gate: $failures failure(s)"
echo "RESULT FAIL"
exit 1
