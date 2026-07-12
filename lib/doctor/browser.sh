#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"

if [[ ! -x "$WL_HOME/bin/wl-browser" ]]; then
  echo "FAIL Browser subsystem missing"
  exit 1
fi

"$WL_HOME/bin/wl-browser" doctor
