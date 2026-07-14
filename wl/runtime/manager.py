from __future__ import annotations

import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

from wl.runtime.shutdown import ShutdownManager


@dataclass
class CommandResult:
    name: str
    ok: bool
    returncode: int
    output: str


class RuntimeManager:
    def __init__(self, root: Path | None = None):
        self.root = root or Path(__file__).resolve().parents[2]
        self.python = sys.executable

    def start(self, debug: bool = False) -> CommandResult:
        # wl-start does not currently support --debug.
        return self._run("start", [str(self.root / "bin" / "wl-start")], debug)

    def stop(self, debug: bool = False, force: bool = False) -> CommandResult:
        manager = ShutdownManager(root=self.root, dry_run=False, force=force, keep_state=False)
        result = manager.shutdown()

        lines = [result.message]
        lines += [f"STOP {item}" for item in result.stopped]
        lines += [f"SKIP {item}" for item in result.skipped]
        lines += [f"FAIL {item}" for item in result.errors]

        output = "\n".join(lines) + "\n"

        if debug:
            print(output, end="")

        return CommandResult(
            name="stop",
            ok=result.ok,
            returncode=0 if result.ok else 1,
            output=output,
        )

    def restart(self, debug: bool = False, force: bool = False) -> CommandResult:
        stop = self.stop(debug=debug, force=force)
        if not stop.ok:
            return CommandResult("restart", False, stop.returncode, stop.output)

        start = self.start(debug=debug)
        output = stop.output + start.output

        return CommandResult(
            name="restart",
            ok=start.ok,
            returncode=start.returncode,
            output=output,
        )

    def verify(self, debug: bool = False) -> CommandResult:
        return self._run("verify", [self.python, "-m", "wl.runtime.verify"], debug)

    def report(self, debug: bool = False) -> CommandResult:
        return self._run("report", [self.python, "-m", "wl.runtime.report"], debug)

    def _run(self, name: str, command: list[str], debug: bool = False) -> CommandResult:
        proc = subprocess.run(
            command,
            cwd=self.root,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )

        if debug or proc.returncode != 0:
            print(proc.stdout, end="")

        return CommandResult(
            name=name,
            ok=proc.returncode == 0,
            returncode=proc.returncode,
            output=proc.stdout,
        )
