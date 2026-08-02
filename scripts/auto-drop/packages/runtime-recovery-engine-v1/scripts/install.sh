#!/bin/bash
set -euo pipefail

echo "Installing runtime-recovery-engine-v1"

test -f certification/schema.json
test -f certification/recovery-contract.json

echo "Installed"
