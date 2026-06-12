#!/usr/bin/env bash
# core/chaos.sh: Active failure simulator

set -euo pipefail

trigger_disruption() {
    local type="${1:-minor}"
    echo "[!] Injecting targeted failure scenario: [$type]"

    if [ "$type" = "critical" ]; then
        # Kill the event loop and poison the tracking state token
        if [ -f "${WONDERLAND_ROOT}/core/.bus.pid" ]; then
            kill -9 "$(cat "${WONDERLAND_ROOT}/core/.bus.pid")" 2>/dev/null || true
            rm -f "${WONDERLAND_ROOT}/core/.bus.pid"
        fi
        touch "${WONDERLAND_ROOT}/core/.mock_fail"
        echo "CRITICAL_INFRASTRUCTURE_FAILURE" > "${WONDERLAND_ROOT}/core/.event_bus" 2>/dev/null || true
    else
        # Minor: Kill event process tracking silently
        if [ -f "${WONDERLAND_ROOT}/core/.bus.pid" ]; then
            kill -9 "$(cat "${WONDERLAND_ROOT}/core/.bus.pid")" 2>/dev/null || true
        fi
    fi
}

if [ "${1:-}" = "trigger" ]; then
    trigger_disruption "${2:-minor}"
fi
