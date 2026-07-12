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
