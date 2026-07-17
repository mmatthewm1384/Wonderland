#!/usr/bin/env bash
set -euo pipefail

ROOT="${WONDERLAND_ROOT:-$(pwd)}"

TARGET="$ROOT/bin/wl-platform"

echo "======================================"
echo " Platform Entrypoint Migration"
echo "======================================"

cp "$TARGET" \
   "$TARGET.backup.$(date +%Y%m%d-%H%M%S)"

cat > "$TARGET" <<'PY'
#!/usr/bin/env python3

from __future__ import annotations

import os
import sys
from pathlib import Path


def root() -> Path:
    return Path(
        os.environ.get(
            "WL_ROOT",
            Path(__file__).resolve().parents[1],
        )
    ).resolve()


def main() -> int:
    base = root()

    sys.path.insert(
        0,
        str(base / "builder/python/wlplatform"),
    )

    from wlplatform.cli import main as platform_main

    return platform_main(
        sys.argv[1:]
    )


if __name__ == "__main__":
    raise SystemExit(main())
PY

chmod +x "$TARGET"

echo
echo "Platform entrypoint migrated."
echo
echo "Backup created:"
ls -1 "$TARGET.backup."* | tail -1
