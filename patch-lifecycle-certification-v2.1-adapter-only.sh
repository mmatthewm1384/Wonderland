#!/usr/bin/env bash
set -Eeuo pipefail

cd ~/Wonderland

cp \
  bin/wl-runtime-adapter \
  "bin/wl-runtime-adapter.bak.$(date +%Y%m%d-%H%M%S)"

python3 - <<'PY'
from pathlib import Path
import re

path = Path("bin/wl-runtime-adapter")
text = path.read_text()

pattern = re.compile(
    r'''  rootless-runtime:stop\)\n.*?\n  ;;''',
    re.S,
)

match = pattern.search(text)

if not match:
    print("Available rootless references:")
    for line in text.splitlines():
        if "rootless" in line:
            print(repr(line))
    raise SystemExit(
        "rootless-runtime stop case not found"
    )

replacement = '''  rootless-runtime:stop)
    if limactl list | awk '
      $1 == "wonderland-rootless" && $2 == "Stopped" {
        found=1
      }
      END {
        exit(found ? 0 : 1)
      }
    '
    then
      printf 'PASS rootless-runtime already stopped\\\\n'
      exit 0
    fi

    run_first_supported \\
      "rootless-runtime stop" \\
      "bin/wl-rootless|stop" \\
      "bin/wl|rootless|stop"
    ;;'''

path.write_text(
    pattern.sub(
        replacement,
        text,
        count=1,
    )
)

print("rootless-runtime stop patched")
PY

echo "Validating adapter..."

bash -n bin/wl-runtime-adapter

echo "DONE"
