#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
REGISTRY="$WL_HOME/config/storage/t7-mirror.json"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG_DIR="$WL_HOME/vault/08-Operations/logs/mirror"
REPORT_DIR="$WL_HOME/vault/08-Operations/reports/mirror"
CERT_DIR="$WL_HOME/vault/08-Operations/certifications/mirror"
SNAP_DIR="$WL_HOME/vault/08-Operations/snapshots/mirror"

mkdir -p "$LOG_DIR" "$REPORT_DIR" "$CERT_DIR" "$SNAP_DIR"

pass(){ echo "PASS $*"; }
warn(){ echo "WARN $*" >&2; }
fail(){ echo "FAIL $*" >&2; exit 1; }

json_get() {
  python3 - "$REGISTRY" "$1" <<'PY'
import json, sys
path = sys.argv[2].split(".")
with open(sys.argv[1], "r", encoding="utf-8") as f:
    cur = json.load(f)
for p in path:
    cur = cur[p]
print(cur)
PY
}

volume_path(){ json_get storage.volume_path; }
source_path(){ json_get storage.source; }
dest_path(){ json_get storage.destination; }
exclude_file(){ echo "$WL_HOME/$(json_get storage.exclude_file)"; }

require_registry() {
  [[ -f "$REGISTRY" ]] || fail "missing registry: $REGISTRY"
}

mounted() {
  [[ -d "$(volume_path)" ]]
}

status() {
  require_registry

  local vol src dst

  vol="$(volume_path)"
  src="$(source_path)"
  dst="$(dest_path)"

  echo "Wonderland T7 Mirror Status"
  echo
  [[ -d "$vol" ]] && echo "T7 Mounted ........ PASS" || echo "T7 Mounted ........ FAIL"
  [[ -d "$src" ]] && echo "Source ............ PASS $src" || echo "Source ............ FAIL $src"
  [[ -d "$dst" ]] && echo "Destination ....... PASS $dst" || echo "Destination ....... MISSING $dst"
  [[ -f "$(exclude_file)" ]] && echo "Exclude file ...... PASS $(exclude_file)" || echo "Exclude file ...... MISSING $(exclude_file)"
}

doctor() {
  require_registry

  local ok=1
  local vol src dst ex

  vol="$(volume_path)"
  src="$(source_path)"
  dst="$(dest_path)"
  ex="$(exclude_file)"

  status
  echo

  [[ -d "$vol" ]] || { warn "T7 not mounted: $vol"; ok=0; }
  [[ -d "$src" ]] || { warn "source missing: $src"; ok=0; }
  [[ -f "$ex" ]] || { warn "exclude file missing: $ex"; ok=0; }

  if [[ -d "$vol" ]]; then
    mkdir -p "$dst"
    [[ -w "$vol" ]] || { warn "volume not writable: $vol"; ok=0; }
    [[ -w "$dst" ]] || { warn "destination not writable: $dst"; ok=0; }
  fi

  command -v rsync >/dev/null 2>&1 || { warn "rsync missing"; ok=0; }
  command -v diskutil >/dev/null 2>&1 && pass "diskutil available" || warn "diskutil unavailable"

  if [[ "$ok" == "1" ]]; then
    pass "mirror doctor"
  else
    fail "mirror doctor found issues"
  fi
}

attach() {
  local vol
  vol="$(volume_path)"

  if [[ -d "$vol" ]]; then
    pass "T7 already mounted: $vol"
    return 0
  fi

  open /System/Applications/Utilities/Disk\ Utility.app >/dev/null 2>&1 || true
  fail "T7 not mounted. Attach the drive, then rerun: wl mirror doctor"
}

eject() {
  local vol
  vol="$(volume_path)"

  [[ -d "$vol" ]] || { pass "T7 already ejected"; return 0; }

  diskutil eject "$vol"
  pass "ejected $vol"
}

rsync_common() {
  local src dst ex

  src="$(source_path)/"
  dst="$(dest_path)/"
  ex="$(exclude_file)"

  mkdir -p "$dst"

  rsync -aHAX --delete \
    --human-readable \
    --itemize-changes \
    --exclude-from="$ex" \
    "$@" \
    "$src" "$dst"
}

diff_mirror() {
  doctor >/dev/null

  local out="$REPORT_DIR/diff-$STAMP.log"

  rsync_common --dry-run | tee "$out"

  pass "diff log: $out"
}

update_mirror() {
  doctor >/dev/null

  local out="$LOG_DIR/update-$STAMP.log"

  echo "Updating Wonderland T7 mirror..."
  echo "Source: $(source_path)"
  echo "Dest:   $(dest_path)"
  echo

  rsync_common --stats | tee "$out"

  pass "update log: $out"
}

verify() {
  doctor >/dev/null

  local src dst out
  src="$(source_path)"
  dst="$(dest_path)"
  out="$REPORT_DIR/verify-$STAMP.md"

  {
    echo "# Wonderland T7 Mirror Verify"
    echo
    echo "Date: $STAMP"
    echo
    echo "Source: $src"
    echo "Destination: $dst"
    echo
    echo "## Counts"
    echo
    echo '```text'
    echo "Source files:"
    find "$src" -type f | wc -l
    echo "Destination files:"
    find "$dst" -type f | wc -l
    echo '```'
    echo
    echo "## Dry-run diff"
    echo
    echo '```text'
    rsync_common --dry-run | head -200 || true
    echo '```'
  } > "$out"

  pass "mirror verify report: $out"
  echo "RESULT PASS"
}

snapshot() {
  doctor >/dev/null

  local out="$SNAP_DIR/mirror-snapshot-$STAMP.md"

  {
    echo "# Wonderland T7 Mirror Snapshot"
    echo
    echo "Date: $STAMP"
    echo
    status
    echo
    echo "## Registry"
    cat "$REGISTRY"
  } > "$out"

  pass "mirror snapshot: $out"
}

certify() {
  local out="$CERT_DIR/mirror-certified-$STAMP.md"

  {
    echo "# Wonderland T7 Mirror Certification"
    echo
    echo "Date: $STAMP"
    echo
    echo "## Doctor"
    doctor || true
    echo
    echo "## Verify"
    verify || true
    echo
    echo "## Registry"
    cat "$REGISTRY" 2>/dev/null || true
  } > "$out"

  pass "mirror certification: $out"
}

inventory() {
  local out="$WL_HOME/vault/08-Operations/platform/storage/t7-mirror-inventory-latest.json"

  mkdir -p "$(dirname "$out")"

  python3 - "$REGISTRY" "$out" <<'PY'
import json, os, sys
from pathlib import Path

registry = Path(sys.argv[1])
out = Path(sys.argv[2])
data = json.loads(registry.read_text())
storage = data["storage"]

result = {
    "name": storage["name"],
    "volume_path": storage["volume_path"],
    "source": storage["source"],
    "destination": storage["destination"],
    "mounted": Path(storage["volume_path"]).exists(),
    "source_exists": Path(storage["source"]).exists(),
    "destination_exists": Path(storage["destination"]).exists()
}

out.write_text(json.dumps(result, indent=2) + "\n")
PY

  pass "mirror inventory: $out"
}

case "${1:-status}" in
  status) status ;;
  doctor) doctor ;;
  attach) attach ;;
  eject) eject ;;
  diff) diff_mirror ;;
  update) update_mirror ;;
  verify) verify ;;
  snapshot) snapshot ;;
  certify) certify ;;
  inventory) inventory ;;
  bootstrap)
    doctor
    inventory
    snapshot
    ;;
  *)
    cat <<USAGE
Usage:
  wl-mirror status
  wl-mirror doctor
  wl-mirror attach
  wl-mirror eject
  wl-mirror diff
  wl-mirror update
  wl-mirror verify
  wl-mirror snapshot
  wl-mirror certify
  wl-mirror inventory
  wl-mirror bootstrap
USAGE
    exit 1
    ;;
esac
