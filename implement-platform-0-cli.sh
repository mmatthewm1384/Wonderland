#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$(pwd)}"
cd "$ROOT"

mkdir -p bin lib/philosophy docs/philosophy docs/standards docs/design docs/releases

cat > lib/philosophy/cli.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail

wl_philosophy_root() {
  if [[ -n "${WL_ROOT:-}" && -d "$WL_ROOT" ]]; then
    printf '%s\n' "$WL_ROOT"
  else
    git rev-parse --show-toplevel 2>/dev/null || pwd
  fi
}

wl_philosophy_print_box() {
  local title="$1"
  local body="$2"

  cat <<EOF2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$title
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$body

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF2
}

wl_north_star() {
  wl_philosophy_print_box "Wonderland North Star" "Create a world where engineering becomes art,
and art remains engineered.

Everything else is implementation."
}

wl_craftsmanship() {
  wl_philosophy_print_box "Wonderland Craftsmanship" "Leave behind evidence that someone cared.

Build fewer things.
Build them exceptionally well.
Prefer clarity over cleverness.
Prefer longevity over novelty.
Prefer trust over spectacle."
}

wl_philosophy() {
  wl_philosophy_print_box "Wonderland Philosophy — Platform 0" "Luxury Engineering

Engineered with Purpose.
Crafted with Soul.

North Star:
Create a world where engineering becomes art,
and art remains engineered.

Craftsman's Rule:
Leave every system more beautiful than you found it."
}

wl_manifesto() {
  local root
  root="$(wl_philosophy_root)"
  if [[ -f "$root/MANIFESTO.md" ]]; then
    ${PAGER:-less} "$root/MANIFESTO.md"
  elif [[ -f "$root/docs/philosophy/MANIFESTO.md" ]]; then
    ${PAGER:-less} "$root/docs/philosophy/MANIFESTO.md"
  else
    echo "FAIL manifesto not found"
    return 1
  fi
}

wl_constitution() {
  local root
  root="$(wl_philosophy_root)"
  if [[ -f "$root/CONSTITUTION.md" ]]; then
    ${PAGER:-less} "$root/CONSTITUTION.md"
  elif [[ -f "$root/docs/philosophy/CONSTITUTION.md" ]]; then
    ${PAGER:-less} "$root/docs/philosophy/CONSTITUTION.md"
  else
    echo "FAIL constitution not found"
    return 1
  fi
}

wl_design_system() {
  local root
  root="$(wl_philosophy_root)"
  if [[ -f "$root/DESIGN_SYSTEM.md" ]]; then
    ${PAGER:-less} "$root/DESIGN_SYSTEM.md"
  elif [[ -f "$root/docs/design/DESIGN_SYSTEM.md" ]]; then
    ${PAGER:-less} "$root/docs/design/DESIGN_SYSTEM.md"
  elif [[ -f "$root/docs/philosophy/DESIGN_SYSTEM.md" ]]; then
    ${PAGER:-less} "$root/docs/philosophy/DESIGN_SYSTEM.md"
  else
    echo "FAIL design system not found"
    return 1
  fi
}

wl_platform_0_verify() {
  local root missing=0
  root="$(wl_philosophy_root)"

  echo "Wonderland Platform 0 Verify"
  echo

  for file in \
    MANIFESTO.md \
    NORTH_STAR.md \
    CONSTITUTION.md \
    DESIGN_SYSTEM.md \
    docs/philosophy/platform.json \
    docs/releases/PLATFORM-0.0-PHILOSOPHY-RELEASE.md
  do
    if [[ -f "$root/$file" ]]; then
      printf 'PASS %s\n' "$file"
    else
      printf 'FAIL %s\n' "$file"
      missing=1
    fi
  done

  echo
  if [[ "$missing" -eq 0 ]]; then
    echo "RESULT PASS"
  else
    echo "RESULT FAIL"
    return 1
  fi
}
SH

chmod +x lib/philosophy/cli.sh

cat > bin/wl-philosophy <<'SH'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$ROOT/lib/philosophy/cli.sh"
wl_philosophy "$@"
SH

cat > bin/wl-north-star <<'SH'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$ROOT/lib/philosophy/cli.sh"
wl_north_star "$@"
SH

cat > bin/wl-craftsmanship <<'SH'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$ROOT/lib/philosophy/cli.sh"
wl_craftsmanship "$@"
SH

cat > bin/wl-manifesto <<'SH'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$ROOT/lib/philosophy/cli.sh"
wl_manifesto "$@"
SH

cat > bin/wl-constitution <<'SH'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$ROOT/lib/philosophy/cli.sh"
wl_constitution "$@"
SH

cat > bin/wl-design-system <<'SH'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$ROOT/lib/philosophy/cli.sh"
wl_design_system "$@"
SH

cat > bin/wl-platform-0-verify <<'SH'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$ROOT/lib/philosophy/cli.sh"
wl_platform_0_verify "$@"
SH

chmod +x bin/wl-philosophy bin/wl-north-star bin/wl-craftsmanship bin/wl-manifesto bin/wl-constitution bin/wl-design-system bin/wl-platform-0-verify

if [[ -f bin/wl ]]; then
  if ! grep -q 'philosophy)' bin/wl; then
    cp bin/wl "bin/wl.backup-platform-0-$(date +%Y%m%d-%H%M%S)"

    python3 - <<'PY'
from pathlib import Path

p = Path("bin/wl")
s = p.read_text()

insert = '''\
      philosophy)
        exec "$WL_ROOT/bin/wl-philosophy" "$@"
        ;;
      north-star)
        exec "$WL_ROOT/bin/wl-north-star" "$@"
        ;;
      craftsmanship)
        exec "$WL_ROOT/bin/wl-craftsmanship" "$@"
        ;;
      manifesto)
        exec "$WL_ROOT/bin/wl-manifesto" "$@"
        ;;
      constitution)
        exec "$WL_ROOT/bin/wl-constitution" "$@"
        ;;
      design-system)
        exec "$WL_ROOT/bin/wl-design-system" "$@"
        ;;
      platform-0-verify)
        exec "$WL_ROOT/bin/wl-platform-0-verify" "$@"
        ;;
'''

marker = "case"
case_pos = s.find(marker)
if case_pos == -1:
    raise SystemExit("FAIL could not find case dispatch in bin/wl")

# Insert after first case line ending in "in"
lines = s.splitlines(True)
out = []
inserted = False
for line in lines:
    out.append(line)
    if not inserted and line.lstrip().startswith("case ") and line.rstrip().endswith(" in"):
        out.append(insert)
        inserted = True

if not inserted:
    raise SystemExit("FAIL could not patch bin/wl dispatch")

p.write_text("".join(out))
PY
  fi
else
  cat > bin/wl <<'SH'
#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

cmd="${1:-help}"
if [[ $# -gt 0 ]]; then shift; fi

case "$cmd" in
  philosophy) exec "$WL_ROOT/bin/wl-philosophy" "$@" ;;
  north-star) exec "$WL_ROOT/bin/wl-north-star" "$@" ;;
  craftsmanship) exec "$WL_ROOT/bin/wl-craftsmanship" "$@" ;;
  manifesto) exec "$WL_ROOT/bin/wl-manifesto" "$@" ;;
  constitution) exec "$WL_ROOT/bin/wl-constitution" "$@" ;;
  design-system) exec "$WL_ROOT/bin/wl-design-system" "$@" ;;
  platform-0-verify) exec "$WL_ROOT/bin/wl-platform-0-verify" "$@" ;;
  help|*)
    cat <<'HELP'
Wonderland Platform 0 Commands

  wl philosophy
  wl north-star
  wl craftsmanship
  wl manifesto
  wl constitution
  wl design-system
  wl platform-0-verify
HELP
    ;;
esac
SH
  chmod +x bin/wl
fi

cat <<'DONE'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Wonderland Platform 0 CLI Implemented
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Commands added:

✓ wl philosophy
✓ wl north-star
✓ wl craftsmanship
✓ wl manifesto
✓ wl constitution
✓ wl design-system
✓ wl platform-0-verify

Verify:

  wl philosophy
  wl north-star
  wl platform-0-verify

Commit:

  git add bin lib docs MANIFESTO.md NORTH_STAR.md CONSTITUTION.md DESIGN_SYSTEM.md PLATFORM-0.0-PHILOSOPHY-RELEASE.md
  git commit -m "implement Platform 0 philosophy commands"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DONE
