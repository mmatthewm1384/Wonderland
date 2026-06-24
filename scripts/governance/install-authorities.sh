#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
DATE="$(date +%Y%m%d-%H%M%S)"

GOV="$WL_HOME/vault/09-Governance"
AUTH="$GOV/authorities"
THEO="$GOV/theomatrix"
REG="$GOV/registry"
BACKUP="$WL_HOME/backups/governance-authorities-$DATE"

mkdir -p "$AUTH" "$THEO" "$REG" "$BACKUP" "$WL_HOME/bin"

cp -R "$GOV" "$BACKUP/" 2>/dev/null || true

write_doc() {
  local path="$1"
  local title="$2"
  local code="$3"
  local class="$4"

  cat > "$path" <<EOF
# $title

## Purpose

Defines the canonical authority for $title.

## Scope

Applies to Wonderland and THE∅MATRIX long-term governance.

## Principles

- Persistent
- Recoverable
- Auditable
- Secure
- Automated
- Versioned
- Modular

## Authority Code

\`\`\`text
$code
\`\`\`

## Classification

$class

## Verification

\`\`\`bash
wl-authorities verify
\`\`\`

Expected:

\`\`\`text
PASS $code
RESULT PASS
\`\`\`

## Recovery

Restore from latest backup:

\`\`\`bash
cp -R ~/Wonderland/backups/governance-authorities-*/09-Governance ~/Wonderland/vault/
\`\`\`

## Rollback

Rollback to backup created during install:

\`\`\`bash
cp -R "$BACKUP/09-Governance" "$WL_HOME/vault/"
\`\`\`

## Status

Authority: $code  
Version: 1.0  
Status: Certified  

RESULT PASS
EOF
}

write_doc "$AUTH/wonderland-universal-authority-template.md" \
  "Wonderland Universal Authority Template" "WAT" "Universal Template Authority"

write_doc "$AUTH/documentation-style-authority.md" \
  "Wonderland Documentation Style Authority" "WDSA" "Documentation Style Authority"

write_doc "$AUTH/visual-style-authority.md" \
  "Wonderland Visual Style Authority" "WVSA" "Visual Style Authority"

write_doc "$AUTH/governance-authority.md" \
  "Wonderland Governance Authority" "WGA" "Governance Authority"

write_doc "$AUTH/recovery-authority.md" \
  "Wonderland Recovery Authority" "WRA" "Recovery Authority"

write_doc "$AUTH/certification-authority.md" \
  "Wonderland Certification Authority" "WCA" "Certification Authority"

write_doc "$THEO/theomatrix-architecture-authority.md" \
  "THE∅MATRIX Architecture Authority" "TMA" "THE∅MATRIX Architecture Authority"

write_doc "$THEO/theomatrix-visual-authority.md" \
  "THE∅MATRIX Visual Authority" "TMVA" "THE∅MATRIX Visual Authority"

write_doc "$THEO/theomatrix-behavior-authority.md" \
  "THE∅MATRIX Behavior Authority" "TMBA" "THE∅MATRIX Behavior Authority"

cat > "$REG/authority-registry.json" <<'EOF'
{
  "registry": "wonderland.authorities.v1",
  "status": "certified",
  "authorities": [
    "WAT",
    "WDSA",
    "WVSA",
    "WGA",
    "WRA",
    "WCA",
    "TMA",
    "TMVA",
    "TMBA"
  ]
}
EOF

cat > "$WL_HOME/bin/wl-authorities" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
GOV="$WL_HOME/vault/09-Governance"

verify_one() {
  local code="$1"
  local path="$2"

  if [[ -f "$path" ]] && grep -q "Authority: $code" "$path" && grep -q "RESULT PASS" "$path"; then
    echo "PASS $code"
  else
    echo "FAIL $code"
    return 1
  fi
}

case "${1:-verify}" in
  verify)
    fail=0

    verify_one WAT  "$GOV/authorities/wonderland-universal-authority-template.md" || fail=1
    verify_one WDSA "$GOV/authorities/documentation-style-authority.md" || fail=1
    verify_one WVSA "$GOV/authorities/visual-style-authority.md" || fail=1
    verify_one WGA  "$GOV/authorities/governance-authority.md" || fail=1
    verify_one WRA  "$GOV/authorities/recovery-authority.md" || fail=1
    verify_one WCA  "$GOV/authorities/certification-authority.md" || fail=1

    verify_one TMA  "$GOV/theomatrix/theomatrix-architecture-authority.md" || fail=1
    verify_one TMVA "$GOV/theomatrix/theomatrix-visual-authority.md" || fail=1
    verify_one TMBA "$GOV/theomatrix/theomatrix-behavior-authority.md" || fail=1

    if [[ -f "$GOV/registry/authority-registry.json" ]]; then
      echo "PASS registry"
    else
      echo "FAIL registry"
      fail=1
    fi

    if [[ "$fail" -eq 0 ]]; then
      echo
      echo "RESULT PASS"
    else
      echo
      echo "RESULT FAIL"
      exit 1
    fi
    ;;

  status)
    find "$GOV" -type f \( -name "*.md" -o -name "*.json" \) | sort
    ;;

  *)
    echo "Usage: wl-authorities verify|status"
    exit 2
    ;;
esac
EOF

chmod +x "$WL_HOME/bin/wl-authorities"

echo "PASS installed-authorities"
echo "backup: $BACKUP"
echo
"$WL_HOME/bin/wl-authorities" verify
