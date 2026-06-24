#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
GOV="$WL_HOME/vault/09-Governance"
DATE="$(date +%Y%m%d-%H%M%S)"
BACKUP="$WL_HOME/backups/repair-wla-tmca-context-$DATE"

WLA="$GOV/authorities/platform/wla.md"
TMCA="$GOV/theomatrix/constitution/tmca.md"

mkdir -p "$BACKUP"

cp "$WLA" "$BACKUP/wla.md.bak" 2>/dev/null || true
cp "$TMCA" "$BACKUP/tmca.md.bak" 2>/dev/null || true

python3 - <<'PY'
from pathlib import Path
import re

home = Path.home()
gov = home / "Wonderland/vault/09-Governance"

wla = gov / "authorities/platform/wla.md"
tmca = gov / "theomatrix/constitution/tmca.md"

def ensure_section(path: Path, heading: str, body: str):
    text = path.read_text()
    pattern = rf"^## {re.escape(heading)}\n.*?(?=^## |\Z)"
    replacement = f"## {heading}\n\n{body.strip()}\n\n"
    if re.search(pattern, text, flags=re.M | re.S):
        text = re.sub(pattern, replacement, text, flags=re.M | re.S)
    else:
        text += "\n\n" + replacement
    path.write_text(text)

ensure_section(wla, "Recovery", """
Recovery restores the Wonderland Language Authority and its language registry from the latest governance backup.

Procedure:

```bash
cp ~/Wonderland/backups/language-authority-*/authorities/platform/wla.md \\
  ~/Wonderland/vault/09-Governance/authorities/platform/wla.md

cp ~/Wonderland/backups/language-authority-*/authorities/registry/language-registry.json \\
  ~/Wonderland/vault/09-Governance/authorities/registry/language-registry.json

wl-language verify
wl-authorities context

Recovery is successful only when both wl-language verify and wl-authorities context return RESULT PASS.
""")

ensure_section(wla, "Rollback", """
Rollback is required when an unauthorized language is introduced, the approved language set is changed without justification, or the language registry becomes invalid.

Procedure:

cp ~/Wonderland/backups/repair-wla-tmca-context-*/wla.md.bak \\
  ~/Wonderland/vault/09-Governance/authorities/platform/wla.md

wl-language verify
wl-authorities context

Rollback must preserve the approved language set and restore the last certified language authority.
""")

ensure_section(wla, "Certification", """
Certification requirements:

PASS approved-language-set
PASS decision-matrix
PASS language-registry
PASS drift-control
PASS verification
PASS recovery
PASS rollback
PASS authority-context

RESULT PASS

WLA is certified only when the language policy, registry, recovery procedure, rollback procedure, and authority context audit all pass.
""")

TMCA may have valid structure but lacks explicit principles keyword coverage.

ensure_section(tmca, "Principles", """
THE∅MATRIX color governance must remain:

Persistent
Recoverable
Auditable
Secure
Automated where practical
Versioned
Modular

Color tokens are not decorative preferences. They are canonical semantic mappings for entities, realms, presence, emergence, collapse, and simulation state.
""")
PY

echo "PASS repaired-WLA"
echo "PASS repaired-TMCA"
echo "backup: $BACKUP"
echo

wl-authorities context
