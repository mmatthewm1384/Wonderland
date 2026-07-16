from __future__ import annotations

import json
import subprocess

from pathlib import Path

from wlplatform.engine_contract import (
    EngineContract,
    EngineResult,
)


class RegistryEngine(EngineContract):

    name = "registry"

    def verify(self):

        result = subprocess.run(
            [
                "bin/wl",
                "registry",
                "--json",
            ],
            cwd=self.root,
            capture_output=True,
            text=True,
            check=False,
        )

        if result.returncode != 0:
            return EngineResult(
                engine=self.name,
                action="verify",
                status="FAIL",
                details={
                    "stderr": result.stderr,
                },
            )

        return EngineResult(
            engine=self.name,
            action="verify",
            status="PASS",
            details=json.loads(
                result.stdout
            ),
        )
