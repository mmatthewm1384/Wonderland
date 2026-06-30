#!/usr/bin/env bash
set -euo pipefail

wl_inventory_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_inventory_generate() {
  local root out
  root="$(wl_inventory_root)"
  out="$root/vault/05-Registry/inventory/platform-inventory.txt"
  mkdir -p "$(dirname "$out")"

  {
    echo "Wonderland Platform Inventory"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "Commands"
    echo "--------"
    find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null | sed "s#$root/##" | sort
    echo
    echo "Modules"
    echo "-------"
    find "$root/lib" -type f -name '*.sh' 2>/dev/null | sed "s#$root/##" | sort
    echo
    echo "Applications"
    echo "------------"
    find "$root/apps" "$root/Workshop/apps" -maxdepth 3 -type d 2>/dev/null | sed "s#$root/##" | sort || true
    echo
    echo "Services"
    echo "--------"
    find "$root/services" "$root/Workshop/services" -maxdepth 3 -type f \( -name 'compose.yaml' -o -name 'docker-compose.yml' \) 2>/dev/null | sed "s#$root/##" | sort || true
    echo
    echo "LaunchAgents"
    echo "------------"
    find "$HOME/Library/LaunchAgents" -maxdepth 1 -type f -name '*wonderland*' 2>/dev/null | sort || true
    echo
    echo "Vault registry objects"
    echo "----------------------"
    find "$root/vault/05-Registry" -maxdepth 4 -type f 2>/dev/null | sed "s#$root/##" | sort || true
    echo
    echo "Snapshots"
    echo "---------"
    find "$root" -maxdepth 5 -type d -iname '*snapshot*' 2>/dev/null | sed "s#$root/##" | sort | head -100 || true
  } > "$out"

  cat "$out"
  echo
  echo "PASS inventory generated $out"
}

wl_inventory_usage() {
  cat <<'TXT'
Usage:
  wl inventory
  wl inventory generate
TXT
}

wl_inventory_main() {
  case "${1:-generate}" in
    generate) wl_inventory_generate ;;
    -h|--help|help) wl_inventory_usage ;;
    *) wl_inventory_usage; return 2 ;;
  esac
}
