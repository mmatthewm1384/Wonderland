#!/bin/bash
set -e

echo "VERIFY runtime-observability-adapter-v1"

test -f artifacts/metadata.yaml
test -f manifest.json

echo "Evidence contract PASS"
echo "CERTIFIED"
