#!/usr/bin/env bash
set -euo pipefail

wl_migrate_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_migrate_wrappers_plan() {
  local root out
  root="$(wl_migrate_root)"
  out="$root/vault/05-Registry/migrate/wrapper-migration-plan.txt"
  mkdir -p "$(dirname "$out")"

  {
    echo "Wonderland Wrapper Migration Plan"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "Tiny wrapper or alias candidates"
    echo "-------------------------------"

    find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null | sort | while read -r f; do
      rel="${f#$root/}"
      lines="$(wc -l < "$f" | tr -d ' ')"

      if grep -q 'lib/wl-bootstrap.sh' "$f" 2>/dev/null; then
        continue
      fi

      if [[ "$lines" -le 25 ]]; then
        echo "$rel lines=$lines action=review-for-bootstrap-wrapper"
      fi
    done

    echo
    echo "Protected feature commands"
    echo "--------------------------"

    find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null | sort | while read -r f; do
      rel="${f#$root/}"
      lines="$(wc -l < "$f" | tr -d ' ')"

      if [[ "$lines" -gt 25 ]]; then
        echo "$rel lines=$lines action=preserve-feature-command"
      fi
    done
  } > "$out"

  cat "$out"
  echo
  echo "PASS migrate wrappers plan $out"
}

wl_migrate_registry_plan() {
  local root out
  root="$(wl_migrate_root)"
  out="$root/vault/05-Registry/migrate/registry-migration-plan.txt"
  mkdir -p "$(dirname "$out")"

  {
    echo "Wonderland Registry Migration Plan"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "Current registry modules"
    echo "------------------------"
    find "$root/lib/core/registry" -type f -name '*.sh' 2>/dev/null | sed "s#$root/##" | sort
    echo
    echo "Recommended checks"
    echo "------------------"
    echo "1. Keep registry IO centralized."
    echo "2. Keep generation, validation, docs, paths, and CLI separate."
    echo "3. Do not convert feature commands into generic wrappers."
    echo "4. Regenerate registry after command moves."
  } > "$out"

  cat "$out"
  echo
  echo "PASS migrate registry plan $out"
}

wl_migrate_usage() {
  cat <<'TXT'
Usage:
  wl migrate wrappers
  wl migrate registry
  wl migrate all
TXT
}

wl_migrate_main() {
  case "${1:-all}" in
    wrappers) wl_migrate_wrappers_plan ;;
    registry) wl_migrate_registry_plan ;;
    all)
      wl_migrate_wrappers_plan
      wl_migrate_registry_plan
      ;;
    -h|--help|help) wl_migrate_usage ;;
    *) wl_migrate_usage; return 2 ;;
  esac
}
