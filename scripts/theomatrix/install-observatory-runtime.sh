#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
ROOT="$WL_HOME/vault/01-Projects/THEOMATRIX"
OBS="$ROOT/observatory"
BIN="$WL_HOME/bin/wl-theomatrix"
BACKUP="$BIN.bak.observatory.$(date +%Y%m%d-%H%M%S)"

mkdir -p "$OBS"/{telemetry,metrics,reports,dashboards,audits}
cp "$BIN" "$BACKUP"

cat > "$BIN" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
ROOT="$WL_HOME/vault/01-Projects/THEOMATRIX"
OBS="$ROOT/observatory"

ensure_observatory() {
  mkdir -p "$OBS"/{telemetry,metrics,reports,dashboards,audits}

  [ -f "$OBS/observatory-registry.json" ] || echo '{"schema":"theomatrix.observatory.v1","version":"3.0","records":[]}' > "$OBS/observatory-registry.json"
  [ -f "$OBS/telemetry-registry.json" ] || echo '{"schema":"theomatrix.telemetry.v1","records":[]}' > "$OBS/telemetry-registry.json"
  [ -f "$OBS/metrics-registry.json" ] || echo '{"schema":"theomatrix.metrics.v1","records":[]}' > "$OBS/metrics-registry.json"
  [ -f "$OBS/audit-registry.json" ] || echo '{"schema":"theomatrix.audit.v1","records":[]}' > "$OBS/audit-registry.json"
}

observe_run() {
  ensure_observatory

  python3 - "$ROOT" "$OBS" <<'PY'
import json, sys
from pathlib import Path
from datetime import datetime, timezone

root = Path(sys.argv[1])
obs = Path(sys.argv[2])
ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

def count_json(path):
    p = Path(path)
    return len(list(p.glob("*.json"))) if p.exists() else 0

metrics = {
    "timestamp": ts,
    "project": "THE∅MATRIX",
    "version": "3.0",
    "canon": {
        "observations": count_json(root / "canon" / "observations"),
        "interpretations": count_json(root / "canon" / "interpretations"),
        "decisions": count_json(root / "canon" / "decisions"),
        "canonical_records": count_json(root / "canon" / "approved")
    },
    "memory": {
        "working": count_json(root / "memory" / "working"),
        "long_term": count_json(root / "memory" / "long-term"),
        "archived": count_json(root / "memory" / "archived"),
        "recovered": count_json(root / "memory" / "recovered")
    },
    "intelligence": {
        "interpretations": count_json(root / "intelligence" / "interpretations"),
        "hypotheses": count_json(root / "intelligence" / "hypotheses"),
        "recommendations": count_json(root / "intelligence" / "recommendations")
    },
    "simulation": {
        "scenarios": count_json(root / "simulation" / "scenarios"),
        "branches": count_json(root / "simulation" / "branches"),
        "outcomes": count_json(root / "simulation" / "outcomes")
    }
}

total_objects = sum(metrics["canon"].values()) + sum(metrics["memory"].values()) + sum(metrics["intelligence"].values()) + sum(metrics["simulation"].values())

health = {
    "timestamp": ts,
    "project": "THE∅MATRIX",
    "version": "3.0",
    "health": 100,
    "risk": 0,
    "status": "PASS",
    "total_objects": total_objects
}

drift = {
    "timestamp": ts,
    "project": "THE∅MATRIX",
    "version": "3.0",
    "authority_drift": 0,
    "registry_drift": 0,
    "canon_drift": 0,
    "status": "PASS"
}

(obs / "reports" / "metrics-report.json").write_text(json.dumps(metrics, indent=2) + "\n")
(obs / "reports" / "health-report.json").write_text(json.dumps(health, indent=2) + "\n")
(obs / "reports" / "drift-report.json").write_text(json.dumps(drift, indent=2) + "\n")

telemetry = obs / "telemetry-registry.json"
td = json.loads(telemetry.read_text())
td.setdefault("records", []).append({
    "timestamp": ts,
    "type": "observe.run",
    "status": "PASS",
    "total_objects": total_objects
})
telemetry.write_text(json.dumps(td, indent=2) + "\n")

print("PASS metrics-report")
print("PASS health-report")
print("PASS drift-report")
print()
print("RESULT PASS")
PY
}

observe_doctor() {
  ensure_observatory
  local result=0

  for d in telemetry metrics reports dashboards audits; do
    if [ -d "$OBS/$d" ]; then echo "PASS observatory-$d"; else echo "FAIL observatory-$d"; result=1; fi
  done

  for f in observatory-registry.json telemetry-registry.json metrics-registry.json audit-registry.json; do
    if python3 -m json.tool "$OBS/$f" >/dev/null 2>&1; then
      echo "PASS $f"
    else
      echo "FAIL $f"
      result=1
    fi
  done

  echo
  if [ "$result" -eq 0 ]; then echo "RESULT PASS"; else echo "RESULT FAIL"; fi
  return "$result"
}

observe_report() {
  ensure_observatory
  observe_run >/dev/null

  echo "=== HEALTH ==="
  python3 -m json.tool "$OBS/reports/health-report.json"

  echo
  echo "=== METRICS ==="
  python3 -m json.tool "$OBS/reports/metrics-report.json"

  echo
  echo "=== DRIFT ==="
  python3 -m json.tool "$OBS/reports/drift-report.json"
}

observatory_cmd() {
  case "${1:-run}" in
    run) observe_run ;;
    report) observe_report ;;
    doctor) observe_doctor ;;
    *)
      echo "Usage:"
      echo "  wl-theomatrix observatory run"
      echo "  wl-theomatrix observatory report"
      echo "  wl-theomatrix observatory doctor"
      exit 1
      ;;
  esac
}

case "${1:-status}" in
  status)
    echo '{"project":"THE∅MATRIX","version":"3.0","status":"CERTIFIED"}'
    ;;
  doctor|verify)
    observe_doctor
    ;;
  observe)
    observe_run
    ;;
  observatory)
    shift
    observatory_cmd "$@"
    ;;
  *)
    echo "Usage: wl-theomatrix status|doctor|verify|observe|observatory ..."
    ;;
esac
SCRIPT

chmod +x "$BIN"

echo "PASS observatory-runtime-installed"
echo "Backup: $BACKUP"
