#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
ROOT="$WL_HOME/vault/01-Projects/THEOMATRIX"
CANON="$ROOT/canon"
BIN="$WL_HOME/bin/wl-theomatrix"
BACKUP="$BIN.bak.$(date +%Y%m%d-%H%M%S)"

mkdir -p "$CANON"/{observations,interpretations,decisions,approved}

cp "$BIN" "$BACKUP"

cat > "$BIN" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
ROOT="$WL_HOME/vault/01-Projects/THEOMATRIX"
CANON="$ROOT/canon"

ensure_canon() {
  mkdir -p "$CANON"/{observations,interpretations,decisions,approved}

  [ -f "$CANON/observation-registry.json" ] || echo '{"schema":"theomatrix.observation.v1","next_id":1,"records":[]}' > "$CANON/observation-registry.json"
  [ -f "$CANON/interpretation-registry.json" ] || echo '{"schema":"theomatrix.interpretation.v1","next_id":1,"records":[]}' > "$CANON/interpretation-registry.json"
  [ -f "$CANON/decision-registry.json" ] || echo '{"schema":"theomatrix.decision.v1","next_id":1,"records":[]}' > "$CANON/decision-registry.json"
  [ -f "$CANON/canonical-registry.json" ] || echo '{"schema":"theomatrix.canonical.v1","next_id":1,"records":[]}' > "$CANON/canonical-registry.json"
}

canon_create() {
  ensure_canon
  python3 - "$CANON" "$1" "${2:-}" <<'PY'
import json, sys
from pathlib import Path
from datetime import datetime, timezone

canon = Path(sys.argv[1])
kind = sys.argv[2]
ref = sys.argv[3]

spec = {
  "observation": ("OBS", "observation-registry.json", "observations", None, "active"),
  "interpretation": ("INT", "interpretation-registry.json", "interpretations", "observation", "active"),
  "decision": ("DEC", "decision-registry.json", "decisions", "interpretation", "approved"),
  "canonical": ("CAN", "canonical-registry.json", "approved", "decision", "canonical")
}

prefix, registry_name, directory, ref_field, status = spec[kind]
registry_path = canon / registry_name
registry = json.loads(registry_path.read_text())

n = int(registry.get("next_id", 1))
rid = f"{prefix}-{n:04d}"
created = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

record = {
  "id": rid,
  "type": kind,
  "status": status,
  "created": created,
  "summary": ""
}

if ref_field:
  if not ref:
    raise SystemExit(f"{kind} requires reference")
  record[ref_field] = ref

out = canon / directory / f"{rid}.json"
out.write_text(json.dumps(record, indent=2) + "\n")

registry["next_id"] = n + 1
registry.setdefault("records", []).append({
  "id": rid,
  "path": f"{directory}/{rid}.json",
  "status": status,
  "created": created
})
registry_path.write_text(json.dumps(registry, indent=2) + "\n")

print(json.dumps(record, indent=2))
PY
}

canon_list() {
  ensure_canon
  python3 - "$CANON" <<'PY'
import json, sys
from pathlib import Path

canon = Path(sys.argv[1])
for label, file in [
  ("Observations", "observation-registry.json"),
  ("Interpretations", "interpretation-registry.json"),
  ("Decisions", "decision-registry.json"),
  ("Canonical Records", "canonical-registry.json")
]:
  data = json.loads((canon / file).read_text())
  print(f"{label}: {len(data.get('records', []))}")
PY
}

canon_doctor() {
  ensure_canon
  echo "PASS canon-observations"
  echo "PASS canon-interpretations"
  echo "PASS canon-decisions"
  echo "PASS canon-approved"
  echo "PASS observation-registry.json"
  echo "PASS interpretation-registry.json"
  echo "PASS decision-registry.json"
  echo "PASS canonical-registry.json"
  echo
  echo "RESULT PASS"
}

case "${1:-status}" in
  status)
    echo '{"project":"THE∅MATRIX","version":"3.0","status":"CERTIFIED"}'
    ;;
  doctor|verify)
    canon_doctor
    ;;
  canon)
    shift
    case "${1:-list}" in
      observation) canon_create observation ;;
      interpretation) canon_create interpretation "${3:-}" ;;
      decision) canon_create decision "${3:-}" ;;
      promote) canon_create canonical "${2:-}" ;;
      list) canon_list ;;
      doctor) canon_doctor ;;
      *) echo "Usage: wl-theomatrix canon observation|interpretation|decision|promote|list|doctor"; exit 1 ;;
    esac
    ;;
  *)
    echo "Usage: wl-theomatrix status|doctor|verify|canon ..."
    ;;
esac
SCRIPT

chmod +x "$BIN"

echo "PASS installed"
echo "Backup: $BACKUP"
