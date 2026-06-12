#!/usr/bin/env python3
import os
import sys
import shutil
import subprocess

def log_repair(step, status):
    print(f"[REPAIR] {step}: {status}")

def fix_environment():
    print("=== WONDERLAND REPAIR MODE: IDEMPOTENT HEALING ===")
    workspace = os.path.expanduser("~/Wonderland/Wonderland-v4")
    
    # 1. Resolve Python Virtual Environment
    venv_path = os.path.join(workspace, ".venv")
    if not os.path.exists(venv_path):
        log_repair("Python Venv", "Missing. Provisioning isolated environment...")
        try:
            subprocess.run([sys.executable, "-m", "venv", venv_path], check=True)
            log_repair("Python Venv", "SUCCESS: Created workspace-isolated .venv.")
        except Exception as e:
            log_repair("Python Venv", f"FAIL: Unable to create venv. Details: {e}")
            sys.exit(1)
    else:
        log_repair("Python Venv", "PASS: Valid isolated environment already exists.")

    # 2. Resolve Container Runtime Boundary
    nerdctl_path = shutil.which("nerdctl")
    if not nerdctl_path:
        log_repair("Runtime", "CRITICAL: nerdctl engine missing from system PATH.")
        sys.exit(1)

    log_repair("Runtime", "nerdctl found. Inspecting containerd socket visibility...")
    
    # Target common rootless macOS containerd/lima socket patterns
    # Enforce rootless socket address context if missing
    user_runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
    if not user_runtime_dir:
        # Default fallback layout for rootless setups
        os.environ["XDG_RUNTIME_DIR"] = os.path.expanduser("~/.config/lima/boot2containerd/data")
    
    # Attempt to restart the rootless background service wrapper if accessible via launchctl or limactl
    limactl_path = shutil.which("limactl")
    if limactl_path:
        log_repair("Runtime", "Found limactl manager. Ensuring default instance is initialized and running...")
        try:
            # Idempotently start the service instance
            subprocess.run([limactl_path, "start", "--headful=false", "default"], 
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            log_repair("Runtime", "Service signal sent via limactl.")
        except Exception:
            pass

    print("\n[RESULT] Repair steps applied. Re-running verification validation...")
    
    # Cascade back into Doctor mode automatically to close control loop
    doctor_path = os.path.join(workspace, "scripts", "doctor_core.py")
    if os.path.exists(doctor_path):
        os.execv(sys.executable, [sys.executable, doctor_path])

if __name__ == "__main__":
    fix_environment()
