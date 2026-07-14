#!/usr/bin/env python3
from pathlib import Path

ROOT = Path.cwd()
paths = sorted((ROOT / "bin").glob("wl*"))

failed = 0

for path in paths:
    if not path.is_file():
        continue

    text = path.read_text(errors="ignore")
    if "$ROOT" not in text:
        continue

    has_root_default = 'ROOT="${ROOT:-' in text or "ROOT=${ROOT:-" in text
    has_bootstrap = "bootstrap.sh" in text

    if has_bootstrap and not has_root_default:
        print(f"FAIL missing ROOT default: {path}")
        failed += 1

print()
print("RESULT", "FAIL" if failed else "PASS")
raise SystemExit(1 if failed else 0)
