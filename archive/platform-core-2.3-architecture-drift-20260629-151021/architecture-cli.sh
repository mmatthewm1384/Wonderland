#!/usr/bin/env bash
set -euo pipefail

wl_arch_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_arch_report() {
  local root out
  root="$(wl_arch_root)"
  out="$root/vault/05-Registry/architecture/report.txt"
  mkdir -p "$(dirname "$out")"

  {
    echo "Wonderland Architecture Report"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "Module counts"
    echo "-------------"
    find "$root/lib" -type f -name '*.sh' 2>/dev/null \
      | sed "s#^$root/lib/##" \
      | awk -F/ '{print $1}' \
      | sort | uniq -c | sort -nr
    echo
    echo "Largest modules"
    echo "---------------"
    find "$root/lib" -type f -name '*.sh' 2>/dev/null \
      | while read -r f; do wc -l "$f"; done \
      | sort -nr | head -20 \
      | sed "s#$root/##"
    echo
    echo "Command inventory"
    echo "-----------------"
    echo "bin commands: $(find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null | wc -l | tr -d ' ')"
    echo "bootstrap wrappers: $(grep -RIl 'lib/wl-bootstrap.sh' "$root/bin" 2>/dev/null | wc -l | tr -d ' ')"
    echo "feature-like commands: $(find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null | while read -r f; do [[ "$(wc -l < "$f" | tr -d ' ')" -gt 25 ]] && echo "$f"; done | wc -l | tr -d ' ')"
    echo
    echo "Applications"
    echo "------------"
    find "$root/apps" "$root/Workshop/apps" -maxdepth 3 -type d 2>/dev/null | sed "s#$root/##" | sort | head -100 || true
  } > "$out"

  cat "$out"
  echo
  echo "PASS architecture report $out"
}

wl_arch_graph() {
  local root out
  root="$(wl_arch_root)"
  out="$root/vault/05-Registry/architecture/dependency.dot"
  mkdir -p "$(dirname "$out")"

  {
    echo "digraph WonderlandShellDependencies {"
    echo '  rankdir=LR;'
    find "$root/lib" -type f -name '*.sh' 2>/dev/null | while read -r f; do
      local from
      from="$(basename "$f")"
      grep -E '(^|[[:space:]])(\.|source)[[:space:]]+["'\'']?\$?ROOT/' "$f" 2>/dev/null \
        | sed -E 's/.*(lib\/[^"'\'' ]+\.sh).*/\1/' \
        | while read -r dep; do
            [[ "$dep" == lib/* ]] || continue
            printf '  "%s" -> "%s";\n' "$from" "$(basename "$dep")"
          done
    done
    echo "}"
  } > "$out"

  echo "PASS architecture graph $out"
}

wl_arch_usage() {
  cat <<'TXT'
Usage:
  wl architecture report
  wl architecture graph
TXT
}

wl_architecture_main() {
  case "${1:-report}" in
    report) wl_arch_report ;;
    graph) wl_arch_graph ;;
    -h|--help|help) wl_arch_usage ;;
    *) wl_arch_usage; return 2 ;;
  esac
}
