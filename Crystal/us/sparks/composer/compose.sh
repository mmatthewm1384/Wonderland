#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPARK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WL_ROOT="${WL_ROOT:-$(cd "$SPARK_ROOT/../../.." && pwd)}"

SPARK_NAME="${1:?usage: compose.sh <spark-id>}"

PROFILE="$SPARK_ROOT/profiles/${SPARK_NAME}.yaml"
GENERATED="$SPARK_ROOT/generated/${SPARK_NAME}"
VALIDATOR="$SPARK_ROOT/validator/validate-profile"
PYTHON="$SPARK_ROOT/validator/.venv/bin/python"

if [[ ! -f "$PROFILE" ]]; then
    echo "[FAIL] Spark profile not found:"
    echo "$PROFILE"
    exit 1
fi

if [[ ! -x "$PYTHON" ]]; then
    echo "[FAIL] Spark validator environment missing:"
    echo "$PYTHON"
    exit 1
fi

echo "=== Wonderland Spark Composer ==="
echo "Spark: $SPARK_NAME"
echo "Root:  $WL_ROOT"
echo

# ------------------------------------------------------------
# Validate canonical profile first.
# ------------------------------------------------------------

"$VALIDATOR" "$PROFILE"

echo
echo "[PASS] Canonical profile validated"

# ------------------------------------------------------------
# Read profile through the controlled Python environment.
# ------------------------------------------------------------

eval "$(
    "$PYTHON" - "$PROFILE" <<'PY'
import sys
import yaml
import shlex

profile = yaml.safe_load(open(sys.argv[1]))

meta = profile["metadata"]
spec = profile["spec"]
runtime = spec["runtime"]
resources = spec["resources"]
image = spec["image"]
caps = spec.get("capabilities", [])
mounts = spec.get("mounts", [])
bootstrap = spec.get("bootstrap", {})

values = {
    "SPARK_ID": meta["id"],
    "SPARK_VERSION": str(meta["version"]),
    "OWNER": meta.get("owner", ""),
    "PROVIDER": runtime["provider"],
    "VM_TYPE": runtime["vmType"],
    "ARCH": runtime["arch"],
    "CPUS": str(resources["cpus"]),
    "MEMORY": resources["memory"],
    "DISK": resources["disk"],
    "IMAGE_ARTIFACT": image["artifact"],
    "IMAGE_TYPE": image["type"],
    "HOSTNAME": bootstrap.get("hostname", meta["id"]),
    "NODE_TYPE": bootstrap.get("nodeType", "spark"),
    "CAPABILITIES": ",".join(caps),
}

for key, value in values.items():
    print(f"{key}={shlex.quote(value)}")
PY
)"

if [[ "$SPARK_ID" != "$SPARK_NAME" ]]; then
    echo "[FAIL] Profile metadata.id does not match Spark name"
    echo "Expected: $SPARK_NAME"
    echo "Actual:   $SPARK_ID"
    exit 1
fi

IMAGE_CANDIDATES=(
    "$SPARK_ROOT/images/$SPARK_ID/$IMAGE_ARTIFACT"
    "$SPARK_ROOT/images/$SPARK_ID/$SPARK_ID.vm.img"
    "$SPARK_ROOT/images/alpine-spark-v1/artifacts/$IMAGE_ARTIFACT"
)

IMAGE=""

for candidate in "${IMAGE_CANDIDATES[@]}"; do
    if [[ -f "$candidate" ]]; then
        IMAGE="$candidate"
        break
    fi
done

if [[ -z "$IMAGE" ]]; then
    echo "[FAIL] Image artifact not found"
    echo
    echo "Spark:     $SPARK_ID"
    echo "Artifact:  $IMAGE_ARTIFACT"
    echo
    echo "Checked:"
    for candidate in "${IMAGE_CANDIDATES[@]}"; do
        echo "  - $candidate"
    done
    echo
    echo "Available Spark images:"
    find "$SPARK_ROOT/images" \
        -type f \
        \( -name "*.img" -o -name "*.qcow2" \) \
        -print 2>/dev/null | sort || true
    exit 1
fi

echo "[PASS] Image artifact resolved:"
echo "       $IMAGE"

# ------------------------------------------------------------
# Resolve host paths ONLY here.
# They must never enter the canonical profile.
# ------------------------------------------------------------

IMAGE_REL="${IMAGE#"$WL_ROOT"/}"

if [[ "$IMAGE_REL" == "$IMAGE" ]]; then
    echo "[FAIL] Image is outside WL_ROOT"
    echo "$IMAGE"
    exit 1
fi

mkdir -p "$GENERATED"

# ------------------------------------------------------------
# Canonical generated manifest.
# Portable: no /Users, /Volumes, /private, or file:// host paths.
# ------------------------------------------------------------

cat > "$GENERATED/manifest.yaml" <<YAML
apiVersion: spark.wonderland/v1
kind: Spark

metadata:
  id: $SPARK_ID
  version: $SPARK_VERSION
  owner: $OWNER

spec:
  runtime:
    provider: $PROVIDER
    vmType: $VM_TYPE
    arch: $ARCH

  resources:
    cpus: $CPUS
    memory: $MEMORY
    disk: $DISK

  image:
    artifact: $IMAGE_ARTIFACT
    type: $IMAGE_TYPE

  mounts:
    - source: workspace
      guest: /mnt/shared
      writable: true

  capabilities:
$(printf '%s\n' "$CAPABILITIES" | tr ',' '\n' | sed 's/^/    - /')

  bootstrap:
    hostname: $HOSTNAME
    nodeType: $NODE_TYPE

status:
  state: created
YAML

# ------------------------------------------------------------
# Derived Lima profile.
# This is allowed to contain resolved host paths.
# ------------------------------------------------------------

cat > "$GENERATED/lima.yaml" <<YAML
# GENERATED FILE -- DO NOT EDIT
# Source: profiles/$SPARK_NAME.yaml

arch: $ARCH

vmType: $VM_TYPE

cpus: $CPUS
memory: $MEMORY
disk: $DISK

images:
  - location: "$IMAGE"

mounts:
  - location: "$WL_ROOT/Crystal/us/workspace/shared"
    mountPoint: /mnt/shared
    writable: true

ssh:
  loadDotSSHPubKeys: true

containerd:
  system: false
  user: true

provision:
  - mode: system
    script: |
      set -eu
      mkdir -p /etc/wonderland
      printf '%s\n' '$HOSTNAME' > /etc/wonderland/hostname
      printf '%s\n' '$NODE_TYPE' > /etc/wonderland/node-type
      hostname '$HOSTNAME'
YAML

# ------------------------------------------------------------
# Metadata.
# ------------------------------------------------------------

cat > "$GENERATED/metadata.json" <<JSON
{
  "apiVersion": "spark.wonderland/v1",
  "kind": "SparkMetadata",
  "id": "$SPARK_ID",
  "version": $SPARK_VERSION,
  "owner": "$OWNER",
  "image": "$IMAGE_ARTIFACT",
  "imageType": "$IMAGE_TYPE",
  "runtime": {
    "provider": "$PROVIDER",
    "vmType": "$VM_TYPE",
    "arch": "$ARCH"
  },
  "resources": {
    "cpus": $CPUS,
    "memory": "$MEMORY",
    "disk": "$DISK"
  }
}
JSON

# ------------------------------------------------------------
# Generated-artifact portability check.
# ------------------------------------------------------------

echo
echo "=== Generated Artifact Integrity ==="

LEAKS=0

for artifact in \
    "$GENERATED/manifest.yaml" \
    "$GENERATED/metadata.json"
do
    if grep -Eq '/Users/|/Volumes/|/private/|file:///Users/|file:///Volumes/|file:///private/' "$artifact"; then
        echo "[FAIL] Portable artifact leakage:"
        echo "$artifact"
        grep -nE '/Users/|/Volumes/|/private/|file:///Users/|file:///Volumes/|file:///private/' "$artifact"
        LEAKS=1
    fi
done

if [[ "$LEAKS" -ne 0 ]]; then
    exit 1
fi

# Generated runtime artifacts must contain concrete values.
if grep -RInE '\\{\\{[^}]+\\}\\}|<no value>' "$GENERATED"     --include='*.yaml'     --include='*.yml'     --include='*.json'     >/tmp/spark-compose-unresolved-"$SPARK_NAME".log 2>&1; then
    echo "[FAIL] Unresolved template variables detected"
    cat /tmp/spark-compose-unresolved-"$SPARK_NAME".log
    exit 1
fi

echo "[PASS] No unresolved template variables"

echo "[PASS] Canonical artifacts are portable"

echo
echo "=== Spark Manifest Generated ==="
echo
printf '%s\n' \
    "$GENERATED/metadata.json" \
    "$GENERATED/manifest.yaml" \
    "$GENERATED/lima.yaml"
