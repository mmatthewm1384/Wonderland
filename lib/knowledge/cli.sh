#!/usr/bin/env bash
set -euo pipefail

wl_knowledge_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

wks_now() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

wks_generated_dir() {
  local root
  root="$(wl_knowledge_root)"
  mkdir -p "$root/knowledge/generated"
  printf '%s\n' "$root/knowledge/generated"
}

wks_scan_commands() {
  local root out count
  root="$(wl_knowledge_root)"
  out="$(wks_generated_dir)/commands.md"

  count=0
  if [ -d "$root/bin" ]; then
    count="$(find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null | wc -l | tr -d ' ')"
  fi

  {
    echo "# Command Catalog"
    echo
    echo "Generated: $(wks_now)"
    echo
    echo "Executable commands: **$count**"
    echo
    echo "## Commands"
    if [ -d "$root/bin" ]; then
      find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null \
        | sed "s#^$root/bin/##" \
        | sort \
        | awk '{print "- `" $0 "`"}'
    else
      echo "- bin directory not found"
    fi
  } > "$out"
}

wks_scan_apps() {
  local root out app_count swift_count tauri_count
  root="$(wl_knowledge_root)"
  out="$(wks_generated_dir)/applications.md"

  app_count=0
  [ -d "$root/apps" ] && app_count="$(find "$root/apps" -mindepth 1 -maxdepth 3 -type d 2>/dev/null | wc -l | tr -d ' ')"
  swift_count="$(find "$root" -path "*/Package.swift" ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  tauri_count="$(find "$root" \( -path "*/src-tauri/tauri.conf.json" -o -path "*/src-tauri/Tauri.toml" \) ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"

  {
    echo "# Application Catalog"
    echo
    echo "Generated: $(wks_now)"
    echo
    echo "Application directories: **$app_count**"
    echo "Swift packages: **$swift_count**"
    echo "Tauri apps: **$tauri_count**"
    echo
    echo "## App Paths"
    if [ -d "$root/apps" ]; then
      find "$root/apps" -mindepth 1 -maxdepth 3 -type d 2>/dev/null \
        | sed "s#^$root/##" \
        | sort \
        | awk '{print "- `" $0 "`"}'
    else
      echo "- apps directory not found"
    fi
    echo
    echo "## Swift Packages"
    find "$root" -path "*/Package.swift" ! -path "*/.git/*" 2>/dev/null \
      | sed "s#^$root/##" \
      | sort \
      | awk '{print "- `" $0 "`"}'
    echo
    echo "## Tauri Configs"
    find "$root" \( -path "*/src-tauri/tauri.conf.json" -o -path "*/src-tauri/Tauri.toml" \) ! -path "*/.git/*" 2>/dev/null \
      | sed "s#^$root/##" \
      | sort \
      | awk '{print "- `" $0 "`"}'
  } > "$out"
}

wks_scan_docs() {
  local root out md_count adr_count knowledge_count
  root="$(wl_knowledge_root)"
  out="$(wks_generated_dir)/documentation.md"

  md_count="$(find "$root" -type f -name "*.md" ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  adr_count="$(find "$root" -type f \( -name "ADR-*.md" -o -path "*/decisions/*.md" \) ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  knowledge_count="$(find "$root/knowledge" -type f \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | wc -l | tr -d ' ')"

  {
    echo "# Documentation Catalog"
    echo
    echo "Generated: $(wks_now)"
    echo
    echo "Markdown files: **$md_count**"
    echo "ADR / decision files: **$adr_count**"
    echo "Knowledge files: **$knowledge_count**"
    echo
    echo "## Knowledge Documents"
    find "$root/knowledge" -type f \( -name "*.md" -o -name "*.txt" \) ! -path "*/generated/*" ! -path "*/packages/*" 2>/dev/null \
      | sed "s#^$root/##" \
      | sort \
      | awk '{print "- `" $0 "`"}'
    echo
    echo "## ADR / Decision Documents"
    find "$root" -type f \( -name "ADR-*.md" -o -path "*/decisions/*.md" \) ! -path "*/.git/*" 2>/dev/null \
      | sed "s#^$root/##" \
      | sort \
      | awk '{print "- `" $0 "`"}'
  } > "$out"
}

wks_scan_services() {
  local root out service_count plist_count compose_count
  root="$(wl_knowledge_root)"
  out="$(wks_generated_dir)/services.md"

  service_count="$(find "$root" -type f \( -name "*.service" -o -name "*.timer" \) ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  plist_count="$(find "$root" -type f -name "*.plist" ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  compose_count="$(find "$root" -type f \( -name "compose.yml" -o -name "docker-compose.yml" -o -name "docker-compose.yaml" \) ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"

  {
    echo "# Service Catalog"
    echo
    echo "Generated: $(wks_now)"
    echo
    echo "systemd units: **$service_count**"
    echo "LaunchAgent / plist files: **$plist_count**"
    echo "Compose files: **$compose_count**"
    echo
    echo "## Service Files"
    find "$root" -type f \( -name "*.service" -o -name "*.timer" -o -name "*.plist" -o -name "compose.yml" -o -name "docker-compose.yml" -o -name "docker-compose.yaml" \) ! -path "*/.git/*" 2>/dev/null \
      | sed "s#^$root/##" \
      | sort \
      | awk '{print "- `" $0 "`"}'
  } > "$out"
}

wks_scan_stats() {
  local root out files dirs shell python swift ts md
  root="$(wl_knowledge_root)"
  out="$(wks_generated_dir)/statistics.md"

  files="$(find "$root" -type f ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  dirs="$(find "$root" -type d ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  shell="$(find "$root" -type f \( -name "*.sh" -o -path "*/bin/*" \) ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  python="$(find "$root" -type f -name "*.py" ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  swift="$(find "$root" -type f -name "*.swift" ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  ts="$(find "$root" -type f \( -name "*.ts" -o -name "*.tsx" \) ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"
  md="$(find "$root" -type f -name "*.md" ! -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')"

  {
    echo "# Repository Statistics"
    echo
    echo "Generated: $(wks_now)"
    echo
    echo "| Metric | Count |"
    echo "|---|---:|"
    echo "| Files | $files |"
    echo "| Directories | $dirs |"
    echo "| Shell / command files | $shell |"
    echo "| Python files | $python |"
    echo "| Swift files | $swift |"
    echo "| TypeScript files | $ts |"
    echo "| Markdown files | $md |"
  } > "$out"
}

wks_scan_graph() {
  local root out
  root="$(wl_knowledge_root)"
  out="$(wks_generated_dir)/knowledge-graph.md"

  {
    echo "# Knowledge Graph"
    echo
    echo "Generated: $(wks_now)"
    echo
    echo '```text'
    echo "Wonderland"
    [ -d "$root/bin" ] && echo "├── Commands"
    [ -d "$root/lib" ] && echo "├── Libraries"
    [ -d "$root/apps" ] && echo "├── Applications"
    [ -d "$root/builder" ] && echo "├── Builder"
    [ -d "$root/controller" ] && echo "├── Controller"
    [ -d "$root/config" ] && echo "├── Configuration"
    [ -d "$root/docs" ] && echo "├── Documentation"
    [ -d "$root/vault" ] && echo "├── Vault"
    [ -d "$root/knowledge" ] && echo "└── Knowledge"
    echo '```'
  } > "$out"
}

wks_write_repository_inventory() {
  local root out
  root="$(wl_knowledge_root)"
  out="$(wks_generated_dir)/repository-inventory.md"

  {
    echo "# Repository Inventory"
    echo
    echo "Generated: $(wks_now)"
    echo
    echo "## Top-Level Paths"
    find "$root" -maxdepth 2 -mindepth 1 \
      ! -path "*/.git*" \
      ! -path "*/knowledge/packages*" \
      | sed "s#^$root/##" \
      | sort \
      | awk '{print "- `" $0 "`"}'
  } > "$out"
}

wks_write_index() {
  local root out file base
  root="$(wl_knowledge_root)"
  out="$(wks_generated_dir)/index.md"

  {
    echo "# Wonderland Knowledge Index"
    echo
    echo "Generated: $(wks_now)"
    echo
    echo "## Generated Catalogs"
    for file in "$root"/knowledge/generated/*.md; do
      [ -f "$file" ] || continue
      base="$(basename "$file")"
      [ "$base" = "index.md" ] && continue
      echo "- [$base]($base)"
    done | sort
    echo
    echo "## Source Knowledge"
    find "$root/knowledge" -type f \( -name "*.md" -o -name "*.txt" \) \
      ! -path "*/generated/*" \
      ! -path "*/packages/*" \
      | sed "s#^$root/##" \
      | sort \
      | awk '{print "- `" $0 "`"}'
  } > "$out"
}

wks_write_manifest() {
  local root
  root="$(wl_knowledge_root)"

  python3 - "$root" <<'PYJSON'
import hashlib
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

root = Path(sys.argv[1])
knowledge = root / "knowledge"

def valid_file(p: Path) -> bool:
    return p.is_file() and ".git" not in p.parts

def files_under(path: Path):
    if not path.exists():
        return []
    return [p for p in path.rglob("*") if valid_file(p)]

commands = 0
bin_dir = root / "bin"
if bin_dir.exists():
    commands = sum(1 for p in bin_dir.iterdir() if p.is_file() and os.access(p, os.X_OK))

apps_dir = root / "apps"
applications = sum(1 for p in apps_dir.rglob("*") if p.is_dir()) if apps_dir.exists() else 0

documentation = sum(1 for p in root.rglob("*.md") if ".git" not in p.parts)

service_names = {"compose.yml", "docker-compose.yml", "docker-compose.yaml"}
services = sum(
    1
    for p in files_under(root)
    if p.suffix in {".service", ".timer", ".plist"} or p.name in service_names
)

all_files = files_under(root)

h = hashlib.sha256()
for p in sorted(files_under(knowledge)):
    if "packages" in p.parts:
        continue
    rel = p.relative_to(root).as_posix()
    h.update(rel.encode())
    h.update(b"\0")
    h.update(p.read_bytes())
    h.update(b"\0")

manifest = {
    "system": "Wonderland Knowledge System",
    "version": "2.0",
    "stage": "repository-scanner",
    "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "fingerprint": h.hexdigest()[:16],
    "counts": {
        "commands": commands,
        "applications": applications,
        "documentation": documentation,
        "services": services,
        "files": len(all_files),
    },
    "generated_catalogs": [
        "knowledge/generated/index.md",
        "knowledge/generated/commands.md",
        "knowledge/generated/applications.md",
        "knowledge/generated/documentation.md",
        "knowledge/generated/services.md",
        "knowledge/generated/statistics.md",
        "knowledge/generated/repository-inventory.md",
        "knowledge/generated/knowledge-graph.md",
    ],
}

(knowledge / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
PYJSON
}

wl_knowledge_init() {
  local root
  root="$(wl_knowledge_root)"

  mkdir -p "$root/knowledge"/{foundation,architecture,projects,history,roadmap,decisions,standards,bootstrap,handoff,generated,packages}

  [ -f "$root/knowledge/README.md" ] || cat > "$root/knowledge/README.md" <<'EOD'
# Wonderland Knowledge System

Canonical version-controlled continuity layer for Wonderland.

This system preserves architecture, standards, project state, decisions, roadmap, handoffs, and AI bootstrap context.
EOD

  [ -f "$root/knowledge/foundation/WL-KNOW-001-Foundation.md" ] || cat > "$root/knowledge/foundation/WL-KNOW-001-Foundation.md" <<'EOD'
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
EOD

  [ -f "$root/knowledge/decisions/ADR-0001-rootless-by-default.md" ] || cat > "$root/knowledge/decisions/ADR-0001-rootless-by-default.md" <<'EOD'
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
EOD

  [ -f "$root/knowledge/bootstrap/bootstrap.txt" ] || cat > "$root/knowledge/bootstrap/bootstrap.txt" <<'EOD'
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
EOD

  wl_knowledge_build
}

wl_knowledge_build() {
  mkdir -p "$(wl_knowledge_root)/knowledge/generated"

  echo "Scanning Wonderland repository..."
  wks_scan_commands
  echo "PASS commands catalog"
  wks_scan_apps
  echo "PASS applications catalog"
  wks_scan_docs
  echo "PASS documentation catalog"
  wks_scan_services
  echo "PASS services catalog"
  wks_scan_stats
  echo "PASS statistics catalog"
  wks_scan_graph
  echo "PASS knowledge graph"
  wks_write_repository_inventory
  echo "PASS repository inventory"
  wks_write_index
  echo "PASS knowledge index"
  wks_write_manifest
  echo "PASS manifest"
  echo "RESULT PASS"
}

wl_knowledge_verify() {
  local root fail f
  root="$(wl_knowledge_root)"
  fail=0

  for f in \
    knowledge/README.md \
    knowledge/foundation/WL-KNOW-001-Foundation.md \
    knowledge/decisions/ADR-0001-rootless-by-default.md \
    knowledge/bootstrap/bootstrap.txt \
    knowledge/manifest.json \
    knowledge/generated/index.md \
    knowledge/generated/commands.md \
    knowledge/generated/applications.md \
    knowledge/generated/documentation.md \
    knowledge/generated/services.md \
    knowledge/generated/statistics.md \
    knowledge/generated/repository-inventory.md \
    knowledge/generated/knowledge-graph.md
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
    echo "Knowledge manifest missing. Run: wl knowledge init"
    return 1
  fi
}

wl_knowledge_package() {
  local root stamp out
  root="$(wl_knowledge_root)"
  stamp="$(date -u +"%Y%m%d-%H%M%S")"
  out="$root/knowledge/packages/Wonderland-Knowledge-$stamp.zip"

  wl_knowledge_build >/dev/null

  (
    cd "$root"
    zip -qr "$out" knowledge -x "knowledge/packages/*"
  )

  echo "PASS package created: ${out#$root/}"
}

wl_knowledge_scan() {
  local target
  target="${1:-all}"

  case "$target" in
    commands) wks_scan_commands; echo "PASS commands scan" ;;
    apps|applications) wks_scan_apps; echo "PASS applications scan" ;;
    docs|documentation) wks_scan_docs; echo "PASS documentation scan" ;;
    services) wks_scan_services; echo "PASS services scan" ;;
    stats|statistics) wks_scan_stats; echo "PASS statistics scan" ;;
    graph) wks_scan_graph; echo "PASS graph scan" ;;
    all) wl_knowledge_build ;;
    *) echo "FAIL unknown scan target: $target" >&2; return 1 ;;
  esac
}

wl_knowledge_help() {
  cat <<'EOD'
Wonderland Knowledge System

Usage:
  wl knowledge init
  wl knowledge build
  wl knowledge scan [commands|apps|docs|services|stats|graph|all]
  wl knowledge verify
  wl knowledge doctor
  wl knowledge status
  wl knowledge package
  wl knowledge bootstrap
EOD
}

wl_knowledge_main() {
  local cmd
  cmd="${1:-help}"
  shift || true

  case "$cmd" in
    init) wl_knowledge_init "$@" ;;
    build) wl_knowledge_build "$@" ;;
    scan) wl_knowledge_scan "$@" ;;
    verify|doctor) wl_knowledge_verify "$@" ;;
    status) wl_knowledge_status "$@" ;;
    package|export) wl_knowledge_package "$@" ;;
    bootstrap) cat "$(wl_knowledge_root)/knowledge/bootstrap/bootstrap.txt" ;;
    help|-h|--help) wl_knowledge_help ;;
    *) echo "FAIL unknown knowledge command: $cmd" >&2; wl_knowledge_help; return 1 ;;
  esac
}
