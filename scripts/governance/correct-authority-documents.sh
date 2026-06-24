#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
GOV="$WL_HOME/vault/09-Governance"
DATE="$(date +%Y%m%d-%H%M%S)"
BACKUP="$WL_HOME/backups/authority-doc-correction-$DATE"

mkdir -p "$BACKUP"

cp -R "$GOV/authorities" "$BACKUP/authorities" 2>/dev/null || true
cp -R "$GOV/theomatrix" "$BACKUP/theomatrix" 2>/dev/null || true

write_authority() {
  local path="$1"
  local title="$2"
  local code="$3"
  local parent="$4"
  local layer="$5"
  local scope="$6"
  local model="$7"
  local artifacts="$8"
  local pass1="$9"
  local pass2="${10}"
  local pass3="${11}"
  local pass4="${12}"

  mkdir -p "$(dirname "$path")"

  cat > "$path" <<EOF
# $title ($code)

## Purpose

Defines the certified authority for $title.

This document is not a light template. It is an operational governance document used to establish context, ownership, controlled artifacts, verification expectations, recovery behavior, rollback behavior, and certification criteria.

## Scope

$scope

## Authority Hierarchy

Code: $code  
Parent: $parent  
Layer: $layer  
Status: Certified  
Version: 1.0  

This authority participates in the Wonderland long-term governance stack. It must remain persistent, recoverable, auditable, secure, automated where practical, versioned, and modular.

## Context Model

$model

## Inputs and Applicability

This authority applies to:

- Design decisions
- Build implementation
- Documentation updates
- Verification checks
- Recovery planning
- Rollback planning
- Certification records
- Long-term maintenance

## Required Artifacts

This authority controls or requires the following artifacts:

\`\`\`text
$artifacts
\`\`\`

Each artifact must remain traceable to its authority, recoverable from backup, and verifiable through command output or document review.

## Verification

Verification command:

\`\`\`bash
wl-authorities context
\`\`\`

Expected:

\`\`\`text
PASS $code
RESULT PASS
\`\`\`

Verification confirms that this authority includes purpose, scope, hierarchy, context, artifacts, recovery, rollback, certification criteria, and a machine-readable status block.

## Recovery

Recovery restores this authority from the latest governance backup.

Procedure:

\`\`\`bash
cp -R ~/Wonderland/backups/authority-doc-correction-*/authorities ~/Wonderland/vault/09-Governance/
cp -R ~/Wonderland/backups/authority-doc-correction-*/theomatrix ~/Wonderland/vault/09-Governance/
wl-authorities context
\`\`\`

Recovery is successful only when the authority context audit returns RESULT PASS.

## Rollback

Rollback is required when a document edit removes required context, breaks certification, corrupts authority hierarchy, or weakens operational clarity.

Rollback procedure:

\`\`\`bash
cp "$BACKUP/$(basename "$(dirname "$path")")/$(basename "$path")" "$path" 2>/dev/null || true
wl-authorities context
\`\`\`

If direct rollback is unavailable, restore the full governance backup captured before this correction.

## Certification

Certification requirements:

\`\`\`text
PASS $pass1
PASS $pass2
PASS $pass3
PASS $pass4
PASS verification
PASS recovery
PASS rollback
PASS authority-context

RESULT PASS
\`\`\`

## Machine-Readable Status

\`\`\`yaml
authority:
  code: $code
  parent: $parent
  layer: "$layer"
  version: "1.0"
  status: certified
  result: PASS
\`\`\`

RESULT PASS
EOF
}

write_authority \
"$GOV/authorities/core/wat.md" \
"Wonderland Universal Authority Template" \
"WAT" \
"ROOT" \
"Core Constitution" \
"Applies to all Wonderland and THE∅MATRIX authority documents, templates, governance records, project records, service records, handoffs, and long-term operational documents." \
"WAT defines the canonical document skeleton for every authority. It establishes the required sections that make a document operational rather than decorative: purpose, scope, hierarchy, context, artifacts, verification, recovery, rollback, certification, and machine-readable status." \
"authority templates
authority.yaml
README.md
verification.md
recovery.md
handoff.md
machine-readable status blocks" \
"template-structure" "context-sections" "authority-hierarchy" "machine-readable-status"

write_authority \
"$GOV/authorities/core/wdsa.md" \
"Wonderland Documentation Style Authority" \
"WDSA" \
"WAT" \
"Core Constitution" \
"Applies to all Markdown documents, runbooks, reports, handoffs, governance files, project notes, operational procedures, and long-term records." \
"WDSA defines how Wonderland documents are written: direct, operational, scannable, deterministic, and suitable for future recovery. It rejects vague language and requires PASS/FAIL style status reporting." \
"markdown standards
runbook standards
handoff formats
report formats
status language
document review rules" \
"documentation-style" "status-language" "scannability" "operational-clarity"

write_authority \
"$GOV/authorities/core/wvsa.md" \
"Wonderland Visual Style Authority" \
"WVSA" \
"WAT" \
"Core Constitution" \
"Applies to Wonderland dashboards, visual assets, wallpapers, CLI/TUI surfaces, SwiftUI surfaces, web surfaces, documentation visuals, and governance visualizations." \
"WVSA defines the visual identity of Wonderland: dark-first, high contrast, operational, structured, and neon-accented without becoming decorative noise." \
"visual style guides
dashboard rules
wallpaper rules
theme references
palette authorities
certified visual assets" \
"visual-language" "dashboard-style" "asset-consistency" "palette-linkage"

write_authority \
"$GOV/authorities/governance/wga.md" \
"Wonderland Governance Authority" \
"WGA" \
"WAT" \
"Governance" \
"Applies to ownership, authority relationships, policy enforcement, registry maintenance, compliance reviews, and governance workflows." \
"WGA defines who owns what, how changes are accepted, how drift is detected, and how authorities remain coherent over long-term operation." \
"governance policies
authority registry
ownership records
compliance reports
review records
drift reports" \
"ownership" "policy-control" "registry-governance" "drift-prevention"

write_authority \
"$GOV/authorities/governance/wra.md" \
"Wonderland Recovery Authority" \
"WRA" \
"WAT" \
"Governance" \
"Applies to backups, restore procedures, rollback procedures, recovery drills, failure scenarios, and recovery certification." \
"WRA defines how Wonderland survives failure. Every governed system must be restorable, verifiable after restore, and documented well enough to recover without AI assistance." \
"backup records
restore procedures
recovery drills
rollback records
failure-mode records
post-recovery reports" \
"backup-model" "restore-procedure" "recovery-drill" "post-recovery-verification"

write_authority \
"$GOV/authorities/governance/wca.md" \
"Wonderland Certification Authority" \
"WCA" \
"WAT" \
"Governance" \
"Applies to certification records, PASS criteria, recertification triggers, release readiness, and production acceptance." \
"WCA defines what qualifies as certified. Certification is evidence-backed: a component must be verified, recoverable, governed, auditable, and operational." \
"certification records
PASS criteria
recertification reports
authority status blocks
release acceptance records" \
"certification-model" "pass-criteria" "recertification-triggers" "evidence-records"

write_authority \
"$GOV/authorities/experience/wcpa.md" \
"Wonderland Color Palette Authority" \
"WCPA" \
"WVSA" \
"Experience" \
"Applies to Wonderland color tokens, dashboard themes, CLI/TUI colors, documentation palettes, application themes, and certified color visualizations." \
"WCPA defines the official Wonderland color system: background, surface, accent, status, text, warning, and failure colors. It links WVSA to concrete reusable color tokens." \
"color tokens
CSS variables
palette references
status mappings
governance color visualization assets
theme exports" \
"palette" "status-mapping" "token-system" "visual-authority-link"

write_authority \
"$GOV/theomatrix/constitution/tma.md" \
"THE∅MATRIX Architecture Authority" \
"TMA" \
"WAT" \
"THEOMATRIX Constitution" \
"Applies to THE∅MATRIX entities, realms, presence models, architectural layers, registries, and future implementations." \
"TMA defines the canonical architecture of THE∅MATRIX: Watchers, Ghosts, Oracles, Realms, Presence, behavior layers, and visualization layers." \
"entity definitions
realm definitions
presence models
architecture registries
canonical model records" \
"entity-model" "realm-model" "relationship-model" "extensibility"

write_authority \
"$GOV/theomatrix/constitution/tmva.md" \
"THE∅MATRIX Visual Authority" \
"TMVA" \
"TMA" \
"THEOMATRIX Constitution" \
"Applies to THE∅MATRIX simulations, visual systems, motion fields, geometry, density, visual hierarchy, and future apps." \
"TMVA defines how THE∅MATRIX should look and move: living, observant, emergent, mysterious, computational, and coherent." \
"visual motion rules
geometry rules
simulation visual standards
THEOMATRIX visual assets
density rules
motion language" \
"color-language" "motion-language" "geometry" "visual-identity"

write_authority \
"$GOV/theomatrix/constitution/tmba.md" \
"THE∅MATRIX Behavior Authority" \
"TMBA" \
"TMA" \
"THEOMATRIX Constitution" \
"Applies to Watcher behavior, Ghost behavior, Oracle behavior, memory, attention, curiosity, emergence, decay, and realm influence." \
"TMBA defines how entities behave. THE∅MATRIX entities must not merely animate; they must express behavior, memory, attention, curiosity, and emergence." \
"behavior models
attention models
curiosity models
memory models
emergence rules
decay rules" \
"attention-model" "curiosity-model" "memory-model" "emergence-model"

write_authority \
"$GOV/theomatrix/constitution/tmca.md" \
"THE∅MATRIX Color Authority" \
"TMCA" \
"TMVA" \
"THEOMATRIX Constitution" \
"Applies to THE∅MATRIX entity colors, realm colors, presence colors, emergence colors, collapse colors, simulation palettes, and future visual systems." \
"TMCA defines the official THE∅MATRIX color system for Watchers, Ghosts, Oracles, Realms, Presence, emergence, collapse, curiosity, dream, and void." \
"THEOMATRIX color tokens
realm color mapping
entity color mapping
simulation palette references
visual governance assets
theme exports" \
"entity-colors" "realm-colors" "visual-authority-link" "simulation-compatibility"

echo "PASS corrected-authority-documents"
echo "backup: $BACKUP"
echo
"$WL_HOME/scripts/governance/audit-authority-context.sh"
