#!/usr/bin/env python3
import os
import sys
import subprocess

# Style Palette Tokens (24-bit Truecolor)
BG_DARK = "\x1b[48;2;5;7;10m"         # #05070A (Deep Obsidian Canvas Background)
TEXT_WHITE = "\x1b[38;2;255;255;255m" 
CYAN_FG = "\x1b[38;2;0;229;255m"       # #00E5FF Thin Line Borders
GREEN = "\x1b[38;2;0;255;102m"        # #00FF66 Pass Status Indicator
PURPLE = "\x1b[38;2;163;71;255m"      # #A347FF High Contrast Violet Labels
RESET = "\x1b[0m"                     # Host Terminal Default Restoration

# Locked Grid Matrix Boundaries (Internal padding fits inside width 80)
BOX_WIDTH = 80
START_ROW = 2   # Screen row where the box top begins
START_COL = 1   # Leftmost screen column

def get_doctor_summary():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    doctor_path = os.path.join(script_dir, "doctor_core.py")
    try:
        result = subprocess.run([sys.executable, doctor_path], capture_output=True, text=True)
        lines = result.stdout.split("\n")
        passes = sum(1 for line in lines if "[PASS]" in line)
        fails = sum(1 for line in lines if "[FAIL]" in line)
        return passes, fails
    except Exception:
        return 0, 0

def draw_dashboard():
    passes, fails = get_doctor_summary()
    compliance_score = 100 if (passes + fails) == 0 else int((passes / (passes + fails)) * 100)
    status_indicator = "NOMINAL" if fails == 0 else "ALERT"
    status_color = GREEN if fails == 0 else "\x1b[38;2;255;0;102m"

    # Define interface layout text layer rows
    content_layers = [
        f" {GREEN}■{TEXT_WHITE} WONDERLAND SECURE OPERATIONS DASHBOARD",
        "",
        f"  OPERATOR       : {PURPLE}Matthew Mahaney (Final Authority){TEXT_WHITE}",
        f"  RUNTIME BOUNDS : {PURPLE}rootless nerdctl / containerd (Apple Silicon M4){TEXT_WHITE}",
        "",
        f"  SYSTEM MATRIX STATUS:",
        f"   - Engine State:      [{status_color}{status_indicator}{TEXT_WHITE}]",
        f"   - Verified Nodes:    {GREEN}{passes} Passed{TEXT_WHITE} | Missing: {fails}",
        f"   - Compliance Score:  {CYAN_FG}{compliance_score}% Alignment{TEXT_WHITE}",
        "",
        f"  {PURPLE}[TUI Operational Options]{TEXT_WHITE}",
        f"   [1] Re-Run Audit (Doctor)  [2] Apply Self-Healing (Repair)  [3] Exit UI"
    ]

    total_body_rows = len(content_layers)

    # Keep the cursor homed to eliminate render jitter
    sys.stdout.write("\x1b[H")
    
    # =======================================================
    # 1. RENDER CEILING (100% CLEAR OF BG_DARK)
    # =======================================================
    # The entire top bar inherits the natural background of the host shell
    sys.stdout.write(f"\x1b[{START_ROW};{START_COL}H" + RESET + CYAN_FG + "┏" + ("━" * BOX_WIDTH) + "┓\n")
    
    # =======================================================
    # 2. RENDER UNDER-FILLED BODY CAVITY ROWS
    # =======================================================
    for i in range(total_body_rows):
        current_row = START_ROW + 1 + i
        # The borders (┃) are clear. Only the spaces *inside* get the BG_DARK mask.
        sys.stdout.write(
            f"\x1b[{current_row};{START_COL}H" +
            RESET + CYAN_FG + "┃" + 
            BG_DARK + (" " * BOX_WIDTH) + 
            RESET + CYAN_FG + "┃\n"
        )
        
    # =======================================================
    # 3. RENDER FLOOR (100% CLEAR OF BG_DARK)
    # =======================================================
    # The entire bottom bar scales natively without leaking background colors downwards
    floor_row = START_ROW + 1 + total_body_rows
    sys.stdout.write(f"\x1b[{floor_row};{START_COL}H" + RESET + CYAN_FG + "┗" + ("━" * BOX_WIDTH) + "┛\n" + RESET)

    # =======================================================
    # 4. OVERLAY TEXT TRANSPARENTLY OVER THE CANVASES
    # =======================================================
    for idx, text_stream in enumerate(content_layers):
        target_row = START_ROW + 1 + idx
        # Overwrite text layer streams inside the color-locked columns
        sys.stdout.write(f"\x1b[{target_row};{START_COL + 1}H" + BG_DARK + TEXT_WHITE + text_stream)

    # Position operational prompt lines cleanly beneath the viewport asset matrix floor
    prompt_row = floor_row + 2
    sys.stdout.write(f"\x1b[{prompt_row};{START_COL}H" + RESET)
    sys.stdout.flush()

def main_loop():
    # Clear screen buffer once at initial runtime initialization
    sys.stdout.write("\x1b[2J")
    while True:
        draw_dashboard()
        try:
            choice = input(CYAN_FG + " Wonderland CLI Prompt > " + RESET).strip()
            if choice == "1":
                sys.stdout.write("\x1b[2J\x1b[H")
                subprocess.run([sys.executable, os.path.join(os.path.dirname(__file__), "doctor_core.py")])
                input("\nPress Enter to return to Dashboard...")
                sys.stdout.write("\x1b[2J")
            elif choice == "2":
                sys.stdout.write("\x1b[2J\x1b[H")
                subprocess.run([sys.executable, os.path.join(os.path.dirname(__file__), "repair_core.py")])
                input("\nPress Enter to return to Dashboard...")
                sys.stdout.write("\x1b[2J")
            elif choice == "3" or choice.lower() == "exit":
                sys.stdout.write("\x1b[2J\x1b[H")
                print("Exiting Operational TUI Boundary Canvas. Core aligned.")
                break
        except (KeyboardInterrupt, EOFError):
            sys.stdout.write("\n" + RESET)
            print("TUI Interaction Interrupted. Returning to base shell.")
            break

if __name__ == "__main__":
    main_loop()
