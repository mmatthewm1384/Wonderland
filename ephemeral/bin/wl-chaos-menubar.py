#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path

import rumps

WL_HOME = Path(os.environ.get("WL_HOME", str(Path.home() / "Wonderland")))
EPH = WL_HOME / "ephemeral"
PANIC = EPH / "bin" / "wl-chaos-panic"
LOG = WL_HOME / "vault" / "chaos" / "menubar.actions.log"

LOG.parent.mkdir(parents=True, exist_ok=True)

def log(msg):
    with LOG.open("a") as f:
        f.write(msg + "\n")

class ChaosMenu(rumps.App):
    def __init__(self):
        super().__init__("CHAOS")
        self.menu = [
            rumps.MenuItem("Panic", callback=self.panic),
            None,
            rumps.MenuItem("Quit", callback=rumps.quit_application),
        ]

    def panic(self, _):
        log("panic clicked")
        subprocess.Popen([
            str(PANIC),
            "--yes",
            "--reason=menubar-panic"
        ])

if __name__ == "__main__":
    ChaosMenu().run()
