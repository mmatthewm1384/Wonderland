#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
APP="$WL_HOME/apps/macos/wl-chaos-menubar"
BIN="$APP/build/wl-chaos-menubar"
SRC="$APP/Sources/wl-chaos-menubar/main.swift"
PANIC="$WL_HOME/Wonderland-v4/ephemeral/bin/wl-chaos-panic"
CHAOS="$WL_HOME/vault/chaos"
AETHER="$CHAOS/chaos-aether.json"
REPORT="$CHAOS/menubar-certification.txt"

mkdir -p "$CHAOS"

fail=0
check() {
  if eval "$2"; then
    echo "PASS $1"
  else
    echo "FAIL $1"
    fail=1
  fi
}

{
  echo "Wonderland Chaos Menubar Certification"
  echo "created=$(date -Iseconds)"
  echo

  check "source exists" "[[ -f '$SRC' ]]"
  check "binary exists" "[[ -x '$BIN' ]]"
  check "panic exists" "[[ -x '$PANIC' ]]"
  check "source reads chaos marker" "grep -q 'permanent_high_chaos' '$SRC'"
  check "source has panic action" "grep -q 'wl-chaos-panic' '$SRC'"
  check "panic writes chaos marker" "grep -q 'permanent_high_chaos' '$PANIC'"

  echo
  "$PANIC" --yes --reason=certification-test >/dev/null

  check "aether exists" "[[ -f '$AETHER' ]]"
  check "aether active" "grep -q 'permanent_high_chaos' '$AETHER'"
  check "panic log updated" "grep -q 'certification-test' '$CHAOS/panic.log'"

  echo
  if [[ "$fail" == "0" ]]; then
    echo "RESULT PASS"
  else
    echo "RESULT FAIL"
    exit 1
  fi
} | tee "$REPORT"

echo
echo "report: $REPORT"
