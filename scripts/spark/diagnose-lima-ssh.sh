#!/bin/sh
set -eu

# Read-only diagnostic for a Lima Spark VM. It does not mutate the VM or host.
# Usage: ./scripts/spark/diagnose-lima-ssh.sh [instance-name]

NAME="${1:-spark-matthew-001}"

printf '%s\n' "=== Spark/Lima SSH Diagnostic ==="
printf 'instance: %s\n' "$NAME"
printf 'time: '; date -u '+%Y-%m-%dT%H:%M:%SZ'
printf '\n--- Lima ---\n'
limactl --version || true
limactl list || true

DIR="$HOME/.lima/$NAME"
printf '\n--- Lima directory ---\n'
printf 'dir: %s\n' "$DIR"
if [ -d "$DIR" ]; then
  ls -la "$DIR" || true
else
  printf '%s\n' 'MISSING: Lima instance directory'
  exit 1
fi

printf '\n--- Generated configuration ---\n'
if [ -f "$DIR/lima.yaml" ]; then
  sed -n '1,240p' "$DIR/lima.yaml"
else
  printf '%s\n' 'MISSING: lima.yaml'
fi

printf '\n--- SSH configuration ---\n'
if [ -f "$DIR/ssh.config" ]; then
  sed -n '1,200p' "$DIR/ssh.config"
else
  printf '%s\n' 'MISSING: ssh.config'
fi

printf '\n--- Host-agent stderr: transport failures ---\n'
if [ -f "$DIR/ha.stderr.log" ]; then
  grep -E 'no route to host|connection reset|Failed to wait for guest SSH|tcpproxy|kex_exchange|ssh' "$DIR/ha.stderr.log" | tail -100 || true
else
  printf '%s\n' 'MISSING: ha.stderr.log'
fi

printf '\n--- Host-agent stdout ---\n'
if [ -f "$DIR/ha.stdout.log" ]; then
  tail -100 "$DIR/ha.stdout.log" || true
fi

printf '\n--- Serial logs ---\n'
for f in "$DIR/serial.log" "$DIR/serialv.log"; do
  if [ -f "$f" ]; then
    printf '\n[%s]\n' "$f"
    tail -100 "$f" || true
  fi
done

printf '\n--- Host port ---\n'
PORT=""
if [ -f "$DIR/ssh.config" ]; then
  PORT="$(awk '$1 == "Port" {print $2; exit}' "$DIR/ssh.config")"
fi
if [ -n "$PORT" ]; then
  printf 'ssh-local-port: %s\n' "$PORT"
  if command -v nc >/dev/null 2>&1; then
    nc -vz 127.0.0.1 "$PORT" 2>&1 || true
  fi
fi

printf '\n=== Interpretation ===\n'
printf '%s\n' 'If tcpproxy reports "no route to host" for the guest address, SSH authentication has not been reached. Investigate guest networking/SSH reachability before changing keys or authorized_keys.'
printf '%s\n' 'This script is intentionally read-only. Use it to collect evidence before making a repair.'
