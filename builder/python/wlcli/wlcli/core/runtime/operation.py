from __future__ import annotations

import subprocess
import time
from dataclasses import dataclass

from wlcli.core.runtime.context import RuntimeContext


@dataclass(frozen=True)
class OperationResult:
    name: str
    command: list[str]
    code: int
    duration: float
    log: str

    @property
    def passed(self) -> bool:
        return self.code == 0


class BashOperationRunner:
    def __init__(self, context: RuntimeContext):
        self.context = context
        self.context.log_dir.mkdir(parents=True, exist_ok=True)

    def run(self, name: str, command: list[str], timeout: int = 60) -> OperationResult:
        safe = "".join(c if c.isalnum() else "_" for c in name).strip("_")
        log = self.context.log_dir / f"wl-op-{safe}.log"
        started = time.time()

        with log.open("w") as f:
            try:
                proc = subprocess.run(
                    command,
                    stdout=f,
                    stderr=subprocess.STDOUT,
                    env=self.context.env(),
                    timeout=timeout,
                    check=False,
                )
                code = proc.returncode
            except subprocess.TimeoutExpired:
                f.write(f"\nTIMEOUT after {timeout}s\n")
                code = 124
            except FileNotFoundError as e:
                f.write(f"\nMISSING command: {e}\n")
                code = 127

        return OperationResult(
            name=name,
            command=command,
            code=code,
            duration=time.time() - started,
            log=str(log),
        )
