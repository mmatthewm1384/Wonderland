#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WL_REPORT_DIR="$WL_HOME/vault/08-Operations/reports"
WL_SERVICE_REGISTRY="$WL_HOME/governance/registries/lifecycle-services.json"

mkdir -p "$WL_REPORT_DIR"

wl_ts() { date +%Y%m%d-%H%M%S; }
wl_iso() { date -Iseconds; }

wl_step() { echo; echo "== $* =="; }
wl_pass() { printf "PASS %-24s %s\n" "$1" "${2:-}"; }
wl_warn() { printf "WARN %-24s %s\n" "$1" "${2:-}"; }
wl_fail() { printf "FAIL %-24s %s\n" "$1" "${2:-}"; }

wl_services() {
  printf "%s
" wl-vaultwarden wl-vaultwarden-db wl-loki
}

wl_rootless_services() {
  printf "%s
" wl-vaultwarden wl-vaultwarden-db wl-loki
}

wl_lima_running() {
  limactl list 2>/dev/null | grep -q "^$1[[:space:]].*Running"
}

wl_container_running() {
  nerdctl ps --format '{{.Names}}' 2>/dev/null | grep -qx "$1"
}

wl_rootless_container_running() {
  LIMA_INSTANCE=wonderland-rootless nerdctl ps --format '{{.Names}}' 2>/dev/null | grep -qx "$1"
}

wl_write_report() {
  local action="$1"
  local result="$2"
  local score="${3:-0}"
  local file="$WL_REPORT_DIR/lifecycle-${action}-$(wl_ts).json"

  cat > "$file" <<JSON
{
  "action": "$action",
  "result": "$result",
  "health_score": $score,
  "timestamp": "$(wl_iso)",
  "root": "$WL_HOME",
  "mode": "$(cat "$WL_HOME/.wl-mode" 2>/dev/null || echo light)"
}
JSON

  echo "REPORT $file"
}
