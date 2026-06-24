#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
EPH="$ROOT/Wonderland-v4/ephemeral"
BIN="$EPH/bin"
WATCH="$EPH/chaos-watchdog"
VAULT="$ROOT/vault"
CHAOS="$VAULT/chaos"

mkdir -p "$BIN" "$WATCH" "$CHAOS" "$VAULT/renders"

cat > "$WATCH/chaos_watchdog.py" <<'PY'
#!/usr/bin/env python3
from __future__ import annotations

import json, os, signal, subprocess, sys, time
from datetime import datetime, timezone, timedelta
from pathlib import Path

ROOT = Path(os.environ.get("WL_ROOT", str(Path.home() / "Wonderland"))).expanduser()
EPH = ROOT / "Wonderland-v4" / "ephemeral"
BIN = EPH / "bin"
VAULT = ROOT / "vault"
RUNS = VAULT / "ephemeral-runs.log"
CHAOS = VAULT / "chaos"
AETHER = CHAOS / "chaos-aether.json"
PIDFILE = CHAOS / "chaos-watchdog.pid"
LOG = CHAOS / "watchdog.log"

VISUALS = [
    "wave-agitator",
    "matrix-atom-slam",
    "counter-rotate-city-wave",
    "slam-waste-eliminator",
]

running = True


def utc():
    return datetime.now(timezone.utc)


def iso():
    return utc().isoformat()


def write_log(msg):
    CHAOS.mkdir(parents=True, exist_ok=True)
    with LOG.open("a") as f:
        f.write(f"{iso()} {msg}\n")
    print(msg, flush=True)


def append_event(event, payload):
    VAULT.mkdir(parents=True, exist_ok=True)
    with RUNS.open("a") as f:
        f.write(json.dumps({
            "recorded_at": iso(),
            "valid_at": iso(),
            "event": event,
            "payload": payload,
        }, sort_keys=True) + "\n")


def read_aether():
    if not AETHER.exists():
        return None
    try:
        return json.loads(AETHER.read_text())
    except Exception as e:
        append_event("aether_read_failed", {"error": str(e)})
        return None


def write_aether(reason):
    CHAOS.mkdir(parents=True, exist_ok=True)
    record = {
        "version": "1.4",
        "mode": "permanent_high_chaos",
        "activated_at": iso(),
        "last_reapplied": iso(),
        "reason": reason,
        "threshold_hours": float(os.environ.get("CHAOS_THRESHOLD_HOURS", "6")),
        "retrigger_interval_min": float(os.environ.get("CHAOS_RETRIGGER_MIN", "30")),
        "escalated_visuals": VISUALS,
        "recovery": "Run wl-chaos-watchdog up or repair after wake/reboot. Run wl-chaos-watchdog reset to clear.",
    }
    AETHER.write_text(json.dumps(record, indent=2, sort_keys=True))
    append_event("aether_activated", record)
    return record


def update_aether_reapplied(reason):
    record = read_aether()
    if not record:
        record = write_aether(reason)
    record["last_reapplied"] = iso()
    record["last_reapply_reason"] = reason
    AETHER.write_text(json.dumps(record, indent=2, sort_keys=True))
    append_event("aether_reapplied", record)


def manager_launch(name, chaos=True):
    cmd = [str(BIN / "wl-ephemeral"), "launch", name]
    if chaos:
        cmd.append("--chaos")
    subprocess.run(cmd, check=False)


def escalate(reason):
    write_log(f"Escalating chaos: {reason}")
    write_aether(reason)
    manager_launch("chaos-escalator", chaos=True)
    update_aether_reapplied(reason)


def reapply_from_aether(reason):
    if not read_aether():
        return
    write_log(f"Reapplying from aether: {reason}")
    manager_launch("chaos-escalator", chaos=True)
    update_aether_reapplied(reason)


def last_activity():
    if not RUNS.exists():
        return None
    last = None
    for line in RUNS.read_text(errors="ignore").splitlines()[-500:]:
        try:
            obj = json.loads(line)
            ts = obj.get("recorded_at") or obj.get("valid_at")
            if ts:
                last = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        except Exception:
            continue
    return last


def detect_power_event():
    if sys.platform != "darwin":
        return None
    try:
        out = subprocess.check_output(["pmset", "-g", "log"], text=True, timeout=10, errors="ignore")
    except Exception:
        return None

    keys = ("Sleep", "Wake", "DarkWake", "Standby", "AC Power", "Battery Power")
    lines = [x for x in out.splitlines() if any(k in x for k in keys)]
    if not lines:
        return None
    return lines[-1][-500:]


def status_once():
    CHAOS.mkdir(parents=True, exist_ok=True)
    threshold = float(os.environ.get("CHAOS_THRESHOLD_HOURS", "6"))
    retrigger = float(os.environ.get("CHAOS_RETRIGGER_MIN", "30"))
    aether = read_aether()
    last = last_activity()
    age = None if last is None else (utc() - last).total_seconds() / 3600
    power = detect_power_event()

    print(f"Chaos watchdog: OK")
    print(f"AETHER MEMORY: {'ACTIVE' if aether else 'inactive'}")
    print(f"Aether path: {AETHER}")
    print(f"Threshold hours: {threshold}")
    print(f"Retrigger minutes: {retrigger}")
    print(f"Last activity hours ago: {age if age is not None else 'unknown'}")
    print(f"Recent power event: {power or 'none detected'}")

    if aether:
        print(f"Mode: {aether.get('mode')}")
        print(f"Last reapplied: {aether.get('last_reapplied')}")
        print(f"Visuals: {', '.join(aether.get('escalated_visuals', []))}")

    append_event("chaos_watchdog_doctor", {
        "aether_active": bool(aether),
        "threshold_hours": threshold,
        "last_activity_hours": age,
        "power_event": power,
    })


def reset():
    if AETHER.exists():
        AETHER.unlink()
    append_event("chaos_reset", {"aether_removed": True})
    write_log("Aether reset complete")


def handle_signal(signum, frame):
    global running
    running = False
    write_log(f"Received signal {signum}; shutting down gracefully")


def main_loop():
    signal.signal(signal.SIGTERM, handle_signal)
    signal.signal(signal.SIGINT, handle_signal)

    CHAOS.mkdir(parents=True, exist_ok=True)
    PIDFILE.write_text(str(os.getpid()))

    threshold = float(os.environ.get("CHAOS_THRESHOLD_HOURS", "6"))
    retrigger_min = float(os.environ.get("CHAOS_RETRIGGER_MIN", "30"))

    power = detect_power_event()
    if power:
        append_event("power_event_detected", {"event": power})
        if read_aether():
            reapply_from_aether("power_loss_recovery")

    if read_aether():
        reapply_from_aether("watchdog_startup")

    last_retrigger = utc()

    while running:
        aether = read_aether()
        last = last_activity()
        age = None if last is None else (utc() - last).total_seconds() / 3600

        if aether:
            if (utc() - last_retrigger).total_seconds() >= retrigger_min * 60:
                reapply_from_aether("scheduled_aether_retrigger")
                last_retrigger = utc()
        elif age is None or age >= threshold:
            escalate("inactivity_threshold_breached")
            last_retrigger = utc()

        time.sleep(60)

    try:
        PIDFILE.unlink()
    except FileNotFoundError:
        pass


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "run"
    if cmd == "run":
        main_loop()
    elif cmd == "doctor":
        status_once()
    elif cmd == "aether-status":
        a = read_aether()
        print(json.dumps(a or {"active": False}, indent=2, sort_keys=True))
    elif cmd == "reset":
        reset()
    elif cmd == "escalate":
        escalate("manual")
    else:
        raise SystemExit(f"unknown command: {cmd}")
PY

cat > "$BIN/wl-chaos-watchdog" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
EPH="$ROOT/Wonderland-v4/ephemeral"
WATCH="$EPH/chaos-watchdog/chaos_watchdog.py"
CHAOS="$ROOT/vault/chaos"
PID="$CHAOS/chaos-watchdog.pid"
LOG="$CHAOS/watchdog.log"

mkdir -p "$CHAOS"

case "${1:-status}" in
  up)
    if [[ -f "$PID" ]] && kill -0 "$(cat "$PID")" 2>/dev/null; then
      echo "chaos-watchdog already running: $(cat "$PID")"
      exit 0
    fi
    nohup python3 "$WATCH" run >> "$LOG" 2>&1 &
    echo $! > "$PID"
    echo "chaos-watchdog started: $!"
    ;;
  down)
    if [[ -f "$PID" ]]; then
      P="$(cat "$PID")"
      kill "$P" 2>/dev/null || true
      sleep 2
      kill -9 "$P" 2>/dev/null || true
      rm -f "$PID"
    fi
    echo "chaos-watchdog stopped"
    ;;
  status)
    if [[ -f "$PID" ]] && kill -0 "$(cat "$PID")" 2>/dev/null; then
      echo "chaos-watchdog running: $(cat "$PID")"
    else
      echo "chaos-watchdog stopped"
    fi
    python3 "$WATCH" aether-status
    ;;
  doctor)
    python3 "$WATCH" doctor
    ;;
  logs)
    tail -80 "$LOG" 2>/dev/null || true
    ;;
  repair)
    if [[ -f "$PID" ]] && ! kill -0 "$(cat "$PID")" 2>/dev/null; then
      rm -f "$PID"
    fi
    "$0" up
    python3 "$WATCH" doctor
    ;;
  reset)
    "$0" down || true
    python3 "$WATCH" reset
    ;;
  aether-status)
    python3 "$WATCH" aether-status
    ;;
  escalate)
    python3 "$WATCH" escalate
    ;;
  *)
    echo "Usage: wl-chaos-watchdog up|down|status|doctor|logs|repair|reset|aether-status|escalate"
    exit 2
    ;;
esac
SH

cat > "$BIN/wl-chaos-panic" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
CHAOS="$ROOT/vault/chaos"
RUNS="$ROOT/vault/ephemeral-runs.log"
PID="$CHAOS/chaos-watchdog.pid"

FORCE=false
REASON="manual panic"

for arg in "$@"; do
  case "$arg" in
    --force|-y) FORCE=true ;;
    *) REASON="$arg" ;;
  esac
done

if [[ "$FORCE" != true ]]; then
  read -r -p "Emergency panic will stop watchdog and wipe aether. Continue? [y/N] " ans
  [[ "$ans" == "y" || "$ans" == "Y" ]] || exit 1
fi

mkdir -p "$CHAOS" "$(dirname "$RUNS")"

if [[ -f "$PID" ]]; then
  P="$(cat "$PID")"
  kill "$P" 2>/dev/null || true
  sleep 1
  kill -9 "$P" 2>/dev/null || true
  rm -f "$PID"
fi

rm -f "$CHAOS/chaos-aether.json" "$CHAOS/chaos.flag"

python3 - "$RUNS" "$REASON" "$FORCE" <<'PY'
import json, sys
from datetime import datetime, timezone
path, reason, forced = sys.argv[1], sys.argv[2], sys.argv[3]
record = {
  "recorded_at": datetime.now(timezone.utc).isoformat(),
  "valid_at": datetime.now(timezone.utc).isoformat(),
  "event": "EMERGENCY_PANIC",
  "payload": {"reason": reason, "forced": forced == "true"}
}
with open(path, "a") as f:
    f.write(json.dumps(record, sort_keys=True) + "\n")
PY

echo "Emergency panic complete. Aether cleared."
SH

cat > "$BIN/wl-skhd-permissions" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

SKHD_BIN="$(command -v skhd 2>/dev/null || echo /opt/homebrew/bin/skhd)"

echo "skhd path: $SKHD_BIN"
echo "Opening System Settings → Privacy & Security → Accessibility..."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

if [[ -x "$SKHD_BIN" ]]; then
  echo "If skhd is not listed, add:"
  echo "$SKHD_BIN"
else
  echo "skhd binary not found. Install with: brew install skhd"
fi
SH

chmod +x "$WATCH/chaos_watchdog.py" "$BIN/wl-chaos-watchdog" "$BIN/wl-chaos-panic" "$BIN/wl-skhd-permissions"

cat > "$HOME/.skhdrc" <<'SH'
# Wonderland Emergency Panic Hotkey
cmd + ctrl + alt + shift - p : export PATH="$HOME/Wonderland/Wonderland-v4/ephemeral/bin:$PATH"; wl-chaos-panic --force "Global hotkey panic triggered"

# Reload skhd config
cmd + ctrl + alt + shift - r : skhd --reload
SH

echo "Installed chaos/aether/panic layer."
echo ""
echo "Add to PATH:"
echo "export PATH=\"\$HOME/Wonderland/Wonderland-v4/ephemeral/bin:\$PATH\""
echo ""
echo "Verify:"
echo "wl-chaos-watchdog doctor"
echo "wl-chaos-watchdog up"
