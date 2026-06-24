#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
BIN="$WL_HOME/bin"
GOV="$WL_HOME/vault/09-Governance"
DATE="$(date +%Y%m%d-%H%M%S)"
BACKUP="$WL_HOME/backups/wl-navigator-$DATE"

mkdir -p "$BIN" "$BACKUP" "$WL_HOME/scripts/install"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! command_exists eza; then
  echo "WARN eza missing"
  echo "Install recommended:"
  echo "  brew install eza"
fi

cat > "$BIN/wl-tree" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
ROOT="${1:-$WL_HOME}"
DEPTH="${WL_TREE_DEPTH:-3}"

if command -v eza >/dev/null 2>&1; then
  eza --tree --level="$DEPTH" --group-directories-first "$ROOT"
elif command -v tree >/dev/null 2>&1; then
  tree -L "$DEPTH" "$ROOT"
else
  find "$ROOT" -maxdepth "$DEPTH" | sort
fi
EOF

cat > "$BIN/wl-nav" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
GOV="$WL_HOME/vault/09-Governance"

show_header() {
  echo "Wonderland Navigator"
  echo "WL_HOME=$WL_HOME"
  echo
}

show_governance() {
  echo "Wonderland Governance"
  echo
  echo "Authorities"
  echo "  Core"
  [[ -f "$GOV/authorities/core/wat.md" ]] && echo "    WAT   Wonderland Authority Template"
  [[ -f "$GOV/authorities/core/wdsa.md" ]] && echo "    WDSA  Documentation Style Authority"
  [[ -f "$GOV/authorities/core/wvsa.md" ]] && echo "    WVSA  Visual Style Authority"
  echo
  echo "  Governance"
  [[ -f "$GOV/authorities/governance/wga.md" ]] && echo "    WGA    Governance Authority"
  [[ -f "$GOV/authorities/governance/wra.md" ]] && echo "    WRA    Recovery Authority"
  [[ -f "$GOV/authorities/governance/wca.md" ]] && echo "    WCA    Certification Authority"
  [[ -f "$GOV/authorities/governance/wrega.md" ]] && echo "    WRegA  Registry Authority"
  echo
  echo "  Experience"
  [[ -f "$GOV/authorities/experience/wcpa.md" ]] && echo "    WCPA  Color Palette Authority"
  echo
  echo "THE∅MATRIX"
  echo "  Constitution"
  [[ -f "$GOV/theomatrix/constitution/tma.md" ]] && echo "    TMA      Architecture Authority"
  [[ -f "$GOV/theomatrix/constitution/tmva.md" ]] && echo "    TMVA     Visual Authority"
  [[ -f "$GOV/theomatrix/constitution/tmba.md" ]] && echo "    TMBA     Behavior Authority"
  [[ -f "$GOV/theomatrix/constitution/tmca.md" ]] && echo "    TMCA     Color Authority"
  [[ -f "$GOV/theomatrix/constitution/tmcanon.md" ]] && echo "    TMCanon  Canon Authority"
  echo
  echo "Registries"
  find "$GOV" -path "*registry*" -type f -name "*.json" 2>/dev/null | sed "s|$GOV/|  |" | sort || true
  echo
  echo "RESULT PASS"
}

show_services() {
  echo "Wonderland Services"
  echo
  if command -v nerdctl >/dev/null 2>&1; then
    nerdctl ps -a --format '{{.Names}} {{.Status}}' | grep '^wl-' || true
  else
    echo "WARN nerdctl unavailable"
  fi
  echo
  echo "RESULT PASS"
}

show_assets() {
  echo "Wonderland Assets"
  echo
  for d in "$WL_HOME/assets" "$WL_HOME/assets/governance" "$WL_HOME/assets/wallpapers"; do
    [[ -d "$d" ]] && echo "PASS $(basename "$d"): $d"
  done
  echo
  find "$WL_HOME/assets" -maxdepth 3 -type f 2>/dev/null | sed "s|$WL_HOME/|  |" | sort | head -80 || true
  echo
  echo "RESULT PASS"
}

show_reports() {
  echo "Wonderland Reports"
  echo
  find "$WL_HOME/vault/08-Operations/reports" -maxdepth 2 -type f 2>/dev/null | sort | tail -40 || true
  echo
  echo "RESULT PASS"
}

show_root() {
  show_header
  echo "Domains"
  echo "  governance     $GOV"
  echo "  theomatrix     $GOV/theomatrix"
  echo "  services       $WL_HOME/services"
  echo "  assets         $WL_HOME/assets"
  echo "  reports        $WL_HOME/vault/08-Operations/reports"
  echo
  echo "Commands"
  echo "  wl nav governance"
  echo "  wl nav theomatrix"
  echo "  wl nav services"
  echo "  wl nav assets"
  echo "  wl nav reports"
  echo "  wl inspect <path>"
  echo "  wl tree <path>"
  echo
  echo "RESULT PASS"
}

case "${1:-root}" in
  root|home)
    show_root
    ;;
  governance|authorities)
    show_governance
    ;;
  theomatrix)
    show_governance
    ;;
  services)
    show_services
    ;;
  assets)
    show_assets
    ;;
  reports)
    show_reports
    ;;
  *)
    echo "Usage: wl-nav [governance|theomatrix|services|assets|reports]"
    exit 2
    ;;
esac
EOF

cat > "$BIN/wl-inspect" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
TARGET="${1:-.}"

if [[ ! -e "$TARGET" ]]; then
  echo "FAIL target-missing: $TARGET"
  exit 1
fi

TARGET="$(cd "$(dirname "$TARGET")" && pwd)/$(basename "$TARGET")"

echo "Wonderland Inspect"
echo "Target: $TARGET"
echo

if [[ -d "$TARGET" ]]; then
  files="$(find "$TARGET" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')"
  dirs="$(find "$TARGET" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
  md="$(find "$TARGET" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')"
  json="$(find "$TARGET" -maxdepth 1 -type f -name "*.json" 2>/dev/null | wc -l | tr -d ' ')"
  sh="$(find "$TARGET" -maxdepth 1 -type f -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')"

  echo "Type: directory"
  echo "Directories: $((dirs - 1))"
  echo "Files: $files"
  echo "Markdown: $md"
  echo "JSON: $json"
  echo "Shell: $sh"
  echo

  if [[ -f "$TARGET/.wlmeta.json" ]]; then
    echo "Metadata:"
    cat "$TARGET/.wlmeta.json"
    echo
  fi

  echo "Contents:"
  if command -v eza >/dev/null 2>&1; then
    eza -lah --group-directories-first "$TARGET"
  else
    ls -lah "$TARGET"
  fi

elif [[ -f "$TARGET" ]]; then
  echo "Type: file"
  echo "Size: $(du -h "$TARGET" | awk '{print $1}')"
  echo "Lines: $(wc -l < "$TARGET" | tr -d ' ')"
  echo "Words: $(wc -w < "$TARGET" | tr -d ' ')"
  echo

  case "$TARGET" in
    *.md)
      echo "Markdown headings:"
      grep -E '^#{1,4}[[:space:]]+' "$TARGET" || true
      ;;
    *.json)
      echo "JSON validation:"
      python3 -m json.tool "$TARGET" >/dev/null && echo "PASS json-valid" || echo "FAIL json-valid"
      ;;
    *)
      echo "Preview:"
      sed -n '1,40p' "$TARGET"
      ;;
  esac
fi

echo
echo "RESULT PASS"
EOF

chmod +x "$BIN/wl-tree" "$BIN/wl-nav" "$BIN/wl-inspect"

cat > "$WL_HOME/.wlmeta.json" <<EOF
{
  "name": "Wonderland",
  "type": "platform-root",
  "owner": "operator",
  "authority": "WAT",
  "description": "Long-term governed platform root for Wonderland and THEOMATRIX."
}
EOF

mkdir -p "$GOV"

cat > "$GOV/.wlmeta.json" <<EOF
{
  "name": "Governance",
  "type": "authority-domain",
  "owner": "WGA",
  "authority": "WGA",
  "description": "Governance root for Wonderland authorities, registries, reports, and THEOMATRIX constitution."
}
EOF

cat > "$GOV/theomatrix/.wlmeta.json" <<EOF
{
  "name": "THEOMATRIX",
  "type": "living-digital-cosmology",
  "owner": "TMA",
  "authority": "TMA",
  "description": "Constitution, canon, realms, entities, behavior, visual language, and registries for THEOMATRIX."
}
EOF

WL="$BIN/wl"

if [[ -f "$WL" ]]; then
  cp "$WL" "$BACKUP/wl.bak"

  if ! grep -q "nav)" "$WL"; then
    python3 - <<'PY'
from pathlib import Path

p = Path.home() / "Wonderland/bin/wl"
s = p.read_text()

insert = '''  nav)
    shift
    exec "$WL_HOME/bin/wl-nav" "$@"
    ;;

  inspect)
    shift
    exec "$WL_HOME/bin/wl-inspect" "$@"
    ;;

  tree)
    shift
    exec "$WL_HOME/bin/wl-tree" "$@"
    ;;

'''

if "case " in s and "  *)" in s:
    s = s.replace("  *)\n", insert + "  *)\n", 1)
else:
    s += '''

case "${1:-}" in
  nav)
    shift
    exec "$WL_HOME/bin/wl-nav" "$@"
    ;;
  inspect)
    shift
    exec "$WL_HOME/bin/wl-inspect" "$@"
    ;;
  tree)
    shift
    exec "$WL_HOME/bin/wl-tree" "$@"
    ;;
esac
'''

p.write_text(s)
PY
  fi
else
  cat > "$WL" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"

case "${1:-nav}" in
  nav)
    shift || true
    exec "$WL_HOME/bin/wl-nav" "$@"
    ;;
  inspect)
    shift || true
    exec "$WL_HOME/bin/wl-inspect" "$@"
    ;;
  tree)
    shift || true
    exec "$WL_HOME/bin/wl-tree" "$@"
    ;;
  *)
    echo "Usage: wl nav|inspect|tree"
    exit 2
    ;;
esac
EOF
fi

chmod +x "$WL"

echo "PASS wl-tree"
echo "PASS wl-nav"
echo "PASS wl-inspect"
echo "PASS metadata"
echo "backup: $BACKUP"
echo
"$BIN/wl-nav" governance
