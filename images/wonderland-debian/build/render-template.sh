#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

IMAGE_ROOT="$WL_ROOT/images/wonderland-debian"

export IMAGE_ARTIFACT="$IMAGE_ROOT/artifacts/wonderland-debian-rootless-v1.tar.gz"

mkdir -p "$IMAGE_ROOT/generated"

envsubst \
  < "$IMAGE_ROOT/templates/wonderland-debian-rootless-v1.yaml.tpl" \
  > "$IMAGE_ROOT/generated/wonderland-debian-rootless-v1.yaml"

echo "Generated:"
echo "$IMAGE_ROOT/generated/wonderland-debian-rootless-v1.yaml"
