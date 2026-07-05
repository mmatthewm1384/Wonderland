#!/usr/bin/env bash
set -euo pipefail

wl_knowledge_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

wl_knowledge_build() {
  local root now fp
  root="$(wl_knowledge_root)"
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  mkdir -p "$root/knowledge/generated"

  {
    echo "# Wonderland Knowledge Index"
    echo
    echo "Generated: $now"
    echo
    find "$root/knowledge" -type f \
      ! -path "*/packages/*" \
      ! -path "*/generated/*" \
      | sed "s#^$root/##" | sort | awk '{print "- " $0}'
  } > "$root/knowledge/generated/index.md"

  fp="$(find "$root/knowledge" -type f ! -path "*/packages/*" -exec shasum -a 256 {} + 2>/dev/null | sort | shasum -a 256 | awk '{print $1}' | cut -c1-16)"

  cat > "$root/knowledge/manifest.json" <<EOF_MANIFEST
{
  "system": "Wonderland Knowledge System",
  "version": "1.0",
  "generated_at": "$now",
  "fingerprint": "$fp"
}
EOF_MANIFEST

  echo "PASS knowledge build"
  echo "Fingerprint: $fp"
}

wl_knowledge_init() {
  local root
  root="$(wl_knowledge_root)"

  mkdir -p "$root/knowledge"/{foundation,architecture,projects,history,roadmap,decisions,standards,bootstrap,handoff,generated,packages}

  cat > "$root/knowledge/README.md" <<'EOF_README'
# Wonderland Knowledge System

Canonical version-controlled continuity layer for Wonderland.

This system preserves architecture, standards, project state, decisions, roadmap, handoffs, and AI bootstrap context.
EOF_README

  cat > "$root/knowledge/foundation/WL-KNOW-001-Foundation.md" <<'EOF_FOUNDATION'
# WL-KNOW-001 — Foundation

**Status:** Canonical  
**Version:** 1.0

Wonderland is a local-first, rootless, privacy-conscious digital ecosystem integrating infrastructure, automation, software engineering, documentation, desktop applications, observability, governance, and AI-assisted workflows.

Core priorities:

1. Reliability
2. Recoverability
3. Security
4. Privacy
5. Automation
6. Observability
7. Maintainability
8. Simplicity
9. Modularity
10. Documentation

Prefer durable, verified, version-controlled systems over clever one-off implementations.
EOF_FOUNDATION

  cat > "$root/knowledge/decisions/ADR-0001-rootless-by-default.md" <<'EOF_ADR'
# ADR-0001 — Rootless by Default

**Status:** Accepted

## Decision

Wonderland prefers rootless infrastructure using Lima and nerdctl where practical.

## Rationale

Rootless systems reduce host risk, improve recoverability, avoid unnecessary privileged daemons, and align with Wonderland's local-first platform model.

## Consequences

- Shared runtime conventions are required.
- Verification tooling must account for Lima and nerdctl.
- Platform services should avoid unnecessary host privileges.
EOF_ADR

  cat > "$root/knowledge/bootstrap/bootstrap.txt" <<'EOF_BOOTSTRAP'
This is the canonical Wonderland Knowledge System.

Before making architecture or implementation decisions, read the knowledge directory and treat it as authoritative.

Wonderland priorities:
- local-first
- rootless where practical
- nerdctl over Docker
- Lima-backed infrastructure
- privacy-conscious defaults
- reusable platform services
- verification-driven development
- documentation as production code
EOF_BOOTSTRAP

  wl_knowledge_build
}

wl_knowledge_verify() {
  local root fail
  root="$(wl_knowledge_root)"
  fail=0

  for f in \
    knowledge/README.md \
    knowledge/foundation/WL-KNOW-001-Foundation.md \
    knowledge/decisions/ADR-0001-rootless-by-default.md \
    knowledge/bootstrap/bootstrap.txt \
    knowledge/manifest.json
  do
    if [ -f "$root/$f" ]; then
      echo "PASS $f"
    else
      echo "FAIL missing $f"
      fail=1
    fi
  done

  if [ "$fail" -eq 0 ]; then
    echo "RESULT PASS"
  else
    echo "RESULT FAIL"
    return 1
  fi
}

wl_knowledge_status() {
  local root
  root="$(wl_knowledge_root)"
  if [ -f "$root/knowledge/manifest.json" ]; then
    cat "$root/knowledge/manifest.json"
  else
    echo "Knowledge manifest missing. Run: wl-knowledge init"
    return 1
  fi
}

wl_knowledge_package() {
  local root stamp out
  root="$(wl_knowledge_root)"
  stamp="$(date -u +"%Y%m%d-%H%M%S")"
  out="$root/knowledge/packages/Wonderland-Knowledge-$stamp.zip"

  wl_knowledge_build >/dev/null

  cd "$root"
  zip -qr "$out" knowledge -x "knowledge/packages/*"

  echo "PASS package created: ${out#$root/}"
}

wl_knowledge_main() {
  local cmd
  cmd="${1:-help}"
  shift || true

  case "$cmd" in
    init) wl_knowledge_init "$@" ;;
    build) wl_knowledge_build "$@" ;;
    verify|doctor) wl_knowledge_verify "$@" ;;
    status) wl_knowledge_status "$@" ;;
    package|export) wl_knowledge_package "$@" ;;
    bootstrap) cat "$(wl_knowledge_root)/knowledge/bootstrap/bootstrap.txt" ;;
    help|-h|--help)
      echo "Usage: wl-knowledge {init|build|verify|doctor|status|package|bootstrap}"
      ;;
    *)
      echo "FAIL unknown knowledge command: $cmd" >&2
      return 1
      ;;
  esac
}
