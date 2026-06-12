#!/usr/bin/env python3
import os
import sys
import re
from pathlib import Path

VAULT_DIR = Path(os.path.expanduser("~/Wonderland/vault/00-Core"))

REQUIRED_DOCS = {
    "MANIFEST.md": "VAULT-DOCUMENT-CATALOG-V4",
    "AUTHORITY.md": "VAULT-AUTHORITY-V4",
    "KNOWLEDGE.md": "VAULT-KNOWLEDGE-V4",
    "RUNTIME.md": "VAULT-RUNTIME-V4",
    "SECURITY.md": "VAULT-SECURITY-V4",
    "OPERATIONS.md": "VAULT-OPERATIONS-V4",
    "RECOVERY.md": "VAULT-RECOVERY-V4"
}

REQUIRED_SECTIONS = ["## Verification", "## Recovery", "## Rollback"]

def calculate_density(text):
    # Operator's metric: ratio of alphanumeric characters to overall string length
    clean = re.sub(r'\s+', '', text)
    if not text:
        return 0.0
    alnum_count = sum(1 for c in clean if c.isalnum())
    return round(alnum_count / len(clean), 3) if len(clean) > 0 else 0.0

def run_doctor():
    print(f"[*] Executing Doctor Mode against: {VAULT_DIR}")
    if not VAULT_DIR.exists():
        print(f"[ERROR] Core vault path does not exist: {VAULT_DIR}")
        return False

    failures = 0
    for filename, expected_id in REQUIRED_DOCS.items():
        filepath = VAULT_DIR / filename
        print(f"\n--- Auditing: {filename} ---")
        
        if not filepath.exists():
            print(f"[FAIL] File missing: {filename}")
            failures += 1
            continue
            
        # Permission check
        stat = filepath.stat()
        perm = oct(stat.st_mode & 0o777)
        if perm not in ['0o600', '0o700']:
            print(f"[FAIL] Insecure permissions: {perm} (Expected 0600 or 0700)")
            failures += 1
        else:
            print(f"[PASS] Permissions: {perm}")

        # Document structure check
        content = filepath.read_text()
        
        # ID Validation
        id_match = re.search(r'', content)
        if not id_match or id_match.group(1) != expected_id:
            actual = id_match.group(1) if id_match else "NONE"
            print(f"[FAIL] Metadata ID discrepancy: Found {actual}, Expected {expected_id}")
            failures += 1
        else:
            print(f"[PASS] Metadata ID: {expected_id}")

        # Density Target check
        density = calculate_density(content)
        if not (0.69 <= density <= 0.75):
            print(f"[WARN] Persona Density out of bounds: {density} (Target: 0.69 - 0.75)")
        else:
            print(f"[PASS] Persona Density: {density}")

        # Integrity Sections check (Except for Manifest file itself if it serves as the root table)
        if filename != "MANIFEST.md":
            missing_sec = [sec for sec in REQUIRED_SECTIONS if sec not in content]
            if missing_sec:
                print(f"[FAIL] Missing operational blocks: {missing_sec}")
                failures += 1
            else:
                print("[PASS] Core VRR Blocks Present")

    return failures == 0

def run_repair():
    print(f"[*] Executing Idempotent Repair Mode on: {VAULT_DIR}")
    VAULT_DIR.mkdir(parents=True, exist_ok=True)

    for filename, expected_id in REQUIRED_DOCS.items():
        filepath = VAULT_DIR / filename
        
        if not filepath.exists() or filepath.stat().st_size == 0:
            print(f"[REPAIR] Re-seeding missing file: {filename}")
            title = filename.replace(".md", "").replace("_", " ").title()
            default_content = (
                f"\n\n"
                f"# WONDERLAND {title.upper()}\n\n"
                f"## Overview\nSeed file initialized via recovery automation.\n\n"
                f"## Verification\nPlaceholder verification step.\n\n"
                f"## Recovery\nPlaceholder recovery step.\n\n"
                f"## Rollback\nPlaceholder rollback step.\n"
            )
            filepath.write_text(default_content)
        else:
            # Inline Repair of metadata header if structural boundaries require it
            content = filepath.read_text()
            if f"ID: {expected_id}" not in content:
                print(f"[REPAIR] Fixing missing metadata target header in {filename}")
                content = f"\n" + content
                filepath.write_text(content)

        # Enforce target POSIX permissions safely
        os.chmod(filepath, 0o600)
        print(f"[REPAIR] Enforced 0600 on {filename}")

    print("[*] Repair run finished.")
    return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: control.py [doctor|repair]")
        sys.exit(1)
        
    mode = sys.argv[1].lower()
    if mode == "doctor":
        success = run_doctor()
        sys.exit(0 if success else 1)
    elif mode == "repair":
        success = run_repair()
        sys.exit(0 if success else 1)
    else:
        print(f"Unknown operational control directive: {mode}")
        sys.exit(1)
