#!/usr/bin/env python3
import curses
import subprocess
import time

def run_command(cmd):
    try:
        res = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return res.stdout.strip() if res.returncode == 0 else f"ERROR: {res.stderr.strip()}"
    except Exception as e:
        return f"CRITICAL: {str(e)}"

def get_input_string(stdscr, prompt_text, y, x):
    curses.echo()
    stdscr.attron(curses.color_pair(1) | curses.A_BOLD)
    stdscr.addstr(y, x, prompt_text)
    stdscr.attroff(curses.color_pair(1) | curses.A_BOLD)
    stdscr.refresh()
    input_bytes = stdscr.getstr(y, x + len(prompt_text), 60)
    curses.noecho()
    return input_bytes.decode('utf-8').strip()

def draw_tui(stdscr):
    curses.curs_set(0)
    stdscr.nodelay(True)
    stdscr.timeout(500)
    
    curses.start_color()
    curses.use_default_colors()
    
    # Restrained Cyberpunk Color Mapping Spec
    curses.init_pair(1, 51, -1)   # Cyan Energy Intersects
    curses.init_pair(2, 93, -1)   # Deep Violet Panel Caps
    curses.init_pair(3, 46, -1)   # Green Validations (PASS)
    curses.init_pair(4, 196, -1)  # Red Intercepts (FAULT)
    curses.init_pair(5, 244, -1)  # Muted Structural Outlines
    
    while True:
        stdscr.clear()
        height, width = stdscr.getmaxyx()
        
        if height < 26 or width < 100:
            stdscr.addstr(0, 0, f"Terminal dimensions low ({width}x{height}). Expand width to at least 100.")
            stdscr.refresh()
            continue
            
        # --- STRUCTURAL FRAME LINES ---
        stdscr.attron(curses.color_pair(5))
        stdscr.hline(0, 0, '-', width)
        stdscr.hline(2, 0, '-', width)
        stdscr.hline(4, 0, '-', width)
        stdscr.hline(15, 0, '-', width)
        stdscr.hline(21, 0, '-', width)
        stdscr.hline(height - 3, 0, '-', width)
        stdscr.attroff(curses.color_pair(5))
        
        # --- BANNER HEADER ---
        stdscr.addstr(1, 2, "✦ WONDERLAND CONTROL CONSOLE ✦", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(1, width - 24, "[RUNTIME: ROOTLESS]", curses.color_pair(2) | curses.A_BOLD)
        
        # --- SUBHEADER METRICS ---
        stdscr.addstr(3, 2, "STATUS: ")
        stdscr.addstr(3, 10, "ONLINE", curses.color_pair(3) | curses.A_BOLD)
        stdscr.addstr(3, 20, "| TARGET CORRIDOR: ")
        stdscr.addstr(3, 39, "0.69 - 0.75", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(3, 53, "| CORE WORKSPACE: WONDERLAND-V4")
        
        # --- PANEL UPPER LEFT: INFRASTRUCTURE LIFECYCLE ---
        stdscr.addstr(6, 2, "CONTAINER LIFECYCLE", curses.color_pair(2) | curses.A_BOLD)
        stdscr.addstr(8, 4, "[U]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(8, 9, "wl start      - Initialize all core containers")
        stdscr.addstr(9, 4, "[D]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(9, 9, "wl stop       - Gracefully halt background tasks")
        stdscr.addstr(10, 4, "[S]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(10, 9, "wl status     - Query system service states")
        stdscr.addstr(11, 4, "[L]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(11, 9, "wl logs       - Tail active environment outputs")
        stdscr.addstr(12, 4, "[N]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(12, 9, "wl dns status - Verify network resolution maps")

        # --- PANEL UPPER RIGHT: DIAGNOSTICS & TELEMETRY ---
        mid_col = 54
        stdscr.addstr(6, mid_col, "DIAGNOSTICS & TELEMETRY", curses.color_pair(2) | curses.A_BOLD)
        stdscr.addstr(8, mid_col + 2, "[K]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(8, mid_col + 7, "wl doctor      - Audit cluster node health")
        stdscr.addstr(9, mid_col + 2, "[R]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(9, mid_col + 7, "wl repair      - Rebuild missing resources")
        stdscr.addstr(10, mid_col + 2, "[V]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(10, mid_col + 7, "wl vm list     - Enumerate live micro-VMs")
        stdscr.addstr(11, mid_col + 2, "[G]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(11, mid_col + 7, "wl graph       - Render dependency schema")
        stdscr.addstr(12, mid_col + 2, "[E]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(12, mid_col + 7, "wl sec doctor  - Verify POSIX security flags")

        # --- PANEL LOWER LEFT: STORAGE & CONFIG ---
        stdscr.addstr(17, 2, "STORAGE & ASSETS", curses.color_pair(2) | curses.A_BOLD)
        stdscr.addstr(19, 4, "[M]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(19, 9, "wl mirror once - Sync target system volumes")
        stdscr.addstr(20, 4, "[C]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(20, 9, "wl chats       - Trace local database records")

        # --- PANEL LOWER RIGHT: TEMPORAL STATE ---
        stdscr.addstr(17, mid_col, "TEMPORAL STATE MANAGEMENT", curses.color_pair(2) | curses.A_BOLD)
        stdscr.addstr(19, mid_col + 2, "[X]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(19, mid_col + 7, "wl snapshot    - Trigger environment backup")
        stdscr.addstr(20, mid_col + 2, "[T]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(20, mid_col + 7, "wl timeline    - Append tracking log entries")

        # --- AUDIT RUNTIMES (BOTTOM LAYER) ---
        stdscr.addstr(23, 2, "VAULT VALIDATION ENGINE", curses.color_pair(2) | curses.A_BOLD)
        stdscr.addstr(24, 4, "[A]", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(24, 9, "wl audit batch - Evaluate metric bounds across Knowledge Vault registries")

        # --- FOOTER BLOCK ---
        stdscr.addstr(height - 2, 2, "Press [Q] to terminate control console session.", curses.color_pair(5))
        stdscr.addstr(height - 2, width - 38, "OPERATOR SIGNATURE: MATTHEW MAHANEY", curses.A_DIM)
        
        stdscr.refresh()
        
        try:
            key = stdscr.getch()
        except Exception:
            key = -1
            
        if key == ord('q') or key == ord('Q'):
            break
            
        # --- LIFECYCLE ROUTING LOGIC ---
        elif key == ord('u') or key == ord('U'):
            stdscr.clear()
            stdscr.addstr(2, 4, "EXECUTING LIFECYCLE: wl start...", curses.color_pair(1) | curses.A_BOLD)
            stdscr.refresh()
            run_command("wl start")
            time.sleep(1)
        elif key == ord('d') or key == ord('D'):
            stdscr.clear()
            stdscr.addstr(2, 4, "EXECUTING LIFECYCLE: wl stop...", curses.color_pair(2) | curses.A_BOLD)
            stdscr.refresh()
            run_command("wl stop")
            time.sleep(1)
        elif key == ord('s') or key == ord('S'):
            stdscr.clear()
            stdscr.addstr(2, 4, "PARSING RUNTIME MATRIX ENGINE DATA...", curses.color_pair(1))
            stdscr.refresh()
            out = run_command("wl status")
            stdscr.addstr(4, 4, out[:height-6])
            stdscr.refresh()
            time.sleep(3)
        elif key == ord('l') or key == ord('L'):
            stdscr.clear()
            stdscr.addstr(2, 4, "TAPPING CONTAINER STREAM BUFFERS...", curses.color_pair(1))
            stdscr.refresh()
            out = run_command("wl logs")
            stdscr.addstr(4, 4, out[:height-6])
            stdscr.refresh()
            time.sleep(3)
        elif key == ord('n') or key == ord('N'):
            stdscr.clear()
            stdscr.addstr(2, 4, "INTERROGATING LOCALIZED DNS RESOLVER REGISTRIES...", curses.color_pair(1))
            stdscr.refresh()
            out = run_command("wl dns status")
            stdscr.addstr(4, 4, out[:height-6])
            stdscr.refresh()
            time.sleep(3)
            
        # --- DIAGNOSTICS & TELEMETRY ROUTING ---
        elif key == ord('k') or key == ord('K'):
            stdscr.clear()
            stdscr.addstr(2, 4, "DEPLOYING NON-MUTATING RUNTIME SECURITY DOCTOR...", curses.color_pair(1) | curses.A_BOLD)
            stdscr.refresh()
            out = run_command("wl doctor")
            stdscr.addstr(4, 4, out[:height-6])
            stdscr.refresh()
            time.sleep(3)
        elif key == ord('r') or key == ord('R'):
            stdscr.clear()
            stdscr.addstr(2, 4, "INVOKING AUTOMATED REPAIR ROUTINES...", curses.color_pair(2) | curses.A_BOLD)
            stdscr.refresh()
            out = run_command("wl repair")
            stdscr.addstr(4, 4, out[:height-6])
            stdscr.refresh()
            time.sleep(3)
        elif key == ord('v') or key == ord('V'):
            stdscr.clear()
            stdscr.addstr(2, 4, "ENUMERATING ISOLATED MICRO-VM TOPOLOGY...", curses.color_pair(1))
            stdscr.refresh()
            out = run_command("wl vm list")
            stdscr.addstr(4, 4, out[:height-6])
            stdscr.refresh()
            time.sleep(3)
        elif key == ord('g') or key == ord('G'):
            stdscr.clear()
            stdscr.addstr(2, 4, "RENDERING LOGICAL DEPENDENCY SCHEMA...", curses.color_pair(2))
            stdscr.refresh()
            out = run_command("wl graph")
            stdscr.addstr(4, 4, out[:height-6])
            stdscr.refresh()
            time.sleep(3)
        elif key == ord('e') or key == ord('E'):
            stdscr.clear()
            stdscr.addstr(2, 4, "RUNNING SECURITY SYSTEM AUDIT RUNTIME...", curses.color_pair(4) | curses.A_BOLD)
            stdscr.refresh()
            out = run_command("wl security doctor")
            stdscr.addstr(4, 4, out[:height-6])
            stdscr.refresh()
            time.sleep(3)
            
        # --- ASSETS & TEMPORAL STORAGE ROUTING ---
        elif key == ord('m') or key == ord('M'):
            stdscr.clear()
            stdscr.addstr(2, 4, "COMMENCING BACKUP MIRROR SYNCHRONIZATION...", curses.color_pair(1) | curses.A_BOLD)
            stdscr.refresh()
            out = run_command("wl mirror once")
            stdscr.addstr(4, 4, out[:height-6])
            stdscr.refresh()
            time.sleep(3)
        elif key == ord('c') or key == ord('C'):
            stdscr.clear()
            stdscr.addstr(2, 4, "FETCHING SYSTEM CORE CHAT TRANSACTION INDEX...", curses.color_pair(1))
            stdscr.refresh()
            out = run_command("wl chats")
            stdscr.addstr(4, 4, out[:height-6])
            stdscr.refresh()
            time.sleep(3)
        elif key == ord('x') or key == ord('X'):
            stdscr.clear()
            stdscr.addstr(2, 4, "PREPARING FILESYSTEM SNAPSHOT CORRIDORS...", curses.color_pair(2) | curses.A_BOLD)
            stdscr.refresh()
            out = run_command("wl snapshot")
            stdscr.addstr(4, 4, out[:height-6])
            stdscr.refresh()
            time.sleep(3)
        elif key == ord('t') or key == ord('T'):
            stdscr.clear()
            msg = get_input_string(stdscr, "Enter timeline delta annotation text: ", 2, 4)
            if msg:
                stdscr.clear()
                stdscr.addstr(2, 4, "COMMITTING TIMELINE ENTRY ACTION...", curses.color_pair(1))
                stdscr.refresh()
                out = run_command(f"wl timeline add '{msg}'")
                stdscr.addstr(4, 4, out[:height-6])
                stdscr.refresh()
                time.sleep(2)
                
        # --- BATCH KNOWLEDGE VAULT ENGINE ---
        elif key == ord('a') or key == ord('A'):
            stdscr.clear()
            stdscr.addstr(2, 4, "COMMENCING SYSTEMIC PERCUSSION AUDITING...", curses.color_pair(3) | curses.A_BOLD)
            stdscr.refresh()
            out = run_command("python3 ~/Wonderland/intelligence/obsidian/99-Tools/audit_batch.py")
            stdscr.clear()
            stdscr.addstr(2, 4, "METRIC ANALYSIS SUMMARY PASSED:", curses.color_pair(1))
            stdscr.addstr(4, 4, out[:height-8])
            stdscr.refresh()
            time.sleep(4)

if __name__ == "__main__":
    curses.wrapper(draw_tui)
