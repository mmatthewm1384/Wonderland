#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
OUT="$WL_HOME/vault/08-Operations/reports/runtime-endpoint-certification.md"

mkdir -p "$(dirname "$OUT")"

pass=0
fail=0
warn=0

check() {
  name="$1"
  shift

  if "$@" >/tmp/wl-runtime-check.out 2>&1; then
    echo "PASS $name"
    pass=$((pass+1))
  else
    echo "FAIL $name"
    sed 's/^/  /' /tmp/wl-runtime-check.out
    fail=$((fail+1))
  fi
}

warn_check() {
  name="$1"
  shift

  if "$@" >/tmp/wl-runtime-check.out 2>&1; then
    echo "PASS $name"
    pass=$((pass+1))
  else
    echo "WARN $name"
    sed 's/^/  /' /tmp/wl-runtime-check.out
    warn=$((warn+1))
  fi
}

{
  echo "# Runtime Endpoint Certification"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Checks"
  echo

  check "nerdctl" command -v nerdctl
  check "wl-dns container" nerdctl inspect wl-dns
  check "wl-nats endpoint" curl -fsS http://127.0.0.1:8222/varz
  check "wl-prometheus endpoint" curl -fsS http://127.0.0.1:9090/-/ready
  check "wl-grafana endpoint" curl -fsS http://127.0.0.1:3000/api/health
  warn_check "wl-loki ready endpoint" curl -fsS http://127.0.0.1:3100/ready
  check "wl-loki metrics endpoint" curl -fsS http://127.0.0.1:3100/metrics
  check "wl-dns query" dig @127.0.0.1 -p 1053 grafana.wl +short

  echo
  echo "## Summary"
  echo
  echo "PASS=$pass"
  echo "WARN=$warn"
  echo "FAIL=$fail"
  echo

  if [ "$fail" -eq 0 ]; then
    echo "RESULT PASS"
  else
    echo "RESULT FAIL"
  fi
} | tee "$OUT"

test "$fail" -eq 0
