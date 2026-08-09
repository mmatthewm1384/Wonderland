#!/usr/bin/env bash
set -euo pipefail

COMPOSER="$HOME/Wonderland/Crystal/us/sparks/composer/compose.sh"

echo "=== Spark Composer Boot Boundary Fix ==="

cat > "$COMPOSER" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SPARK_NAME="${1:?usage: compose.sh <spark-name>}"

SPARK_ROOT="$HOME/Wonderland/Crystal/us/sparks"
RUNTIME_DISK="$SPARK_ROOT/runtime/${SPARK_NAME}-disk.img"
OUTPUT="$SPARK_ROOT/${SPARK_NAME}.yaml"

if [[ ! -f "$RUNTIME_DISK" ]]; then
    echo "[FAIL] Missing runtime disk:"
    echo "$RUNTIME_DISK"
    exit 1
fi

cat > "$OUTPUT" <<YAML
# Wonderland Spark VM Profile

arch: aarch64

vmType: vz

cpus: 2

memory: 2GiB

disk: 10GiB

images:
  - location: https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/aarch64/alpine-virt-3.20.3-aarch64.iso

mounts:
  - location: "$RUNTIME_DISK"
    mountPoint: /mnt/spark-runtime

provision:
  - mode: system
    script: |
      mkdir -p /opt/wonderland/spark
      echo "$SPARK_NAME" > /opt/wonderland/spark/state

ssh:
  loadDotSSHPubKeys: true

containerd:
  system: false
  user: true
YAML

chmod +x "$COMPOSER"

echo "[PASS] Spark composer fixed"
echo
cat "$OUTPUT"
EOF

chmod +x "$COMPOSER"

echo "[PASS] Boot boundary corrected"
