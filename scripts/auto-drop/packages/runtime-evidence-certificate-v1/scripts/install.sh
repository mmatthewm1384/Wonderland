#!/bin/bash
set -euo pipefail

echo "Installing runtime-evidence-certificate-v1"

test -f certification/schema.json
test -f certification/evidence-policy.json

echo "Installed"
