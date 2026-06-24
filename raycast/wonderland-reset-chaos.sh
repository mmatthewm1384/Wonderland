#!/usr/bin/env bash
set -euo pipefail

"$HOME/Wonderland/bin/wl" chaos reset
"$HOME/Wonderland/bin/wl" visual-chaos write-contract
