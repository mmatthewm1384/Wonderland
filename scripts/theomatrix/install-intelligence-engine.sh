#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
ROOT="$WL_HOME/vault/01-Projects/THEOMATRIX"
INTEL="$ROOT/intelligence"
BIN="$WL_HOME/bin/wl-theomatrix"
BACKUP="$BIN.bak.intelligence.$(date +%Y%m%d-%H%M%S)"

mkdir -p "$INTEL"/{interpretations,hypotheses,recommendations,reports}
cp "$BIN" "$BACKUP"

cat > "$BIN" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
ROOT="$WL_HOME/vault/01-Projects/THEOMATRIX"
INTEL="$ROOT/intelligence"

ensure_intelligence() {
  mkdir -p "$INTEL"/{interpretations,hypotheses,recommendations,reports}

  [ -f "$INTEL/intelligence-registry.json" ] || echo '{"schema":"theomatrix.intelligence.v1","next_id":1,"records":[]}' > "$INTEL/intelligence-registry.json"
  [ -f "$INTEL/interpretation-registry.json" ] || echo '{"schema":"theomatrix.interpretation-output.v1","next_id":1,"records":[]}' > "$INTEL/interpretation-registry.json"
  [ -f "$INTEL/hypothesis-registry.json" ] || echo '{"schema":"theomatrix.hypothesis.v1","next_id":1,"records":[]}' > "$INTEL/hypothesis-registry.json"
  [ -f "$INTEL/recommendation-registry.json" ] || echo '{"schema":"theomatrix.recommendation.v1","next_id":1,"records":[]}' > "$INTEL/recommendation-registry.json"
}

intel_create() {
  ensure_intelligence
  local kind="$1"
  local ref="${2:-}"

  python3 - "$INTEL" "$kind" "$ref" <<'PY'
import json, sys
from pathlib import Path
from datetime import datetime, timezone

intel = Path(sys.argv[1])
kind = sys.argv[2]
ref = sys.argv[3]

spec = {
  "interpretation": ("INTEL-INT", "interpretation-registry.json", "interpretations", "source"),
  "hypothesis": ("HYP", "hypothesis-registry.json", "hypotheses", "interpretation"),
  "recommendation": ("REC", "recommendation-registry.json", "recommendations", "hypothesis")
}

prefix, registry_name, directory, ref_field = spec[kind]
registry_path = intel / registry_name
registry = json.loads(registry_path.read_text())

n = int(registry.get("next_id", 1))
rid = f"{prefix}-{n:04d}"
created = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

record = {
  "id": rid,
  "type": kind,
  "status": "active",
  "created": created,
  "confidence": "medium",
  "summary": ""
}

if ref:
  record[ref_field] = ref

out = intel / directory / f"{rid}.json"
out.write_text(json.dumps(record, indent=2) + "\n")

registry["next_id"] = n + 1
registry.setdefault("records", []).append({
  "id": rid,
  "path": f"{directory}/{rid}.json",
  "status": "active",
  "created": created
})
registry_path.write_text(json.dumps(registry, indent=2) + "\n")

main_reg = intel / "intelligence-registry.json"
main = json.loads(main_reg.read_text())
main.setdefault("records", []).append({
  "id": rid,
  "type": kind,
  "path": f"{directory}/{rid}.json",
  "created": created
})
main_reg.write_text(json.dumps(main, indent=2) + "\n")

print(json.dumps(record, indent=2))
PY
}

intel_list() {
  ensure_intelligence
  python3 - "$INTEL" <<'PY'
import json, sys
from pathlib import Path

intel = Path(sys.argv[1])
for label, file in [
  ("Interpretations", "interpretation-registry.json"),
  ("Hypotheses", "hypothesis-registry.json"),
  ("Recommendations", "recommendation-registry.json")
]:
  data = json.loads((intel / file).read_text())
  print(f"{label}: {len(data.get('records', []))}")
PY
}

intel_doctor() {
  ensure_intelligence
  local result=0

  for d in interpretations hypotheses recommendations reports; do
    if [ -d "$INTEL/$d" ]; then echo "PASS intelligence-$d"; else echo "FAIL intelligence-$d"; result=1; fi
  done

  for f in intelligence-registry.json interpretation-registry.json hypothesis-registry.json recommendation-registry.json; do
    if python3 -m json.tool "$INTEL/$f" >/dev/null 2>&1; then
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

intelligence_cmd() {
  case "${1:-list}" in
    interpret) intel_create interpretation "${2:-}" ;;
    hypothesize) intel_create hypothesis "${2:-}" ;;
    recommend) intel_create recommendation "${2:-}" ;;
    list) intel_list ;;
    doctor) intel_doctor ;;
    *)
      echo "Usage:"
      echo "  wl-theomatrix intelligence interpret [SOURCE_ID]"
      echo "  wl-theomatrix intelligence hypothesize [INTEL-INT-0001]"
      echo "  wl-theomatrix intelligence recommend [HYP-0001]"
      echo "  wl-theomatrix intelligence list"
      echo "  wl-theomatrix intelligence doctor"
      exit 1
      ;;
  esac
}

case "${1:-status}" in
  status)
    echo '{"project":"THE∅MATRIX","version":"3.0","status":"CERTIFIED"}'
    ;;
  doctor|verify)
    intel_doctor
    ;;
  intelligence)
    shift
    intelligence_cmd "$@"
    ;;
  *)
    echo "Usage: wl-theomatrix status|doctor|verify|intelligence ..."
    ;;
esac
SCRIPT

chmod +x "$BIN"

echo "PASS intelligence-engine-installed"
echo "Backup: $BACKUP"
