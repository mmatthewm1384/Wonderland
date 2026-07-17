#!/usr/bin/env bash
set -euo pipefail

echo "== Registry Route Test =="

PLATFORM=$(wl-platform engine registry --json)
REGISTRY=$(wl registry --json)

echo "$PLATFORM" | jq '.status'
echo "$REGISTRY" | jq '.result'

test "$(echo "$PLATFORM" | jq -r '.status')" = "PASS"
test "$(echo "$REGISTRY" | jq -r '.result')" = "PASS"

echo "PASS"
