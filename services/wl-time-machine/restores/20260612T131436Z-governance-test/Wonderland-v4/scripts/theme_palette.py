#!/usr/bin/env python3
"""
Wonderland Authoritative TUI Color Palette
Enforces Operator preference for high-contrast elegant negative space.
"""

THEME = {
    "BACKGROUND": "#05070A",  # Dark Base
    "CYAN": "#00E5FF",        # Primary Blue/Cyan Accent
    "PURPLE": "#7000FF",      # Secondary Purple Accent
    "GREEN": "#00FF66",       # Success/Idempotent Green
    "TEXT_MUTED": "#55647A",  # High-altitude atmospheric gray for metadata
    "TEXT_BRIGHT": "#FFFFFF"  # Crisp white for data reading
}

def print_swatch():
    print("=== WONDERLAND ACTIVE UI PALETTE ===")
    for color_name, hex_val in THEME.items():
        print(f"{color_name.ljust(12)} : {hex_val}")

if __name__ == "__main__":
    print_swatch()
