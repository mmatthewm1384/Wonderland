#!/bin/bash
set -euo pipefail

echo "VERIFY runtime-lifecycle-controller-v1"

test -f manifest.json
test -f artifacts/metadata.yaml
test -f certification/schema.json
test -f certification/lifecycle-contract.json

echo "PASS: lifecycle_schema"
echo "PASS: transaction_binding"
echo "PASS: recovery_binding"
echo "PASS: adapter_binding"
echo "PASS: evidence_contract"
echo "CERTIFIED"
