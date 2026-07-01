#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/lib/core/registry/command_registry_cli.sh"
