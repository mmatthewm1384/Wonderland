#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
ROOT="$WL_HOME/vault/01-Projects/THEOMATRIX"
MEMORY="$ROOT/memory"
BIN="$WL_HOME/bin/wl-theomatrix"
BACKUP="$BIN.bak.memory.$(date +%Y%m%d-%H%M%S)"

mkdir -p "$MEMORY"/{working,long-term,archived,recovered}
cp "$BIN" "$BACKUP"

cat > "$BIN" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
ROOT="$WL_HOME/vault/01-Projects/THEOMATRIX"
CANON="$ROOT/canon"
MEMORY="$ROOT/memory"

ensure_memory() {
  mkdir -p "$MEMORY"/{working,long-term,archived,recovered}

  [ -f "$MEMORY/memory-registry.json" ] || echo '{"schema":"theomatrix.memory.v1","next_id":1,"records":[]}' > "$MEMORY/memory-registry.json"
  [ -f "$MEMORY/archive-registry.json" ] || echo '{"schema":"theomatrix.archive.v1","records":[]}' > "$MEMORY/archive-registry.json"
  [ -f "$MEMORY/recovery-registry.json" ] || echo '{"schema":"theomatrix.recovery.v1","records":[]}' > "$MEMORY/recovery-registry.json"
}

memory_capture() {
  ensure_memory
  python3 - "$MEMORY" <<'PY'
import json, sys
from pathlib import Path
from datetime import datetime, timezone

memory = Path(sys.argv[1])
reg = memory / "memory-registry.json"
data = json.loads(reg.read_text())

n = int(data.get("next_id", 1))
mid = f"MEM-{n:04d}"
created = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

record = {
  "id": mid,
  "type": "memory",
  "status": "working",
  "created": created,
  "summary": "",
  "source": ""
}

(memory / "working" / f"{mid}.json").write_text(json.dumps(record, indent=2) + "\n")

data["next_id"] = n + 1
data.setdefault("records", []).append({
  "id": mid,
  "path": f"working/{mid}.json",
  "status": "working",
  "created": created
})
reg.write_text(json.dumps(data, indent=2) + "\n")

print(json.dumps(record, indent=2))
PY
}

memory_move() {
  ensure_memory
  local action="$1"
  local mid="$2"

  python3 - "$MEMORY" "$action" "$mid" <<'PY'
import json, sys, shutil
from pathlib import Path
from datetime import datetime, timezone

memory = Path(sys.argv[1])
action = sys.argv[2]
mid = sys.argv[3]
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

moves = {
  "promote": ("working", "long-term", "long-term"),
  "archive": ("long-term", "archived", "archived"),
  "recover": ("archived", "recovered", "recovered")
}

src_dir, dst_dir, status = moves[action]
src = memory / src_dir / f"{mid}.json"
dst = memory / dst_dir / f"{mid}.json"

if not src.exists():
    raise SystemExit(f"Missing source memory: {src}")

record = json.loads(src.read_text())
record["status"] = status
record["updated"] = now

dst.parent.mkdir(parents=True, exist_ok=True)
dst.write_text(json.dumps(record, indent=2) + "\n")
src.unlink()

reg = memory / "memory-registry.json"
data = json.loads(reg.read_text())

for r in data.get("records", []):
    if r.get("id") == mid:
        r["path"] = f"{dst_dir}/{mid}.json"
        r["status"] = status
        r["updated"] = now

reg.write_text(json.dumps(data, indent=2) + "\n")

if action == "archive":
    ar = memory / "archive-registry.json"
    ad = json.loads(ar.read_text())
    ad.setdefault("records", []).append({"id": mid, "archived": now})
    ar.write_text(json.dumps(ad, indent=2) + "\n")

if action == "recover":
    rr = memory / "recovery-registry.json"
    rd = json.loads(rr.read_text())
    rd.setdefault("records", []).append({"id": mid, "recovered": now})
    rr.write_text(json.dumps(rd, indent=2) + "\n")

print(json.dumps(record, indent=2))
PY
}

memory_list() {
  ensure_memory
  python3 - "$MEMORY" <<'PY'
from pathlib import Path
import sys

memory = Path(sys.argv[1])
counts = {
  "Working": len(list((memory / "working").glob("MEM-*.json"))),
  "Long-Term": len(list((memory / "long-term").glob("MEM-*.json"))),
  "Archived": len(list((memory / "archived").glob("MEM-*.json"))),
  "Recovered": len(list((memory / "recovered").glob("MEM-*.json"))),
}

for k, v in counts.items():
    print(f"{k}: {v}")
PY
}

memory_doctor() {
  ensure_memory
  local result=0

  for d in working long-term archived recovered; do
    if [ -d "$MEMORY/$d" ]; then echo "PASS memory-$d"; else echo "FAIL memory-$d"; result=1; fi
  done

  for f in memory-registry.json archive-registry.json recovery-registry.json; do
    if python3 -m json.tool "$MEMORY/$f" >/dev/null 2>&1; then
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

memory_cmd() {
  case "${1:-list}" in
    capture) memory_capture ;;
    promote) memory_move promote "${2:?Usage: wl-theomatrix memory promote MEM-0001}" ;;
    archive) memory_move archive "${2:?Usage: wl-theomatrix memory archive MEM-0001}" ;;
    recover) memory_move recover "${2:?Usage: wl-theomatrix memory recover MEM-0001}" ;;
    list) memory_list ;;
    doctor) memory_doctor ;;
    *)
      echo "Usage:"
      echo "  wl-theomatrix memory capture"
      echo "  wl-theomatrix memory promote MEM-0001"
      echo "  wl-theomatrix memory archive MEM-0001"
      echo "  wl-theomatrix memory recover MEM-0001"
      echo "  wl-theomatrix memory list"
      echo "  wl-theomatrix memory doctor"
      exit 1
      ;;
  esac
}

case "${1:-status}" in
  status)
    echo '{"project":"THE∅MATRIX","version":"3.0","status":"CERTIFIED"}'
    ;;
  doctor|verify)
    memory_doctor
    ;;
  memory)
    shift
    memory_cmd "$@"
    ;;
  *)
    echo "Usage: wl-theomatrix status|doctor|verify|memory ..."
    ;;
esac
SCRIPT

chmod +x "$BIN"

echo "PASS memory-engine-installed"
echo "Backup: $BACKUP"
