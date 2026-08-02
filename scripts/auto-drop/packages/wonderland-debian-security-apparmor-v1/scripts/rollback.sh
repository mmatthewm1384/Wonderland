#!/usr/bin/env bash
set -euo pipefail

echo "Removing AppArmor capability"

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get remove -y apparmor-utils || true
fi

echo "Rollback complete"
