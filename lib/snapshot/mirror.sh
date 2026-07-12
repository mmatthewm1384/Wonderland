#!/usr/bin/env bash
set -euo pipefail
WL_HOME="${WL_HOME:-$HOME/Wonderland}"
exec "$WL_HOME/bin/wl-mirror" snapshot
