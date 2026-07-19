#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"
cd "$WL_ROOT"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP_DIR="vault/08-Operations/backups/certification-root-fix-${STAMP}"

TARGET="builder/python/wlplatform/wlplatform/certification/__init__.py"

echo "== Certification Root Resolution Fix v1.1.2 =="

if [[ ! -f "$TARGET" ]]; then
    echo "ERROR: Missing:"
    echo "$TARGET"
    exit 1
fi

mkdir -p "$BACKUP_DIR"
cp "$TARGET" "$BACKUP_DIR/"

echo "Backup:"
echo "$BACKUP_DIR"

python3 <<'PY'
from pathlib import Path
import re

path = Path(
    "builder/python/wlplatform/wlplatform/certification/__init__.py"
)

text = path.read_text()

# Find resolve_root function boundaries
match = re.search(
    r"def resolve_root\(.*?\n(?=def |\Z)",
    text,
    flags=re.S
)

if not match:
    raise SystemExit(
        "Could not locate resolve_root()"
    )

old_func = match.group(0)

print("Found existing resolver:")
print(old_func[:500])

# Preserve indentation style but replace resolver authority logic
new_func = """def resolve_root(*args, **kwargs):
    \"\"\"
    Resolve Wonderland root.

    Priority:
    1. Explicit root argument
    2. Environment/discovery
    \"\"\"

    if kwargs.get(\"root\"):
        return Path(kwargs[\"root\"]).resolve()

    candidates = []

    env_root = os.environ.get(\"WL_ROOT\")
    if env_root:
        candidates.append(Path(env_root))

    candidates.extend(discover_root_candidates())

    for candidate in candidates:
        candidate = candidate.resolve()

        if (
            (candidate / \"vault\").exists()
            and
            (candidate / \"builder\").exists()
        ):
            return candidate

    raise RuntimeError(
        \"Unable to resolve Wonderland root\"
    )

"""

text = text.replace(old_func, new_func, 1)

path.write_text(text)

print()
print("Updated:")
print(path)
PY


echo
echo "== Verification =="

grep -n "Explicit root argument" "$TARGET"
grep -n "kwargs.get(\"root\")" "$TARGET"


echo
echo "== Syntax Check =="

python3 -m py_compile "$TARGET"

echo
echo "PASS: certification root resolver patched"
echo "Backup:"
echo "$BACKUP_DIR"
