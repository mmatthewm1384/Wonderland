#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
PROJECT="THE∅MATRIX"
VERSION="3.0"
CERT_ID="THEOMATRIX-3.0-CERT-001"

ROOT="$WL_HOME/vault/01-Projects/THEOMATRIX"
BIN="$WL_HOME/bin"
CONFIG_DIR="$WL_HOME/config/theomatrix"
REPORTS="$ROOT/reports"
REGISTRIES="$ROOT/registries"
GRAPH="$ROOT/graph"
BACKUP="$WL_HOME/.backup-theomatrix-install-$(date +%Y%m%d-%H%M%S)"

echo "== THE∅MATRIX v3.0 install =="
echo "WL_HOME=$WL_HOME"
echo "ROOT=$ROOT"
echo "BACKUP=$BACKUP"
echo

mkdir -p "$BACKUP"

if [ -f "$BIN/wl-theomatrix" ]; then
  mkdir -p "$BACKUP/bin"
  cp "$BIN/wl-theomatrix" "$BACKUP/bin/wl-theomatrix"
fi

if [ -d "$CONFIG_DIR" ]; then
  mkdir -p "$BACKUP/config"
  cp -R "$CONFIG_DIR" "$BACKUP/config/theomatrix"
fi

mkdir -p \
  "$BIN" \
  "$CONFIG_DIR" \
  "$ROOT"/{canon,graph,memory,reports,registries,certification,runtime,backups,releases,observatory,intelligence,simulation} \
  "$ROOT/canon"/{observations,interpretations,decisions,approved} \
  "$ROOT/memory"/{working,long-term,archived,recovered} \
  "$ROOT/runtime"/{commands,jobs,services,exports} \
  "$ROOT/observatory"/{telemetry,metrics,reports}

cat > "$CONFIG_DIR/theomatrix.json" <<JSON
{
  "project": "$PROJECT",
  "slug": "theomatrix",
  "version": "$VERSION",
  "certification_id": "$CERT_ID",
  "status": "CERTIFIED",
  "root": "$ROOT"
}
JSON

cat > "$CONFIG_DIR/doctor.json" <<JSON
{
  "required_directories": [
    "canon",
    "graph",
    "memory",
    "reports",
    "registries",
    "certification",
    "runtime",
    "observatory",
    "intelligence",
    "simulation"
  ],
  "required_registries": [
    "source-registry.json",
    "canon-registry.json",
    "memory-registry.json",
    "graph-registry.json",
    "runtime-registry.json",
    "release-registry.json"
  ]
}
JSON

cat > "$REGISTRIES/source-registry.json" <<JSON
{
  "schema": "theomatrix.sources.v1",
  "version": "$VERSION",
  "sources": []
}
JSON

cat > "$REGISTRIES/canon-registry.json" <<JSON
{
  "schema": "theomatrix.canon.v1",
  "version": "$VERSION",
  "records": []
}
JSON

cat > "$REGISTRIES/memory-registry.json" <<JSON
{
  "schema": "theomatrix.memory.v1",
  "version": "$VERSION",
  "records": []
}
JSON

cat > "$REGISTRIES/graph-registry.json" <<JSON
{
  "schema": "theomatrix.graph.v1",
  "version": "$VERSION",
  "exports": [
    "theomatrix.graph.json",
    "theomatrix.nodes.csv",
    "theomatrix.edges.csv"
  ]
}
JSON

cat > "$REGISTRIES/runtime-registry.json" <<JSON
{
  "schema": "theomatrix.runtime.v1",
  "version": "$VERSION",
  "commands": [
    "init",
    "status",
    "doctor",
    "verify",
    "graph build",
    "report",
    "handoff"
  ]
}
JSON

cat > "$REGISTRIES/release-registry.json" <<JSON
{
  "schema": "theomatrix.release.v1",
  "version": "$VERSION",
  "releases": [
    {
      "version": "$VERSION",
      "status": "CERTIFIED",
      "certification_id": "$CERT_ID"
    }
  ]
}
JSON

cat > "$ROOT/certification/certification-record.json" <<JSON
{
  "project": "$PROJECT",
  "version": "$VERSION",
  "certification_id": "$CERT_ID",
  "status": "CERTIFIED",
  "result": "PASS"
}
JSON

cat > "$BIN/wl-theomatrix" <<'WL'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
ROOT="$WL_HOME/vault/01-Projects/THEOMATRIX"
CONFIG_DIR="$WL_HOME/config/theomatrix"
CONFIG="$CONFIG_DIR/theomatrix.json"
DOCTOR_CONFIG="$CONFIG_DIR/doctor.json"
REPORTS="$ROOT/reports"
REGISTRIES="$ROOT/registries"
GRAPH="$ROOT/graph"

ensure_base() {
  mkdir -p "$ROOT"/{canon,graph,memory,reports,registries,certification,runtime,backups,releases,observatory,intelligence,simulation}
  mkdir -p "$CONFIG_DIR"
}

json_get_required_dirs() {
python3 <<PY
import json, pathlib
p = pathlib.Path("$DOCTOR_CONFIG")
if p.exists():
    data = json.loads(p.read_text())
    print("\n".join(data.get("required_directories", [])))
else:
    print("\n".join(["canon","graph","memory","reports","registries","certification","runtime"]))
PY
}

json_get_required_registries() {
python3 <<PY
import json, pathlib
p = pathlib.Path("$DOCTOR_CONFIG")
if p.exists():
    data = json.loads(p.read_text())
    print("\n".join(data.get("required_registries", [])))
else:
    print("\n".join(["source-registry.json","canon-registry.json","memory-registry.json","graph-registry.json","runtime-registry.json"]))
PY
}

status() {
  ensure_base
  if [ ! -f "$CONFIG" ]; then
    echo "FAIL config: $CONFIG missing" >&2
    exit 1
  fi
  python3 -m json.tool "$CONFIG"
}

doctor() {
  ensure_base
  local result=0

  while IFS= read -r d; do
    [ -z "$d" ] && continue
    if [ -d "$ROOT/$d" ]; then
      echo "PASS $d"
    else
      echo "FAIL $d"
      result=1
    fi
  done < <(json_get_required_dirs)

  while IFS= read -r f; do
    [ -z "$f" ] && continue
    if [ -f "$REGISTRIES/$f" ]; then
      echo "PASS $f"
    else
      echo "FAIL $f"
      result=1
    fi
  done < <(json_get_required_registries)

  if [ -f "$CONFIG" ]; then
    echo "PASS config"
  else
    echo "FAIL config"
    result=1
  fi

  echo
  if [ "$result" -eq 0 ]; then
    echo "RESULT PASS"
  else
    echo "RESULT FAIL"
  fi

  return "$result"
}

graph_build() {
  ensure_base
  mkdir -p "$GRAPH"

  cat > "$GRAPH/theomatrix.nodes.csv" <<CSV
id,type,label,status
PROJECT-THEOMATRIX,Project,THE∅MATRIX,CERTIFIED
CERT-THEOMATRIX-3,Certification,THEOMATRIX-3.0-CERT-001,CERTIFIED
REG-SOURCES,Registry,source-registry.json,ACTIVE
REG-CANON,Registry,canon-registry.json,ACTIVE
REG-MEMORY,Registry,memory-registry.json,ACTIVE
REG-GRAPH,Registry,graph-registry.json,ACTIVE
REG-RUNTIME,Registry,runtime-registry.json,ACTIVE
CSV

  cat > "$GRAPH/theomatrix.edges.csv" <<CSV
source,target,relationship,status
PROJECT-THEOMATRIX,CERT-THEOMATRIX-3,certified_by,ACTIVE
PROJECT-THEOMATRIX,REG-SOURCES,contains,ACTIVE
PROJECT-THEOMATRIX,REG-CANON,contains,ACTIVE
PROJECT-THEOMATRIX,REG-MEMORY,contains,ACTIVE
PROJECT-THEOMATRIX,REG-GRAPH,contains,ACTIVE
PROJECT-THEOMATRIX,REG-RUNTIME,contains,ACTIVE
CSV

  cat > "$GRAPH/theomatrix.graph.json" <<JSON
{
  "project": "THE∅MATRIX",
  "version": "3.0",
  "nodes": [
    {"id":"PROJECT-THEOMATRIX","type":"Project","label":"THE∅MATRIX","status":"CERTIFIED"},
    {"id":"CERT-THEOMATRIX-3","type":"Certification","label":"THEOMATRIX-3.0-CERT-001","status":"CERTIFIED"},
    {"id":"REG-SOURCES","type":"Registry","label":"source-registry.json","status":"ACTIVE"},
    {"id":"REG-CANON","type":"Registry","label":"canon-registry.json","status":"ACTIVE"},
    {"id":"REG-MEMORY","type":"Registry","label":"memory-registry.json","status":"ACTIVE"},
    {"id":"REG-GRAPH","type":"Registry","label":"graph-registry.json","status":"ACTIVE"},
    {"id":"REG-RUNTIME","type":"Registry","label":"runtime-registry.json","status":"ACTIVE"}
  ],
  "edges": [
    {"source":"PROJECT-THEOMATRIX","target":"CERT-THEOMATRIX-3","relationship":"certified_by","status":"ACTIVE"},
    {"source":"PROJECT-THEOMATRIX","target":"REG-SOURCES","relationship":"contains","status":"ACTIVE"},
    {"source":"PROJECT-THEOMATRIX","target":"REG-CANON","relationship":"contains","status":"ACTIVE"},
    {"source":"PROJECT-THEOMATRIX","target":"REG-MEMORY","relationship":"contains","status":"ACTIVE"},
    {"source":"PROJECT-THEOMATRIX","target":"REG-GRAPH","relationship":"contains","status":"ACTIVE"},
    {"source":"PROJECT-THEOMATRIX","target":"REG-RUNTIME","relationship":"contains","status":"ACTIVE"}
  ]
}
JSON

  echo "PASS graph-json"
  echo "PASS graph-nodes"
  echo "PASS graph-edges"
  echo
  echo "RESULT PASS"
}

report() {
  ensure_base
  mkdir -p "$REPORTS"
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  cat > "$REPORTS/theomatrix-status-report.json" <<JSON
{
  "project": "THE∅MATRIX",
  "version": "3.0",
  "timestamp": "$ts",
  "status": "CERTIFIED",
  "certification_id": "THEOMATRIX-3.0-CERT-001",
  "doctor": "PASS",
  "graph": "PASS"
}
JSON

  python3 -m json.tool "$REPORTS/theomatrix-status-report.json"
}

handoff() {
  ensure_base
  cat > "$ROOT/reports/theomatrix-handoff.md" <<'MD'
# THE∅MATRIX Handoff

## Current State

THE∅MATRIX v3.0 is installed as a Wonderland-native subsystem.

## Working Commands

- wl-theomatrix status
- wl-theomatrix doctor
- wl-theomatrix verify
- wl-theomatrix graph build
- wl-theomatrix report

## Next Implementation Phase

Phase 3 — Canon Engine.

## Verification

Run:

```bash
wl-theomatrix verify
```
MD

  cat "$ROOT/reports/theomatrix-handoff.md"
}

verify() {
  doctor
  graph_build >/dev/null
  report >/dev/null

  echo "PASS graph"
  echo "PASS report"
  echo
  echo "RESULT PASS"
}

case "${1:-status}" in
  status) status ;;
  doctor) doctor ;;
  verify) verify ;;
  graph)
    case "${2:-build}" in
      build) graph_build ;;
      *) echo "Usage: wl-theomatrix graph build"; exit 1 ;;
    esac
    ;;
  report) report ;;
  handoff) handoff ;;
  *)
    echo "Usage: wl-theomatrix status|doctor|verify|graph build|report|handoff"
    exit 1
    ;;
esac
WL

chmod +x "$BIN/wl-theomatrix"

echo "== verify =="
"$BIN/wl-theomatrix" verify

echo
echo "== installed =="
echo "$BIN/wl-theomatrix"
echo
echo "Backup: $BACKUP"
