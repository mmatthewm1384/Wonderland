#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
SERVICE="$WL_HOME/services/wl-theomatrix"
BIN="$WL_HOME/bin"
ROOT="$WL_HOME/vault/01-Projects/THEOMATRIX"
BACKUP="$WL_HOME/.backup-theomatrix-v31-$(date +%Y%m%d-%H%M%S)"

echo "== THE∅MATRIX v3.1 modular runtime =="
echo "WL_HOME=$WL_HOME"
echo "SERVICE=$SERVICE"
echo "ROOT=$ROOT"
echo "BACKUP=$BACKUP"

mkdir -p "$BACKUP"
[ -f "$BIN/wl-theomatrix" ] && cp "$BIN/wl-theomatrix" "$BACKUP/wl-theomatrix"

mkdir -p \
  "$SERVICE/bin" \
  "$SERVICE/lib" \
  "$SERVICE/commands" \
  "$SERVICE/config" \
  "$BIN" \
  "$ROOT"/{canon,memory,intelligence,simulation,observatory,runtime,reports,registries,certification,graph}

cat > "$SERVICE/lib/env.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
THEOMATRIX_ROOT="${THEOMATRIX_ROOT:-$WL_HOME/vault/01-Projects/THEOMATRIX}"
THEOMATRIX_SERVICE="${THEOMATRIX_SERVICE:-$WL_HOME/services/wl-theomatrix}"
THEOMATRIX_CONFIG="$THEOMATRIX_SERVICE/config/theomatrix.json"
THEOMATRIX_VERSION="3.1"
THEOMATRIX_PROJECT="THE∅MATRIX"

ensure_core_dirs() {
  mkdir -p "$THEOMATRIX_ROOT"/{canon,memory,intelligence,simulation,observatory,runtime,reports,registries,certification,graph}
}
SH

cat > "$SERVICE/lib/json.sh" <<'SH'
#!/usr/bin/env bash
json_pretty() {
  python3 -m json.tool "$1"
}
SH

cat > "$SERVICE/lib/doctor.sh" <<'SH'
#!/usr/bin/env bash
doctor_dirs() {
  local result=0
  for d in canon memory intelligence simulation observatory runtime reports registries certification graph; do
    if [ -d "$THEOMATRIX_ROOT/$d" ]; then
      echo "PASS $d"
    else
      echo "FAIL $d"
      result=1
    fi
  done
  return "$result"
}
SH

cat > "$SERVICE/lib/registry.sh" <<'SH'
#!/usr/bin/env bash
ensure_registry() {
  local path="$1"
  local schema="$2"
  mkdir -p "$(dirname "$path")"
  if [ ! -f "$path" ]; then
    cat > "$path" <<JSON
{
  "schema": "$schema",
  "version": "$THEOMATRIX_VERSION",
  "records": []
}
JSON
  fi
}
SH

cat > "$SERVICE/config/theomatrix.json" <<JSON
{
  "project": "THE∅MATRIX",
  "version": "3.1",
  "status": "OPERATIONAL_EXPANSION",
  "root": "$ROOT",
  "service": "$SERVICE"
}
JSON

cat > "$SERVICE/commands/status.sh" <<'SH'
#!/usr/bin/env bash
source "$THEOMATRIX_SERVICE/lib/env.sh"
source "$THEOMATRIX_SERVICE/lib/json.sh"
ensure_core_dirs
json_pretty "$THEOMATRIX_CONFIG"
SH

cat > "$SERVICE/commands/doctor.sh" <<'SH'
#!/usr/bin/env bash
source "$THEOMATRIX_SERVICE/lib/env.sh"
source "$THEOMATRIX_SERVICE/lib/doctor.sh"
ensure_core_dirs
doctor_dirs
echo
echo "RESULT PASS"
SH

cat > "$SERVICE/commands/verify.sh" <<'SH'
#!/usr/bin/env bash
source "$THEOMATRIX_SERVICE/lib/env.sh"
ensure_core_dirs
"$THEOMATRIX_SERVICE/commands/doctor.sh"
SH

cat > "$SERVICE/commands/graph.sh" <<'SH'
#!/usr/bin/env bash
source "$THEOMATRIX_SERVICE/lib/env.sh"
ensure_core_dirs

case "${1:-build}" in
  build)
    cat > "$THEOMATRIX_ROOT/graph/theomatrix.nodes.csv" <<CSV
id,type,label,status
PROJECT-THEOMATRIX,Project,THE∅MATRIX,ACTIVE
CSV

    cat > "$THEOMATRIX_ROOT/graph/theomatrix.edges.csv" <<CSV
source,target,relationship,status
CSV

    cat > "$THEOMATRIX_ROOT/graph/theomatrix.graph.json" <<JSON
{
  "project": "THE∅MATRIX",
  "version": "3.1",
  "status": "ACTIVE"
}
JSON

    echo "PASS graph-build"
    echo "RESULT PASS"
    ;;
  *)
    echo "Usage: wl-theomatrix graph build"
    exit 1
    ;;
esac
SH

cat > "$SERVICE/commands/handoff.sh" <<'SH'
#!/usr/bin/env bash
source "$THEOMATRIX_SERVICE/lib/env.sh"
ensure_core_dirs
cat <<MD
# THE∅MATRIX v3.1 Handoff

Status: OPERATIONAL_EXPANSION

Runtime:
$THEOMATRIX_SERVICE

Root:
$THEOMATRIX_ROOT

Next:
Modularize canon, memory, intelligence, simulation, observatory, and certification commands.
MD
SH

for cmd in canon memory intelligence simulation observatory certify; do
cat > "$SERVICE/commands/$cmd.sh" <<SH
#!/usr/bin/env bash
source "\$THEOMATRIX_SERVICE/lib/env.sh"
ensure_core_dirs
echo "PASS $cmd-module-present"
echo "TODO modular $cmd implementation"
SH
done

cat > "$SERVICE/bin/wl-theomatrix" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
THEOMATRIX_SERVICE="${THEOMATRIX_SERVICE:-$WL_HOME/services/wl-theomatrix}"
export THEOMATRIX_SERVICE

cmd="${1:-status}"
shift || true

case "$cmd" in
  status|doctor|verify|graph|handoff|canon|memory|intelligence|simulation|observatory|certify)
    exec "$THEOMATRIX_SERVICE/commands/$cmd.sh" "$@"
    ;;
  *)
    echo "Usage: wl-theomatrix status|doctor|verify|graph|handoff|canon|memory|intelligence|simulation|observatory|certify"
    exit 1
    ;;
esac
SH

chmod +x "$SERVICE/bin/wl-theomatrix" "$SERVICE"/commands/*.sh "$SERVICE"/lib/*.sh

cat > "$BIN/wl-theomatrix" <<SH
#!/usr/bin/env bash
exec "$SERVICE/bin/wl-theomatrix" "\$@"
SH

chmod +x "$BIN/wl-theomatrix"

cat > "$SERVICE/README.md" <<MD
# THE∅MATRIX v3.1 Modular Runtime

This service provides a modular command runtime for THE∅MATRIX.

Root:

\`\`\`text
$ROOT
\`\`\`

Command:

\`\`\`bash
wl-theomatrix status
wl-theomatrix doctor
wl-theomatrix graph build
\`\`\`
MD

echo
echo "== verify =="
"$BIN/wl-theomatrix" status
"$BIN/wl-theomatrix" doctor
"$BIN/wl-theomatrix" graph build
"$BIN/wl-theomatrix" handoff

echo
echo "RESULT PASS"
echo "Backup: $BACKUP"
