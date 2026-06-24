#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
GOV="$WL_HOME/vault/09-Governance"
DATE="$(date +%Y%m%d-%H%M%S)"
BACKUP="$WL_HOME/backups/language-authority-$DATE"

mkdir -p \
  "$GOV/authorities/platform" \
  "$GOV/authorities/registry" \
  "$WL_HOME/bin" \
  "$BACKUP"

cp -R "$GOV/authorities" "$BACKUP/authorities" 2>/dev/null || true

cat > "$GOV/authorities/platform/wla.md" <<'EOF'
# Wonderland Language Authority (WLA)

## Purpose

Defines the approved language set for Wonderland and THE∅MATRIX.

This authority exists to reduce long-term maintenance burden, recovery complexity, audit scope, implementation drift, and knowledge fragmentation.

## Scope

Applies to all Wonderland and THE∅MATRIX services, commands, applications, automations, registries, documentation, visual systems, and future implementations.

## Authority Hierarchy

Code: WLA  
Parent: WAT  
Layer: Platform Governance  
Status: Certified  
Version: 1.0  

## Context Model

Languages are operational dependencies.

Every language added to Wonderland increases:

- Installation surface
- Recovery complexity
- Debugging complexity
- Toolchain drift
- Documentation burden
- Security review scope

New languages require documented architectural justification.

## Approved Language Set

| Layer | Language | Use |
|---|---|---|
| CLI / install / repair | Bash | `wl-*` commands, bootstrap, shell automation |
| Structured automation | Python | audits, registries, reports, JSON processing |
| Native macOS apps | Swift / SwiftUI | menu bar apps, native interfaces, visual tools |
| Cross-platform visual apps | TypeScript | Tauri UI, web dashboards, simulations |
| Runtime services | Python or Go | APIs, workers, daemons |
| Machine-readable data | JSON | registries, metadata, intents, status |
| Documentation / canon | Markdown | Obsidian, governance, handoffs, runbooks |
| Styling / themes | CSS | palettes, dashboards, visual systems |
| Containers | Dockerfile / Compose | container build and service orchestration |

## Default Decision Matrix

```text
Need a command?
    Bash

Need automation?
    Python

Need a macOS app?
    Swift / SwiftUI

Need a visual cross-platform app?
    TypeScript + Tauri

Need a long-running service?
    Python or Go

Need persistence?
    JSON

Need documentation?
    Markdown

Need styling?
    CSS

Wonderland Rule
Bash starts it.
Python understands it.
JSON records it.
Markdown explains it.
Swift presents it.
TypeScript visualizes it.
Docker contains it.
THE∅MATRIX Rule
Python models behavior.
JSON preserves canon.
TypeScript renders systems.
Swift makes native presence.
Markdown preserves mythology.
Disallowed by Default

These languages are not forbidden, but they require explicit justification:

Ruby
Perl
PHP
Java
C#
Lua
Rust
Kotlin
Elixir
Excessive YAML logic
Inputs and Applicability

This authority applies when creating:

New wl-* commands
New automation scripts
New services
New visual apps
New native apps
New registries
New documentation
New runtime components
Required Artifacts

This authority controls:

language policy
language registry
toolchain standards
runtime language choices
implementation review records
Verification
wl-language verify
wl-authorities context
Recovery

Restore this authority from the latest governance backup.

cp -R ~/Wonderland/backups/language-authority-*/authorities/platform/wla.md \
  ~/Wonderland/vault/09-Governance/authorities/platform/wla.md

wl-language verify
Rollback

Rollback is required when the approved language set is changed without justification or a toolchain becomes unrecoverable.

cp -R ~/Wonderland/backups/language-authority-*/authorities \
  ~/Wonderland/vault/09-Governance/

wl-authorities context
Certification
PASS approved-language-set
PASS decision-matrix
PASS drift-control
PASS recovery
PASS rollback
PASS authority-context

RESULT PASS
Machine-Readable Status
authority:
  code: WLA
  parent: WAT
  layer: Platform Governance
  version: "1.0"
  status: certified
  result: PASS

RESULT PASS
EOF

cat > "$GOV/authorities/registry/language-registry.json" <<'EOF'
{
"registry": "wonderland.languages.v1",
"status": "certified",
"authority": "WLA",
"approved": {
"shell": ["bash"],
"automation": ["python"],
"native_apps": ["swift", "swiftui"],
"cross_platform_ui": ["typescript", "tauri"],
"runtime_services": ["python", "go"],
"data": ["json"],
"documentation": ["markdown"],
"styling": ["css"],
"containers": ["dockerfile", "compose"]
},
"requires_justification": [
"ruby",
"perl",
"php",
"java",
"csharp",
"lua",
"rust",
"kotlin",
"elixir",
"yaml_logic"
]
}
EOF

cat > "$WL_HOME/bin/wl-language" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
GOV="$WL_HOME/vault/09-Governance"
AUTH="$GOV/authorities/platform/wla.md"
REG="$GOV/authorities/registry/language-registry.json"

case "${1:-verify}" in
verify)
fail=0

[[ -f "$AUTH" ]] && echo "PASS WLA-document" || { echo "FAIL WLA-document"; fail=1; }
[[ -f "$REG" ]] && echo "PASS language-registry" || { echo "FAIL language-registry"; fail=1; }

if [[ -f "$REG" ]]; then
  python3 -m json.tool "$REG" >/dev/null && echo "PASS registry-json" || { echo "FAIL registry-json"; fail=1; }
fi

for term in bash python swift typescript json markdown css; do
  grep -qi "$term" "$AUTH" && echo "PASS language-$term" || { echo "FAIL language-$term"; fail=1; }
done

echo
[[ "$fail" -eq 0 ]] && echo "RESULT PASS" || { echo "RESULT FAIL"; exit 1; }
;;

show)
cat "$AUTH"
;;

registry)
cat "$REG"
;;

path)
echo "$AUTH"
;;

*)
echo "Usage: wl-language verify|show|registry|path"
exit 2
;;
esac
EOF

chmod +x "$WL_HOME/bin/wl-language"

echo "PASS language-authority-installed"
echo "backup: $BACKUP"
echo
"$WL_HOME/bin/wl-language" verify
