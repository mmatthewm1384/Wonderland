#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WL_BIN="$WL_HOME/bin/wl"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$WL_HOME/vault/08-Operations/backups/bin-wl/$STAMP"

mkdir -p "$WL_HOME/bin" "$BACKUP_DIR"

[[ -f "$WL_BIN" ]] && cp "$WL_BIN" "$BACKUP_DIR/wl.backup"

cat > "$WL_BIN" <<'WL'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
export WL_HOME

cmd="${1:-help}"
shift || true

die() {
  echo "wl: $*" >&2
  exit 1
}

run_if_exists() {
  local target="$1"
  shift
  [[ -x "$target" ]] && exec "$target" "$@"
  return 1
}

case "$cmd" in
  help|-h|--help)
    cat <<'HELP'
Wonderland command surface

Usage:
  wl help
  wl doctor
  wl status
  wl universe status|doctor|dashboard
  wl storage status|attach|attach-light|attach-full|eject|force-eject|verify|doctor|authority
  wl governance doctor|verify|status
  wl runtime start|stop|status|doctor
  wl repair doctor
HELP
    ;;

  doctor)
    "$WL_HOME/bin/wl" storage doctor || true
    "$WL_HOME/bin/wl" universe status || true
    ;;

  status)
    "$WL_HOME/bin/wl" universe status
    ;;

  storage)
    sub="${1:-status}"
    shift || true
    case "$sub" in
      attach-light) exec "$WL_HOME/bin/wl-storage" attach --light "$@" ;;
      attach-full)  exec "$WL_HOME/bin/wl-storage" attach --full "$@" ;;
      *)            exec "$WL_HOME/bin/wl-storage" "$sub" "$@" ;;
    esac
    ;;

  universe)
    run_if_exists "$WL_HOME/bin/wl-universe" "$@" || die "wl-universe not found"
    ;;

  governance)
    run_if_exists "$WL_HOME/bin/wl-governance" "$@" || die "wl-governance not found"
    ;;

  runtime)
    run_if_exists "$WL_HOME/bin/wl-runtime" "$@" || die "wl-runtime not found"
    ;;

  repair)
    echo "WL_HOME=$WL_HOME"
    echo "wl=$(command -v wl || true)"
    echo "canonical=$WL_HOME/bin/wl"
    ls -l "$WL_HOME/bin/wl"
    type wl || true
    ;;

  *)
    candidate="$WL_HOME/bin/wl-$cmd"
    [[ -x "$candidate" ]] && exec "$candidate" "$@"
    die "unknown wl command: $cmd"
    ;;
esac
WL

chmod +x "$WL_BIN"

echo "PASS fixed $WL_BIN"
echo "Backup: $BACKUP_DIR"
