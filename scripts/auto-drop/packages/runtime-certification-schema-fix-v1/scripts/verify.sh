#!/usr/bin/env bash
set -euo pipefail

test -f certification/schema.json || {
    echo "FAIL: certification/schema.json missing"
    exit 1
}

echo "PASS: certification schema"
