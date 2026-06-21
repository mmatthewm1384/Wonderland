#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
EPH_HOME="$WL_HOME/runtime/ephemeral"
WL_BIN="$WL_HOME/bin"
VAULT="$WL_HOME/vault"
CATALOG="$VAULT/catalog.json"

mkdir -p \
  "$EPH_HOME/bin" \
  "$EPH_HOME/renders" \
  "$VAULT/renders" \
  "$WL_BIN" \
  "$VAULT/09-Governance/audit"

cat > "$EPH_HOME/manager.py" <<'PY'
#!/usr/bin/env python3
import json, sys, pathlib, subprocess, time

WL_HOME = pathlib.Path.home() / "Wonderland"
EPH_HOME = WL_HOME / "runtime" / "ephemeral"
VAULT = WL_HOME / "vault"
CATALOG = VAULT / "catalog.json"
RENDERS = VAULT / "renders"
STATE = EPH_HOME / "state.json"

DEFAULT = {
    "renders": {
        "wave-agitator": {
            "name": "wave-agitator",
            "type": "ephemeral-render",
            "status": "registered"
        }
    }
}

def load_catalog():
    if not CATALOG.exists():
        CATALOG.write_text(json.dumps(DEFAULT, indent=2) + "\n")
    return json.loads(CATALOG.read_text())

def save_state(data):
    STATE.write_text(json.dumps(data, indent=2) + "\n")

def load_state():
    if STATE.exists():
        return json.loads(STATE.read_text())
    return {"active": None, "last_launch": None}

def cmd_list():
    data = load_catalog()
    for key in sorted(data.get("renders", {})):
        print(key)

def cmd_status():
    print(json.dumps(load_state(), indent=2))

def cmd_doctor():
    fail = 0
    checks = [
        ("ephemeral-home", EPH_HOME.is_dir()),
        ("vault", VAULT.is_dir()),
        ("renders", RENDERS.is_dir()),
        ("catalog", CATALOG.exists()),
    ]
    for name, ok in checks:
        print(("PASS " if ok else "FAIL ") + name)
        if not ok:
            fail = 1
    print("RESULT PASS" if fail == 0 else "RESULT FAIL")
    sys.exit(fail)

def cmd_launch(name):
    data = load_catalog()
    if name not in data.get("renders", {}):
        print(f"FAIL unknown render: {name}")
        sys.exit(1)
    state = load_state()
    state["active"] = name
    state["last_launch"] = time.strftime("%Y-%m-%dT%H:%M:%S%z")
    save_state(state)
    print(f"PASS launched {name}")

def cmd_repair():
    EPH_HOME.mkdir(parents=True, exist_ok=True)
    RENDERS.mkdir(parents=True, exist_ok=True)
    if not CATALOG.exists():
        CATALOG.write_text(json.dumps(DEFAULT, indent=2) + "\n")
    if not STATE.exists():
        save_state({"active": None, "last_launch": None})
    print("RESULT PASS")

def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "help"
    if cmd == "list":
        cmd_list()
    elif cmd == "status":
        cmd_status()
    elif cmd == "doctor":
        cmd_doctor()
    elif cmd == "launch":
        if len(sys.argv) < 3:
            print("usage: wl ephemeral launch <name>")
            sys.exit(2)
        cmd_launch(sys.argv[2])
    elif cmd == "repair":
        cmd_repair()
    else:
        print("wl ephemeral list|doctor|launch <name>|status|repair")
        sys.exit(2)

if __name__ == "__main__":
    main()
PY

chmod +x "$EPH_HOME/manager.py"

cat > "$EPH_HOME/bin/wl-ephemeral" <<EOF2
#!/usr/bin/env bash
set -euo pipefail
exec "$EPH_HOME/manager.py" "\$@"
EOF2

chmod +x "$EPH_HOME/bin/wl-ephemeral"

ln -sf "$EPH_HOME/bin/wl-ephemeral" "$WL_BIN/wl-ephemeral"

if [[ ! -f "$CATALOG" ]]; then
  cat > "$CATALOG" <<'JSON'
{
  "renders": {
    "wave-agitator": {
      "name": "wave-agitator",
      "type": "ephemeral-render",
      "status": "registered"
    }
  }
}
JSON
fi

"$WL_BIN/wl-ephemeral" repair
"$WL_BIN/wl-ephemeral" doctor

echo "RESULT PASS"
