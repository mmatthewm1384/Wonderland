#!/usr/bin/env bash
set -euo pipefail
ROOT="${WL_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"
REGISTRY="$ROOT/sparks/registry.yaml"
BACKUP="$ROOT/.wonderland/registry-certification-v1.preinstall.yaml"
MARKER="$ROOT/.wonderland/spark-registry-certification-v1.installed"
[ -f "$REGISTRY" ] || { printf 'ERROR: registry missing\n' >&2; exit 1; }
[ -f "$BACKUP" ] || { printf 'ERROR: rollback backup missing\n' >&2; exit 1; }
cp "$BACKUP" "$REGISTRY"
rm -f "$MARKER"
printf '%s\n' 'PASS: Spark Registry Certification v1 rollback complete'
