#!/usr/bin/env bash
set -Eeuo pipefail

FILE="bin/wl-runtime-adapter"

echo "Creating backup..."
cp "$FILE" "${FILE}.bak.$(date +%Y%m%d-%H%M%S)"

echo "Patching rootless-runtime stop reconciliation..."

python3 - <<'PY'
from pathlib import Path

path = Path("bin/wl-runtime-adapter")

text = path.read_text()

old = '''  rootless-runtime:stop)
    run_first_supported \\
      "rootless-runtime stop" \\
      "bin/wl-rootless|stop" \\
      "bin/wl|rootless|stop"
    ;;
'''

new = '''  rootless-runtime:stop)
    lima_status="$(
      limactl list --format '{{.Name}} {{.Status}}' 2>/dev/null \\
      | awk '$1 == "wonderland-rootless" { print $2 }'
    )"

    case "$lima_status" in
      Running)
        run_first_supported \\
          "rootless-runtime stop" \\
          "bin/wl-rootless|stop" \\
          "bin/wl|rootless|stop"
        ;;

      Stopped)
        printf 'PASS rootless-runtime already stopped\\\\n'
        ;;

      "")
        printf 'PASS rootless-runtime unavailable (already stopped)\\\\n'
        ;;

      *)
        fail "rootless-runtime unexpected external state: $lima_status"
        ;;
    esac
    ;;
'''

if old not in text:
    raise SystemExit("target block not found")

path.write_text(text.replace(old, new))

PY

chmod +x "$FILE"

echo "Patch applied."

echo
echo "Validation:"
bash -n bin/wl-runtime-adapter

echo "PASS"
