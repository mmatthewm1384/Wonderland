#!/bin/bash
set -e

echo "Installing runtime-observability-adapter-v1"

test -f builder/python/wlplatform/src/wlplatform/services/runtime_service.py
test -d builder/python/wlplatform/src/wlplatform/runtime

echo "Runtime observability boundary available"
