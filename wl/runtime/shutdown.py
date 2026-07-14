from __future__ import annotations

import json
import os
import signal
import subprocess
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

from wl.runtime.launchagents import bootout_default_launch_agents


@dataclass
class ShutdownResult:
    ok: bool
    message: str
    stopped: list[str]
    skipped: list[str]
    errors: list[str]


class ShutdownManager:
    def __init__(self, root: Path | None = None, dry_run: bool = False, force: bool = False, keep_state: bool = False):
        self.root = root or Path.cwd()
        self.dry_run = dry_run
        self.force = force
        self.keep_state = keep_state
        self.state_dir = self.root / "state" / "runtime"
        self.logs_dir = self.root / "logs" / "runtime"
        self.stopped: list[str] = []
        self.skipped: list[str] = []
        self.errors: list[str] = []

    def shutdown(self) -> ShutdownResult:
        self.state_dir.mkdir(parents=True, exist_ok=True)
        self.logs_dir.mkdir(parents=True, exist_ok=True)

        self._write_stop_sentinel()
        self._disable_launch_agents()
        self._stop_known_processes()
        time.sleep(1.0)
        self._stop_known_processes()
        self._archive_state()
        self._cleanup_state()

        ok = not self.errors
        result = ShutdownResult(
            ok=ok,
            message="Wonderland runtime stopped" if ok else "Wonderland runtime stop completed with errors",
            stopped=self.stopped,
            skipped=self.skipped,
            errors=self.errors,
        )
        self._write_shutdown_report(result)
        return result


    def _write_stop_sentinel(self) -> None:
        path = self.state_dir / "stop.requested"
        if self.dry_run:
            self.stopped.append(f"DRY RUN would create {path}")
            return
        try:
            path.write_text(str(time.time()) + "\n", encoding="utf-8")
            self.stopped.append("created stop.requested sentinel")
        except OSError as exc:
            self.errors.append(f"failed to create stop sentinel: {exc}")


    def _disable_launch_agents(self) -> None:
        for result in bootout_default_launch_agents(self.root, dry_run=self.dry_run):
            if result.startswith("DRY RUN") or result.startswith("booted out"):
                self.stopped.append(result)
            else:
                self.skipped.append(result)

    def _stop_known_processes(self) -> None:
        patterns = [
            "wl.runtime",
            "wl-chaos-menubar",
            "ephemeral/bin/wl-chaos-menubar",
            "wl-matrix",
            "ephemeral/bin/wl-matrix",
            "wonderland-runtime",
        ]

        for pattern in patterns:
            pids = self._pgrep(pattern)
            if not pids:
                self.skipped.append(f"{pattern}: not running")
                continue

            for pid in pids:
                self._terminate_pid(pid, pattern)

    def _pgrep(self, pattern: str) -> list[int]:
        try:
            proc = subprocess.run(
                ["pgrep", "-f", pattern],
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                check=False,
            )
        except FileNotFoundError:
            self.skipped.append("pgrep unavailable")
            return []

        current = os.getpid()
        pids: list[int] = []

        for line in proc.stdout.splitlines():
            try:
                pid = int(line.strip())
            except ValueError:
                continue

            if pid != current:
                pids.append(pid)

        return sorted(set(pids))

    def _terminate_pid(self, pid: int, label: str) -> None:
        if self.dry_run:
            self.stopped.append(f"DRY RUN would stop {label} pid={pid}")
            return

        try:
            os.kill(pid, signal.SIGTERM)
            if not self.force:
                for _ in range(20):
                    if not self._pid_exists(pid):
                        self.stopped.append(f"stopped {label} pid={pid}")
                        return
                    time.sleep(0.1)

            if self.force and self._pid_exists(pid):
                os.kill(pid, signal.SIGKILL)

            self.stopped.append(f"stopped {label} pid={pid}")
        except ProcessLookupError:
            self.skipped.append(f"{label} pid={pid}: already stopped")
        except PermissionError as exc:
            self.errors.append(f"{label} pid={pid}: permission denied: {exc}")
        except OSError as exc:
            self.errors.append(f"{label} pid={pid}: stop failed: {exc}")

    def _pid_exists(self, pid: int) -> bool:
        try:
            os.kill(pid, 0)
            return True
        except ProcessLookupError:
            return False
        except PermissionError:
            return True

    def _archive_state(self) -> None:
        startup = self.state_dir / "startup.json"
        last_session = self.state_dir / "last-session.json"

        if not startup.exists():
            self.skipped.append("startup.json missing")
            return

        if self.dry_run:
            self.stopped.append(f"DRY RUN would archive {startup} -> {last_session}")
            return

        try:
            last_session.write_text(startup.read_text(), encoding="utf-8")
            self.stopped.append("archived startup.json to last-session.json")
        except OSError as exc:
            self.errors.append(f"failed to archive runtime state: {exc}")

    def _cleanup_state(self) -> None:
        if self.keep_state:
            self.skipped.append("state cleanup skipped by --keep-state")
            return

        transient = [
            self.state_dir / "startup.json",
            self.state_dir / "status.json",
            self.state_dir / "services.json",
            self.state_dir / "session.json",
        ]

        for path in transient:
            if not path.exists():
                self.skipped.append(f"{path.name}: already absent")
                continue

            if self.dry_run:
                self.stopped.append(f"DRY RUN would remove {path}")
                continue

            try:
                path.unlink()
                self.stopped.append(f"removed {path.name}")
            except OSError as exc:
                self.errors.append(f"failed to remove {path}: {exc}")

    def _write_shutdown_report(self, result: ShutdownResult) -> None:
        report = {
            "ok": result.ok,
            "message": result.message,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "dry_run": self.dry_run,
            "force": self.force,
            "keep_state": self.keep_state,
            "stopped": result.stopped,
            "skipped": result.skipped,
            "errors": result.errors,
        }

        if self.dry_run:
            print(json.dumps(report, indent=2))
            return

        path = self.state_dir / "shutdown.json"
        path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
