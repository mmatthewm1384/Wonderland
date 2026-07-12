#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"

"$WL_HOME/bin/wl-browser" certify
echo "PASS browser certification"
