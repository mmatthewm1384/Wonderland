#!/usr/bin/env bash
set -euo pipefail

NAME="wonderland-debian-rootless-v1"

limactl shell "${NAME}" -- bash -lc '
id
nerdctl info
systemctl --user status containerd --no-pager
'

echo "Runtime verification PASS"
