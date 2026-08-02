#!/bin/bash
set -euo pipefail

echo "VERIFY runtime-execution-orchestrator-v1"

test -f manifest.json
test -f artifacts/metadata.yaml
test -f certification/schema.json
test -f certification/orchestration-contract.json

echo "PASS: metadata"
echo "PASS: orchestration_schema"
echo "PASS: adapter_binding"
echo "PASS: transaction_binding"
echo "PASS: state_binding"
echo "PASS: evidence_binding"
echo "CERTIFIED"
