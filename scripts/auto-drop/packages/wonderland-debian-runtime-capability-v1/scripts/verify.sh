#!/bin/sh
set -e

test -f artifacts/metadata.yaml
test -f certification/schema.json

limactl list wonderland-debian-rootless-v1

echo "PASS"
