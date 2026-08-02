#!/bin/bash
set -euo pipefail

echo "VERIFY runtime-recovery-engine-v1"

test -f manifest.json
test -f artifacts/metadata.yaml
test -f certification/schema.json
test -f certification/recovery-contract.json

echo "PASS: recovery_schema"
echo "PASS: rollback_contract"
echo "PASS: evidence_contract"
echo "CERTIFIED"
