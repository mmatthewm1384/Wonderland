#!/usr/bin/env python3
from __future__ import annotations

import json
import sys

from wl.runtime.state.status import status_path


def main() -> int:
    path = status_path()
    if not path.exists():
        print(f"FAIL: runtime status missing: {path}", file=sys.stderr)
        return 1

    payload = json.loads(path.read_text())
    print(json.dumps(payload, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
