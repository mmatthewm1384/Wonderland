#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
DATE="$(date +%Y%m%d-%H%M%S)"

GOV="$WL_HOME/vault/09-Governance"
BACKUP="$WL_HOME/backups/governance-long-term-structure-$DATE"

mkdir -p "$BACKUP"

cp -R "$GOV" "$BACKUP/09-Governance" 2>/dev/null || true

mkdir -p \
  "$GOV/authorities/core" \
  "$GOV/authorities/governance" \
  "$GOV/authorities/security" \
  "$GOV/authorities/operations" \
  "$GOV/authorities/platform" \
  "$GOV/authorities/experience" \
  "$GOV/authorities/registry" \
  "$GOV/theomatrix/constitution" \
  "$GOV/theomatrix/canon" \
  "$GOV/theomatrix/realms" \
  "$GOV/theomatrix/entities" \
  "$GOV/theomatrix/visual" \
  "$GOV/theomatrix/behavior" \
  "$GOV/theomatrix/registry" \
  "$GOV/reports" \
  "$GOV/archive"

move_if_exists() {
  local src="$1"
  local dst="$2"

  if [[ -f "$src" ]]; then
    cp "$src" "$dst"
    echo "PASS copied $(basename "$src") -> $dst"
  else
    echo "WARN missing $(basename "$src")"
  fi
}

move_if_exists "$GOV/authorities/wonderland-universal-authority-template.md" \
  "$GOV/authorities/core/wat.md"

move_if_exists "$GOV/authorities/documentation-style-authority.md" \
  "$GOV/authorities/core/wdsa.md"

move_if_exists "$GOV/authorities/visual-style-authority.md" \
  "$GOV/authorities/core/wvsa.md"

move_if_exists "$GOV/authorities/governance-authority.md" \
  "$GOV/authorities/governance/wga.md"

move_if_exists "$GOV/authorities/recovery-authority.md" \
  "$GOV/authorities/governance/wra.md"

move_if_exists "$GOV/authorities/certification-authority.md" \
  "$GOV/authorities/governance/wca.md"

move_if_exists "$GOV/theomatrix/theomatrix-architecture-authority.md" \
  "$GOV/theomatrix/constitution/tma.md"

move_if_exists "$GOV/theomatrix/theomatrix-visual-authority.md" \
  "$GOV/theomatrix/constitution/tmva.md"

move_if_exists "$GOV/theomatrix/theomatrix-behavior-authority.md" \
  "$GOV/theomatrix/constitution/tmba.md"

cat > "$GOV/authorities/registry/wonderland-authority-registry.json" <<EOF
{
  "registry": "wonderland.authorities.v1",
  "created": "$DATE",
  "status": "active",
  "root": "$GOV/authorities",
  "authorities": {
    "core": [
      "core/wat.md",
      "core/wdsa.md",
      "core/wvsa.md"
    ],
    "governance": [
      "governance/wga.md",
      "governance/wra.md",
      "governance/wca.md"
    ],
    "security": [],
    "operations": [],
    "platform": [],
    "experience": []
  }
}
EOF

cat > "$GOV/theomatrix/registry/theomatrix-authority-registry.json" <<EOF
{
  "registry": "theomatrix.authorities.v1",
  "created": "$DATE",
  "status": "active",
  "root": "$GOV/theomatrix",
  "authorities": {
    "constitution": [
      "constitution/tma.md",
      "constitution/tmva.md",
      "constitution/tmba.md"
    ],
    "canon": [],
    "realms": [],
    "entities": [],
    "visual": [],
    "behavior": []
  }
}
EOF

cat > "$GOV/README.md" <<'EOF'
# Wonderland Governance

## Purpose

Long-term governance root for Wonderland and THE∅MATRIX.

## Structure

```text
09-Governance/

├── authorities/
│   ├── core/
│   ├── governance/
│   ├── security/
│   ├── operations/
│   ├── platform/
│   ├── experience/
│   └── registry/
│
├── theomatrix/
│   ├── constitution/
│   ├── canon/
│   ├── realms/
│   ├── entities/
│   ├── visual/
│   ├── behavior/
│   └── registry/
│
├── reports/
└── archive/

Rule

Wonderland governs infrastructure.

THE∅MATRIX governs living digital cosmology.

Both are long-term systems.

RESULT PASS
EOF

cat > “$WL_HOME/bin/wl-authorities” <<‘EOF’
#!/usr/bin/env bash
set -euo pipefail

WL_HOME=”${WL_HOME:-$HOME/Wonderland}”
GOV=”$WL_HOME/vault/09-Governance”

check_file() {
local label=”$1”
local path=”$2”

if [[ -f “$path” ]]; then
echo “PASS $label”
else
echo “FAIL $label”
return 1
fi
}

case “${1:-verify}” in
verify)
fail=0

check_file WAT  "$GOV/authorities/core/wat.md" || fail=1
check_file WDSA "$GOV/authorities/core/wdsa.md" || fail=1
check_file WVSA "$GOV/authorities/core/wvsa.md" || fail=1

check_file WGA "$GOV/authorities/governance/wga.md" || fail=1
check_file WRA "$GOV/authorities/governance/wra.md" || fail=1
check_file WCA "$GOV/authorities/governance/wca.md" || fail=1

check_file TMA  "$GOV/theomatrix/constitution/tma.md" || fail=1
check_file TMVA "$GOV/theomatrix/constitution/tmva.md" || fail=1
check_file TMBA "$GOV/theomatrix/constitution/tmba.md" || fail=1

check_file wonderland-registry "$GOV/authorities/registry/wonderland-authority-registry.json" || fail=1
check_file theomatrix-registry "$GOV/theomatrix/registry/theomatrix-authority-registry.json" || fail=1

echo

if [[ "$fail" -eq 0 ]]; then
  echo "RESULT PASS"
else
  echo "RESULT FAIL"
  exit 1
fi
;;
tree)
find “$GOV” -maxdepth 4 -type f | sort
;;

status)
“$0” verify
;;

backup)
echo “$WL_HOME/backups”
;;

*)
echo “Usage: wl-authorities verify|status|tree|backup”
exit 2
;;
esac
EOF

chmod +x “$WL_HOME/bin/wl-authorities”

echo
echo “PASS long-term-authority-structure”
echo “backup: $BACKUP”
echo
“$WL_HOME/bin/wl-authorities” verify
