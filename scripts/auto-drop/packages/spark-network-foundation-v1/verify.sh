\
#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-}"
[[ -n "$ROOT" ]] || ROOT="$(git rev-parse --show-toplevel)"
export WL_ROOT="$ROOT"

SPARK_ID="${1:-}"
[[ "$SPARK_ID" =~ ^spark-[a-z0-9-]+$ ]] || { echo "[FAIL] usage: $0 spark-<id>"; exit 2; }

IMAGE="$ROOT/Crystal/us/sparks/images/$SPARK_ID/$SPARK_ID.vm.img"
PROFILE="$ROOT/profiles/$SPARK_ID.yaml"

[[ -f "$IMAGE" ]] || { echo "[FAIL] missing image"; exit 1; }
[[ -f "$PROFILE" ]] || { echo "[FAIL] missing canonical Lima profile"; exit 1; }

echo "===== LIMA INSTANCE ====="
limactl list | grep -E "^$SPARK_ID[[:space:]]" || { echo "[FAIL] Spark instance missing"; exit 1; }

STATUS="$(limactl list --format '{{.Name}} {{.Status}}' | awk -v n="$SPARK_ID" '$1==n{print $2}')"
[[ "$STATUS" == "Running" ]] || { echo "[FAIL] Spark not running: $STATUS"; exit 1; }

echo "===== GUEST ====="
limactl shell "$SPARK_ID" -- sh -c '
set -eu
test -f /etc/network/interfaces
grep -Eq "^auto eth0$" /etc/network/interfaces
grep -Eq "^iface eth0 inet dhcp$" /etc/network/interfaces
test -L /etc/runlevels/boot/networking
test -L /etc/runlevels/default/sshd
test -L /etc/runlevels/default/lima-guestagent
test -x /sbin/ifup
test -x /sbin/ifquery
ip -4 addr show dev eth0 | grep -q "inet "
rc-service sshd status
rc-service lima-guestagent status
echo "[PASS] guest network + SSH + Lima agent"
'

echo "===== PROFILE IMAGE BINDING ====="
grep -Fq "location: \"$IMAGE\"" "$PROFILE"

echo "===== LOCAL SSH ====="
LINE="$(limactl list | grep -E "^${SPARK_ID}[[:space:]]" || true)"
PORT="$(printf '%s\n' "$LINE" | sed -n 's/.*127\.0\.0\.1:\([0-9][0-9]*\).*/\1/p' | head -1)"
[[ -n "$PORT" ]] || { echo "[FAIL] no localhost SSH port in Lima state"; exit 1; }
nc -z 127.0.0.1 "$PORT"

echo "[PASS] Canonical Spark network foundation verified: $SPARK_ID"
