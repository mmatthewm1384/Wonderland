#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

TARGET="$ROOT/bin/wl-platform"

BACKUP="$TARGET.backup.$(date +%Y%m%d-%H%M%S)"

echo "Wonderland Platform CLI Router Drop-In"
echo "======================================"

if [[ -f "$TARGET" ]]; then
    cp "$TARGET" "$BACKUP"
    echo "Backup:"
    echo "  $BACKUP"
fi


cat > "$TARGET" <<'PYTHON'
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

    root_path = root()

    sys.path.insert(
        0,
        str(root_path / "builder/python/wlplatform"),
    )

    from wlplatform.cli import main as platform_main

    argv = sys.argv[1:]

    return platform_main(argv)


if __name__ == "__main__":
    raise SystemExit(main())
PYTHON


chmod +x "$TARGET"


echo
echo "Installed:"
echo "  $TARGET"

echo
echo "Verification:"
"$TARGET" --help

echo
echo "Registry test:"
"$TARGET" engine registry --json >/dev/null

echo "PASS: wl-platform registry route active"
