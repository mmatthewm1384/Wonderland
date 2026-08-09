#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPARK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

COMMAND="${1:?command required}"
SPARK="${2:?spark name required}"

case "$COMMAND" in

compose)
    "$SPARK_ROOT/composer/compose.sh" "$SPARK"
    ;;

build)
    "$SPARK_ROOT/image-builder/build-vm-image.sh" \
        "$SPARK_ROOT/runtime/${SPARK}-disk.img" \
        "$SPARK_ROOT/images/$SPARK/${SPARK}.vm.img"
    ;;

verify)
    "$SPARK_ROOT/image-builder/verify-spark.sh" \
        "$SPARK_ROOT/images/$SPARK/${SPARK}.vm.img"
    ;;

create)
    limactl create \
        --name "$SPARK" \
        "$SPARK_ROOT/generated/$SPARK/lima.yaml"
    ;;

start)
    limactl start "$SPARK"
    ;;

stop)
    limactl stop "$SPARK"
    ;;

delete)
    limactl delete "$SPARK"
    ;;

status)
    limactl list
    ;;

*)
    echo "Unknown command: $COMMAND"
    exit 1
    ;;
esac
