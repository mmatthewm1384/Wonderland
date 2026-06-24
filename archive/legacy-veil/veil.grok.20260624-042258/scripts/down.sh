#!/bin/bash
set -euo pipefail
nerdctl rm -f veil 2>/dev/null || true
echo "Stray containers removed."
