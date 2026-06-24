#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
GOV="$WL_HOME/vault/09-Governance"
REPORT_DIR="$WL_HOME/vault/08-Operations/reports"
STAMP="$(date +%Y%m%d-%H%M%S)"
REPORT="$REPORT_DIR/authority-context-audit-$STAMP.txt"

mkdir -p "$REPORT_DIR"

fail=0

check_contains() {
  local label="$1"
  local path="$2"
  local pattern="$3"
  local severity="${4:-FAIL}"

  if grep -Eiq "$pattern" "$path"; then
    echo "PASS $label" | tee -a "$REPORT"
  else
    echo "$severity $label" | tee -a "$REPORT"
    [[ "$severity" == "FAIL" ]] && fail=1
  fi
}

grade_doc() {
  local code="$1"
  local path="$2"
  local min_words="${3:-180}"

  echo | tee -a "$REPORT"
  echo "== $code ==" | tee -a "$REPORT"
  echo "path: $path" | tee -a "$REPORT"

  if [[ ! -f "$path" ]]; then
    echo "FAIL file-exists" | tee -a "$REPORT"
    fail=1
    return
  fi

  local words
  words="$(wc -w < "$path" | tr -d ' ')"

  check_contains "authority-code" "$path" "Code:[[:space:]]*$code|Authority:[[:space:]]*$code|\\($code\\)"
  check_contains "purpose" "$path" "^##[[:space:]]+Purpose"
  check_contains "scope" "$path" "^##[[:space:]]+Scope"
  check_contains "authority-hierarchy" "$path" "Parent:|Parent Authority|Authority Hierarchy|Parent"
  check_contains "principles" "$path" "Persistent|Recoverable|Auditable|Secure|Automated|Versioned|Modular" "WARN"

  check_contains "context-model" "$path" "Context|Model|Palette|Mapping|Entity|Realm|Architecture|Behavior|Governance|Recovery|Certification"
  check_contains "inputs-or-applicability" "$path" "Applies to|Inputs|Consumers|Surfaces|Services|Applications|Entities|Realms"
  check_contains "outputs-or-artifacts" "$path" "Required Artifacts|Artifacts|Outputs|Reports|Registry|Visual Reference|Asset" "WARN"

  check_contains "verification" "$path" "^[[:space:]]*##[[:space:]]+Verification"
  check_contains "recovery" "$path" "^[[:space:]]*##[[:space:]]+Recovery"
  check_contains "rollback" "$path" "^[[:space:]]*##[[:space:]]+Rollback"
  check_contains "certification" "$path" "^[[:space:]]*##[[:space:]]+Certification"

  check_contains "pass-criteria" "$path" "PASS[[:space:]][a-zA-Z0-9_-]+"
  check_contains "result-block" "$path" "RESULT PASS|RESULT FAIL"
  check_contains "machine-readable-context" "$path" "Code:|Version:|Status:|authority:|status:" "WARN"

  if [[ "$words" -ge "$min_words" ]]; then
    echo "PASS minimum-length words=$words min=$min_words" | tee -a "$REPORT"
  else
    echo "FAIL minimum-length words=$words min=$min_words" | tee -a "$REPORT"
    fail=1
  fi
}

echo "Wonderland Authority Context Audit" | tee "$REPORT"
echo "WL_HOME=$WL_HOME" | tee -a "$REPORT"
echo "created=$STAMP" | tee -a "$REPORT"

grade_doc WAT  "$GOV/authorities/core/wat.md" 220
grade_doc WDSA "$GOV/authorities/core/wdsa.md" 220
grade_doc WVSA "$GOV/authorities/core/wvsa.md" 220

grade_doc WGA "$GOV/authorities/governance/wga.md" 180
grade_doc WRA "$GOV/authorities/governance/wra.md" 180
grade_doc WCA "$GOV/authorities/governance/wca.md" 180

grade_doc WCPA "$GOV/authorities/experience/wcpa.md" 150

grade_doc WLA "$GOV/authorities/platform/wla.md" 220

grade_doc TMA  "$GOV/theomatrix/constitution/tma.md" 180
grade_doc TMVA "$GOV/theomatrix/constitution/tmva.md" 180
grade_doc TMBA "$GOV/theomatrix/constitution/tmba.md" 180
grade_doc TMCA "$GOV/theomatrix/constitution/tmca.md" 150

echo | tee -a "$REPORT"
echo "Report: $REPORT" | tee -a "$REPORT"
echo | tee -a "$REPORT"

if [[ "$fail" -eq 0 ]]; then
  echo "RESULT PASS" | tee -a "$REPORT"
else
  echo "RESULT FAIL" | tee -a "$REPORT"
  exit 1
fi
