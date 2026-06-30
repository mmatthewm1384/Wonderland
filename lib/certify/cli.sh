#!/usr/bin/env bash
set -euo pipefail

wl_certify_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_certify_platform_core() {
  local root version id cert out failed=0
  root="$(wl_certify_root)"
  version="${1:-2.3}"
  id="platform-core-$version"
  cert="$root/vault/05-Registry/certifications/$id.json"
  out="$root/vault/05-Registry/exports/$id-certified-handoff.md"

  mkdir -p "$(dirname "$cert")" "$(dirname "$out")"

  echo "Wonderland Platform Core Certification"
  echo "version=$version"
  echo

  "$root/bin/wl" fix apply --safe || failed=1
  "$root/bin/wl" architecture snapshot >/dev/null || failed=1
  "$root/bin/wl" status >/dev/null || failed=1
  "$root/bin/wl" doctor all || failed=1
  "$root/bin/wl" verify || failed=1
  "$root/bin/wl" checkpoint validate || failed=1
  "$root/bin/wl" checkpoint export >/dev/null || failed=1

  if [[ "$failed" -ne 0 ]]; then
    echo "RESULT FAIL"
    return 1
  fi

  cat > "$cert" <<JSON
{
  "id": "$id",
  "name": "Wonderland Platform Core $version",
  "state": "certified",
  "created_utc": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "gate": {
    "fix_apply_safe": "PASS",
    "architecture_snapshot": "PASS",
    "status": "PASS",
    "doctor_all": "PASS",
    "verify": "PASS",
    "checkpoint_validate": "PASS"
  },
  "artifacts": {
    "status": "vault/05-Registry/status/latest-status.md",
    "status_json": "vault/05-Registry/status/latest-status.json",
    "checkpoint": "vault/05-Registry/checkpoints/latest-platform-core.json",
    "handoff": "vault/05-Registry/exports/$id-certified-handoff.md"
  }
}
JSON

  {
    echo "# Wonderland Platform Core $version Certified Handoff"
    echo
    echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "## Certification"
    echo
    echo '```json'
    cat "$cert"
    echo '```'
    echo
    echo "## Status"
    echo
    cat "$root/vault/05-Registry/status/latest-status.md"
    echo
    echo "## Verification Commands"
    echo
    echo '```bash'
    echo "wl certify platform-core $version"
    echo "wl doctor all"
    echo "wl verify"
    echo "wl checkpoint validate"
    echo '```'
  } > "$out"

  echo "PASS certification ${cert#$root/}"
  echo "PASS handoff ${out#$root/}"
  echo "RESULT PASS"
}

wl_certify_usage() {
  cat <<'TXT'
Usage:
  wl certify platform-core [version]
TXT
}

wl_certify_main() {
  case "${1:-}" in
    platform-core)
      shift
      wl_certify_platform_core "${1:-2.3}"
      ;;
    -h|--help|help|"") wl_certify_usage ;;
    *) wl_certify_usage; return 2 ;;
  esac
}
