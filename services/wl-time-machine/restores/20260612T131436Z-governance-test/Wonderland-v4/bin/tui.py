#!/usr/bin/env python3
import curses
import sys
import os
import subprocess
import time

def run_command(cmd):
    try:
        res = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return res.stdout.strip() if res.returncode == 0 else f"ERROR: {res.stderr.strip()}"
    except Exception as e:
        return f"CRITICAL: {str(e)}"

def draw_tui(stdscr):
    # Enforce strict terminal settings
    curses.curs_set(0)
    stdscr.nodelay(True)
    stdscr.timeout(500)
    
    # Initialize extended color capabilities
    curses.start_color()
    curses.use_default_colors()
    
    # Map the exact Wonderland hex palette to xterm-256 approximations
    # Cyan accent: #00E5FF (xterm 51) | Violet accent: #7000FF (xterm 93)
    curses.init_pair(1, 51, -1)   # Cyan text, transparent background
    curses.init_pair(2, 93, -1)   # Violet text, transparent background
    curses.init_pair(3, 46, -1)   # Bright Green for PASS/UP states
    curses.init_pair(4, 196, -1)  # Bright Red for FAIL/DOWN states
    curses.init_pair(5, 244, -1)  # Muted Grey for borders/dividers
    
    current_service = "obsidian"
    
    while True:
        stdscr.clear()
        height, width = stdscr.getmaxyx()
        
        # Guard rails for minimum terminal geometry
        if height < 20 or width < 80:
            stdscr.addstr(0, 0, "Terminal area insufficient. Resize window.")
            stdscr.refresh()
            continue
            
        # Draw structural framing grid using native curses constants
        stdscr.attron(curses.color_pair(5))
        stdscr.hline(0, 0, curses.ACS_HLINE, width)
        stdscr.hline(2, 0, curses.ACS_HLINE, width)
        stdscr.hline(4, 0, curses.ACS_HLINE, width)
        stdscr.hline(height - 3, 0, curses.ACS_HLINE, width)
        stdscr.attroff(curses.color_pair(5))
        
        # Header Banner Area
        stdscr.addstr(1, 2, "✦ WONDERLAND CONTROL CONSOLE ✦", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(1, width - 24, "[RUNTIME: ROOTLESS]", curses.color_pair(2) | curses.A_BOLD)
        
        # Telemetry Metadata Bar
        stdscr.addstr(3, 2, "STATUS: ")
        stdscr.addstr(3, 10, "ACTIVE", curses.color_pair(3) | curses.A_BOLD)
        stdscr.addstr(3, 22, "│ CORE DENSITY: ")
        stdscr.addstr(3, 38, "73.09%", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(3, 48, "│ AUTHORITY: OPERATOR")
        
        # Operational Section Layout
        stdscr.addstr(6, 2, "LIFECYCLE ENGINES", curses.color_pair(2) | curses.A_BOLD)
        
        stdscr.addstr(8, 4, "[U]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(8, 9, "wl up        - Bring service infrastructure online")
        
        stdscr.addstr(9, 4, "[D]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(9, 9, "wl down      - Gracefully halt running containers")
        
        stdscr.addstr(10, 4, "[S]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(10, 9, "wl status    - Query system state registries")
        
        stdscr.addstr(11, 4, "[L]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(11, 9, "wl logs      - Tail active container output streams")
        
        # Administrative Section Divider
        stdscr.addstr(13, 2, "ADMINISTRATIVE AUTOMATION", curses.color_pair(2) | curses.A_BOLD)
        
        stdscr.addstr(15, 4, "[K]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(15, 9, "wl doctor    - Run non-mutating system diagnostics")
        
        stdscr.addstr(16, 4, "[R]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(16, 9, "wl repair    - Execute idempotent mitigation routines")
        
        # Navigation / Footer
        stdscr.addstr(height - 2, 2, "Press [Q] to terminate control session safely.", curses.color_pair(5))
        
        stdscr.refresh()
        
        try:
            key = stdscr.getch()
        except Exception:
            key = -1
            
        if key == ord('q') or key == ord('Q'):
            break
        elif key == ord('u') or key == ord('U'):
            stdscr.clear()
            stdscr.addstr(2, 4, "INVOKING: wl up...", curses.color_pair(1) | curses.A_BOLD)
            stdscr.refresh()
            run_command("nerdctl compose up -d")
            time.sleep(1)
        elif key == ord('d') or key == ord('D'):
            stdscr.clear()
            stdscr.addstr(2, 4, "INVOKING: wl down...", curses.color_pair(2) | curses.A_BOLD)
            stdscr.refresh()
            run_command("nerdctl compose down")
            time.sleep(1)
        elif key == ord('k') or key == ord('K'):
            stdscr.clear()
            stdscr.addstr(2, 4, "EXECUTING READ-ONLY SYSTEM DIAGNOSTICS...", curses.color_pair(1) | curses.A_BOLD)
            stdscr.refresh()
            run_command("python3 ~/Wonderland/intelligence/obsidian/99-Tools/audit_style.py ~/Wonderland/intelligence/obsidian/00-Core/Governance.md")
            time.sleep(2)
        elif key == ord('r') or key == ord('R'):
            stdscr.clear()
            stdscr.addstr(2, 4, "EXECUTING IDEMPOTENT REPAIR SUITE...", curses.color_pair(2) | curses.A_BOLD)
            stdscr.refresh()
            run_command("mkdir -p ~/Wonderland/intelligence/obsidian/99-Tools")
            time.sleep(1.5)

if __name__ == "__main__":
    curses.wrapper(draw_tui)
