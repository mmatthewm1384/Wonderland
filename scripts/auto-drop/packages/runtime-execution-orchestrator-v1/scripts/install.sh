#!/bin/bash
set -euo pipefail

echo "Installing runtime-execution-orchestrator-v1"

test -f certification/schema.json
test -f certification/orchestration-contract.json

echo "Installed"
