#!/usr/bin/env bash
set -euo pipefail

NAME="wonderland-debian-rootless-v1"

if limactl list --format "{{.Name}}" | grep -q "^${NAME}$"; then
    limactl stop "${NAME}" || true
    limactl delete "${NAME}"
fi

echo "Rollback complete"
