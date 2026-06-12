#!/usr/bin/env python3
import os
import sys
import shutil
import subprocess

def log_status(component, status, message):
    print(f"[{status.upper()}] {component}: {message}")

def check_environment():
    failed = False
    print("=== WONDERLAND DOCTOR MODE: AUDIT RUN ===")
    
    workspace = os.path.expanduser("~/Wonderland/Wonderland-v4")
    vault_path = os.path.expanduser("~/Wonderland/intelligence/obsidian")
    
    # ==========================================
    # TIER 3: RUNTIME & INFRASTRUCTURE VERIFICATION
    # ==========================================
    # 1. Check Workspace Location
    if not os.path.exists(workspace):
        log_status("Workspace", "FAIL", f"Path missing: {workspace}")
        failed = True
    else:
        log_status("Workspace", "PASS", f"Located at {workspace}")

    # 2. Check Python Virtual Environment
    venv_path = os.path.join(workspace, ".venv")
    if not os.path.exists(venv_path):
        log_status("Python Venv", "FAIL", "Virtual environment (.venv) does not exist.")
        failed = True
    else:
        log_status("Python Venv", "PASS", "Isolated virtual environment present.")

    # 3. Check Container Runtime Boundary
    nerdctl_path = shutil.which("nerdctl")
    if not nerdctl_path:
        log_status("Runtime", "FAIL", "nerdctl binary not found in PATH.")
        failed = True
    else:
        try:
            # Simple non-mutating containerd ping
            subprocess.run([nerdctl_path, "info"], capture_output=True, text=True, check=True)
            log_status("Runtime", "PASS", "nerdctl is communicating with containerd.")
        except Exception:
            log_status("Runtime", "FAIL", "nerdctl found but containerd is unreachable or misconfigured.")
            failed = True

    # ==========================================
    # TIER 1: AUTHORITATIVE KNOWLEDGE VAULT VERIFICATION
    # ==========================================
    print("\n--- TIER 1 OBSIDIAN VAULT AUDIT ---")
    required_files = [
        "00-Core/Governance.md",
        "00-Core/INSTALL.md",
        "00-Core/REPOSITORY.md",
        "10-Architecture/Runtime-Engine.md",
        "10-Architecture/Isolation-Boundaries.md",
        "20-Registries/Service-Catalog.md",
        "30-Automation/Schema-Validation.md"
    ]
    
    if not os.path.exists(vault_path):
        log_status("Obsidian Vault", "FAIL", f"Vault directory missing at {vault_path}")
        failed = True
    else:
        for rel_path in required_files:
            full_path = os.path.join(vault_path, rel_path)
            if os.path.exists(full_path):
                log_status(f"Vault Node", "PASS", f"Verified: {rel_path}")
            else:
                log_status(f"Vault Node", "FAIL", f"Missing Authoritative Document: {rel_path}")
                failed = True

    # Final Evaluation Boundary
    if failed:
        print("\n[RESULT] System configuration issues detected. Run 'wl repair' to apply fixes.")
        sys.exit(1)
    else:
        print("\n[RESULT] All systems optimal. Governance alignment verified.")
        sys.exit(0)

if __name__ == "__main__":
    check_environment()
