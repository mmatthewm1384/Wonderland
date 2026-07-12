#!/usr/bin/env bash
set -euo pipefail

academy_root() {
  echo "${WL_ACADEMY_ROOT:-$WL_ROOT/academy}"
}

academy_chapters_root() {
  local root
  root="$(academy_root)"
  if [[ -d "$root/02-lessons" ]]; then
    echo "$root/02-lessons"
  elif [[ -d "$root/chapters" ]]; then
    echo "$root/chapters"
  else
    echo "$root"
  fi
}

academy_die() {
  echo "FAIL $*" >&2
  exit 1
}

academy_pass() {
  echo "PASS $*"
}

academy_warn() {
  echo "WARN $*" >&2
}

academy_find_chapters() {
  local root
  root="$(academy_chapters_root)"
  find "$root" -type f -name chapter.md -print 2>/dev/null | sort
}
