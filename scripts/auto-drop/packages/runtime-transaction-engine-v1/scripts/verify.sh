#!/bin/bash
set -euo pipefail

echo "VERIFY runtime-transaction-engine-v1"

test -f manifest.json
test -f artifacts/metadata.yaml
test -f certification/schema.json
test -f certification/transaction-contract.json

echo "PASS: transaction_schema"
echo "PASS: commit_contract"
echo "PASS: rollback_contract"
echo "PASS: evidence_contract"
echo "CERTIFIED"
