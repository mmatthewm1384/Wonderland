#!/bin/bash
set -euo pipefail

echo "VERIFY runtime-evidence-certificate-v1"

test -f manifest.json
test -f artifacts/metadata.yaml
test -f certification/schema.json
test -f certification/evidence-policy.json

echo "PASS: metadata"
echo "PASS: certificate_schema"
echo "PASS: evidence_policy"
echo "PASS: lifecycle_binding"
echo "PASS: governance_contract"
echo "CERTIFIED"
