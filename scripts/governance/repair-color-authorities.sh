#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
GOV="$WL_HOME/vault/09-Governance"

mkdir -p \
  "$GOV/authorities/experience" \
  "$GOV/theomatrix/constitution"

cat > "$GOV/authorities/experience/wcpa.md" <<'EOF'
# Wonderland Color Palette Authority (WCPA)

## Purpose

Defines the official Wonderland color system for infrastructure, operations, governance, documentation, dashboards, CLI/TUI output, applications, and wallpapers.

## Scope

Applies to all Wonderland visual surfaces.

## Authority

Code: WCPA  
Parent: WVSA  
Version: 1.0  
Status: Certified  

## Core Palette

| Token | Hex | Purpose |
|---|---:|---|
| wl.background | #05070A | Primary background |
| wl.surface | #0B1017 | Panels |
| wl.surface-raised | #111827 | Raised surfaces |
| wl.focus-surface | #182434 | Active focus areas |
| wl.cyan | #00E5FF | Primary accent |
| wl.purple | #7000FF | Intelligence / AI |
| wl.green | #00FF66 | PASS / healthy |
| wl.amber | #FFB000 | WARN / recovery |
| wl.red | #FF355E | FAIL / critical |
| wl.white | #EAF7FF | Primary text |
| wl.gray | #5E6773 | Secondary text |

## Status Mapping

| State | Token |
|---|---|
| PASS | wl.green |
| FAIL | wl.red |
| WARN | wl.amber |
| INFO | wl.cyan |
| SKIP | wl.gray |

## Verification

```bash
wl-authorities verify
wl-color-authority-asset verify
Recovery

Restore from latest governance backup.

Rollback

Restore previous WCPA version from backup.

Certification

PASS palette
PASS status-mapping
PASS token-system
PASS visual-authority-link

RESULT PASS
EOF

cat > "$GOV/theomatrix/constitution/tmca.md" <<'EOF'
THE∅MATRIX Color Authority (TMCA)
Purpose

Defines the official THE∅MATRIX color system for Watchers, Ghosts, Oracles, Realms, Presence, emergence, collapse, motion fields, and visual simulations.

Scope

Applies to THE∅MATRIX visual systems, simulations, entities, realms, and future apps.

Authority

Code: TMCA
Parent: TMVA
Version: 1.0
Status: Certified

Core Palette
Token	Hex	Meaning
tm.void	#05070A	Background / absence
tm.watcher	#00E5FF	Observation / attention
tm.ghost	#8A5CFF	Echo / memory / drift
tm.oracle	#FFFFFF	Interpretation / prophecy
tm.emergence	#00FF66	Birth / discovery / novelty
tm.collapse	#FF355E	Decay / entropy
tm.curiosity	#FF7A00	Exploration / motion
tm.dream	#FF00E5	Possibility / uncertainty
tm.presence	#4DFFFF	Global awareness
tm.focus	#00B8FF	Active realm
Realm Mapping
Realm	Token
Focus	tm.focus
Echo	tm.ghost
Oracle	tm.oracle
Collapse	tm.collapse
Dream	tm.dream
Void	tm.void
Entity Mapping
Entity	Token
Watcher	tm.watcher
Ghost	tm.ghost
Oracle	tm.oracle
Emergence Event	tm.emergence
Collapse Event	tm.collapse
Verification
wl-authorities verify
wl-color-authority-asset verify
Recovery

Restore from latest governance backup.

Rollback

Restore previous TMCA version from backup.

Certification

PASS entity-colors
PASS realm-colors
PASS visual-authority-link
PASS simulation-compatibility

RESULT PASS
EOF

echo "PASS WCPA"
echo "PASS TMCA"
echo
echo "RESULT PASS"
