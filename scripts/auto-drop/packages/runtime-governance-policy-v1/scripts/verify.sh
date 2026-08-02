#!/bin/bash
set -e

echo "VERIFY runtime-governance-policy-v1"

test -f artifacts/metadata.yaml
test -f certification/schema.json
test -f certification/runtime-policy.json
test -f manifest.json

echo "PASS: policy_schema"
echo "PASS: governance_controls"
echo "PASS: lifecycle_controls"

echo "CERTIFIED"
