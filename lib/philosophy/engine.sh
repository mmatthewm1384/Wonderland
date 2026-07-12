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
