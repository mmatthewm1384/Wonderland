#!/usr/bin/env bash
set -Eeuo pipefail
# SPARK_NETWORK_FOUNDATION_ERR_TRAP
trap 'rc=$?; echo "[FAIL] Spark network foundation failed at line ${BASH_LINENO[0]:-$LINENO} (exit=$rc)" >&2; exit "$rc"' ERR


set -euo pipefail

###############################################################################
# Wonderland Spark Network Foundation v1
#
# Purpose:
#   Apply the canonical network foundation to a Spark disk image, generate the
#   canonical Lima runtime profile, create/start the Spark, and emit evidence.
#
# Schema boundary:
#
#   Spark Mesh / SparkProfile
#          |
#          v
#   generated/lima.yaml
#          |
#          v
#       limactl
#
# IMPORTANT:
#   The Wonderland SparkProfile is NOT a Lima configuration and must never be
#   passed directly to limactl.
###############################################################################

ROOT="${WL_ROOT:-}"

if [[ -z "$ROOT" ]]; then
    ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
fi

if [[ -z "$ROOT" ]]; then
    ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
fi

ROOT="$(cd "$ROOT" && pwd)"
export WL_ROOT="$ROOT"

SPARK_ID="${1:-}"

if [[ ! "$SPARK_ID" =~ ^spark-[a-z0-9-]+$ ]]; then
    echo "[FAIL] usage: $0 spark-<id>"
    exit 2
fi

###############################################################################
# Canonical identity
###############################################################################

FACTORY="${WL_SPARK_FACTORY:-wonderland-debian-rootless-v1}"
FACTORY_ROOT="/mnt/wonderland"

IMAGE="$ROOT/Crystal/us/sparks/images/$SPARK_ID/$SPARK_ID.vm.img"
PROFILE="$ROOT/Crystal/us/sparks/profiles/$SPARK_ID.yaml"
GENERATED_DIR="$ROOT/Crystal/us/sparks/generated/$SPARK_ID"
LIMA_PROFILE="$GENERATED_DIR/lima.yaml"

EVIDENCE="$ROOT/vault/08-Operations/evidence/spark-network-foundation/$SPARK_ID"
PACKAGE_DIR="$ROOT/scripts/auto-drop/packages/spark-network-foundation-v1"

SHARED="$ROOT/Crystal/us/workspace/shared"

###############################################################################
# Canonical resource specification
###############################################################################

CANONICAL_CPUS=2
CANONICAL_MEMORY="2GiB"
CANONICAL_DISK="10GiB"

###############################################################################
# Required commands / executable boundaries
###############################################################################

LIMACTL="${LIMACTL:-/opt/homebrew/bin/limactl}"

if [[ ! -x "$LIMACTL" ]]; then
    echo "[FAIL] Lima executable not found or not executable: $LIMACTL"
    exit 1
fi

echo "Lima:        $LIMACTL"

for command in shasum awk grep sed cp mkdir date; do
    command -v "$command" >/dev/null 2>&1 || {
        echo "[FAIL] required command missing: $command"
        exit 1
    }
done

echo "[PASS] Required command dependencies verified"
echo "[PASS] Lima executable boundary verified"

###############################################################################
# Preconditions
###############################################################################

[[ -d "$ROOT/.git" ]] || {
    echo "[FAIL] WL_ROOT is not a Git repository: $ROOT"
    exit 1
}

[[ -f "$IMAGE" ]] || {
    echo "[FAIL] Spark image missing: $IMAGE"
    exit 1
}

[[ -f "$PROFILE" ]] || {
    echo "[FAIL] SparkProfile missing: $PROFILE"
    exit 1
}

mkdir -p "$EVIDENCE"
mkdir -p "$GENERATED_DIR"
mkdir -p "$ROOT/Crystal/us/sparks/profiles"

echo "=== Spark Network Foundation v1 ==="

###############################################################################
# Post-install runtime verification
###############################################################################

echo
echo "[+] Post-install runtime verification"

RUNTIME_VERIFY="$EVIDENCE/runtime-verification.txt"

{
    echo "=== SPARK RUNTIME VERIFICATION ==="
    date -u +"%Y-%m-%dT%H:%M:%SZ"
    echo "spark_id=$SPARK_ID"
    echo "limactl=$LIMACTL"
    echo
} >"$RUNTIME_VERIFY"

RUNTIME_RC=0

echo "[+] Verifying canonical Lima instance"

SPARK_STATE="$(
    "$LIMACTL" list --format '{{.Name}} {{.Status}}' 2>/dev/null |
        awk -v n="$SPARK_ID" '$1 == n { print $2; exit }'
)"

if [[ "$SPARK_STATE" != "Running" ]]; then
    echo "[FAIL] Spark is not Running: ${SPARK_STATE:-absent}"
    printf 'state=%s\n' "${SPARK_STATE:-absent}" >>"$RUNTIME_VERIFY"
    RUNTIME_RC=1
else
    echo "[PASS] Spark is Running"
    printf 'state=Running\n' >>"$RUNTIME_VERIFY"
fi

if (( RUNTIME_RC == 0 )); then
    echo "[+] Verifying guest identity and runtime"

    if "$LIMACTL" shell "$SPARK_ID" -- bash -s -- "$SPARK_ID" >>"$RUNTIME_VERIFY" 2>&1 <<'LINUX'
set -euo pipefail

EXPECTED_SPARK_ID="$1"

echo "=== GUEST ==="
printf 'hostname=%s\n' "$(hostname)"
printf 'wonderland_hostname=%s\n' "$(cat /etc/wonderland/hostname)"
printf 'node_type=%s\n' "$(cat /etc/wonderland/node-type)"

test "$(cat /etc/wonderland/hostname)" = "$EXPECTED_SPARK_ID"
test "$(hostname)" = "$EXPECTED_SPARK_ID"
test "$(cat /etc/wonderland/node-type)" = "spark"

echo
echo "=== SHARED ==="
test -d /mnt/shared
test -w /mnt/shared
printf 'shared=/mnt/shared\n'
printf 'shared_writable=true\n'

echo
echo "=== NETWORK ==="
ip -brief address
ip route

echo
echo "=== CONTAINER RUNTIME ==="
command -v nerdctl
nerdctl info

echo
echo "RUNTIME_VERIFY=PASS"
LINUX
    then
        echo "[PASS] Guest identity, shared mount, network, and container runtime verified"
        printf 'verification=PASS\n' >>"$RUNTIME_VERIFY"
    else
        echo "[FAIL] Guest runtime verification failed"
        printf 'verification=FAIL\n' >>"$RUNTIME_VERIFY"
        RUNTIME_RC=1
    fi
fi

if (( RUNTIME_RC != 0 )); then
    echo
    echo "=== RUNTIME VERIFICATION ==="
    cat "$RUNTIME_VERIFY" || true
    echo
    echo "=== LIMA STATE ==="
    "$LIMACTL" list || true
    exit "$RUNTIME_RC"
fi

echo "[PASS] Post-install runtime verification complete"

echo "Spark:       $SPARK_ID"
echo "Repository:  $ROOT"
echo "Image:       $IMAGE"
echo "Profile:     $PROFILE"
echo "Lima:        $LIMA_PROFILE"
echo "Evidence:    $EVIDENCE"
echo "Factory:     $FACTORY"

###############################################################################
# Validate SparkProfile identity/resources
###############################################################################

echo
echo "[+] Validating canonical SparkProfile"

grep -Eq '^apiVersion:[[:space:]]*spark\.wonderland/v1$' "$PROFILE" || {
    echo "[FAIL] SparkProfile apiVersion is not spark.wonderland/v1"
    exit 1
}

grep -Eq '^kind:[[:space:]]*SparkProfile$' "$PROFILE" || {
    echo "[FAIL] SparkProfile kind is not SparkProfile"
    exit 1
}

grep -Eq "^[[:space:]]*id:[[:space:]]*$SPARK_ID$" "$PROFILE" || {
    echo "[FAIL] SparkProfile identity mismatch: $SPARK_ID"
    exit 1
}

grep -Eq '^([[:space:]]*)cpus:[[:space:]]*2$' "$PROFILE" || {
    echo "[FAIL] SparkProfile CPU resource is not 2"
    exit 1
}

grep -Eq '^([[:space:]]*)memory:[[:space:]]*2GiB$' "$PROFILE" || {
    echo "[FAIL] SparkProfile memory resource is not 2GiB"
    exit 1
}

grep -Eq '^([[:space:]]*)disk:[[:space:]]*10GiB$' "$PROFILE" || {
    echo "[FAIL] SparkProfile disk resource is not 10GiB"
    exit 1
}

echo "[PASS] SparkProfile schema and canonical resources"

###############################################################################
# Verify factory
###############################################################################

echo
echo "[+] Verifying factory VM"

if "$LIMACTL" list --format '{{.Name}} {{.Status}}' 2>/dev/null |
    awk -v n="$FACTORY" '$1 == n && $2 == "Running" { found=1 } END { exit !found }'
then
    echo "[PASS] Factory running: $FACTORY"
else
    echo "[FAIL] Factory VM is not running: $FACTORY"
    echo "       Start it before installing the foundation."
    exit 1
fi

###############################################################################
# Capture pre-mutation evidence
###############################################################################

echo
echo "[+] Capturing pre-mutation image"

cp -p \
    "$IMAGE" \
    "$EVIDENCE/$SPARK_ID.pre-network-foundation.vm.img"

shasum -a 256 "$IMAGE" |
    tee "$EVIDENCE/pre.sha256" >/dev/null

date -u +"%Y-%m-%dT%H:%M:%SZ" |
    tee "$EVIDENCE/started-at" >/dev/null

###############################################################################
# Translate host paths to factory paths
###############################################################################

echo
echo "[+] Translating host paths into factory paths"

case "$IMAGE" in
    "$ROOT"/*)
        IMAGE_RELATIVE="${IMAGE#"$ROOT"/}"
        ;;
    *)
        echo "[FAIL] Image is outside WL_ROOT"
        echo "       ROOT:  $ROOT"
        echo "       IMAGE: $IMAGE"
        exit 1
        ;;
esac

case "$EVIDENCE" in
    "$ROOT"/*)
        EVIDENCE_RELATIVE="${EVIDENCE#"$ROOT"/}"
        ;;
    *)
        echo "[FAIL] Evidence directory is outside WL_ROOT"
        echo "       ROOT:     $ROOT"
        echo "       EVIDENCE: $EVIDENCE"
        exit 1
        ;;
esac

IMAGE_VM="$FACTORY_ROOT/$IMAGE_RELATIVE"
EVIDENCE_VM="$FACTORY_ROOT/$EVIDENCE_RELATIVE"

case "$IMAGE_VM" in
    "$FACTORY_ROOT"/*) ;;
    *)
        echo "[FAIL] Translated image escaped factory mount"
        exit 1
        ;;
esac

case "$EVIDENCE_VM" in
    "$FACTORY_ROOT"/*) ;;
    *)
        echo "[FAIL] Translated evidence path escaped factory mount"
        exit 1
        ;;
esac

echo "    Host image:       $IMAGE"
echo "    Factory image:    $IMAGE_VM"
echo "    Host evidence:    $EVIDENCE"
echo "    Factory evidence: $EVIDENCE_VM"

###############################################################################
# Verify factory path boundary
###############################################################################

echo
echo "[+] Verifying factory path boundary"

"$LIMACTL" shell \
    --workdir "$FACTORY_ROOT" \
    "$FACTORY" \
    bash -s -- \
    "$IMAGE_VM" \
    "$EVIDENCE_VM" \
    "$SPARK_ID" <<'LINUX'
set -euo pipefail

IMAGE="$1"
EVIDENCE="$2"
SPARK_ID="$3"

printf 'FACTORY_PWD=%s\n' "$PWD"
printf 'IMAGE=%s\n' "$IMAGE"
printf 'EVIDENCE=%s\n' "$EVIDENCE"
printf 'SPARK_ID=%s\n' "$SPARK_ID"

test "$PWD" = "/mnt/wonderland"
test -d "/mnt/wonderland"
test -f "$IMAGE"
test -d "$EVIDENCE"

case "$IMAGE" in
    /mnt/wonderland/*) ;;
    *)
        echo "[FAIL] Image escaped factory mount"
        exit 1
        ;;
esac

case "$EVIDENCE" in
    /mnt/wonderland/*) ;;
    *)
        echo "[FAIL] Evidence escaped factory mount"
        exit 1
        ;;
esac

echo "[PASS] factory path boundary"
LINUX

###############################################################################
# Mutate image inside factory
###############################################################################

echo
echo "[+] Applying guest network foundation in factory"

"$LIMACTL" shell \
    --workdir "$FACTORY_ROOT" \
    "$FACTORY" \
    bash -s -- \
    "$IMAGE_VM" \
    "$EVIDENCE_VM" \
    "$SPARK_ID" <<'LINUX'
set -uo pipefail

IMAGE="$1"
EVIDENCE="$2"
SPARK_ID="$3"

WORK="/tmp/spark-network-foundation-$SPARK_ID"
LOOP=""
ROOT_MOUNT=""
EFI_MOUNT=""
TRANSACTION_OK=0

fail() {
    local rc="${1:-1}"
    shift || true
    echo "[FAIL] $*" >&2
    return "$rc"
}

cleanup_image() {
    local rc=0

    echo "[+] Cleaning up factory image mounts"

    if [[ -n "${ROOT_MOUNT:-}" ]] &&
       mountpoint -q "$ROOT_MOUNT" 2>/dev/null; then
        sudo umount "$ROOT_MOUNT" || rc=1
        ROOT_MOUNT=""
    fi

    if [[ -n "${EFI_MOUNT:-}" ]] &&
       mountpoint -q "$EFI_MOUNT" 2>/dev/null; then
        sudo umount "$EFI_MOUNT" || rc=1
        EFI_MOUNT=""
    fi

    if [[ -n "${LOOP:-}" ]] &&
       [[ -b "$LOOP" ]]; then
        sudo losetup -d "$LOOP" || rc=1
        LOOP=""
    fi

    sudo rm -rf "$WORK" || rc=1

    return "$rc"
}

###############################################################################
# Factory-side preconditions
###############################################################################

echo "=== FACTORY IMAGE MUTATION ==="

echo "FACTORY_PWD=$PWD"
echo "IMAGE=$IMAGE"
echo "EVIDENCE=$EVIDENCE"
echo "SPARK_ID=$SPARK_ID"

[[ "$PWD" == "/mnt/wonderland" ]] || {
    fail 1 "Factory working directory is not /mnt/wonderland"
    exit 1
}

[[ "$IMAGE" == /mnt/wonderland/* ]] || {
    fail 1 "Image escaped factory mount"
    exit 1
}

[[ "$EVIDENCE" == /mnt/wonderland/* ]] || {
    fail 1 "Evidence escaped factory mount"
    exit 1
}

[[ -f "$IMAGE" ]] || {
    fail 1 "Factory image does not exist: $IMAGE"
    exit 1
}

[[ -d "$EVIDENCE" ]] || {
    fail 1 "Factory evidence directory does not exist: $EVIDENCE"
    exit 1
}

echo "[PASS] factory path boundary"

###############################################################################
# Prepare transaction workspace
###############################################################################

sudo rm -rf "$WORK"
sudo mkdir -p "$WORK/root" "$WORK/efi"

echo "IMAGE=$IMAGE" |
    tee "$EVIDENCE/factory-image-state.txt" >/dev/null

ls -lh "$IMAGE" |
    tee -a "$EVIDENCE/factory-image-state.txt" >/dev/null

###############################################################################
# Detect image layout
###############################################################################

echo "[+] Detecting image filesystem layout"

file "$IMAGE" |
    tee "$EVIDENCE/image-file.txt" >/dev/null

###############################################################################
# Attach image
###############################################################################

echo "[+] Attaching Spark image"

LOOP="$(
    sudo losetup --find --show --partscan "$IMAGE" 2>&1
)"
rc=$?

if [[ "$rc" -ne 0 || ! -b "$LOOP" ]]; then
    echo "$LOOP" |
        tee "$EVIDENCE/losetup-error.txt" >/dev/null

    fail 1 "Unable to attach image: $LOOP"
    cleanup_image || true
    exit 1
fi

echo "    Loop: $LOOP"

###############################################################################
# Wait for partition devices
###############################################################################

echo "[+] Waiting for partition devices"

for _ in $(seq 1 10); do
    if [[ -b "${LOOP}p1" && -b "${LOOP}p2" ]]; then
        break
    fi
    sleep 1
done

if [[ ! -b "${LOOP}p1" ]]; then
    fail 1 "EFI partition was not exposed: ${LOOP}p1"
    cleanup_image || true
    exit 1
fi

if [[ ! -b "${LOOP}p2" ]]; then
    fail 1 "Root partition was not exposed: ${LOOP}p2"
    cleanup_image || true
    exit 1
fi

echo "    EFI:  ${LOOP}p1"
echo "    Root: ${LOOP}p2"

###############################################################################
# Filesystem inspection
###############################################################################

echo "[+] Inspecting partition filesystems"

sudo blkid "${LOOP}p1" 2>&1 |
    tee "$EVIDENCE/efi-blkid.txt" >/dev/null || true

sudo blkid "${LOOP}p2" 2>&1 |
    tee "$EVIDENCE/root-blkid.txt" >/dev/null || true

EFI_FSTYPE="$(
    sudo blkid -o value -s TYPE "${LOOP}p1" 2>/dev/null || true
)"

ROOT_FSTYPE="$(
    sudo blkid -o value -s TYPE "${LOOP}p2" 2>/dev/null || true
)"

echo "    EFI filesystem:  ${EFI_FSTYPE:-unknown}"
echo "    Root filesystem: ${ROOT_FSTYPE:-unknown}"

[[ "$EFI_FSTYPE" == "vfat" ]] || {
    fail 1 "Unexpected EFI filesystem: ${EFI_FSTYPE:-unknown}"
    cleanup_image || true
    exit 1
}

[[ "$ROOT_FSTYPE" == "ext4" ]] || {
    fail 1 "Unexpected root filesystem: ${ROOT_FSTYPE:-unknown}"
    cleanup_image || true
    exit 1
}

###############################################################################
# Mount root
###############################################################################

echo "[+] Mounting root filesystem"

ROOT_MOUNT_OUTPUT="$(
    sudo mount "${LOOP}p2" "$WORK/root" 2>&1
)"
rc=$?

printf '%s\n' "$ROOT_MOUNT_OUTPUT" |
    tee "$EVIDENCE/root-mount.txt" >/dev/null

if [[ "$rc" -ne 0 ]]; then
    echo "$ROOT_MOUNT_OUTPUT"
    fail 1 "Root filesystem mount failed"
    cleanup_image || true
    exit 1
fi

ROOT_MOUNT="$WORK/root"

if ! mountpoint -q "$ROOT_MOUNT"; then
    fail 1 "Root mount command succeeded but mountpoint verification failed"
    cleanup_image || true
    exit 1
fi

echo "[PASS] Root filesystem mounted"

###############################################################################
# Mount EFI
###############################################################################

echo "[+] Mounting EFI filesystem"

EFI_MOUNT_OUTPUT="$(
    sudo mount "${LOOP}p1" "$WORK/efi" 2>&1
)"
rc=$?

printf '%s\n' "$EFI_MOUNT_OUTPUT" |
    tee "$EVIDENCE/efi-mount.txt" >/dev/null

if [[ "$rc" -ne 0 ]]; then
    echo "$EFI_MOUNT_OUTPUT"
    fail 1 "EFI filesystem mount failed"
    cleanup_image || true
    exit 1
fi

EFI_MOUNT="$WORK/efi"

if ! mountpoint -q "$EFI_MOUNT"; then
    fail 1 "EFI mount command succeeded but mountpoint verification failed"
    cleanup_image || true
    exit 1
fi

echo "[PASS] EFI filesystem mounted"

###############################################################################
# Verify mounted filesystems
###############################################################################

echo "[+] Verifying mounted filesystems"

findmnt "$ROOT_MOUNT" |
    tee "$EVIDENCE/root-findmnt.txt" >/dev/null

findmnt "$EFI_MOUNT" |
    tee "$EVIDENCE/efi-findmnt.txt" >/dev/null

[[ -d "$ROOT_MOUNT/etc" ]] || {
    fail 1 "Mounted root does not contain /etc"
    cleanup_image || true
    exit 1
}

[[ -d "$ROOT_MOUNT/etc/runlevels" ]] || {
    fail 1 "Mounted root does not contain OpenRC runlevels"
    cleanup_image || true
    exit 1
}

echo "[PASS] Spark image attached and mounted"

###############################################################################
# Validate Alpine userspace
###############################################################################

echo "[+] Validating Alpine userspace"

echo "[+] Resolving Alpine network capabilities"

NETWORK_COMMANDS="$(
    sudo chroot "$ROOT_MOUNT" /bin/sh -c '
        set -eu
        command -v ifup
        command -v ifdown
        command -v ifquery
        command -v rc-service
        command -v rc-update
    ' 2>&1
)" || {
    printf "%s\n" "$NETWORK_COMMANDS" |
        tee "$EVIDENCE/network-command-resolution.txt" >/dev/null || true
    fail 1 "Required Alpine network capabilities are unavailable"
}

printf "%s\n" "$NETWORK_COMMANDS" |
    tee "$EVIDENCE/network-command-resolution.txt" >/dev/null

echo "[PASS] Alpine network capabilities resolved"

echo "[PASS] Alpine networking userspace"

###############################################################################
# Canonical network configuration
###############################################################################

echo "[+] Writing canonical network configuration"

sudo mkdir -p \
    "$ROOT_MOUNT/etc/network" \
    "$ROOT_MOUNT/etc/wonderland"

sudo tee "$ROOT_MOUNT/etc/network/interfaces" >/dev/null <<'EOF'
# Wonderland Spark Network Foundation v1

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

sudo tee "$ROOT_MOUNT/etc/wonderland/network-foundation.json" >/dev/null <<EOF
{
  "schema": "wonderland.spark.network.v1",
  "foundation": "spark-network-foundation-v1",
  "spark": "$SPARK_ID",
  "interface": "eth0",
  "addressing": "dhcp",
  "loopback": true,
  "network_manager": "ifupdown-ng",
  "transport": "lima"
}
EOF

###############################################################################
# Guest service enablement
###############################################################################

echo "[+] Enabling guest services"

sudo chroot "$ROOT_MOUNT" /bin/sh -c '
set -eu

rc-update add networking boot >/dev/null 2>&1 || true
rc-update add sshd default >/dev/null 2>&1 || true
rc-update add lima-guestagent default >/dev/null 2>&1 || true
'

###############################################################################
# Verify mutation
###############################################################################

echo "[+] Verifying factory mutation"

sudo grep -Eq '^auto eth0$' \
    "$ROOT_MOUNT/etc/network/interfaces"

sudo grep -Eq '^iface eth0 inet dhcp$' \
    "$ROOT_MOUNT/etc/network/interfaces"

sudo chroot "$ROOT_MOUNT" /bin/sh -c '
    set -eu
    command -v ifup >/dev/null
    command -v ifdown >/dev/null
    command -v ifquery >/dev/null
'

sudo test -L \
    "$ROOT_MOUNT/etc/runlevels/boot/networking"

sudo test -L \
    "$ROOT_MOUNT/etc/runlevels/default/sshd"

sudo test -L \
    "$ROOT_MOUNT/etc/runlevels/default/lima-guestagent"

sudo test -f \
    "$ROOT_MOUNT/etc/wonderland/network-foundation.json"

echo "[PASS] Factory mutation verified"

###############################################################################
# Read-only evidence
###############################################################################

echo
echo "=== NETWORK INTERFACES ==="
sudo cat "$ROOT_MOUNT/etc/network/interfaces"

echo
echo "=== WONDERLAND NETWORK IDENTITY ==="
sudo cat "$ROOT_MOUNT/etc/wonderland/network-foundation.json"

echo
echo "=== SERVICE LINKS ==="
sudo ls -l \
    "$ROOT_MOUNT/etc/runlevels/boot/networking" \
    "$ROOT_MOUNT/etc/runlevels/default/sshd" \
    "$ROOT_MOUNT/etc/runlevels/default/lima-guestagent"

echo
echo "=== ROOT FILESYSTEM ==="
sudo find "$ROOT_MOUNT/etc/wonderland" \
    -maxdepth 1 \
    -type f \
    -print |
    sort

###############################################################################
# Unmount transaction
###############################################################################

echo
echo "[+] Unmounting Spark image"

if ! sudo umount "$ROOT_MOUNT"; then
    echo "[FAIL] Root filesystem unmount failed" >&2
    cleanup_image || true
    exit 1
fi
ROOT_MOUNT=""

if ! sudo umount "$EFI_MOUNT"; then
    echo "[FAIL] EFI filesystem unmount failed" >&2
    cleanup_image || true
    exit 1
fi
EFI_MOUNT=""

if ! sudo losetup -d "$LOOP"; then
    echo "[FAIL] Loop device detach failed: $LOOP" >&2
    LOOP=""
    cleanup_image || true
    exit 1
fi
LOOP=""

echo "[PASS] Spark image unmounted"

###############################################################################
# Final factory-side image evidence
###############################################################################

sha256sum "$IMAGE" |
    tee "$EVIDENCE/post-image.sha256" >/dev/null

date -u +"%Y-%m-%dT%H:%M:%SZ" |
    tee "$EVIDENCE/factory-mutation-completed-at" >/dev/null

printf 'FACTORY_MUTATION_OK\n' |
    tee "$EVIDENCE/factory-mutation.ok" >/dev/null

TRANSACTION_OK=1

echo "[PASS] FACTORY IMAGE MUTATION COMPLETE"
echo "[PASS] factory-mutation.ok written"

exit 0
LINUX

###############################################################################
###############################################################################
# Verify factory transaction
###############################################################################

FACTORY_MUTATION_MARKER="$EVIDENCE_VM/factory-mutation.ok"
FACTORY_MUTATION_COMPLETED="$EVIDENCE_VM/factory-mutation-completed-at"
FACTORY_POST_HASH="$EVIDENCE_VM/post-image.sha256"

echo
echo "[+] Verifying factory mutation transaction"
echo "    Marker:    $FACTORY_MUTATION_MARKER"
echo "    Completed: $FACTORY_MUTATION_COMPLETED"
echo "    Post hash: $FACTORY_POST_HASH"

if ! "$LIMACTL" shell "$FACTORY" -- test -f "$FACTORY_MUTATION_MARKER"; then
    echo "[FAIL] Factory image mutation marker not found"
    echo "      Expected: $FACTORY_MUTATION_MARKER"
    echo "      Factory evidence:"
    "$LIMACTL" shell "$FACTORY" -- ls -la "$EVIDENCE_VM" || true
    echo
    echo "=== FACTORY TRANSACTION LOG ==="
    "$LIMACTL" shell "$FACTORY" -- sh -c '
        for f in "$EVIDENCE_VM/factory-mutation-completed-at" "$EVIDENCE_VM/factory-mutation.ok" "$EVIDENCE_VM/post-image.sha256"; do
            echo "--- $f"
            cat "$f" 2>/dev/null || true
        done
    '
    exit 1
fi

if ! "$LIMACTL" shell "$FACTORY" -- grep -qx "FACTORY_MUTATION_OK" "$FACTORY_MUTATION_MARKER"; then
    echo "[FAIL] Factory mutation marker has unexpected contents"
    "$LIMACTL" shell "$FACTORY" -- cat "$FACTORY_MUTATION_MARKER" || true
    exit 1
fi

if ! "$LIMACTL" shell "$FACTORY" -- test -s "$FACTORY_POST_HASH"; then
    echo "[FAIL] Factory post-mutation hash evidence is missing"
    exit 1
fi

echo "[PASS] Factory mutation transaction verified"

###############################################################################
# Generate canonical Lima profile
###############################################################################

echo
echo "[+] Generating canonical Lima profile"

mkdir -p "$GENERATED_DIR"

cat > "$LIMA_PROFILE" <<EOF
# GENERATED FILE -- DO NOT EDIT
# Source: $PROFILE
# Generator: scripts/auto-drop/packages/spark-network-foundation-v1/install.sh
# Spark: $SPARK_ID
# Profile: $PROFILE
# Image: $IMAGE
# Generated-by: spark-network-foundation-v1

arch: aarch64
vmType: vz

cpus: 2
memory: 2GiB
disk: 10GiB

images:
- location: "$IMAGE"

mounts:
- location: "$SHARED"
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
    printf '%s\n' '$SPARK_ID' > /etc/wonderland/hostname
    printf '%s\n' 'spark' > /etc/wonderland/node-type
    hostname '$SPARK_ID'
EOF

###############################################################################
# Validate generated Lima profile
###############################################################################

echo
echo "[+] Validating generated Lima profile"

[[ -f "$LIMA_PROFILE" ]]

grep -Eq '^arch:[[:space:]]*aarch64$' "$LIMA_PROFILE"
grep -Eq '^vmType:[[:space:]]*vz$' "$LIMA_PROFILE"
grep -Eq '^cpus:[[:space:]]*2$' "$LIMA_PROFILE"
grep -Eq '^memory:[[:space:]]*2GiB$' "$LIMA_PROFILE"
grep -Eq '^disk:[[:space:]]*10GiB$' "$LIMA_PROFILE"
grep -Eq '^images:$' "$LIMA_PROFILE"
grep -Fq "location: \"$IMAGE\"" "$LIMA_PROFILE"
grep -Fq "mountPoint: /mnt/shared" "$LIMA_PROFILE"

if grep -Eq '^apiVersion:' "$LIMA_PROFILE" ||
   grep -Eq '^kind:' "$LIMA_PROFILE" ||
   grep -Eq '^spec:' "$LIMA_PROFILE"
then
    echo "[FAIL] Generated Lima profile contains Wonderland schema fields"
    exit 1
fi

echo "[PASS] Generated Lima profile is Lima-native"

###############################################################################
# Ask Lima to validate the generated artifact
###############################################################################

echo
echo "[+] Lima-validating generated profile"

"$LIMACTL" validate "$LIMA_PROFILE"

echo "[PASS] Lima accepted generated profile"

###############################################################################
# Record generated profile evidence
###############################################################################

cp -p \
    "$LIMA_PROFILE" \
    "$EVIDENCE/lima.yaml"

shasum -a 256 "$LIMA_PROFILE" |
    tee "$EVIDENCE/lima.sha256" >/dev/null

printf '%s\n' "$PROFILE" |
    tee "$EVIDENCE/profile.path" >/dev/null

printf '%s\n' "$LIMA_PROFILE" |
    tee "$EVIDENCE/lima-profile.path" >/dev/null

###############################################################################
# Canonical Spark lifecycle reconciliation
###############################################################################

# Hardening:
# Keep the canonical Spark identity immutable after argument validation.
# The guest-side heredoc scripts use their own shell/process and are unaffected.
readonly SPARK_ID

INSTANCE_EXISTS() {
    "$LIMACTL" list --format '{{.Name}}' 2>/dev/null |
        awk -v expected="$SPARK_ID" '
            $0 == expected {
                found=1
                exit
            }
            END {
                exit(found ? 0 : 1)
            }
        '
}

GET_SPARK_STATUS() {
    "$LIMACTL" list --format '{{.Name}} {{.Status}}' 2>/dev/null |
        awk -v expected="$SPARK_ID" '
            $1 == expected {
                print $2
                exit
            }
        '
}

REMOVE_EXISTING_SPARK() {
    if ! INSTANCE_EXISTS; then
        return 0
    fi

    echo "[+] Reconciling existing Spark instance: $SPARK_ID"

    SPARK_STATUS="$(GET_SPARK_STATUS)"

    echo "    Existing status: ${SPARK_STATUS:-unknown}"

    if [[ "$SPARK_STATUS" == "Running" ]]; then
        echo "[+] Stopping existing Spark instance"

        if ! "$LIMACTL" stop "$SPARK_ID" \
            >"$EVIDENCE/spark-reconcile-stop.log" 2>&1
        then
            echo "[WARN] Graceful stop returned non-zero"
        fi

        sleep 1

        if [[ "$(GET_SPARK_STATUS)" == "Running" ]]; then
            echo "[WARN] Spark remains running; forcing stop"

            "$LIMACTL" stop --force "$SPARK_ID" \
                >>"$EVIDENCE/spark-reconcile-stop.log" 2>&1 || true

            sleep 1
        fi
    fi

    echo "[+] Deleting existing Spark instance"

    if ! "$LIMACTL" delete --force "$SPARK_ID" \
        >"$EVIDENCE/spark-reconcile-delete.log" 2>&1
    then
        echo "[FAIL] Unable to delete existing Spark instance"
        echo
        echo "=== DELETE LOG ==="
        cat "$EVIDENCE/spark-reconcile-delete.log" || true
        echo
        echo "=== LIMA LIST ==="
        "$LIMACTL" list || true
        return 1
    fi

    sleep 1

    if INSTANCE_EXISTS; then
        echo "[FAIL] Spark instance still exists after reconciliation"
        echo
        echo "=== DELETE LOG ==="
        cat "$EVIDENCE/spark-reconcile-delete.log" || true
        echo
        echo "=== LIMA LIST ==="
        "$LIMACTL" list || true
        return 1
    fi

    echo "[PASS] Existing Spark instance reconciled"
}

###############################################################################
# Establish the lifecycle invariant before create.
###############################################################################

if INSTANCE_EXISTS; then
    echo "[WARN] Canonical Spark already exists before create"
    REMOVE_EXISTING_SPARK || exit 1
else
    echo "[PASS] No existing Spark instance"
fi

# Defensive invariant check immediately before mutation.
if INSTANCE_EXISTS; then
    echo "[FAIL] Lifecycle invariant violated: $SPARK_ID still exists before create"
    "$LIMACTL" list || true
    exit 1
fi

###############################################################################
# Create canonical Lima instance
###############################################################################

echo
echo "[+] Creating canonical Lima instance"

CREATE_LOG="$EVIDENCE/spark-create.log"

echo "    Log: $CREATE_LOG"

if "$LIMACTL" create \
    --yes \
    --name="$SPARK_ID" \
    "$LIMA_PROFILE" \
    >"$CREATE_LOG" 2>&1
then
    CREATE_RC=0
else
    CREATE_RC=$?
fi

if [[ "$CREATE_RC" -ne 0 ]]; then

    # Lima can race with another process between the invariant check and
    # create. Treat an explicit "already exists" as a lifecycle collision,
    # reconcile once, then retry the canonical create.
    if grep -Fq "already exists" "$CREATE_LOG"; then
        echo "[WARN] Lima reported an existing Spark instance during create"
        echo "[+] Reconciling create-time lifecycle collision"

        if ! REMOVE_EXISTING_SPARK; then
            echo "[FAIL] Unable to recover from create-time lifecycle collision"
            echo
            echo "=== CREATE LOG ==="
            cat "$CREATE_LOG" || true
            exit "$CREATE_RC"
        fi

        echo "[+] Retrying canonical Lima create"

        if "$LIMACTL" create \
            --yes \
            --name="$SPARK_ID" \
            "$LIMA_PROFILE" \
            >>"$CREATE_LOG" 2>&1
        then
            CREATE_RC=0
        else
            CREATE_RC=$?
        fi
    fi
fi

if [[ "$CREATE_RC" -ne 0 ]]; then
    echo "[FAIL] Lima create failed: rc=$CREATE_RC"
    echo
    echo "=== CREATE LOG ==="
    cat "$CREATE_LOG" || true
    echo
    echo "=== LIMA LIST ==="
    "$LIMACTL" list || true
    exit "$CREATE_RC"
fi

echo "[PASS] Lima create returned rc=0"

if INSTANCE_EXISTS; then
    echo "[PASS] Canonical Lima instance created"
else
    echo "[FAIL] Lima create returned success but instance is absent"
    echo
    echo "=== CREATE LOG ==="
    cat "$CREATE_LOG" || true
    echo
    echo "=== LIMA LIST ==="
    "$LIMACTL" list || true
    exit 1
fi

###############################################################################
# Start canonical Spark
###############################################################################

echo
echo "[+] Starting canonical Spark"

"$LIMACTL" start "$SPARK_ID"

echo
echo "[+] Waiting for Spark guest readiness"

SSH_READY=0
SSH_ATTEMPTS=0
SSH_MAX_ATTEMPTS=48
SSH_READY_LOG="$EVIDENCE/ssh-readiness.log"

: >"$SSH_READY_LOG"

while (( SSH_ATTEMPTS < SSH_MAX_ATTEMPTS )); do
    SSH_ATTEMPTS=$((SSH_ATTEMPTS + 1))

    {
        printf '[attempt=%d] ' "$SSH_ATTEMPTS"
        date -u +"%Y-%m-%dT%H:%M:%SZ"
    } >>"$SSH_READY_LOG"

    # Lima may report Running before its forwarded SSH endpoint accepts
    # connections. The authoritative readiness test is a successful guest
    # command through limactl shell.
    if "$LIMACTL" shell "$SPARK_ID" -- sh -c '
        set -eu
        test -S /run/lima-guestagent.sock
        command -v sshd >/dev/null 2>&1 || true
        printf "GUEST_READY=1\n"
    ' >>"$SSH_READY_LOG" 2>&1; then
        SSH_READY=1
        break
    fi

    if ! "$LIMACTL" list --format '{{.Name}} {{.Status}}' 2>/dev/null |
        awk -v n="$SPARK_ID"             '$1 == n && $2 == "Running" { found=1 } END { exit !found }'
    then
        echo "[FAIL] Spark stopped while waiting for guest readiness"
        "$LIMACTL" list || true
        exit 1
    fi

    printf '.'
    sleep 5
done

echo

if (( SSH_READY != 1 )); then
    echo "[FAIL] Spark guest readiness timeout after $((SSH_MAX_ATTEMPTS * 5)) seconds"

    echo
    echo "=== SSH READINESS LOG ==="
    cat "$SSH_READY_LOG" || true

    echo
    echo "=== SPARK STATE ==="
    "$LIMACTL" list || true

    echo
    echo "=== SPARK SERIAL LOG ==="
    SPARK_DIR="$HOME/.lima/$SPARK_ID"
    if [[ -f "$SPARK_DIR/ha.stderr.log" ]]; then
        tail -200 "$SPARK_DIR/ha.stderr.log" || true
    fi

    exit 1
fi

echo "[PASS] Spark guest command channel is ready"

echo

if (( SSH_READY != 1 )); then
    echo "[FAIL] Spark SSH readiness timeout after $((SSH_MAX_ATTEMPTS * 5)) seconds"

    echo
    echo "=== SPARK STATE ==="
    "$LIMACTL" list || true

    echo
    echo "=== SPARK SERIAL LOG ==="
    SPARK_DIR="$HOME/.lima/$SPARK_ID"

    for log in "$SPARK_DIR"/serial*.log; do
        if [[ -f "$log" ]]; then
            echo "--- $log ---"
            tail -n 100 "$log" || true
        fi
    done

    echo
    echo "=== SPARK CONFIG ==="
    if [[ -f "$SPARK_DIR/lima.yaml" ]]; then
        sed -n '1,220p' "$SPARK_DIR/lima.yaml" || true
    fi

    exit 1
fi

echo "[PASS] Spark guest became reachable"

echo
echo "[+] Verifying Spark network foundation"

"$LIMACTL" shell "$SPARK_ID" -- sh -c '
    set -eu

    test -f /etc/wonderland/network-foundation.json
    test -f /etc/network/interfaces
    test -x /sbin/ifup || command -v ifup >/dev/null
    test -x /sbin/ifdown || command -v ifdown >/dev/null
    test -x /sbin/rc-service
    test -x /sbin/rc-update

    rc-service networking status >/dev/null 2>&1 || true

    echo "[PASS] Guest network foundation verified"
'

###############################################################################
# Verify guest networking and identity
###############################################################################

echo
echo "[+] Verifying Spark guest"

"$LIMACTL" shell "$SPARK_ID" -- sh -c '
set -eu

EXPECTED_SPARK_ID="$1"

echo "===== IDENTITY ====="

test "$(cat /etc/wonderland/hostname)" = "$EXPECTED_SPARK_ID" || {
    echo "[FAIL] hostname identity mismatch"
    exit 1
}

test "$(cat /etc/wonderland/node-type)" = "spark" || {
    echo "[FAIL] node type mismatch"
    exit 1
}

echo "===== GUEST NETWORK ====="
ip -4 addr show dev eth0
ip route

echo "===== NETWORK CONFIG ====="
grep -Eq "^auto eth0$" /etc/network/interfaces
grep -Eq "^iface eth0 inet dhcp$" /etc/network/interfaces

echo "===== FOUNDATION ====="
test -f /etc/wonderland/network-foundation.json
cat /etc/wonderland/network-foundation.json

echo "===== SSH ====="
rc-service sshd status

echo "===== LIMA AGENT ====="
rc-service lima-guestagent status

echo "[PASS] guest verification"
' sh "$SPARK_ID"

###############################################################################
# Final evidence
###############################################################################

echo
echo "[+] Capturing final evidence"

"$LIMACTL" list |
    tee "$EVIDENCE/lima-list.txt"

shasum -a 256 "$IMAGE" |
    tee "$EVIDENCE/final.sha256"

date -u +"%Y-%m-%dT%H:%M:%SZ" |
    tee "$EVIDENCE/completed-at" >/dev/null

###############################################################################
# Final summary
###############################################################################

echo
echo "=== SPARK NETWORK FOUNDATION COMPLETE ==="
echo "Spark:       $SPARK_ID"
echo "Profile:     $PROFILE"
echo "Lima:        $LIMA_PROFILE"
echo "Image:       $IMAGE"
echo "Evidence:    $EVIDENCE"
echo "Resources:   2 CPU / 2 GiB / 10 GiB"
echo
echo "[PASS] Spark network foundation deployed: $SPARK_ID"
echo "[PASS] Spark Network Foundation v1 transaction complete"

exit 0
