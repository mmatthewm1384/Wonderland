#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WL_BIN="$WL_HOME/bin"
WL_VAULT="$WL_HOME/vault"

mkdir -p "$WL_BIN" "$WL_VAULT/01-intents"

cat > "$WL_BIN/wl-obsidian" <<'EOS'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WL_VAULT="$WL_HOME/vault"

case "${1:-}" in
  verify)
    test -d "$WL_VAULT" && echo "PASS vault" || { echo "FAIL vault"; exit 1; }
    test -d "$WL_VAULT/01-intents" && echo "PASS intents" || { echo "FAIL intents"; exit 1; }
    echo "RESULT PASS"
    ;;
  list)
    find "$WL_VAULT/01-intents" -name '*.intent.json' -maxdepth 1 -print | sort
    ;;
  run)
    name="${2:-}"
    file="$WL_VAULT/01-intents/$name.intent.json"
    test -f "$file" || { echo "FAIL missing intent: $file"; exit 1; }
    cmd="$(python3 - "$file" <<'PY'
import json, sys
print(json.load(open(sys.argv[1]))["command"])
PY
)"
    bash -lc "$cmd"
    ;;
  *)
    echo "usage: wl-obsidian verify | list | run <intent>"
    ;;
esac
EOS

chmod +x "$WL_BIN/wl-obsidian"

cat > "$WL_VAULT/01-intents/universe-status.intent.json" <<EOF_JSON
{
  "name": "universe-status",
  "command": "$WL_HOME/bin/wl universe status"
}
EOF_JSON

"$WL_BIN/wl-obsidian" verify
