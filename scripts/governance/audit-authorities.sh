#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
GOV="$WL_HOME/vault/09-Governance"
ASSETS="$WL_HOME/assets/governance/color-authorities"
REPORT_DIR="$WL_HOME/vault/08-Operations/reports"
REPORT="$REPORT_DIR/authority-organization-audit-$(date +%Y%m%d-%H%M%S).txt"

mkdir -p "$REPORT_DIR"

fail=0

check_file() {
  local label="$1"
  local path="$2"

  if [[ -f "$path" ]]; then
    echo "PASS $label: $path" | tee -a "$REPORT"
  else
    echo "FAIL $label: $path" | tee -a "$REPORT"
    fail=1
  fi
}

check_dir() {
  local label="$1"
  local path="$2"

  if [[ -d "$path" ]]; then
    echo "PASS $label: $path" | tee -a "$REPORT"
  else
    echo "FAIL $label: $path" | tee -a "$REPORT"
    fail=1
  fi
}

echo "Wonderland Authority Organization Audit" | tee "$REPORT"
echo "WL_HOME=$WL_HOME" | tee -a "$REPORT"
echo | tee -a "$REPORT"

check_dir "governance-root" "$GOV"

check_dir "authorities-core" "$GOV/authorities/core"
check_dir "authorities-governance" "$GOV/authorities/governance"
check_dir "authorities-experience" "$GOV/authorities/experience"
check_dir "authorities-registry" "$GOV/authorities/registry"

check_dir "theomatrix-constitution" "$GOV/theomatrix/constitution"
check_dir "theomatrix-canon" "$GOV/theomatrix/canon"
check_dir "theomatrix-realms" "$GOV/theomatrix/realms"
check_dir "theomatrix-entities" "$GOV/theomatrix/entities"
check_dir "theomatrix-visual" "$GOV/theomatrix/visual"
check_dir "theomatrix-behavior" "$GOV/theomatrix/behavior"
check_dir "theomatrix-registry" "$GOV/theomatrix/registry"

echo | tee -a "$REPORT"
echo "== Documents ==" | tee -a "$REPORT"

check_file "WAT"  "$GOV/authorities/core/wat.md"
check_file "WDSA" "$GOV/authorities/core/wdsa.md"
check_file "WVSA" "$GOV/authorities/core/wvsa.md"

check_file "WGA" "$GOV/authorities/governance/wga.md"
check_file "WRA" "$GOV/authorities/governance/wra.md"
check_file "WCA" "$GOV/authorities/governance/wca.md"

check_file "WCPA" "$GOV/authorities/experience/wcpa.md"

check_file "TMA"  "$GOV/theomatrix/constitution/tma.md"
check_file "TMVA" "$GOV/theomatrix/constitution/tmva.md"
check_file "TMBA" "$GOV/theomatrix/constitution/tmba.md"
check_file "TMCA" "$GOV/theomatrix/constitution/tmca.md"

echo | tee -a "$REPORT"
echo "== Registries ==" | tee -a "$REPORT"

check_file "wonderland-authority-registry" "$GOV/authorities/registry/wonderland-authority-registry.json"
check_file "theomatrix-authority-registry" "$GOV/theomatrix/registry/theomatrix-authority-registry.json"

echo | tee -a "$REPORT"
echo "== Visual Asset ==" | tee -a "$REPORT"

check_file "color-authority-image" "$ASSETS/wonderland-theomatrix-color-authority-v1.png"
check_file "color-authority-metadata" "$ASSETS/wonderland-theomatrix-color-authority-v1.metadata.json"
check_file "color-authority-checksum" "$ASSETS/wonderland-theomatrix-color-authority-v1.sha256"
check_file "color-authority-readme" "$ASSETS/README.md"

if [[ -f "$ASSETS/wonderland-theomatrix-color-authority-v1.sha256" ]]; then
  if shasum -a 256 -c "$ASSETS/wonderland-theomatrix-color-authority-v1.sha256" >/dev/null 2>&1; then
    echo "PASS checksum-valid" | tee -a "$REPORT"
  else
    echo "FAIL checksum-valid" | tee -a "$REPORT"
    fail=1
  fi
fi

echo | tee -a "$REPORT"
echo "== Commands ==" | tee -a "$REPORT"

check_file "wl-authorities" "$WL_HOME/bin/wl-authorities"
check_file "wl-color-authority-asset" "$WL_HOME/bin/wl-color-authority-asset"

echo | tee -a "$REPORT"
echo "== Command Verification ==" | tee -a "$REPORT"

if command -v "$WL_HOME/bin/wl-authorities" >/dev/null 2>&1; then
  "$WL_HOME/bin/wl-authorities" verify | tee -a "$REPORT" || fail=1
fi

if command -v "$WL_HOME/bin/wl-color-authority-asset" >/dev/null 2>&1; then
  "$WL_HOME/bin/wl-color-authority-asset" verify | tee -a "$REPORT" || fail=1
fi

echo | tee -a "$REPORT"
echo "Report: $REPORT" | tee -a "$REPORT"
echo | tee -a "$REPORT"

if [[ "$fail" -eq 0 ]]; then
  echo "RESULT PASS" | tee -a "$REPORT"
else
  echo "RESULT FAIL" | tee -a "$REPORT"
  exit 1
fi
