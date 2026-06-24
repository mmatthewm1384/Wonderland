#!/usr/bin/env python3
import os
import sys
import shutil
import subprocess
from pathlib import Path

SERVICE_DIR = Path(__file__).parent.resolve()
COMPOSE_FILE = SERVICE_DIR / "compose.yml"
DATA_DIR = SERVICE_DIR / "data"
RUNTIME_DIR = SERVICE_DIR / "runtime"

class SandboxManager:
    def __init__(self):
        self.compose_cmd = ["nerdctl", "compose", "-f", str(COMPOSE_FILE)]

    def _run(self, cmd: list, capture=False):
        if capture:
            return subprocess.run(cmd, capture_output=True, text=True)
        return subprocess.run(cmd)

    def doctor(self) -> bool:
        """Doctor Mode: Read-only health evaluation of the sandbox environment."""
        healthy = True
        print("[DOCTOR] Inspecting Persistent Sandbox Environment...")

        # 1. Check commands
        if not shutil.which("nerdctl"):
            print("[-] Error: 'nerdctl' binary missing from system PATH.")
            healthy = False

        # 2. Check structural directory alignments
        for path in [DATA_DIR, RUNTIME_DIR, COMPOSE_FILE]:
            if not path.exists():
                print(f"[-] Error: Expected structural resource missing: {path.name}")
                healthy = False

        # 3. Check container runtime layer state
        if healthy:
            res = self._run(self.compose_cmd + ["ps", "--format", "json"], capture=True)
            if "wl-sandbox" in res.stdout and "running" in res.stdout.lower():
                print("[+] Container 'wl-sandbox' is running actively.")
            else:
                print("[-] Warning: Container engine target 'wl-sandbox' is stopped or unbuilt.")

        if healthy:
            print("[+] Doctor Mode: Sandbox infrastructure structural configuration is healthy.")
        return healthy

    def repair(self) -> bool:
        """Repair Mode: Idempotently configure missing directories, links, and pull layers."""
        print("[REPAIR] Executing idempotent self-healing routine...")
        
        # Ensure directories exist
        DATA_DIR.mkdir(parents=True, exist_ok=True)
        RUNTIME_DIR.mkdir(parents=True, exist_ok=True)

        # Validate engine container availability
        print("[*] Pulling underlying container image blocks if missing...")
        self._run(self.compose_cmd + ["pull"])
        
        print("[+] Repair processing cycle completed.")
        return True

    def up(self):
        """Bring the sandbox daemon up."""
        print("[*] Spawning detached sandbox runtime process...")
        self.repair()
        # Ensure stale artifacts are cleared
        self._run(self.compose_cmd + ["down"])
        self._run(self.compose_cmd + ["up", "-d"])
        print("[+] Persistent Sandbox service operational.")

    def down(self):
        """Tear down the sandbox context cleanly."""
        print("[*] Halting container execution threads...")
        self._run(self.compose_cmd + ["down"])
        print("[+] Container execution threads fully halted.")

    def status(self):
        """Display container environment visibility parameters."""
        print("=== SANDBOX STATUS ===")
        self._run(self.compose_cmd + ["ps"])

    def logs(self):
        """Stream standard sandbox log pipelines."""
        self._run(self.compose_cmd + ["logs", "--tail", "100"])

    def execute(self, cmd_args: list):
        """Execute an arbitrary command inside the running sandbox container."""
        exec_cmd = ["nerdctl", "exec", "-it", "wl-sandbox"] + cmd_args
        subprocess.run(exec_cmd)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: wl-sandbox [up|down|status|logs|doctor|repair]")
        sys.exit(1)

    manager = SandboxManager()
    cmd = sys.argv[1]

    if cmd == "up":
        manager.up()
    elif cmd == "down":
        manager.down()
    elif cmd == "status":
        manager.status()
    elif cmd == "logs":
        manager.logs()
    elif cmd == "doctor":
        sys.exit(0 if manager.doctor() else 1)
    elif cmd == "repair":
        sys.exit(0 if manager.repair() else 1)
    elif cmd == "exec":
        if len(sys.argv) < 3:
            print("Usage: wl-sandbox exec [command]")
            sys.exit(1)
        manager.execute(sys.argv[2:])
    else:
        print(f"Unknown operation directive: {cmd}")
        sys.exit(1)
