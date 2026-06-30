#!/usr/bin/env bash
set -euo pipefail

wl_refactor_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_refactor_split_plan() {
  local root out threshold
  root="$(wl_refactor_root)"
  threshold="${1:-200}"
  out="$root/vault/05-Registry/refactor/module-split-plan.txt"
  mkdir -p "$(dirname "$out")"

  {
    echo "Wonderland Module Split Plan"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "Threshold: $threshold lines"
    echo
    echo "Oversized modules"
    echo "-----------------"

    find "$root/lib" -type f -name '*.sh' 2>/dev/null | sort | while read -r f; do
      lines="$(wc -l < "$f" | tr -d ' ')"
      rel="${f#$root/}"

      if [[ "$lines" -gt "$threshold" ]]; then
        echo "$rel lines=$lines"

        echo "  candidate functions:"
        grep -E '^[a-zA-Z0-9_]+[[:space:]]*\(\)[[:space:]]*\{' "$f" 2>/dev/null \
          | sed -E 's/[[:space:]]*\(\)[[:space:]]*\{//' \
          | sed 's/^/    - /' \
          || true

        echo "  recommendation: split only by cohesive responsibility, not line count alone"
        echo
      fi
    done

    echo
    echo "Safe refactor rules"
    echo "-------------------"
    echo "1. Copy before moving."
    echo "2. Preserve compatibility shims."
    echo "3. Keep public commands stable."
    echo "4. Regenerate registry after changes."
    echo "5. Run wl lint all, wl doctor all, wl verify."
  } > "$out"

  cat "$out"
  echo
  echo "PASS refactor split plan $out"
}

wl_refactor_usage() {
  cat <<'TXT'
Usage:
  wl refactor split [line-threshold]
  wl refactor plan [line-threshold]
TXT
}

wl_refactor_main() {
  case "${1:-plan}" in
    split|plan)
      shift || true
      wl_refactor_split_plan "${1:-200}"
      ;;
    -h|--help|help) wl_refactor_usage ;;
    *) wl_refactor_usage; return 2 ;;
  esac
}
