#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
VAULT="$WL_HOME/vault"
REPORT_DIR="$VAULT/90-Operator/operations/reports"
REPORT="$REPORT_DIR/obsidian-certification.md"

mkdir -p "$REPORT_DIR"

{
  echo "# Obsidian Operator Certification"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Checks"
  echo

  check() {
    name="$1"
    shift
    if "$@" >/tmp/wl-obsidian-certify.out 2>&1; then
      echo "- PASS $name"
    else
      echo "- FAIL $name"
      sed 's/^/  /' /tmp/wl-obsidian-certify.out
    fi
  }

  check "wl exists" test -x "$WL_HOME/bin/wl"
  check "wl-obsidian exists" test -x "$WL_HOME/bin/wl-obsidian"
  check "operator home" test -f "$VAULT/90-Operator/dashboard/home.md"
  check "operator intents" test -d "$VAULT/90-Operator/intents"
  check "obsidian status" "$WL_HOME/bin/wl" obsidian status
  check "obsidian verify" "$WL_HOME/bin/wl" obsidian verify
  check "obsidian list" "$WL_HOME/bin/wl" obsidian list
  
echo "- INFO wl doctor runtime state"
"$WL_HOME/bin/wl" doctor > /tmp/wl-obsidian-certify-doctor.out 2>&1 || true
sed 's/^/  /' /tmp/wl-obsidian-certify-doctor.out


  echo
  echo "## Result"
  echo
  echo "Obsidian operator layer is certified if all Obsidian checks are PASS. Runtime/storage failures are reported separately."
} > "$REPORT"

cat "$REPORT"
