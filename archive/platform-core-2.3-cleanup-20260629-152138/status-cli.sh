#!/usr/bin/env bash
set -euo pipefail

wl_status_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_status_summary() {
  local root out json score gate_result verify_result
  root="$(wl_status_root)"
  out="$root/vault/05-Registry/status/latest-status.md"
  json="$root/vault/05-Registry/status/latest-status.json"
  mkdir -p "$(dirname "$out")"

  score="$("$root/bin/wl" architecture score 2>/dev/null | awk -F= '/^score=/{print $2}' | tail -1 || true)"
  [[ -n "$score" ]] || score="unknown"

  gate_result="unknown"
  if [[ -f "$root/vault/05-Registry/gates/latest-status.txt" ]]; then
    gate_result="$(awk -F= '/^result=/{print $2}' "$root/vault/05-Registry/gates/latest-status.txt" | tail -1)"
  fi

  verify_result="unknown"
  if "$root/bin/wl" verify >/tmp/wl-status-verify.$$ 2>&1; then
    verify_result="PASS"
  else
    verify_result="FAIL"
  fi
  rm -f /tmp/wl-status-verify.$$

  {
    echo "# Wonderland Platform Status"
    echo
    echo "- Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "- Architecture score: $score"
    echo "- Last gate result: $gate_result"
    echo "- Verify result: $verify_result"
    echo
    echo "## Counts"
    echo
    echo "- Commands: $(find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null | wc -l | tr -d ' ')"
    echo "- Shell modules: $(find "$root/lib" -type f -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')"
    echo "- Doctor modules: $(find "$root/lib/doctor" -type f -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')"
    echo "- Registry files: $(find "$root/vault/05-Registry" -type f 2>/dev/null | wc -l | tr -d ' ')"
    echo
    echo "## Next Recommended Gate"
    echo
    echo '```bash'
    echo "wl fix apply --safe"
    echo "wl lint all"
    echo "wl doctor all"
    echo "wl verify"
    echo '```'
  } > "$out"

  python3 - "$json" "$score" "$gate_result" "$verify_result" "$root" <<'PY'
import json
import os
import sys
from pathlib import Path

json_path, score, gate, verify, root = sys.argv[1:]
root_path = Path(root)

def count(paths):
    total = 0
    for base, pred in paths:
        p = root_path / base
        if not p.exists():
            continue
        for item in p.rglob("*"):
            if pred(item):
                total += 1
    return total

data = {
    "generated": __import__("datetime").datetime.utcnow().replace(microsecond=0).isoformat() + "Z",
    "architecture_score": score,
    "last_gate_result": gate,
    "verify_result": verify,
    "counts": {
        "commands": sum(1 for p in (root_path / "bin").glob("*") if p.is_file() and os.access(p, os.X_OK)) if (root_path / "bin").exists() else 0,
        "shell_modules": count([("lib", lambda p: p.is_file() and p.name.endswith(".sh"))]),
        "doctor_modules": count([("lib/doctor", lambda p: p.is_file() and p.name.endswith(".sh"))]),
        "registry_files": count([("vault/05-Registry", lambda p: p.is_file())]),
    },
}
Path(json_path).write_text(json.dumps(data, indent=2) + "\n")
PY

  cat "$out"
  echo
  echo "PASS status markdown $out"
  echo "PASS status json $json"
}

wl_status_handoff() {
  local root out
  root="$(wl_status_root)"
  out="$root/vault/05-Registry/exports/platform-handoff-latest.md"
  mkdir -p "$(dirname "$out")"

  {
    echo "# Wonderland Platform Handoff"
    echo
    echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    "$root/bin/wl" status
    echo
    echo "## Architecture"
    echo
    "$root/bin/wl" architecture score || true
    echo
    echo "## Gate"
    echo
    "$root/bin/wl" gate status || true
    echo
    echo "## Maintenance Commands"
    echo
    echo '```bash'
    echo "wl status"
    echo "wl architecture score"
    echo "wl architecture drift"
    echo "wl architecture duplicates"
    echo "wl architecture cycles"
    echo "wl fix apply --safe"
    echo "wl gate check"
    echo '```'
  } > "$out"

  cat "$out"
  echo
  echo "PASS handoff export $out"
}

wl_status_usage() {
  cat <<'TXT'
Usage:
  wl status
  wl status summary
  wl status handoff
TXT
}

wl_status_main() {
  case "${1:-summary}" in
    summary) wl_status_summary ;;
    handoff) wl_status_handoff ;;
    -h|--help|help) wl_status_usage ;;
    *) wl_status_usage; return 2 ;;
  esac
}
