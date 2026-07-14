#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$(pwd)}"
cd "$ROOT"

mkdir -p bin lib/philosophy docs/philosophy docs/governance docs/templates config/platform0

cat > lib/philosophy/engine.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail

wl_p0_root() {
  if [[ -n "${WL_ROOT:-}" && -d "$WL_ROOT" ]]; then
    printf '%s\n' "$WL_ROOT"
  else
    git rev-parse --show-toplevel 2>/dev/null || pwd
  fi
}

wl_p0_line() {
  printf '%s\n' "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

wl_p0_box() {
  local title="$1"
  shift || true

  wl_p0_line
  printf '%s\n' "$title"
  wl_p0_line
  printf '\n'
  printf '%s\n' "$@"
  printf '\n'
  wl_p0_line
}

wl_p0_open_first() {
  local root="$1"
  shift

  local file
  for file in "$@"; do
    if [[ -f "$root/$file" ]]; then
      ${PAGER:-less} "$root/$file"
      return 0
    fi
  done

  printf 'FAIL no matching document found\n' >&2
  return 1
}

wl_p0_north_star() {
  wl_p0_box \
    "Wonderland North Star" \
    "Create a world where engineering becomes art," \
    "and art remains engineered." \
    "" \
    "Everything else is implementation."
}

wl_p0_philosophy() {
  wl_p0_box \
    "Wonderland Philosophy — Platform 0.1" \
    "Luxury Engineering" \
    "" \
    "Engineered with Purpose." \
    "Crafted with Soul." \
    "" \
    "Leave behind evidence that someone cared."
}

wl_p0_craftsmanship() {
  wl_p0_box \
    "Wonderland Craftsmanship" \
    "Build fewer things." \
    "Build them exceptionally well." \
    "" \
    "Prefer clarity over cleverness." \
    "Prefer longevity over novelty." \
    "Prefer trust over spectacle." \
    "" \
    "Beauty follows clarity."
}

wl_p0_governance() {
  wl_p0_box \
    "Wonderland Governance — Platform 0" \
    "Authority Chain" \
    "" \
    "North Star" \
    "↓" \
    "Manifesto" \
    "↓" \
    "Constitution" \
    "↓" \
    "Design System" \
    "↓" \
    "Engineering Standards" \
    "↓" \
    "Architecture" \
    "↓" \
    "Implementation" \
    "" \
    "No implementation may contradict Platform 0."
}

wl_p0_review() {
  cat <<'OUT'
Wonderland Engineering Review

Manifesto Check:

[ ] Engineered with purpose
[ ] Crafted with soul
[ ] Improves Wonderland
[ ] Avoids unnecessary complexity
[ ] Consistent with the North Star

Engineering Check:

[ ] Reliable
[ ] Recoverable
[ ] Observable where appropriate
[ ] Maintainable
[ ] Documented
[ ] Verified

North Star:

Create a world where engineering becomes art,
and art remains engineered.
OUT
}

wl_p0_manifesto() {
  local root
  root="$(wl_p0_root)"
  wl_p0_open_first "$root" \
    "MANIFESTO.md" \
    "docs/philosophy/MANIFESTO.md" \
    "00-Philosophy/MANIFESTO.md"
}

wl_p0_constitution() {
  local root
  root="$(wl_p0_root)"
  wl_p0_open_first "$root" \
    "CONSTITUTION.md" \
    "docs/philosophy/CONSTITUTION.md" \
    "00-Philosophy/CONSTITUTION.md"
}

wl_p0_design_system() {
  local root
  root="$(wl_p0_root)"
  wl_p0_open_first "$root" \
    "DESIGN_SYSTEM.md" \
    "docs/philosophy/DESIGN_SYSTEM.md" \
    "docs/design/DESIGN_SYSTEM.md" \
    "00-Philosophy/DESIGN_SYSTEM.md"
}

wl_p0_status() {
  local root
  root="$(wl_p0_root)"

  wl_p0_line
  echo "Wonderland Platform 0.1 Status"
  wl_p0_line
  echo

  echo "Root: $root"
  echo "Model: Philosophy First"
  echo "Status: ACTIVE"
  echo "Codename: Luxury Engineering"
  echo
  echo "North Star:"
  echo "Create a world where engineering becomes art,"
  echo "and art remains engineered."
  echo
  wl_p0_line
}

wl_p0_doctor() {
  local root fail=0
  root="$(wl_p0_root)"

  echo "Wonderland Platform 0.1 Doctor"
  echo

  local files=(
    "NORTH_STAR.md"
    "MANIFESTO.md"
    "CONSTITUTION.md"
    "DESIGN_SYSTEM.md"
    "docs/philosophy/INDEX.md"
    "docs/philosophy/RELEASE.json"
    "docs/governance/PLATFORM0_GOVERNANCE.md"
    "docs/templates/DESIGN_REVIEW.md"
    "config/platform0/platform0.json"
    "bin/wl-philosophy"
    "bin/wl-north-star"
    "bin/wl-craftsmanship"
    "bin/wl-governance"
    "bin/wl-review"
    "bin/wl-platform-0-doctor"
  )

  local file
  for file in "${files[@]}"; do
    if [[ -f "$root/$file" ]]; then
      printf 'PASS %-58s\n' "$file"
    else
      printf 'FAIL %-58s\n' "$file"
      fail=1
    fi
  done

  echo

  if [[ -f "$root/NORTH_STAR.md" ]] && grep -Fq "engineering becomes art" "$root/NORTH_STAR.md"; then
    printf 'PASS %-58s\n' "north star content"
  else
    printf 'FAIL %-58s\n' "north star content"
    fail=1
  fi

  if [[ "$fail" -eq 0 ]]; then
    echo
    echo "RESULT PASS"
  else
    echo
    echo "RESULT FAIL"
    return 1
  fi
}

wl_p0_help() {
  cat <<'OUT'
Wonderland Platform 0.1 — Philosophy Engine

Commands:

  wl philosophy
  wl north-star
  wl craftsmanship
  wl governance
  wl review
  wl manifesto
  wl constitution
  wl design-system
  wl platform-0-status
  wl platform-0-doctor
  wl platform-0-verify

Direct binaries:

  wl-philosophy
  wl-north-star
  wl-craftsmanship
  wl-governance
  wl-review
  wl-manifesto
  wl-constitution
  wl-design-system
  wl-platform-0-status
  wl-platform-0-doctor
  wl-platform-0-verify
OUT
}

wl_p0_dispatch() {
  local cmd="${1:-help}"
  if [[ $# -gt 0 ]]; then shift; fi

  case "$cmd" in
    philosophy) wl_p0_philosophy "$@" ;;
    north-star) wl_p0_north_star "$@" ;;
    craftsmanship) wl_p0_craftsmanship "$@" ;;
    governance) wl_p0_governance "$@" ;;
    review) wl_p0_review "$@" ;;
    manifesto) wl_p0_manifesto "$@" ;;
    constitution) wl_p0_constitution "$@" ;;
    design-system) wl_p0_design_system "$@" ;;
    status|platform-0-status) wl_p0_status "$@" ;;
    doctor|verify|platform-0-doctor|platform-0-verify) wl_p0_doctor "$@" ;;
    help|-h|--help) wl_p0_help ;;
    *)
      echo "FAIL unknown Platform 0 command: $cmd" >&2
      wl_p0_help >&2
      return 64
      ;;
  esac
}
SH

chmod +x lib/philosophy/engine.sh

make_bin() {
  local name="$1"
  local fn="$2"

  cat > "bin/$name" <<SH
#!/usr/bin/env bash
set -euo pipefail
ROOT="\${WL_ROOT:-\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)}"
source "\$ROOT/lib/philosophy/engine.sh"
$fn "\$@"
SH
  chmod +x "bin/$name"
}

make_bin "wl-platform-0" "wl_p0_dispatch"
make_bin "wl-philosophy" "wl_p0_philosophy"
make_bin "wl-north-star" "wl_p0_north_star"
make_bin "wl-craftsmanship" "wl_p0_craftsmanship"
make_bin "wl-governance" "wl_p0_governance"
make_bin "wl-review" "wl_p0_review"
make_bin "wl-manifesto" "wl_p0_manifesto"
make_bin "wl-constitution" "wl_p0_constitution"
make_bin "wl-design-system" "wl_p0_design_system"
make_bin "wl-platform-0-status" "wl_p0_status"
make_bin "wl-platform-0-doctor" "wl_p0_doctor"
make_bin "wl-platform-0-verify" "wl_p0_doctor"

cat > docs/philosophy/PLATFORM-0.1-PHILOSOPHY-ENGINE.md <<'DOC'
# Wonderland Platform 0.1 — Philosophy Engine

## Status

Implemented.

## Purpose

Platform 0.1 turns the Wonderland philosophy into an executable subsystem.

The manifesto is no longer only a document.

It is inspectable, callable, and verifiable through `wl`.

## Commands

- `wl philosophy`
- `wl north-star`
- `wl craftsmanship`
- `wl governance`
- `wl review`
- `wl manifesto`
- `wl constitution`
- `wl design-system`
- `wl platform-0-status`
- `wl platform-0-doctor`
- `wl platform-0-verify`

## North Star

> Create a world where engineering becomes art, and art remains engineered.

## Principle

Leave behind evidence that someone cared.
DOC

cat > config/platform0/engine.json <<'JSON'
{
  "platform": "0.1",
  "name": "Philosophy Engine",
  "status": "implemented",
  "commands": [
    "wl philosophy",
    "wl north-star",
    "wl craftsmanship",
    "wl governance",
    "wl review",
    "wl manifesto",
    "wl constitution",
    "wl design-system",
    "wl platform-0-status",
    "wl platform-0-doctor",
    "wl platform-0-verify"
  ],
  "north_star": "Create a world where engineering becomes art, and art remains engineered.",
  "principle": "Leave behind evidence that someone cared."
}
JSON

if [[ -f bin/wl ]]; then
  if ! grep -q 'platform-0)' bin/wl; then
    cp bin/wl "bin/wl.backup-p0-1-$(date +%Y%m%d-%H%M%S)"

    python3 - <<'PY'
from pathlib import Path

p = Path("bin/wl")
s = p.read_text()

insert = '''\
      platform-0)
        exec "$WL_ROOT/bin/wl-platform-0" "$@"
        ;;
      platform-0-status)
        exec "$WL_ROOT/bin/wl-platform-0-status" "$@"
        ;;
      platform-0-doctor)
        exec "$WL_ROOT/bin/wl-platform-0-doctor" "$@"
        ;;
      platform-0-verify)
        exec "$WL_ROOT/bin/wl-platform-0-verify" "$@"
        ;;
      philosophy)
        exec "$WL_ROOT/bin/wl-philosophy" "$@"
        ;;
      north-star)
        exec "$WL_ROOT/bin/wl-north-star" "$@"
        ;;
      craftsmanship)
        exec "$WL_ROOT/bin/wl-craftsmanship" "$@"
        ;;
      governance)
        exec "$WL_ROOT/bin/wl-governance" "$@"
        ;;
      review)
        exec "$WL_ROOT/bin/wl-review" "$@"
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
'''

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
  platform-0) exec "$WL_ROOT/bin/wl-platform-0" "$@" ;;
  platform-0-status) exec "$WL_ROOT/bin/wl-platform-0-status" "$@" ;;
  platform-0-doctor|platform-0-verify) exec "$WL_ROOT/bin/wl-platform-0-doctor" "$@" ;;
  philosophy) exec "$WL_ROOT/bin/wl-philosophy" "$@" ;;
  north-star) exec "$WL_ROOT/bin/wl-north-star" "$@" ;;
  craftsmanship) exec "$WL_ROOT/bin/wl-craftsmanship" "$@" ;;
  governance) exec "$WL_ROOT/bin/wl-governance" "$@" ;;
  review) exec "$WL_ROOT/bin/wl-review" "$@" ;;
  manifesto) exec "$WL_ROOT/bin/wl-manifesto" "$@" ;;
  constitution) exec "$WL_ROOT/bin/wl-constitution" "$@" ;;
  design-system) exec "$WL_ROOT/bin/wl-design-system" "$@" ;;
  help|*)
    "$WL_ROOT/bin/wl-platform-0" help
    ;;
esac
SH
  chmod +x bin/wl
fi

cat <<'DONE'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Platform 0.1 Philosophy Engine Implemented
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Added:

✓ lib/philosophy/engine.sh
✓ bin/wl-platform-0
✓ bin/wl-philosophy
✓ bin/wl-north-star
✓ bin/wl-craftsmanship
✓ bin/wl-governance
✓ bin/wl-review
✓ bin/wl-manifesto
✓ bin/wl-constitution
✓ bin/wl-design-system
✓ bin/wl-platform-0-status
✓ bin/wl-platform-0-doctor
✓ bin/wl-platform-0-verify
✓ docs/philosophy/PLATFORM-0.1-PHILOSOPHY-ENGINE.md
✓ config/platform0/engine.json

Verify:

  wl philosophy
  wl platform-0 status
  wl platform-0 doctor

Commit:

  git add bin lib docs config
  git commit -m "implement Platform 0.1 philosophy engine"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DONE
