#!/usr/bin/env bash
set -euo pipefail
source "$WL_ROOT/lib/academy/common.sh"

academy_quality() {
  local root failures=0 chapters
  root="$(academy_root)"

  [[ -d "$root" ]] && academy_pass "academy root" || { echo "FAIL academy root missing: $root"; return 1; }

  if [[ -f "$root/registry/chapters.json" ]]; then
    "$WL_ROOT/lib/academy/registry.py" validate || return 1
    "$WL_ROOT/lib/academy/manifest.py" validate || return 1
    if [[ -f "$root/build/build-manifest.json" ]]; then
      "$WL_ROOT/lib/academy/build.py" validate || return 1
    else
      echo "WARN build manifest missing; run wl academy build"
    fi
  else
    echo "FAIL registry missing: $root/registry/chapters.json"
    return 1
  fi

  mapfile -t chapters < <(academy_find_chapters)
  [[ "${#chapters[@]}" -gt 0 ]] && academy_pass "chapters discovered: ${#chapters[@]}" || {
    echo "FAIL no chapter.md files found"
    return 1
  }

  for chapter in "${chapters[@]}"; do
    local dir
    dir="$(dirname "$chapter")"

    for required in chapter.md metadata.yaml publication.json certification.md README.md; do
      if [[ -f "$dir/$required" ]]; then
        academy_pass "$(realpath --relative-to="$WL_ROOT" "$dir/$required" 2>/dev/null || echo "$dir/$required")"
      else
        echo "FAIL missing $dir/$required"
        failures=$((failures + 1))
      fi
    done

    if grep -RInE 'TODO|FIXME|TBD|PLACEHOLDER' "$dir" \
      --exclude-dir=.git \
      --exclude='*.png' \
      --exclude='*.jpg' \
      --exclude='*.jpeg' \
      --exclude='*.webp' >/tmp/wl-academy-placeholders.$$ 2>/dev/null; then
      echo "FAIL placeholders found in $dir"
      cat /tmp/wl-academy-placeholders.$$
      failures=$((failures + 1))
    else
      academy_pass "placeholder audit: $dir"
    fi
    rm -f /tmp/wl-academy-placeholders.$$
  done

  [[ "$failures" -eq 0 ]] && echo "RESULT PASS" || { echo "RESULT FAIL"; return 1; }
}
