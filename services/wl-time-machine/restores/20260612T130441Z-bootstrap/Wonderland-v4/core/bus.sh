#!/usr/bin/env bash
# core/bus.sh: IPC Event Bus Handler

set -euo pipefail

BUS_PIPE="${WONDERLAND_ROOT}/core/.event_bus"
LOG_FILE="${WONDERLAND_ROOT}/core/bus.log"
PID_FILE="${WONDERLAND_ROOT}/core/.bus.pid"

init_bus() {
    if [ ! -p "$BUS_PIPE" ]; then
        rm -f "$BUS_PIPE"
        mkfifo "$BUS_PIPE"
    fi

    # Avoid duplicate listeners
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        return 0
    fi

    exec 3<>"$BUS_PIPE"
    while read -r line <&3; do
        timestamp=$(date +%s)
        echo "[$timestamp] $line" >> "$LOG_FILE"
        if [[ "$line" == *"CRITICAL"* ]]; then
            # Autonomously invoke repair loop on structural alerts
            "${WONDERLAND_ROOT}/core/repair.sh" run >/dev/null 2>&1 &
        fi
    done &
    echo $! > "$PID_FILE"
}

if [ "${1:-}" = "init" ]; then
    init_bus
fi
