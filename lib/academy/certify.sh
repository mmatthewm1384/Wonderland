#!/usr/bin/env bash
set -euo pipefail
source "$WL_ROOT/lib/academy/common.sh"
source "$WL_ROOT/lib/academy/verify.sh"

academy_certify() {
  "$WL_ROOT/lib/academy/manifest.py" generate
  "$WL_ROOT/lib/academy/build.py" build
  academy_verify

  local out
  out="$(academy_root)/certification"
  mkdir -p "$out"

  cat > "$out/academy-platform-1.0-certified.json" <<JSON
{
  "system": "Wonderland Academy",
  "certification": "Academy Platform 1.0",
  "status": "PASS",
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSON

  academy_pass "certification written: $out/academy-platform-1.0-certified.json"
  echo "RESULT PASS"
}
