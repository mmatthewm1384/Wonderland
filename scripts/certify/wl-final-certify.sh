#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
REPORT="$WL_HOME/vault/08-Operations/reports/final-certification-$(date +%Y%m%d-%H%M%S).md"

mkdir -p "$(dirname "$REPORT")"

{
  echo "# Wonderland Final Certification"
  echo
  date
  echo
  echo "## Path"
  which -a wl
  echo
  echo "## Rootless"
  wl rootless status
  echo
  echo "## Universe"
  wl universe status
  echo
  echo "## Containers"
  nerdctl ps --format '{{.Names}} {{.Status}} {{.Ports}}'
} | tee "$REPORT"

echo
echo "PASS report written: $REPORT"
