#!/usr/bin/env python3
from __future__ import annotations

import json, os, signal, subprocess, sys, time
from datetime import datetime, timezone, timedelta
from pathlib import Path

ROOT = Path(os.environ.get("WL_ROOT", str(Path.home() / "Wonderland"))).expanduser()
EPH = ROOT / "ephemeral"
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
    subprocess.run([str(BIN / "wl-visual-chaos"), "launch-all"], check=False)
    update_aether_reapplied(reason)


def reapply_from_aether(reason):
    if not read_aether():
        return
    write_log(f"Reapplying from aether: {reason}")
    manager_launch("chaos-escalator", chaos=True)
    subprocess.run([str(BIN / "wl-visual-chaos"), "launch-all"], check=False)
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



def operator_checkin():
    append_event("operator_checkin", {"source": "manual"})
    write_log("Operator check-in recorded; inactivity timer reset")


def countdown():
    threshold = float(os.environ.get("CHAOS_THRESHOLD_HOURS", "6"))
    last = last_activity()
    if last is None:
        print("No activity recorded.")
        print(f"Threshold: {threshold}h")
        print("Escalation: eligible now")
        return

    age_hours = (utc() - last).total_seconds() / 3600
    remaining = max(0, threshold - age_hours)

    print(f"Threshold: {threshold:.2f}h")
    print(f"Last activity: {age_hours:.2f}h ago")
    print(f"Escalation in: {remaining:.2f}h")
    print(f"Escalation eligible: {'YES' if remaining <= 0 else 'NO'}")

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
    elif cmd == "checkin":
        operator_checkin()
    elif cmd == "countdown":
        countdown()
    elif cmd == "escalate":
        escalate("manual")
    else:
        raise SystemExit(f"unknown command: {cmd}")
