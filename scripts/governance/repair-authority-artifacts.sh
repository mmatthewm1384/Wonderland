#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
GOV="$WL_HOME/vault/09-Governance"

patch_artifacts() {
  local path="$1"
  local code="$2"
  local artifacts="$3"

  [[ -f "$path" ]] || return 0

  if ! grep -Eiq "Required Artifacts|Controlled Artifacts|## Artifacts" "$path"; then
    cat >> "$path" <<EOF

## Required Artifacts

This authority controls the following artifacts:

\`\`\`text
$artifacts
\`\`\`

Each artifact must remain versioned, recoverable, auditable, and verifiable.
EOF
  fi
}

patch_artifacts "$GOV/authorities/core/wat.md" "WAT" \
"authority templates
authority.yaml
README.md
verification.md
recovery.md
handoff.md"

patch_artifacts "$GOV/authorities/core/wdsa.md" "WDSA" \
"documentation standards
markdown files
runbooks
handoffs
reports"

patch_artifacts "$GOV/authorities/core/wvsa.md" "WVSA" \
"visual style guides
palette documents
theme files
dashboard references
wallpaper references"

patch_artifacts "$GOV/authorities/governance/wga.md" "WGA" \
"governance policies
authority registry
ownership records
compliance reports"

patch_artifacts "$GOV/authorities/governance/wra.md" "WRA" \
"backup records
restore procedures
recovery drills
rollback records"

patch_artifacts "$GOV/authorities/governance/wca.md" "WCA" \
"certification records
PASS criteria
recertification reports
authority status blocks"

patch_artifacts "$GOV/authorities/experience/wcpa.md" "WCPA" \
"color tokens
CSS variables
palette references
governance color visualization assets"

patch_artifacts "$GOV/theomatrix/constitution/tma.md" "TMA" \
"entity definitions
realm definitions
presence models
architecture registries"

patch_artifacts "$GOV/theomatrix/constitution/tmva.md" "TMVA" \
"visual motion rules
geometry rules
simulation visual standards
THEOMATRIX visual assets"

patch_artifacts "$GOV/theomatrix/constitution/tmba.md" "TMBA" \
"behavior models
attention models
curiosity models
memory models
emergence rules"

patch_artifacts "$GOV/theomatrix/constitution/tmca.md" "TMCA" \
"THEOMATRIX color tokens
realm color mapping
entity color mapping
simulation palette references"

echo "PASS required-artifacts-patched"
echo
"$WL_HOME/scripts/governance/audit-authority-context.sh"
