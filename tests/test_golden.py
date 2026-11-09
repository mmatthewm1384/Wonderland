#!/usr/init/env python3
import os
import re
import sys
import argparse
import difflib

# Corrected workspace root for Wonderland
WORKSPACE_ROOT = os.environ.get("WORKSPACE_ROOT", "/Users/Wonderland/wonderland")
GOLDEN_DIR = os.path.join(WORKSPACE_ROOT, "tests", "golden")
SERIAL_LOG = "/tmp/vfkit_serial.log"

def normalize_output(text):
    text = re.sub(r'\[\s*\d+\.\d+\]', '[TIMESTAMP]', text)
    text = re.sub(r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}', 'UUID-MASKED', text)
    return text.strip()

def test_serial_boot(update=False):
    os.makedirs(GOLDEN_DIR, exist_ok=True)
    golden_path = os.path.join(GOLDEN_DIR, "serial_boot.golden")
    
    if not os.path.exists(SERIAL_LOG):
        print(f"[!] Error: Serial log not found at {SERIAL_LOG}. Run 'make up' first.")
        sys.exit(1)
        
    with open(SERIAL_LOG, "r") as f:
        actual_content = normalize_output(f.read())
        
    if update or not os.path.exists(golden_path):
        print(f"[+] Writing golden reference file at {golden_path}")
        with open(golden_path, "w") as f:
            f.write(actual_content)
        print("[PASS] Golden baseline updated successfully.")
        return

    with open(golden_path, "r") as f:
        expected_content = f.read().strip()

    if actual_content == expected_content:
        print("[PASS] Serial boot output matches golden file.")
    else:
        print(f"[FAIL] Serial boot output differs from golden reference ({golden_path})!\n")
        diff = difflib.unified_diff(
            expected_content.splitlines(),
            actual_content.splitlines(),
            fromfile="golden_reference",
            tofile="actual_build",
            lineterm=""
        )
        print("\n".join(diff))
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run or update serial boot golden test.")
    parser.add_argument("--update", action="store_true", help="Overwrite golden reference file with current output")
    args = parser.parse_args()
    
    test_serial_boot(update=args.update)
