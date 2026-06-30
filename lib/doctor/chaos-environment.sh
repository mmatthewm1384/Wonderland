#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_HOME:-$HOME/Wonderland}"

check() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    return 1
  fi
}

check "environment registry exists" test -f "$ROOT/vault/chaos/environment-effects.json"
check "environment registry valid json" jq -e '.schema=="wonderland.chaos.environment.effects.v1" and .models.storm.matrix==true' "$ROOT/vault/chaos/environment-effects.json"
check "environment command exists" test -x "$ROOT/bin/wl-chaos-environment"
check "model command exists" test -x "$ROOT/bin/wl-chaos-model"
check "foundation model writable" bash -lc "$ROOT/bin/wl-chaos-model calm >/dev/null"
check "environment status works" bash -lc "$ROOT/bin/wl-chaos-environment status >/dev/null"

echo "RESULT PASS"
