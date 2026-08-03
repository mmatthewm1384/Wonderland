#!/usr/bin/env bash
export WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"
export PATH="$WL_ROOT/bin:$PATH"

wl-chaos-panic --force "Raycast Panic"
