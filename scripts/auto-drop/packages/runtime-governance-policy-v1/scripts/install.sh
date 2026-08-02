#!/bin/bash
set -e

echo "Installing runtime-governance-policy-v1"

test -f certification/runtime-policy.json
test -f certification/schema.json

echo "Runtime governance policy installed"
