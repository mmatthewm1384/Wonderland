from __future__ import annotations

import shlex
from pathlib import Path

from wl.operator.backend.tmux import TmuxBackend
from wl.operator.commands import window_commands
from wl.operator.events import emit
from wl.operator.notifications import notify
from wl.operator.state import write_json
from wl.operator.status import write_status
from wl.operator.workspace import get_workspace


SESSION = "wonderland"


class OperatorKernel:
    def __init__(self, root: Path, session: str = SESSION) -> None:
        self.root = root
        self.session = session
        self.tmux = TmuxBackend(root=root, session=session)

    def start(self, workspace: str = "full") -> None:
        ws = get_workspace(workspace)

        self.tmux.require()
        self.tmux.write_config()

        if self.tmux.exists():
            self.tmux.source()
            print(f"PASS operator already running: {self.session}")
            return

        self.tmux.new_session(ws.windows[0])
        self.tmux.source()

        for window in ws.windows[1:]:
            self.tmux.new_window(window)

        context = type(
            "Context",
            (),
            {
                "root": self.root,
                "state_dir": self.root / "state" / "operator",
                "session": self.session,
            },
        )()
        commands = window_commands(context)

        for window in ws.windows:
            self.tmux.send(window, f"cd {shlex.quote(str(self.root))}; {commands.get(window, 'clear')}")

        self.tmux.select(ws.windows[0])

        write_json(self.root / "state" / "operator" / "operator.json", {
            "version": "1.0",
            "session": self.session,
            "root": str(self.root),
            "intent": "Wonderland local-first operator environment",
            "backend": "tmux",
            "workspace": ws.name,
            "windows": ws.windows,
            "theme": str(self.tmux.conf),
        })

        write_status(self.root)
        emit(self.root, "operator", "started", {"workspace": ws.name})
        notify(
            self.root,
            "operator",
            "info",
            "Operator started",
            f"Workspace active: {ws.name}",
            {"workspace": ws.name},
        )
        print(f"PASS started operator: {self.session} workspace={ws.name}")

    def stop(self) -> None:
        self.tmux.require()

        if not self.tmux.exists():
            print(f"PASS operator not running: {self.session}")
            return

        self.tmux.stop()
        write_status(self.root)
        emit(self.root, "operator", "stopped", {})
        notify(
            self.root,
            "operator",
            "info",
            "Operator stopped",
            "tmux session stopped",
            {},
        )
        print(f"PASS stopped operator: {self.session}")

    def restart(self, workspace: str = "full") -> None:
        self.stop()
        self.start(workspace)

    def attach(self, workspace: str = "full") -> None:
        self.tmux.require()

        if not self.tmux.exists():
            self.start(workspace)

        self.tmux.attach()

    def reload(self) -> None:
        self.tmux.require()
        self.tmux.write_config()

        if not self.tmux.exists():
            raise SystemExit(f"FAIL operator not running: {self.session}")

        self.tmux.source()
        self.tmux.send(
            "dashboard",
            f"cd {shlex.quote(str(self.root))}; python3 -m wl.operator.dashboard",
        )
        write_status(self.root)
        emit(self.root, "operator", "reloaded", {})
        notify(
            self.root,
            "operator",
            "info",
            "Operator reloaded",
            "tmux theme and dashboard refreshed",
            {},
        )
        print(f"PASS reloaded operator: {self.session}")

    def list_windows(self) -> None:
        self.tmux.require()

        if not self.tmux.exists():
            raise SystemExit(f"FAIL operator not running: {self.session}")

        print(f"PASS operator running: {self.session}")
        self.tmux.list_windows()
