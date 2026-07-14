#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_HOME:-$HOME/Wonderland}"

cd "$ROOT"

TARGET="builder/python/wlruntime/wlruntime/certification.py"

if [[ ! -f "$TARGET" ]]; then
  echo "missing certification.py"
  exit 1
fi

BACKUP="${TARGET}.bak.$(date +%Y%m%d%H%M%S)"

echo "Backing up:"
echo "$TARGET"
cp "$TARGET" "$BACKUP"

python3 - <<'PY'
from pathlib import Path

path = Path("builder/python/wlruntime/wlruntime/certification.py")
text = path.read_text()

old = '''        except Exception as exc:
            checks["certification_execution"] = False
            errors.append(
                f"{type(exc).__name__}: {exc}"
            )

            self._best_effort_cleanup(
                evidence_root=evidence_root,
            )
'''

new = '''        except Exception as exc:
            import traceback

            checks["certification_execution"] = False

            errors.append(
                f"{type(exc).__name__}: {exc}"
            )

            errors.append(
                traceback.format_exc()
            )

            write_json(
                evidence_root / "exception-traceback.json",
                {
                    "type": type(exc).__name__,
                    "message": str(exc),
                    "traceback": traceback.format_exc(),
                },
            )

            self._best_effort_cleanup(
                evidence_root=evidence_root,
            )
'''

if old not in text:
    raise SystemExit("exception handler marker not found")

text = text.replace(old,new,1)

path.write_text(text)

print("patched certification traceback")
PY

python3 -m compileall \
builder/python/wlruntime/wlruntime

echo
echo "Complete."
echo "Run:"
echo
echo "wl runtime certify --mode full"
