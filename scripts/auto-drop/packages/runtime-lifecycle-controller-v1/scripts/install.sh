#!/bin/bash
set -euo pipefail

echo "Installing runtime-lifecycle-controller-v1"

test -f certification/schema.json
test -f certification/lifecycle-contract.json

echo "Installed"
