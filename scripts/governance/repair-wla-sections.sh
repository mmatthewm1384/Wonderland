#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WLA="$WL_HOME/vault/09-Governance/authorities/platform/wla.md"
DATE="$(date +%Y%m%d-%H%M%S)"
BACKUP="$WL_HOME/backups/wla-section-repair-$DATE"

mkdir -p "$BACKUP"
cp "$WLA" "$BACKUP/wla.md.bak"

cat >> "$WLA" <<'EOF'

## Verification

Verification command:

```bash
wl-language verify
wl-authorities context
Expected result:

PASS WLA-document
PASS language-registry
PASS registry-json
RESULT PASS
Recovery

Recovery restores the Wonderland Language Authority and its registry from the latest governance backup.

Procedure:

cp -R ~/Wonderland/backups/language-authority-*/authorities/platform/wla.md \
  ~/Wonderland/vault/09-Governance/authorities/platform/wla.md

cp -R ~/Wonderland/backups/language-authority-*/authorities/registry/language-registry.json \
  ~/Wonderland/vault/09-Governance/authorities/registry/language-registry.json

wl-language verify
wl-authorities context
Rollback

Rollback is required when the approved language set changes without justification, when a new language enters the system without registry approval, or when the language registry becomes invalid.

Procedure:

cp -R ~/Wonderland/backups/wla-section-repair-*/wla.md.bak \
  ~/Wonderland/vault/09-Governance/authorities/platform/wla.md

wl-language verify
wl-authorities context
Certification

Certification requirements:

PASS approved-language-set
PASS decision-matrix
PASS drift-control
PASS language-registry
PASS verification
PASS recovery
PASS rollback
PASS authority-context

RESULT PASS

EOF

echo "PASS WLA-section-repair"
echo "backup: $BACKUP"
echo
wl-authorities context
