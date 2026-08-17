#!/usr/bin/env bash

set -euo pipefail

ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)}"
"$ROOT/scripts/auto-drop/packages/mesh-relationship-v1/scripts/verify.sh"
printf '%s\n' "mesh-relationship-v1 CERTIFIED (local verification scope)"
