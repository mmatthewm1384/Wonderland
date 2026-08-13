\
#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-}"
[[ -n "$ROOT" ]] || ROOT="$(git rev-parse --show-toplevel)"
export WL_ROOT="$ROOT"

SPARK_ID="${1:-}"
[[ "$SPARK_ID" =~ ^spark-[a-z0-9-]+$ ]] || { echo "[FAIL] usage: $0 spark-<id>"; exit 2; }

IMAGE="$ROOT/Crystal/us/sparks/images/$SPARK_ID/$SPARK_ID.vm.img"
EVIDENCE="$ROOT/vault/08-Operations/evidence/spark-network-foundation/$SPARK_ID"
BACKUP="$EVIDENCE/$SPARK_ID.pre-network-foundation.vm.img"
PROFILE="$ROOT/profiles/$SPARK_ID.yaml"

[[ -f "$BACKUP" ]] || { echo "[FAIL] rollback image missing: $BACKUP"; exit 1; }

if limactl list --format '{{.Name}}' 2>/dev/null | grep -Fxq "$SPARK_ID"; then
  limactl stop "$SPARK_ID" 2>/dev/null || true
  limactl delete "$SPARK_ID" 2>/dev/null || true
fi

cp -p "$BACKUP" "$IMAGE"
rm -f "$PROFILE"

echo "[PASS] Spark image and generated profile rolled back: $SPARK_ID"
