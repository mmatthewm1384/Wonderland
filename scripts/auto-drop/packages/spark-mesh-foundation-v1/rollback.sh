#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"

say() { printf '%s\n' "$*"; }

say "== Spark Mesh Foundation v1 rollback =="

# The package never overwrites existing files. Remove only the files and empty
# directories it owns, preserving any user-created content underneath them.
MARKER="$ROOT/.wonderland/spark-mesh-foundation-v1.installed"
if [ -f "$MARKER" ]; then
  rm -f "$MARKER"
  say "REMOVED installation marker"
fi

if [ -f "$ROOT/sparks/registry.yaml" ] && grep -q '^schema: wonderland.spark-registry/v1$' "$ROOT/sparks/registry.yaml" && grep -q '^sparks: \[\]$' "$ROOT/sparks/registry.yaml"; then
  rm -f "$ROOT/sparks/registry.yaml"
  say "REMOVED foundation-created empty registry"
else
  say "PRESERVED sparks/registry.yaml"
fi

for path in \
  sparks/spark-taylor-001/evidence \
  sparks/spark-taylor-001/ui \
  sparks/spark-taylor-001/capabilities \
  sparks/spark-matthew-001/evidence \
  sparks/spark-matthew-001/ui \
  sparks/spark-matthew-001/capabilities \
  Crystal/us/certification \
  Crystal/us/evidence \
  Crystal/us/registry \
  Crystal/us/trust \
  Crystal/us/identity; do
  if [ -d "$ROOT/$path" ] && [ -z "$(find "$ROOT/$path" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
    rmdir "$ROOT/$path"
    say "REMOVED empty $path"
  else
    say "PRESERVED $path"
  fi
done

say "PASS: rollback complete"
