#!/bin/bash
set -euo pipefail

echo "Installing runtime-transaction-engine-v1"

test -f certification/schema.json
test -f certification/transaction-contract.json

echo "Installed"
