#!/usr/bin/env bash
set -euo pipefail

wl_checkpoint_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_checkpoint_latest() {
  local root latest
  root="$(wl_checkpoint_root)"
  latest="$root/vault/05-Registry/checkpoints/latest-platform-core.json"

  [[ -f "$latest" ]] || {
    echo "FAIL missing latest checkpoint: $latest"
    return 1
  }

  cat "$latest"
}

wl_checkpoint_validate() {
  local root failed=0
  root="$(wl_checkpoint_root)"

  echo "Wonderland Checkpoint Validation"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo

  for f in \
    "$root/vault/05-Registry/checkpoints/latest-platform-core.json" \
    "$root/vault/05-Registry/certifications/platform-core-2.3.json"
  do
    if [[ ! -f "$f" ]]; then
      echo "FAIL missing $f"
      failed=1
      continue
    fi

    if python3 -m json.tool "$f" >/dev/null; then
      echo "PASS valid json ${f#$root/}"
    else
      echo "FAIL invalid json ${f#$root/}"
      failed=1
    fi
  done

  [[ "$failed" -eq 0 ]] && echo "RESULT PASS" || echo "RESULT FAIL"
  return "$failed"
}

wl_checkpoint_export() {
  local root latest cert out
  root="$(wl_checkpoint_root)"
  latest="$root/vault/05-Registry/checkpoints/latest-platform-core.json"
  cert="$root/vault/05-Registry/certifications/platform-core-2.3.json"
  out="$root/vault/05-Registry/exports/platform-core-2.3-certified-handoff.md"

  mkdir -p "$(dirname "$out")"

  {
    echo "# Wonderland Platform Core 2.3 Certified Handoff"
    echo
    echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "## Latest Checkpoint"
    echo
    echo '```json'
    cat "$latest"
    echo '```'
    echo
    echo "## Certification"
    echo
    echo '```json'
    cat "$cert"
    echo '```'
    echo
    echo "## Current Status"
    echo
    if [[ -f "$root/vault/05-Registry/status/latest-status.md" ]]; then
      cat "$root/vault/05-Registry/status/latest-status.md"
    else
      echo "No latest status markdown found."
    fi
    echo
    echo "## Recovery Commands"
    echo
    echo '```bash'
    echo "wl checkpoint latest"
    echo "wl checkpoint validate"
    echo "wl status"
    echo "wl doctor all"
    echo "wl verify"
    echo '```'
  } > "$out"

  cat "$out"
  echo
  echo "PASS checkpoint handoff $out"
}

wl_checkpoint_usage() {
  cat <<'TXT'
Usage:
  wl checkpoint latest
  wl checkpoint validate
  wl checkpoint export
TXT
}

wl_checkpoint_main() {
  case "${1:-latest}" in
    latest) wl_checkpoint_latest ;;
    validate) wl_checkpoint_validate ;;
    export) wl_checkpoint_export ;;
    -h|--help|help) wl_checkpoint_usage ;;
    *) wl_checkpoint_usage; return 2 ;;
  esac
}
