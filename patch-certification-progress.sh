#!/usr/bin/env bash
set -Eeuo pipefail

cd ~/Wonderland

cp builder/python/wlruntime/wlruntime/certification.py \
builder/python/wlruntime/wlruntime/certification.py.bak.$(date +%Y%m%d%H%M%S)

python3 - <<'PY'
from pathlib import Path

p = Path("builder/python/wlruntime/wlruntime/certification.py")
t = p.read_text()

replacements = {
'''            first_start = self.engine.start()
''':
'''            print("CERT: starting runtime", flush=True)
            first_start = self.engine.start()
            print("CERT: runtime started", flush=True)
''',

'''            health = self.engine.health()
''':
'''            print("CERT: health check", flush=True)
            health = self.engine.health()
            print("CERT: health complete", flush=True)
''',

'''            second_start = self.engine.start()
''':
'''            print("CERT: second start", flush=True)
            second_start = self.engine.start()
            print("CERT: second start complete", flush=True)
''',

'''            doctor = self.engine.doctor()
''':
'''            print("CERT: doctor", flush=True)
            doctor = self.engine.doctor()
            print("CERT: doctor complete", flush=True)
''',

'''            first_stop = self.engine.stop()
''':
'''            print("CERT: first stop", flush=True)
            first_stop = self.engine.stop()
            print("CERT: first stop complete", flush=True)
''',
}

for old,new in replacements.items():
    if old not in t:
        print("missing:", old.strip())
    else:
        t=t.replace(old,new,1)

p.write_text(t)
print("patched")
PY

python3 -m compileall builder/python/wlruntime/wlruntime
