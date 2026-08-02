#!/usr/bin/env bash
set -euo pipefail

NAME="wonderland-debian-rootless-v1"
TEMPLATE="images/wonderland-debian/templates/wonderland-debian-rootless-v1.yaml"

if limactl list --format '{{.Name}}' | grep -q "^${NAME}$"; then
    echo "VM already exists"
    exit 0
fi

limactl create \
  --name "${NAME}" \
  "${TEMPLATE}"

echo "Installed ${NAME}"
