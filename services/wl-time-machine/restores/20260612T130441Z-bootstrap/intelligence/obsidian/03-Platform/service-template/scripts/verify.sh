#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="wl-service-template"

if command -v nerdctl >/dev/null 2>&1; then
  nerdctl ps --filter "name=${SERVICE_NAME}"
elif command -v docker >/dev/null 2>&1; then
  docker ps --filter "name=${SERVICE_NAME}"
else
  echo "FAIL: neither nerdctl nor docker found"
  exit 1
fi
