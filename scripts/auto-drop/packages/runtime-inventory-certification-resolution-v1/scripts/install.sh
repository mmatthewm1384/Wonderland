#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/inventory.py"

cp "$TARGET" "$TARGET.runtime-inventory-certification-resolution-v1.bak"


python3 <<PY
from pathlib import Path

p = Path("$TARGET")

text = p.read_text()


text = text.replace(
"""        return data.get(
            "runtimes",
            []
        )
""",
"""
        runtimes = data.get(
            "runtimes",
            []
        )

        try:
            from wlplatform.runtime.targets.loader import (
                RuntimeTargetRegistry
            )

            registry = RuntimeTargetRegistry(
                self.path.parents[4]
            )

            for runtime in runtimes:

                target = registry.get(
                    runtime["instance"]
                )

                runtime["certified"] = bool(
                    target.get("certification")
                )

        except Exception:
            for runtime in runtimes:
                runtime["certified"] = False


        return runtimes
"""
)


p.write_text(text)

PY


python3 -m compileall "$TARGET"

echo "Runtime inventory certification resolution installed"

