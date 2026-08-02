#!/usr/bin/env bash
set -euo pipefail

echo "Installing AppArmor capability"

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y apparmor apparmor-utils
fi

echo "AppArmor capability installed"
