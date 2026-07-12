#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
WL_MIRROR_SOURCE="${WL_MIRROR_SOURCE:-$WL_ROOT}"
WL_MIRROR_VOLUME="${WL_MIRROR_VOLUME:-/Volumes/T7_Wonderland}"
WL_MIRROR_DEST="${WL_MIRROR_DEST:-$WL_MIRROR_VOLUME/Wonderland}"

WL_REPLICATION_DIR="$WL_ROOT/vault/08-Operations/replication"
WL_MIRROR_LOG_DIR="$WL_REPLICATION_DIR/logs"
WL_MIRROR_STATE_DIR="$WL_REPLICATION_DIR/state"
WL_MIRROR_HISTORY_DIR="$WL_REPLICATION_DIR/history"
WL_MIRROR_MANIFEST="$WL_MIRROR_STATE_DIR/manifest.json"

mirror_now(){ date -u +"%Y-%m-%dT%H:%M:%SZ"; }
mirror_stamp(){ date -u +"%Y%m%d-%H%M%S"; }
pass(){ printf 'PASS %s\n' "$*"; }
warn(){ printf 'WARN %s\n' "$*"; }
fail(){ printf 'FAIL %s\n' "$*"; }

mirror_dirs(){
  mkdir -p "$WL_MIRROR_LOG_DIR" "$WL_MIRROR_STATE_DIR" "$WL_MIRROR_HISTORY_DIR"
}

mirror_mounted(){ [ -d "$WL_MIRROR_VOLUME" ]; }
mirror_writable(){ [ -d "$WL_MIRROR_VOLUME" ] && [ -w "$WL_MIRROR_VOLUME" ]; }

mirror_excludes_file(){
  mirror_dirs
  local f="$WL_MIRROR_STATE_DIR/excludes.txt"
  printf '%s\n' \
    '.git/' \
    '.DS_Store' \
    'node_modules/' \
    'target/' \
    'dist/' \
    'build/' \
    '.cache/' \
    '__pycache__/' \
    '*.pyc' \
    'vault/08-Operations/replication/logs/*.log' \
    'vault/08-Operations/replication/history/*.json' > "$f"
  printf '%s\n' "$f"
}

mirror_manifest_write(){
  local health="${1:-UNKNOWN}"
  local action="${2:-status}"
  mirror_dirs
  python3 - "$WL_MIRROR_MANIFEST" "$health" "$action" "$(mirror_now)" "$WL_MIRROR_SOURCE" "$WL_MIRROR_DEST" <<'PYJSON'
import json, os, sys
path, health, action, ts, source, dest = sys.argv[1:]
data = {}
if os.path.exists(path):
    try:
        data = json.load(open(path, encoding="utf-8"))
    except Exception:
        data = {}
data.update({
    "version": 2,
    "engine": "Wonderland Mirror Engine 2.0",
    "health": health,
    "last_action": action,
    "updated_at": ts,
    "source": source,
    "destination": dest,
    "policy": "safe-incremental-rsync",
    "destructive_operations_default": False,
})
if action == "update":
    data["last_sync"] = ts
if action == "verify":
    data["last_verify"] = ts
if action == "certify":
    data["last_certify"] = ts
os.makedirs(os.path.dirname(path), exist_ok=True)
tmp = path + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, sort_keys=True)
    f.write("\n")
os.replace(tmp, path)
PYJSON
}
