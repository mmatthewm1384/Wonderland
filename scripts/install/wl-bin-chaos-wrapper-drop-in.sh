#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
WL="$ROOT/bin/wl"
REAL="$ROOT/bin/wl.real.$(date +%Y%m%d-%H%M%S)"
EPH="$ROOT/Wonderland-v4/ephemeral/bin"

mkdir -p "$ROOT/bin"

if [[ ! -f "$WL" ]]; then
  echo "FAIL missing $WL"
  exit 1
fi

if grep -q "WL_CHAOS_WRAPPER_DROP_IN" "$WL"; then
  echo "PASS wrapper already installed"
  exit 0
fi

cp "$WL" "$REAL"

cat > "$WL" <<'SH2'
#!/usr/bin/env bash
set -euo pipefail
# WL_CHAOS_WRAPPER_DROP_IN

ROOT="${WL_ROOT:-$HOME/Wonderland}"
EPH="$ROOT/Wonderland-v4/ephemeral/bin"
REAL_WL="$(ls -1 "$ROOT"/bin/wl.real.* 2>/dev/null | tail -1)"

case "${1:-}" in
  ephemeral)
    shift
    exec "$EPH/wl-ephemeral" "$@"
    ;;

  chaos|chaos-watchdog)
    shift
    exec "$EPH/wl-chaos-watchdog" "$@"
    ;;

  chaos-panic)
    shift
    exec "$EPH/wl-chaos-panic" "$@"
    ;;

  skhd-permissions)
    shift
    exec "$EPH/wl-skhd-permissions" "$@"
    ;;

  visual-chaos)
    shift
    exec "$EPH/wl-visual-chaos" "$@"
    ;;

  governance)
    shift
    case "${1:-}" in
      verify-chaos)
        shift
        exec python3 "$ROOT/Wonderland-v4/governance/verify-chaos.py" "$@"
        ;;
    esac
    ;;&
esac

if [[ -n "$REAL_WL" && -x "$REAL_WL" ]]; then
  exec "$REAL_WL" "$@"
fi

echo "Usage: wl <command>"
exit 2
SH2

chmod +x "$WL"

echo "PASS installed wrapper-safe wl drop-in"
echo "Original preserved as:"
echo "  $REAL"
