#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
DATE="$(date +%Y%m%d-%H%M%S)"

SRC="${1:-}"
ASSET_DIR="$WL_HOME/assets/governance/color-authorities"
GOV="$WL_HOME/vault/09-Governance"
BACKUP="$WL_HOME/backups/color-authority-asset-$DATE"

OUT="$ASSET_DIR/wonderland-theomatrix-color-authority-v1.png"
META="$ASSET_DIR/wonderland-theomatrix-color-authority-v1.metadata.json"
SHA="$ASSET_DIR/wonderland-theomatrix-color-authority-v1.sha256"
README="$ASSET_DIR/README.md"

mkdir -p "$ASSET_DIR" "$BACKUP" "$WL_HOME/bin"

if [[ -z "$SRC" ]]; then
  SRC="$(find "$HOME/Downloads" -maxdepth 1 -type f \( \
    -iname "*color*authorit*.png" -o \
    -iname "*wonderland*theomatrix*.png" -o \
    -iname "*split*infographic*.png" -o \
    -iname "ChatGPT Image*.png" \
  \) -print 2>/dev/null | sort | tail -1)"
fi

if [[ -z "$SRC" || ! -f "$SRC" ]]; then
  echo "FAIL source-image"
  echo "Usage:"
  echo "  $0 /path/to/image.png"
  exit 1
fi

cp "$SRC" "$BACKUP/source-image.png"
cp "$SRC" "$OUT"

shasum -a 256 "$OUT" > "$SHA"

cat > "$META" <<EOF
{
  "asset": "wonderland-theomatrix-color-authority-v1",
  "version": "1.0",
  "classification": "certified-governance-visualization",
  "status": "certified",
  "source": "$SRC",
  "installed_at": "$DATE",
  "authorities": [
    "WCPA",
    "TMCA"
  ],
  "paths": {
    "image": "$OUT",
    "checksum": "$SHA",
    "metadata": "$META"
  },
  "purpose": "Visual reference for Wonderland Color Palette Authority and THEOMATRIX Color Authority"
}
EOF

cat > "$README" <<EOF
# Color Authority Visual Assets

## Certified Asset

\`\`\`text
wonderland-theomatrix-color-authority-v1.png
\`\`\`

## Purpose

Visual reference for:

- WCPA — Wonderland Color Palette Authority
- TMCA — THE∅MATRIX Color Authority

## Verification

\`\`\`bash
wl-color-authority-asset verify
\`\`\`

## Status

RESULT PASS
EOF

patch_doc() {
  local path="$1"
  local label="$2"

  [[ -f "$path" ]] || return 0

  cp "$path" "$BACKUP/$(basename "$path").bak"

  if ! grep -q "wonderland-theomatrix-color-authority-v1.png" "$path"; then
    cat >> "$path" <<EOF

## Certified Visual Reference

\`\`\`text
$OUT
\`\`\`

Asset Classification:

\`\`\`text
Certified Governance Visualization
\`\`\`

Linked Authority:

\`\`\`text
$label
\`\`\`
EOF
  fi
}

patch_doc "$GOV/authorities/experience/wcpa.md" "WCPA"
patch_doc "$GOV/theomatrix/constitution/tmca.md" "TMCA"

cat > "$WL_HOME/bin/wl-color-authority-asset" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
ASSET_DIR="$WL_HOME/assets/governance/color-authorities"
IMG="$ASSET_DIR/wonderland-theomatrix-color-authority-v1.png"
META="$ASSET_DIR/wonderland-theomatrix-color-authority-v1.metadata.json"
SHA="$ASSET_DIR/wonderland-theomatrix-color-authority-v1.sha256"
WCPA="$WL_HOME/vault/09-Governance/authorities/experience/wcpa.md"
TMCA="$WL_HOME/vault/09-Governance/theomatrix/constitution/tmca.md"

case "${1:-verify}" in
  verify)
    fail=0

    [[ -f "$IMG" ]] && echo "PASS image" || { echo "FAIL image"; fail=1; }
    [[ -f "$META" ]] && echo "PASS metadata" || { echo "FAIL metadata"; fail=1; }
    [[ -f "$SHA" ]] && shasum -a 256 -c "$SHA" >/dev/null && echo "PASS checksum" || { echo "FAIL checksum"; fail=1; }

    [[ -f "$WCPA" ]] && grep -q "wonderland-theomatrix-color-authority-v1.png" "$WCPA" \
      && echo "PASS WCPA-reference" || { echo "WARN WCPA-reference"; }

    [[ -f "$TMCA" ]] && grep -q "wonderland-theomatrix-color-authority-v1.png" "$TMCA" \
      && echo "PASS TMCA-reference" || { echo "WARN TMCA-reference"; }

    echo
    [[ "$fail" -eq 0 ]] && echo "RESULT PASS" || { echo "RESULT FAIL"; exit 1; }
    ;;

  open)
    open "$ASSET_DIR"
    ;;

  path)
    echo "$IMG"
    ;;

  *)
    echo "Usage: wl-color-authority-asset verify|open|path"
    exit 2
    ;;
esac
EOF

chmod +x "$WL_HOME/bin/wl-color-authority-asset"

echo "PASS installed-color-authority-asset"
echo "source: $SRC"
echo "asset:  $OUT"
echo "backup: $BACKUP"
echo
"$WL_HOME/bin/wl-color-authority-asset" verify
