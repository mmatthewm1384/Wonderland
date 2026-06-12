#!/usr/bin/env bash
set -euo pipefail

# Route directly to the verified Knowledge Core tools directory
WORKSPACE="$HOME/Wonderland/intelligence/obsidian/99-Tools"
cd "$WORKSPACE"

# Idempotent venv management
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

# Execute the styled console interface
python3 tui.py
