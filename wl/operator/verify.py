from __future__ import annotations

import json
from pathlib import Path


REQUIRED = [
    "wl/operator/__main__.py",
    "wl/operator/kernel.py",
    "wl/operator/core.py",
    "wl/operator/commands.py",
    "wl/operator/registry.py",
    "wl/operator/plugins/logs.py",
    "wl/operator/plugins/git.py",
    "wl/operator/plugins/security.py",
    "wl/operator/plugins/chaos.py",
    "wl/operator/plugins/builder.py",
    "wl/operator/plugins/runtime.py",
    "wl/operator/dashboard.py",
    "wl/operator/theme.py",
    "wl/operator/state.py",
    "wl/operator/status.py",
    "wl/operator/events.py",
    "wl/operator/notifications.py",
    "wl/operator/workspace.py",
    "wl/operator/workspaces/incident.json",
    "wl/operator/workspaces/builder.json",
    "wl/operator/workspaces/development.json",
    "wl/operator/workspaces/full.json",
    "wl/operator/backend/tmux.py",
    "wl/operator/subsystem.json",
    "docs/operator/milestones/v1.0-alpha.md",
    "wl/operator/milestone.json",
    "docs/operator/README.md",
]


def main() -> int:
    ok = True

    for item in REQUIRED:
        path = Path(item)
        if path.exists():
            print(f"PASS file {item}")
        else:
            print(f"FAIL file {item}")
            ok = False

    manifest = Path("wl/operator/subsystem.json")
    if manifest.exists():
        try:
            data = json.loads(manifest.read_text())
            if data.get("name") == "operator":
                print("PASS manifest name operator")
            else:
                print("FAIL manifest name")
                ok = False
        except Exception as exc:
            print(f"FAIL manifest invalid: {exc}")
            ok = False

    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
