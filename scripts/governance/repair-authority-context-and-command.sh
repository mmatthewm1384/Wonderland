#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
GOV="$WL_HOME/vault/09-Governance"
BIN="$WL_HOME/bin/wl-authorities"

patch_doc() {
  local path="$1"
  local code="$2"
  local parent="$3"

  [[ -f "$path" ]] || return 0

  if ! grep -Eiq "Parent:|Authority Hierarchy|Parent Authority" "$path"; then
    cat >> "$path" <<EOF

## Authority Hierarchy

Code: $code  
Parent: $parent  
Layer: Governance Constitution  

This authority is governed by the Wonderland authority stack and participates in verification, recovery, rollback, and certification workflows.
EOF
  fi
}

patch_doc "$GOV/authorities/core/wat.md" "WAT" "ROOT"
patch_doc "$GOV/authorities/core/wdsa.md" "WDSA" "WAT"
patch_doc "$GOV/authorities/core/wvsa.md" "WVSA" "WAT"

patch_doc "$GOV/authorities/governance/wga.md" "WGA" "WAT"
patch_doc "$GOV/authorities/governance/wra.md" "WRA" "WAT"
patch_doc "$GOV/authorities/governance/wca.md" "WCA" "WAT"

patch_doc "$GOV/authorities/experience/wcpa.md" "WCPA" "WVSA"

patch_doc "$GOV/theomatrix/constitution/tma.md" "TMA" "WAT"
patch_doc "$GOV/theomatrix/constitution/tmva.md" "TMVA" "TMA"
patch_doc "$GOV/theomatrix/constitution/tmba.md" "TMBA" "TMA"
patch_doc "$GOV/theomatrix/constitution/tmca.md" "TMCA" "TMVA"

if [[ ! -f "$BIN" ]]; then
  mkdir -p "$WL_HOME/bin"
  cat > "$BIN" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
GOV="$WL_HOME/vault/09-Governance"

case "${1:-verify}" in
  verify)
    "$WL_HOME/scripts/governance/audit-authorities.sh"
    ;;

  context)
    "$WL_HOME/scripts/governance/audit-authority-context.sh"
    ;;

  tree)
    find "$GOV" -maxdepth 5 -type f | sort
    ;;

  status)
    "$0" verify
    "$0" context
    ;;

  *)
    echo "Usage: wl-authorities verify|context|tree|status"
    exit 2
    ;;
esac
EOF
else
  cp "$BIN" "$BIN.bak.$(date +%Y%m%d-%H%M%S)"

  if ! grep -q "context)" "$BIN"; then
    python3 - <<'PY'
from pathlib import Path

p = Path.home() / "Wonderland/bin/wl-authorities"
s = p.read_text()

insert = '''  context)
    "$WL_HOME/scripts/governance/audit-authority-context.sh"
    ;;

'''

if "  status)" in s:
    s = s.replace("  status)\n", insert + "  status)\n", 1)
else:
    s = s.replace("  *)\n", insert + "  *)\n", 1)

s = s.replace(
    "Usage: wl-authorities verify|status|tree|backup",
    "Usage: wl-authorities verify|context|status|tree|backup"
)
s = s.replace(
    "Usage: wl-authorities verify|status|tree",
    "Usage: wl-authorities verify|context|status|tree"
)

p.write_text(s)
PY
  fi
fi

chmod +x "$BIN"

echo "PASS authority-hierarchy-patched"
echo "PASS wl-authorities-context-command"
echo
"$BIN" context
