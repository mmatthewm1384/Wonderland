#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_HOME:-$PWD}"

cd "$ROOT"

echo "Creating adapter backup..."

cp \
  bin/wl-runtime-adapter \
  "bin/wl-runtime-adapter.bak.$(date +%Y%m%d-%H%M%S)"

echo "Patching rootless stop idempotency..."

python3 - <<'PY'
from pathlib import Path

path = Path("bin/wl-runtime-adapter")
text = path.read_text()

start = text.index("  rootless-runtime:stop)")
end = text.index("\n  ;;", start) + len("\n  ;;")

replacement = r'''  rootless-runtime:stop)
    if limactl list | awk '
      $1 == "wonderland-rootless" && $2 == "Stopped" {
        found=1
      }
      END {
        exit(found ? 0 : 1)
      }
    '
    then
      printf 'PASS rootless-runtime already stopped\n'
      exit 0
    fi

    run_first_supported \
      "rootless-runtime stop" \
      "bin/wl-rootless|stop" \
      "bin/wl|rootless|stop"
    ;;'''

path.write_text(
    text[:start] +
    replacement +
    text[end:]
)

print("adapter patched")
PY


echo "Adding timeout protection..."

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlruntime/wlruntime/engine.py"
)

text = path.read_text()

if "timeout=command.timeout_seconds" in text:
    print("timeout already present")
    raise SystemExit(0)

old = """        completed = subprocess.run(
            list(command.argv),
            cwd=self.root,
            text=True,
            capture_output=True,
            check=False,
        )
"""

new = """        try:
            completed = subprocess.run(
                list(command.argv),
                cwd=self.root,
                text=True,
                capture_output=True,
                timeout=command.timeout_seconds,
                check=False,
            )
        except subprocess.TimeoutExpired as exc:
            return {
                "status": "FAIL",
                "argv": list(command.argv),
                "returncode": None,
                "error": (
                    f"command timeout after "
                    f"{command.timeout_seconds}s"
                ),
                "stdout": exc.stdout or "",
                "stderr": exc.stderr or "",
                "finished_at": utc_now(),
            }
"""

if old not in text:
    raise SystemExit(
        "engine subprocess block not found"
    )

path.write_text(text.replace(old, new))

print("engine patched")
PY


echo "Compile validation..."

python3 -m compileall \
  builder/python/wlruntime/wlruntime


echo "Regression validation..."

PYTHONPATH=builder/python/wlruntime \
python3 -m wlruntime.cli \
--root "$ROOT" \
self-test

echo "Lifecycle Certification v2.1 patch complete."
