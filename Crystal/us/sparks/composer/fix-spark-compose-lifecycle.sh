#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

SPARK_DIR="$WL_ROOT/Crystal/us/sparks"
COMPOSER="$SPARK_DIR/composer/compose.sh"

echo "=== Spark Composer Lifecycle Fix ==="

if [[ ! -f "$COMPOSER" ]]; then
    echo "[FAIL] Missing composer:"
    echo "$COMPOSER"
    exit 1
fi

cp "$COMPOSER" "$COMPOSER.backup.$(date +%Y%m%d-%H%M%S)"

python3 <<'PY'
from pathlib import Path

p = Path.home() / "Wonderland/Crystal/us/sparks/composer/compose.sh"

s = p.read_text()

s = s.replace(
'''cat > "$OUTPUT" <<EOF
''',
'''cat > "$OUTPUT" <<EOF
'''
)

if 'spark-matthew-001.lima' in s:
    pass

p.write_text(s)
PY

cat > "$SPARK_DIR/composer/preflight.sh" <<'INNER'
#!/usr/bin/env bash
set -euo pipefail

SPARK_NAME="${1:?spark name required}"

echo "=== Spark Preflight ==="

if limactl list --format '{{.Name}}' | grep -q "^${SPARK_NAME}$"; then
    echo "[+] Removing existing Spark instance"
    limactl stop "$SPARK_NAME" 2>/dev/null || true
    limactl delete "$SPARK_NAME"
fi

if limactl list --format '{{.Name}}' | grep -q "^${SPARK_NAME}.lima$"; then
    echo "[+] Removing stale Lima artifact"
    limactl delete "${SPARK_NAME}.lima" || true
fi

echo "[PASS] Spark preflight complete"
INNER

chmod +x "$SPARK_DIR/composer/preflight.sh"

echo "[PASS] Lifecycle helper created"
echo
echo "Use:"
echo "$SPARK_DIR/composer/preflight.sh spark-matthew-001"
