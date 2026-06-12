#!/usr/bin/env python3
import os
import sys
from pathlib import Path
from datetime import datetime

# ANSI Style Profiles
CYAN = "\x1b[38;2;0;229;255m"
GREEN = "\x1b[38;2;0;255;102m"
YELLOW = "\x1b[38;2;255;204;0m"
PURPLE = "\x1b[38;2;163;71;255m"
TEXT_WHITE = "\x1b[38;2;255;255;255m"
RED = "\x1b[38;2;255;0;102m"
RESET = "\x1b[0m"

TARGET_DIR = Path.home() / "Wonderland/vault"

def format_size(size_bytes):
    """Converts bytes to human-readable string profiles."""
    if size_bytes < 1024:
        return f"{size_bytes} B"
    elif size_bytes < 1024 * 1024:
        return f"{size_bytes / 1024:.1f} KB"
    return f"{size_bytes / (1024 * 1024):.1f} MB"

def inventory_legacy_vault():
    print(f"\n{CYAN}┏━ [LEGACY VAULT DISCOVERY: ARCHIVE INVESTIGATION] ━┓{RESET}")
    print(f"┃ Target Path: {TEXT_WHITE}{TARGET_DIR}{RESET}")
    
    if not TARGET_DIR.exists():
        print(f"┃ Status: {RED}INACTIVE / DOES NOT EXIST{RESET}")
        print(f"┃ No files to clean or reconcile.")
        print(f"{CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛{RESET}\n")
        return

    all_files = list(TARGET_DIR.rglob("*"))
    files_only = [f for f in all_files if f.is_file()]
    
    total_size = sum(f.stat().st_size for f in files_only)
    print(f"┃ Aggregate Density: {GREEN}{len(files_only)}{RESET} Files | Total Weight: {GREEN}{format_size(total_size)}{RESET}")
    print(f"┃")
    
    if not files_only:
        print(f"┃ {YELLOW}Directory is empty. No tracking payload found.{RESET}")
    else:
        print(f"┃ {PURPLE}Payload Manifest Breakdown:{RESET}")
        # Sort files alphabetically by relative path for scannable auditing
        for file_path in sorted(files_only, key=lambda x: x.relative_to(TARGET_DIR)):
            rel_path = file_path.relative_to(TARGET_DIR)
            stat = file_path.stat()
            size_str = format_size(stat.st_size)
            mod_time = datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S')
            
            print(f"┃   ├── {TEXT_WHITE}{rel_path}{RESET}")
            print(f"┃   │     └── Size: {YELLOW}{size_str}{RESET} | Modified: {YELLOW}{mod_time}{RESET}")
            
    print(f"┃")
    print(f"┃ {CYAN}Retention Note:{RESET} Review this file checklist before migrating target items")
    print(f"┃ to 'intelligence/obsidian'. Unsaved nodes can be cleared safely.")
    print(f"{CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛{RESET}\n")

if __name__ == "__main__":
    inventory_legacy_vault()
