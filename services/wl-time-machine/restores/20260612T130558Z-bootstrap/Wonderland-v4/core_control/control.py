#!/usr/bin/env python3
import os
import sys
import re
import argparse
from pathlib import Path

VAULT_BASE = Path(os.path.expanduser("~/Wonderland/vault"))
TOOLS_BASE = Path(os.path.expanduser("~/Wonderland/Wonderland-v4/tools"))

DIRECTORY_MAP = {
    "00-core": VAULT_BASE / "00-Core",
    "01-intelligence": VAULT_BASE / "01-Intelligence",
    "02-infrastructure": VAULT_BASE / "02-Infrastructure",
    "03-automation": VAULT_BASE / "03-Automation",
    "04-security": VAULT_BASE / "04-Security",
    "05-resilience": VAULT_BASE / "05-Resilience",
    "06-projects": VAULT_BASE / "06-Projects",
    "07-archive": VAULT_BASE / "07-Archive",
    "tools": TOOLS_BASE
}

CORE_DOCS = {
    "MANIFEST.md": "VAULT-DOCUMENT-CATALOG-V4",
    "AUTHORITY.md": "VAULT-AUTHORITY-V4",
    "KNOWLEDGE.md": "VAULT-KNOWLEDGE-V4",
    "RUNTIME.md": "VAULT-RUNTIME-V4",
    "SECURITY.md": "VAULT-SECURITY-V4",
    "OPERATIONS.md": "VAULT-OPERATIONS-V4",
    "RECOVERY.md": "VAULT-RECOVERY-V4"
}

REQUIRED_SECTIONS = ["## Verification", "## Recovery", "## Rollback"]

def calculate_phonetic_density(text):
    words = text.split()
    if not words:
        return 0.0
    percussive_words = [w for w in words if re.search(r'[ktqpbdg]', w, re.I)]
    return round(len(percussive_words) / len(words), 4)

def run_universal_domain_audit():
    print(f"\n[UNIVERSAL DOMAIN AUDIT: {VAULT_BASE}]")
    if not VAULT_BASE.exists():
        print(f"[ERROR] Vault base path does not exist: {VAULT_BASE}")
        return False

    all_passed = True
    for domain in sorted([d for d in VAULT_BASE.iterdir() if d.is_dir()]):
        has_manifest = (domain / "MANIFEST.md").exists()
        has_governance = (domain / "AUTHORITY.md").exists() or (domain / "Governance.md").exists()
        
        status = "COMPLETE" if (has_manifest or has_governance) else "INCOMPLETE"
        marker = "✔" if status == "COMPLETE" else "✘"
        if status == "INCOMPLETE":
            all_passed = False
        
        print(f"  {marker} {domain.name: <25} | Status: {status}")
    return all_passed

def run_doctor(target_dir, is_core=False):
    print(f"[*] [DOCTOR] Auditing target directory: {target_dir}")
    if not target_dir.exists():
        print(f"[ERROR] Target directory does not exist: {target_dir}")
        return False

    failures = 0
    if is_core:
        files_to_check = [(target_dir / f, expected_id) for f, expected_id in CORE_DOCS.items()]
    else:
        files_to_check = [(f, None) for f in target_dir.rglob("*.md") if f.is_file() and not f.name.startswith(".")]
        if "tools" in str(target_dir):
            files_to_check += [(f, None) for f in target_dir.glob("*") if f.is_file() and f.suffix in ['.py', '.sh']]

    if not files_to_check:
        print("[*] No active assets found in target directory selection.")
        return True

    for filepath, expected_id in files_to_check:
        if not filepath.exists():
            if is_core:
                print(f"[FAIL] Core file missing: {filepath.name}")
                failures += 1
            continue

        print(f"\n--- Auditing Asset: {filepath.name} ---")
        stat = filepath.stat()
        perm_oct = oct(stat.st_mode & 0o777)[-3:]
        if perm_oct not in ['600', '700']:
            print(f"[FAIL] Insecure permissions detected: {perm_oct} (Expected 600 or 700)")
            failures += 1
        else:
            print(f"[PASS] Permissions Verified: {perm_oct}")

        if filepath.suffix in ['.md', '.py', '.sh', '.txt']:
            try:
                content = filepath.read_text(errors='ignore')
            except Exception as e:
                print(f"[WARN] Could not read file content: {e}")
                continue

            if expected_id:
                id_match = re.search(r'', content)
                actual_id = id_match.group(1) if (id_match and len(id_match.groups()) >= 1) else None
                if actual_id != expected_id:
                    print(f"[FAIL] Metadata ID discrepancy: Found '{actual_id}', Expected '{expected_id}'")
                    failures += 1
                else:
                    print(f"[PASS] Metadata ID Verified: {expected_id}")

            density = calculate_phonetic_density(content)
            if not (0.69 <= density <= 0.75):
                print(f"[WARN] Phonetic Density standard discrepancy: {density:.2%} (Target: 69%-75%)")
            else:
                print(f"[PASS] Phonetic Density Standard Verified: {density:.2%}")

            if filepath.suffix == '.md' and filepath.name != "MANIFEST.md":
                missing_sec = [sec for sec in REQUIRED_SECTIONS if sec not in content]
                if missing_sec:
                    print(f"[FAIL] Missing operational blocks: {missing_sec}")
                    failures += 1
                else:
                    print("[PASS] Core VRR Blocks Present")

    return failures == 0

def run_repair(target_dir, is_core=False):
    print(f"[*] [REPAIR] Initializing idempotent execution on target: {target_dir}")
    target_dir.mkdir(parents=True, exist_ok=True)

    if is_core:
        for filename, expected_id in CORE_DOCS.items():
            filepath = target_dir / filename
            if not filepath.exists() or filepath.stat().st_size == 0:
                print(f"[REPAIR] Re-seeding missing file structural matrix: {filename}")
                title = filename.replace(".md", "").replace("_", " ").title()
                default_content = (
                    f"\n\n"
                    f"# WONDERLAND {title.upper()}\n\n"
                    f"## Overview\nSeed file initialized via systemic repair loop.\n\n"
                    f"## Verification\nPlaceholder text checking verification sequence loops.\n\n"
                    f"## Recovery\nPlaceholder text tracking recovery restoration tasks.\n\n"
                    f"## Rollback\nPlaceholder text enforcing rollback operational boundaries.\n"
                )
                filepath.write_text(default_content)
            else:
                content = filepath.read_text()
                if f"ID: {expected_id}" not in content:
                    print(f"[REPAIR] Injecting missing metadata system target header to {filename}")
                    content = f"\n" + content
                    filepath.write_text(content)
            os.chmod(filepath, 0o600)
    else:
        for filepath in target_dir.rglob("*"):
            if filepath.is_file() and not filepath.name.startswith("."):
                os.chmod(filepath, 0o600)

    print("[*] Repair execution routine complete.")
    return True

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Wonderland Control Plane Interface Engine")
    parser.add_argument("action", choices=["doctor", "repair", "audit-domains"], help="Operational mode execution selection.")
    parser.add_argument("-d", "--directory", default="00-core", 
                        choices=list(DIRECTORY_MAP.keys()), 
                        help="Target vault area selection space.")
    
    args = parser.parse_args()
    
    if args.action == "audit-domains":
        success = run_universal_domain_audit()
        sys.exit(0 if success else 1)
        
    selected_dir_key = args.directory.lower()
    target_path = DIRECTORY_MAP[selected_dir_key]
    is_core_space = (selected_dir_key == "00-core")

    if args.action == "doctor":
        success = run_doctor(target_path, is_core=is_core_space)
        sys.exit(0 if success else 1)
    elif args.action == "repair":
        success = run_repair(target_path, is_core=is_core_space)
        sys.exit(0 if success else 1)
